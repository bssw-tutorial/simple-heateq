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
