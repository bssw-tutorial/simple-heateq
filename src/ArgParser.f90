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
