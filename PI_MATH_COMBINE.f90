! THIS FILE CONTAINS ALL COMBINATORIAL PROBLEM SUBROUTINES

! FACTORIAL ====================================================================  
! **** PURPOSE ****
! CALCULATES THE VALUES OF FACTORIAL FUNCTION, EX: N!=N*(N-1)*...*1
! **** INPUT VARIABLES ****
! [N]: INTEGER, 1X1, N-FACTORIAL
! **** OUTPUT VARIABLES ****
! [FACTORIAL]: REAL(KIND=8), 1X1, VALUE OF N!
! **** VERSION ****
! 1/20/2014 FIRST BUILT 
! 1/28/2014 ADD N=0 AND N<0 CASE
! **** COMMENT **** 
! THE OUTPUT IS A REAL(KIND=8) RATHER THAN AN INTEGER TO ACCOMDATE THE MANY
! DIGITS OF THE CALCULATION

SUBROUTINE PI_FACTORIAL(N,FACTORIAL)
  IMPLICIT NONE
  ! INPUT
  INTEGER, INTENT(IN) :: N  ! INPUT (N>25 MAY GET WRONG!)
  ! OUTPUT VALUES
  REAL(KIND=8), INTENT(OUT) :: FACTORIAL ! OUTPUT
  ! LOCAL(VALUES)
  INTEGER :: I=0
  ! LOCAL (ARRAY)
  INTEGER :: M(N)
    ! CLEAN VARIABLES
    M=0
    FACTORIAL=0.0
    ! START PROGRAM
	IF (N==0) THEN
		FACTORIAL=1
	ELSE IF (N<0) THEN
		WRITE(*,*) 'ERROR IN PI_FACTORIAL! N CANNOT BE NEGATIVE!'
		RETURN
	ELSE 
		M=(/(I,I=1,N)/)
		FACTORIAL=PRODUCT(REAL(M))
	END IF
	
END SUBROUTINE 

! COMBINATORIAL ================================================================ 
! **** PURPOSE **** 
! CALCULATES THE VALUES OF COMBINATORIAL FUNCTION, EX:C(N,M)
! **** INPUT VARIABLES ****
! [N]: INTEGER, 1X1, N TOTAL BALLS
! [M]: INTEGER, 1X1, M BALLS TO PICK
! **** OUTPUT VARIABLES ****
! [COMB]: REAL(KIND=8), 1X1, TOTAL # OF CHOICES 
! **** VERSION ****
! 1/20/2014 FIRST BUILT 
! **** COMMENT **** 
! 

SUBROUTINE PI_COMBINATORIAL(N,M,COMB)
  IMPLICIT NONE
  ! INPUT
  INTEGER, INTENT(IN) :: N,M  ! INPUT
  ! OUTPUT
  REAL(KIND=8), INTENT(OUT) :: COMB !OUTPUT
  ! LOCAL (VALUES)
  REAL(KIND=8) :: FACT1=0.0, FACT2=0.0, FACT3=0.0 !LOCAL VARIABLES
  ! CLEAN VARIABLES
  COMB=0.0
  ! START PROGRAM 
  CALL PI_FACTORIAL(N,FACT1)
  CALL PI_FACTORIAL(M,FACT2)
  CALL PI_FACTORIAL(N-M,FACT3)
  COMB=FACT1/(FACT2*FACT3)
END SUBROUTINE

! Multi-Combinatorial =======================================================
! **** PURPOSE **** 
! CALCULATES THE PRODUCT OF MANY COMBINATORIAL FUNCTION, EX:C(N,M)XC(P,Q)...
! **** INPUT VARIABLES ****
! [N]: INTEGER, 1X1, N TOTAL BALLS
! [M]: INTEGER, 1X1, M BALLS TO PICK
! **** OUTPUT VARIABLES ****
! [TOT_COMB]: REAL(KIND=8), 1X1, TOTAL # OF CHOICES 
! **** VERSION ****
! 1/21/2014 FIRST BUILT 
! **** COMMENT **** 
! EX: COMB_INDEX(2,2)  DATA /N,N,P,Q/ 
! TOT_COMB IS REAL(KIND=8)! IF YOU FIND YOUR RESULT IS ALWAYS ZERO, CHECK IT!
SUBROUTINE PI_MULTICOMB(COMB_INDEX,COMB_INDEX_DIM,TOT_COMB)
  IMPLICIT NONE
  ! INPUT
  INTEGER, INTENT(IN) :: COMB_INDEX_DIM(2)
  INTEGER, INTENT(IN) :: COMB_INDEX(COMB_INDEX_DIM(1),COMB_INDEX_DIM(2))
  ! OUTPUT
  REAL(KIND=8) :: TOT_COMB
  !LOCAL(DUMMY)
  INTEGER :: N 
  !LOCAL(VALUE)
  INTEGER :: TOT_PICK=0 
  REAL(KIND=8) :: COMB=0.0
  !LOCAL(ARRAY)
  !LOCAL(ALLOCATABLE)
  !CLEAN VARIABLES
  TOT_COMB=0.0; 
  
  ! PROGRAM START
  TOT_COMB=1.0
  TOT_PICK=COMB_INDEX_DIM(2)
  
  DO N=1,TOT_PICK  
   CALL PI_COMBINATORIAL(COMB_INDEX(1,N),COMB_INDEX(2,N),COMB)
   TOT_COMB=TOT_COMB*COMB
  END DO
END SUBROUTINE


