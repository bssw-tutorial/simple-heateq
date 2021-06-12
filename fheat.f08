module ArgParser
  ! module holding a Params class to store simulation parameters
  implicit none
  private

  integer, public, parameter :: dp=kind(0.d0) ! double precision

  public :: IC, Const, Sine
  enum, bind(c)
    enumerator :: IC = 0 ! we use this to name the enumeration
    enumerator :: Const = 157839
    enumerator :: Sine = 230972
  end enum

  type, public :: Params
    real(dp) :: alpha = 1.0
    real(dp) :: u0 = 0.0, u1 = 0.0
    real(dp) :: dx = 1.0, dt = 0.001
    integer :: Nx = 10, Nt = 10
    integer(Kind(IC)) :: init = Const
  contains
    procedure :: show
  end type Params
contains
  subroutine show_ic(init)
    integer(Kind(IC)), intent(in) :: init
    if (init == Const) then
      print *, "ic = const"
    else if (init == Sine) then
      print *, "ic = sin"
    end if
  end subroutine show_ic

  subroutine show(p)
    class(Params), intent(in) :: p
    print *, "Nx = ", p%Nx
    print *, "Nt = ",  p%Nt
    print *, "bc = ",  p%u0, " ", p%u1
    print *, "alpha = ", p%alpha
    print *, "dx = ",  p%dx
    print *, "dt = ", p%dt
    call show_ic(p%init)
  end subroutine show
end module ArgParser

! Class storing the energy as a function of position
! at a single time.  The internal representation uses a grid
! with N intervals and spacing dx.
!
! The grid values are stored at the end-points of each
! interval, making the internal vector size N+1.
!
module EnergyField
  use ArgParser
  implicit none
  private

  type, public :: Energy
    integer :: N
    integer :: cur
    ! Note: because u can't be both allocatable and target,
    ! we declare u as a circular buffer:
    !   u(:,cur) is the "current" u
    !   u(:,mod(cur+1,size(cur,2))) is the "next" u 
    !   u(:,mod(cur+size(cur,2)-1,size(cur,2))) is the "last/previous" u 
    real(dp) :: dx
    real(dp), allocatable :: u(:,:)
  contains
    procedure :: step
    procedure :: set_bc
    procedure :: en
!   final :: destructor ! not used
  end type Energy

  interface Energy ! declare constructor
    module procedure constructor
  end interface Energy
contains
  function constructor(p) Result(E)
    type(Params), intent(in) :: p
    type(Energy) :: E

    E%N  = p%Nx
    E%dx = p%dx
    E%cur = 0
    allocate (E%u(1:p%Nx+1,0:1))
    E%u = 1.0_dp
  end function constructor
! Not needed, since u auto-destructs when E disappears.
! subroutine destructor(this)
!   type(Energy) :: E
!   if (allocated(E % u)) deallocate(E % u)
! end subroutine destructor

  subroutine step(E, alpha, dt)
    class(Energy), target, intent(inout) :: E
    real(dp), intent(in) :: alpha
    real(dp), intent(in) :: dt
    real(dp) :: k
    integer :: circ
    integer :: i
    real(dp), pointer :: u(:), u_last(:)

    ! time-constant for updating
    k = alpha*dt / (E%dx*E%dx)
    ! Start by swapping u and last
    u_last => E%u(:, E%cur)
    circ   = size(E%u, 2)
    E%cur  = mod(E%cur+1, circ)
    u      => E%u(:, E%cur)
    ! Now paint new solution into u

    ! update (N-1) interior points
    ! partial u/partial t = alpha partial^2 u/partial x^2
    ! \Delta u = (dt*alpha/dx^2) D^2 u
    do i=2,E%N
      u(i) = u_last(i) + k*(u_last(i-1)-2*u_last(i)+u_last(i+1))
    end do
    u(1) = u_last(1)
    u(E%N+1) = u_last(E%N+1)
  end subroutine step
  subroutine set_bc(E, u0, u1)
    class(Energy), intent(inout) :: E
    real(dp), intent(in) :: u0, u1

    E%u(1,    E%cur) = u0
    E%u(E%N+1,E%cur) = u1
  end subroutine set_bc
  real(dp) function en(E)
    class(Energy), target, intent(in) :: E
    integer :: i
    real(dp) :: ans
    real(dp), pointer :: u(:)

    u => E%u(:,E%cur)
    !do concurrent (i=1:10)
    ans = 0.5*(u(1) + u(E%N+1))
    do i=2,E%N
        ans = ans + u(i)
    end do
    en = ans * E%dx
  end function en
