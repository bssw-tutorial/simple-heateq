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
