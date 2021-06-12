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

program heat
    use ArgParser
    implicit none

    type(Params) :: p
    p = parse_args()
    call p%show()

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
  end function

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
  end function
end program heat