end module EnergyField

program heat
    use ArgParser
    use EnergyField
    implicit none

    type(Params) :: p
    p = parse_args()
    call p%show()

    call simulate(p)

  contains
    subroutine usage(prog)
      character(len=*), intent(in) :: prog
      print *, "Usage: ", prog, " [options]"
      print *, "  Options:\n";
      print *, "     -Nx <int>               Number of grid-points (10)"
      print *, "     -Nt <int>               Number of time-steps (10)"
      print *, "     -bc <real u0> <real u1> Dirichlet boundary conditions (0 0)"
      print *, "     -alpha <real>           Diffusion coefficient (1 cm^2/s)"
      print *, "     -dx <real>              Grid spacing (1 cm)"
      print *, "     -dt <real>              Time step    (0.001 s)"
      print *, "     -ic [const|sin]         Initial Condition (const)"
  end subroutine usage

  logical function get_ic(t, init)
    ! parse init condition from t
    ! returns .true. on error
    character(len=*), intent(in) :: t
    integer(Kind(IC)), intent(out) :: init

    get_ic = .false.
    if (t == "const") then
      init = Const
    else if (t == "sin") then
      init = Sine
    else
      get_ic = .true.
    end if
  end function get_ic

  function parse_args() result(ret)
    ! construct and return a Params class

    type(Params) :: ret
    integer :: nargs
    integer :: pos = 1
    integer :: stat
    character(len=32) :: prog, s, arg1, arg2
    logical :: found = .true.

    ! ret = Params()

    nargs = command_argument_count() ! 0 for no arguments
    call get_command_argument(0, prog)

    do while(pos <= nargs)
        call get_command_argument(pos, s)

        if (pos+1 <= nargs) then ! one-parameter options
          found = .true.
          call get_command_argument(pos+1, arg1)

          if (s == "-Nx") then
            read (arg1,*,iostat=stat)  ret%Nx
          else if(s == "-Nt") then
            read (arg1,*,iostat=stat)  ret%Nt
          else if(s == "-alpha") then
            read (arg1,*,iostat=stat)  ret%alpha
          else if(s == "-dx") then
            read (arg1,*,iostat=stat)  ret%dx
          else if(s == "-dt") then
            read (arg1,*,iostat=stat)  ret%dt
          else if(s == "-ic") then
            if (get_ic(arg1, ret%init)) then
              call usage(prog)
              stop 1
            end if
          else
            found = .false.
          end if
          if(found) then
            pos = pos+2
            cycle
          end if
        end if
        if(pos+2 <= nargs) then ! two-parameter options
          found = .true.
          call get_command_argument(pos+1, arg1)
          call get_command_argument(pos+2, arg2)

          if (s == "-bc") then
            read (arg1,*,iostat=stat)  ret%u0
            read (arg2,*,iostat=stat)  ret%u1
          else
            found = .false.
          end if
          if(found) then
            pos = pos + 3
            cycle
          end if
        end if

        call usage(prog)
        stop 1
    end do
  end function parse_args

  subroutine simulate(p)
    type(Params), intent(in) :: p
    type(Energy), target :: E
    integer :: n 

    E = Energy(p)

    print *, "Time Energy"
    do n = 1,p%Nt
        call E%set_bc(p%u0, p%u1)
        call E%step(p%alpha, p%dt)
        if (mod(n, 10) == 1) then
            print *, n*p%dt, " ", E%en()
        end if
    end do
  end subroutine simulate
end program heat
