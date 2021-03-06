! THIS FILES CONTAINS ALL I/O SUBROUTINES

! PRINT RMAT ====================================================================  
! **** PURPOSE ****
! PRINT OUT THE INPUT REAL MATRIX
! **** INPUT VARIABLES ****
! [DESC]: CHARACTER, DESCRIPTION OF YOUR DATA
! [A]: REAL, NXM, THE MATRIX 
! [FID]: YOUR FILE ID OR USE 6 FOR SCREEN PRINT OUT
! **** OUTPUT VARIABLES ****
! N/A
! **** VERSION ****
! 1/21/2014 FIRST BUILT 
! **** COMMENT **** 
! USE FID=6 TO SHOW ON SCREEN
! USE OPEN(UNIT=10,FILE='YOUR_FILE.TXT') TO SHOW IN FILE
! ALL DATA ARE SHOWN BY A VALUE LESS THAN. THE ORDER OF 
! THEM WILLL BE SHOWN IN THE HEADER
SUBROUTINE ML_PRINT_RMAT( DESC, A,A_DIM, FID )
  IMPLICIT NONE
  CHARACTER*(*)    DESC
  CHARACTER(LEN=30) OUT_FORM
  INTEGER          FID, A_DIM(2)
  REAL             A( A_DIM(1), A_DIM(2) )
  INTEGER          I, J,ORDER,C_NUM(A_DIM(2))

  DO I=1,A_DIM(2)
    C_NUM(I)=I
  END DO
  ORDER=LOG10(MAXVAL(ABS(A)))
  WRITE(FID,*)
  WRITE(FID,*) DESC, ", ORDER=",ORDER
  WRITE(FID,*) "************************************************"
  WRITE(OUT_FORM,*) "(",A_DIM(2),"(2XI9))"
  WRITE(FID,OUT_FORM) (C_NUM)
  WRITE(FID,*) 
  WRITE(OUT_FORM,*) "(",A_DIM(2),"(2XF9.5))"
  DO I = 1, A_DIM(1)
      WRITE(FID,OUT_FORM) A(I,:)/10.0**ORDER
  END DO
END SUBROUTINE

! PRINT CMAT ====================================================================  
! **** PURPOSE ****
! PRINT OUT THE INPUT COMPLEX MATRIX
! **** INPUT VARIABLES ****
! [DESC]: CHARACTER, DESCRIPTION OF YOUR DATA
! [A]: COMPLEX, NXM, THE MATRIX 
! [FID]: YOUR FILE ID OR USE 6 FOR SCREEN PRINT OUT
! **** OUTPUT VARIABLES ****
! N/A
! **** VERSION ****
! 1/21/2014 FIRST BUILT 
! **** COMMENT **** 
! USE FID=6 TO SHOW ON SCREEN
! USE OPEN(UNIT=10,FILE='YOUR_FILE.TXT') TO SHOW IN FILE
! ALL DATA ARE SHOWN BY A VALUE LESS THAN. THE ORDER OF 
! THEM WILLL BE SHOWN IN THE HEADER
SUBROUTINE ML_PRINT_CMAT(DESC,A,A_DIM, FID )
  IMPLICIT NONE
  CHARACTER*(*)    DESC
  CHARACTER(LEN=30) OUT_FORM
  INTEGER          FID, A_DIM(2)
  COMPLEX          A( A_DIM(1), A_DIM(2) )
  INTEGER          I, J, ORDER, C_NUM(A_DIM(2))

  DO I=1,A_DIM(2)
    C_NUM(I)=I
  END DO
  ORDER=LOG10(MAXVAL(ABS(A)))
  WRITE(FID,*)
  WRITE(FID,*) DESC, ", ORDER=",ORDER
  WRITE(FID,*) "************************************************"
  WRITE(OUT_FORM,*) "(",A_DIM(2),"(2XI9))"
  WRITE(FID,OUT_FORM) (C_NUM)
  WRITE(FID,*) 
  WRITE(OUT_FORM,*) "(",A_DIM(2),"(2X,F9.5,F9.5))"
  DO I = 1, A_DIM(1)
      WRITE(FID,OUT_FORM) A(I,:)/10.0**ORDER
  END DO
END SUBROUTINE

! PRINT IMAT ====================================================================  
! **** PURPOSE ****
! PRINT OUT THE INPUT INTEGER MATRIX
! **** INPUT VARIABLES ****
! [DESC]: CHARACTER, DESCRIPTION OF YOUR DATA
! [A]: INTEGER, NXM, THE MATRIX 
! [FID]: YOUR FILE ID OR USE 6 FOR SCREEN PRINT OUT
! **** OUTPUT VARIABLES ****
! N/A
! **** VERSION ****
! 1/21/2014 FIRST BUILT 
! **** COMMENT **** 
! USE FID=6 TO SHOW ON SCREEN
! USE OPEN(UNIT=10,FILE='YOUR_FILE.TXT') TO SHOW IN FILE
! ALL DATA ARE SHOWN BY A VALUE LESS THAN. THE ORDER OF 
! THEM WILLL BE SHOWN IN THE HEADER
SUBROUTINE ML_PRINT_IMAT(DESC,A,A_DIM,FID )
  IMPLICIT NONE
  CHARACTER*(*)   :: DESC
  CHARACTER(LEN=30) :: OUT_FORM
  INTEGER ::         FID, A_DIM(2)
  INTEGER ::         A( A_DIM(1), A_DIM(2) )
  INTEGER ::         I, C_NUM(A_DIM(2))

  DO I=1,A_DIM(2)
    C_NUM(I)=I
  END DO

  WRITE(FID,*)
  WRITE(FID,*) DESC, ", ORDER=",0
  WRITE(FID,*) "************************************************"
  WRITE(OUT_FORM,*) "(",A_DIM(2),"(2X,I6))"
  WRITE(FID,OUT_FORM) (C_NUM)
  WRITE(FID,*) 
  WRITE(OUT_FORM,*) "(",A_DIM(2),"(2X,I6))"
  DO I = 1, A_DIM(1)
     WRITE(FID,OUT_FORM) A(I,:)
  END DO
END SUBROUTINE