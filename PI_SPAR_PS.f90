! SPARSE MATRIX CONVERTER =====================================================
! **** PURPOSE ****
! THIS CODE CONVERT A SYMMETRY MATRIX FORM SPARSE TO PACKED-SOTRAGE FORM
! IT IS HELPFUL TO CALL LAPACK SUBROUTINE. 
! **** INPUT/OUTPUT VARIABLES ****
! [A_SP_IND]: INTEGER, 3X(M+1), THE SPARSE MATRIX 
! [A_SP_VAL]: REAL, (M+1), THE SPARSE VALUE
! [A_PS]: REAL, N(N+1)/2, THE UPPER TRIANGLE MATRIX OUTPUT IN PACK-STORAGE FORM 
!         WHERE N IS THE DIEMNSION OF YOUR FULL MATRIX.
! **** VERSION ****
! FEB/5/2014
! **** COMMENT **** 
! 1. INSTRUCTION
! THIS FUNCTION IS PARTICULAR DESINGED TO LARGE CALCULATION WHERE USUALLY THE
! DATA ARE STORE IN SPARSE MATRIX FORM. HOWEVER, LAPACK DOESN'T SUPPORT DIRECT
! INPUT OF SPARSE FORM, SO THIS CODE CONVERT YOUR SPARSE MATRIX TO PS FORM
! WHICH WILL ALSO SAVE YOUR MEMORY A LOT. SO, IN GENERAL, YOU WON'Y NEED USE
! THIS FUNCTION DIRECTLY. IT IS USUALLY CALLED BY LAPAKC INTERFACE FUNCTIONS.
! 2 DIFFERENCE FROM SP 2 FULL
! PI_SYSY_FULL CAN DO THE CONVERSION FORWARD OR BACKWARD. BUT SP 2 PS CANNOT.
! IT IS BECAUSE SP2PS USUALLY USE FOR LAPCK. THE OUTPUT PS IS USUALLY NO LONGER
! A SPARSE MATRIX. SO IT IS NOT RECOMMEND TO DO IT REVERSE. WHAT YOU NEED
! IS PS TO FULL. SEE PI_PS_SYMAT, PI_PS_HEMAT

SUBROUTINE PI_SYSP_PS(A_SP_IND,A_SP_IND_DIM,A_SP_VAL,A_SP_VAL_DIM,A_PS,A_PS_DIM) 
	IMPLICIT NONE
	! DIMENSION 
	INTEGER, INTENT(IN) :: A_SP_IND_DIM(2),A_SP_VAL_DIM, A_PS_DIM
	! INPUT
	INTEGER, INTENT(IN) :: A_SP_IND(A_SP_IND_DIM(1),A_SP_IND_DIM(2))
	REAL, INTENT(IN) :: A_SP_VAL(A_SP_VAL_DIM)
	! OUTPUT
	REAL, INTENT(OUT) :: A_PS(A_PS_DIM)
	! LOCAL(DUMMY)
	INTEGER :: N, M, TMP_I_N1
	
	A_PS=0
	DO N=2,A_SP_VAL_DIM
		TMP_I_N1=0
		DO M=1,A_SP_IND(2,N)-1
			TMP_I_N1=TMP_I_N1+M
		END DO
		TMP_I_N1=TMP_I_N1+A_SP_IND(1,N)
		A_PS(TMP_I_N1)=A_SP_VAL(A_SP_IND(3,N))
	END DO
END SUBROUTINE
		
SUBROUTINE PI_HESP_PS(A_SP_IND,A_SP_IND_DIM,A_SP_VAL,A_SP_VAL_DIM,A_PS,A_PS_DIM) 
	IMPLICIT NONE
	! DIMENSION 
	INTEGER, INTENT(IN) :: A_SP_IND_DIM(2),A_SP_VAL_DIM, A_PS_DIM
	! INPUT
	INTEGER, INTENT(IN) :: A_SP_IND(A_SP_IND_DIM(1),A_SP_IND_DIM(2))
	COMPLEX, INTENT(IN) :: A_SP_VAL(A_SP_VAL_DIM)
	! OUTPUT
	COMPLEX, INTENT(OUT) :: A_PS(A_PS_DIM)
	! LOCAL(DUMMY)
	INTEGER :: N, M, TMP_I_N1
	
	A_PS=0
	DO N=2,A_SP_VAL_DIM
		TMP_I_N1=0
		DO M=1,A_SP_IND(2,N)-1
			TMP_I_N1=TMP_I_N1+M
		END DO
		TMP_I_N1=TMP_I_N1+A_SP_IND(1,N)
		A_PS(TMP_I_N1)=A_SP_VAL(A_SP_IND(3,N))
	END DO
END SUBROUTINE
