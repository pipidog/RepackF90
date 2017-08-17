! THIS FILE CONTAINS ALL NUMERICAL APPROXIMATION SUBROUTINES

! CLEAN REAL MATRIX =============================================================
! **** PURPOSE **** 
! THIS CODE ERASE THE ELEMENTS OF A REAL MATRIX THAT SMALLER THAN A SPECIFIC VALUE
! **** INPUT VARIABLES ****
! [M]: REAL, (N)X(N), MATRIX TO CLEAN 
! [FLITER]: REAL, 1X1, FLITER VALUE
! **** OUTPUT VARIABLES ****
! [M]: REAL, NXN, MATRIX CLEANED
! **** VERSION ****
! 1/26/2014 FIRST BUILT 
! **** COMMENT ****
! 1. OUTPUT
! THE OUTPUT AND INPUT ARE THE SAME
! 2. TRICK
! YOU CAN USE FLITER=MAX(ABS(M))*10**(-3) TO ELIMIATE RELATIVELY SMALL VALUES

SUBROUTINE PI_CLEAN_RMAT(M,M_DIM,FLITER)
	IMPLICIT NONE
	! DIMENSION
	INTEGER :: M_DIM(2)
	! INPUT
	REAL, INTENT(IN) :: FLITER
	! INPUT / OUTPUT
	REAL, INTENT(INOUT) :: M(M_DIM(1),M_DIM(2))
	
	WHERE(ABS(M) <= FLITER)
		M=0.0
	END WHERE
END SUBROUTINE

! CLEAN COMPLEX MATRIX =========================================================
! **** PURPOSE **** 
! THIS CODE ERASE THE ELEMENTS OF A COMPLEX MATRIX THAT SMALLER THAN A SPECIFIC VALUE
! REAL AND IMAG PARTS ARE EARSED SEPERATLY
! **** INPUT VARIABLES ****
! [M]: COMPLEX, (N)X(N), MATRIX TO CLEAN 
! **** OUTPUT VARIABLES ****
! [M]: REAL, NXN, MATRIX CLEANED
! **** VERSION ****
! 1/26/2014 FIRST BUILT 
! **** COMMENT ****
! 1. OUTPUT
! THE OUTPUT AND INPUT ARE THE SAME
! 2. TRICK
! YOU CAN USE FLITER=MAX(ABS(M))*10**(-3) TO ELIMIATE RELATIVELY SMALL VALUES

SUBROUTINE PI_CLEAN_CMAT(M,M_DIM,FLITER)
	IMPLICIT NONE
	! DIMENSION
	INTEGER :: M_DIM(2)
	! INPUT
	REAL, INTENT(IN) :: FLITER
	! INPUT / OUTPUT
	COMPLEX, INTENT(INOUT) :: M(M_DIM(1),M_DIM(2))
	! LOCAL(DUMMY)
	INTEGER :: N, P
	! LOCAL(ARRAY)
	REAL :: M_REAL(M_DIM(1),M_DIM(2)), M_IMAG(M_DIM(1),M_DIM(2))
	
	
	M_REAL= REALPART(M)
	M_IMAG= IMAGPART(M)
	
	WHERE(ABS(M_REAL) <= FLITER)
		M_REAL=0.0
	END WHERE
	WHERE(ABS(M_IMAG) <= FLITER)
		M_IMAG=0.0
	END WHERE
	M=0
	M=M_REAL+(0.0,1.0)*M_IMAG
END SUBROUTINE	