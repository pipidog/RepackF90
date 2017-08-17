! FERMION OPERATOR =============================================================  
! **** PURPOSE ****
! THIS CODE CALCULATES THE FERMION OPERATORS ACTING ON A GIVEN FOCK STATE 
! **** INPUT VARIABLES ****
! [FERMION_OP], INTEGER, 2XN, THE FERMION OPERATORS YOU WANT TO PERFORM
! [FOCK_KET_IN], INTEGER, MX1, THE FOCK KET TO BE ACTED 
! **** OUTPUT VARIABLES ****
! [FOCK_KET_OUT], INTEGER, MX1, THE OUTPUT KET
! [FOCK_PHASE], INTEGER, 1X1, PHASE OF THE OUTPUT KET (+1,0,-1)
! **** VERSION ****
! 1/24/2014 FIRST BUILT 
! **** COMMENT **** 
! 1. FERMION_OP:
! FOR EXAMPLE, WE WANT TO CALCULATE C+(I)C(J), THEN, THEN GIVE A 2X2 MATIRX WITH
! VALUES: /J,-1,I,+1/, IT MEANS, DO DESTORY ON J AND CREATE ON I
! 2. FOCK_PHASE:
! PHASE OF THE OUTPUT KET. EITHER +1 OR -1. IF THE OPERATORS MAKE THE KET NULL
! PHASE WILL BE SET ZERO. 

SUBROUTINE PI_FERMION_OP(FERMION_OP,FERMION_OP_DIM,FOCK_KET_IN,FOCK_KET_IN_DIM,FOCK_KET_OUT,FOCK_KET_OUT_DIM,FOCK_PHASE)
  IMPLICIT NONE
  ! DIMENSION
  INTEGER, INTENT(IN) :: FERMION_OP_DIM(2), FOCK_KET_IN_DIM, FOCK_KET_OUT_DIM
  ! INPUT
  INTEGER, INTENT(IN) :: FERMION_OP(FERMION_OP_DIM(1),FERMION_OP_DIM(2))
  INTEGER, INTENT(IN) :: FOCK_KET_IN(FOCK_KET_IN_DIM)
  ! OUTPUT
  INTEGER, INTENT(OUT) :: FOCK_KET_OUT(FOCK_KET_OUT_DIM)
  INTEGER, INTENT(OUT) :: FOCK_PHASE
  ! LOCAL (DUMMY)
  INTEGER :: N, M, P
  ! LOCAL (VALUE)
  INTEGER :: TOT_OP
  ! LOCAL (ARRAY)
  ! LOCAL (ALLOCATABLE)

  ! VARIABLE INITIALIZATION  
  FOCK_KET_OUT=0; FOCK_PHASE=0 ! OUTPUT
  TOT_OP=0 ! LOCAL(VALUES)
  ! PROGRAM START -------------------
  
  ! CHEKC INPUT CORRECTNESS
  IF (FOCK_KET_IN_DIM /= FOCK_KET_OUT_DIM) THEN
    WRITE(*,*) "ERROR IN PI_FERMION! 'FOCK_KET_IN' MUST HAVE THE SAME DIMENSION WITH 'FOCK_KET_OUT'!"
  END IF
  IF ( (MAXVAL(FERMION_OP(1,:))>FOCK_KET_IN_DIM) .OR. MINVAL(FERMION_OP(1,:)) <= 0 ) THEN
    WRITE(*,*) "ERROR IN PI_FERMION! 'FERMION_OP' HAS WRONG VALUES!"
  END IF
  
  ! GENERATE ALL VARIABLES
  TOT_OP=FERMION_OP_DIM(2)
  FOCK_KET_OUT=FOCK_KET_IN
  DO N=1,TOT_OP
    SELECT CASE(FERMION_OP(2,N))
    CASE(+1) ! CREATE
      SELECT CASE(FOCK_KET_IN(FERMION_OP(1,N)))
      CASE(+1)
        FOCK_KET_OUT=0
        FOCK_PHASE=0
        EXIT
      CASE(0)       
        FOCK_KET_OUT(FERMION_OP(1,N))=1
        IF (FERMION_OP(1,N)/=1) THEN
          FOCK_PHASE=(-1)**(SUM(FOCK_KET_OUT(1:FERMION_OP(1,N)-1)))
        END IF
      END SELECT 
     CASE(-1) ! DESTORY
      SELECT CASE(FOCK_KET_IN(FERMION_OP(1,N)))
      CASE(0)
        FOCK_KET_OUT=0
        FOCK_PHASE=0
        EXIT
      CASE(+1)
        FOCK_KET_OUT(FERMION_OP(1,N))=0
        IF (FERMION_OP(1,N)/=1) THEN
          FOCK_PHASE=(-1)**(SUM(FOCK_KET_OUT(1:FERMION_OP(1,N)-1)))
        END IF
      END SELECT   
     END SELECT
   END DO  
END SUBROUTINE