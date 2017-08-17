﻿! THIS FILE CONTAINS ALL HAMILTONIAN RELATED SUBROUTINES 
! FOCK STATE ==================================================================  
! **** PURPOSE ****
! GENERATES THE FERMION FOCK STATE 
! **** INPUT VARIABLES ****
! [OCCUP_NUM]: INTEGER, 2XN, TELLS THE LEVELS AND PT # OF EACH SITE
! [OUT_FORM]: STRING, 'SITE' OR 'TOTAL', DECIDE HOW WILL YOU LABEL THE STATE
! **** OUTPUT VARIABLES ****
! [FOCK_OCCUP]: INTEGER, SUM(OCCUP_NUM(2,:))X(C(5,2)XC(4,2)), SHOW OCCUPIED STATES
! **** VERSION ****
! 1/20/2014 FIRST BUILT 
! **** COMMENT **** 
! 1. SCENARIO 
! THE OCCUP_NUM HAS THE FORM, EX: [5,2;4,2], WHICH MEANS YOU HAVE 5 LEVELS AT
! SITE-1 WITH 2 PARTICLE IN IT AND SO ON. THE OUTPUT WILL GIVE YOU THE WHICH
! STATES ARE OCCUPIED. THE STATE ARE LABELED IN TOTAL STATE SERIES. SO, FOR
! THIS CASE, SITE-1:1~5, SITE-2:6~9 AND OBVIOUSLY, THE SIZE OF FOCK_STATE IS
! (TOTAL PARTICLE)X(TOTAL PERMUTAION)
! 2. OVERSIZE PROBLEM (PARTICLE-HOLE TRANSFORMATION)
! THE COMBINATORIAL PROBLEM GOES TO EXTREMELY LARGE QUICKLY. TO AVIOD TIS ISSUE,
! TRY TO USE PARTICLE-HOLE ALTERNATIVE LANGUAGE FOR YOUR PROBLEM. EX: UING C(14,4)
! INTTEAD OF C(14,10) WHICH MEANS YOU TAKE OFF 4 PARTICLES RATHER THAN ADDING 10
! PARTICLES. IT WILL HIGHLY REDUCE THE LOADING. HOWEVER, KEEP IN MIND WHAT YOU
! ARE USING! 
! 3. OUT_FORM
! IF 'SITE', THE CODE WILL LABEL THE STATES OF EACH SITE FROM 1. IF 'TOTAL', THE
! CODE WILL LABLE EACH SITE FORM 1 TO TOTAL STATE. EX: OCCUP_NUM=[5,3,4,3], THEN
! STATE LABLE WILL BE 1-5 ON SITE 1 AND 6-9 ON SITE 2.
! IT IS STRONGLY RECOMMMEND TO USE 'TOTAL' WHICH IS COMPATIBLE FOR FURTHER
! CALCULATIONS. THE 'SITE' OPTION IS DESIGNED TO SOLVE THE COMBINATORIAL PROBLEM. 
! 4. FORAML FOCK STATE
! THIS CODE JUST HELPS YOU FIGURE OUT THE OCCUPIED STATES FOR TWO REASONS. (1)
! SAVE THE MEMORY (2) ABILITY FOR USE AS A CODE THAT OUTPUTS YOU THE C(N,M) PROBLEM
! IF YOU NEED TO USE OTHER FOCK STATE PROBLEMS, YOU SHOULD USE ML_FOCK_CONVERT
! TO GENERATE REAL FOCK STATE REPRESENTATION

SUBROUTINE ML_FOCK_OCCUP(OCCUP_NUM,OCCUP_NUM_DIM,FOCK_OCCUP,FOCK_OCCUP_DIM,OUT_FORM)
  IMPLICIT NONE
  ! DIMENSION
  INTEGER, INTENT(IN) :: OCCUP_NUM_DIM(2), FOCK_OCCUP_DIM(2)
  ! INPUT   
  CHARACTER(*), INTENT(IN) :: OUT_FORM
  INTEGER, INTENT(IN) :: OCCUP_NUM(OCCUP_NUM_DIM(1),OCCUP_NUM_DIM(2))
  ! OUTPUT
  INTEGER, INTENT(OUT) :: FOCK_OCCUP(FOCK_OCCUP_DIM(1),FOCK_OCCUP_DIM(2))
  ! LOCAL(DUMMY)
  INTEGER :: N, M, P
  ! LOCAL (VALUES) 
  INTEGER :: TOT_SITE=0, TOT_PT=0, TMP_COUNT=0 
  INTEGER :: LOOP_INDEX_TEST=0, TOT_COMB=0, COMB=0 
  ! LOCAL (ARRAYS)
  ! N/A
  ! LOCAL(ALLOVATABLES)
  INTEGER, ALLOCATABLE :: LOOP_INDEX(:,:), LOOP_END(:), SITE_LEVEL_RANGE(:,:)
  ! VARIABLES INITIALIZATION
  FOCK_OCCUP=0
  ! PROGRAM START ---------------------------------------
  ! GENERATES ALL NECESSARY VARIABLES
  TOT_SITE=SIZE(OCCUP_NUM,2)
  TOT_PT=SUM(OCCUP_NUM(2,:))
  TOT_COMB=FOCK_OCCUP_DIM(2)
  ALLOCATE(LOOP_END(SUM(OCCUP_NUM(2,:)))); LOOP_END=0  
  ALLOCATE(SITE_LEVEL_RANGE(2,SIZE(OCCUP_NUM,2))); SITE_LEVEL_RANGE=0 
    
  DO N=1,TOT_SITE
   SELECT CASE(N)
     CASE(1)
      SITE_LEVEL_RANGE(1,N)=1
     CASE DEFAULT
      SITE_LEVEL_RANGE(1,N)=SITE_LEVEL_RANGE(2,N-1)+1
   END SELECT
   SITE_LEVEL_RANGE(2,N)=SITE_LEVEL_RANGE(1,N)+OCCUP_NUM(2,N)-1
  END DO
  
  ! GENERATES LOOP_END VECTOR
  TMP_COUNT=0
  DO N=1,TOT_SITE
    DO M=1,OCCUP_NUM(2,N)
      TMP_COUNT=TMP_COUNT+1
      LOOP_END(TMP_COUNT)=OCCUP_NUM(1,N)     
    END DO
  END DO
  ALLOCATE(LOOP_INDEX(TOT_PT,PRODUCT(LOOP_END))) ; LOOP_INDEX=0
  CALL ML_NESTED_LOOP(LOOP_END,SHAPE(LOOP_END),LOOP_INDEX,SHAPE(LOOP_INDEX))
  
  ! KICK OUT UNWANTED LOOP_INDEX
  TMP_COUNT=0
  DO N=1,PRODUCT(LOOP_END)
    LOOP_INDEX_TEST=1
        
    DO M=1,TOT_SITE
       IF (SITE_LEVEL_RANGE(1,M)/=SITE_LEVEL_RANGE(2,M)) THEN 
         DO P=SITE_LEVEL_RANGE(1,M)+1,SITE_LEVEL_RANGE(2,M)
          IF (ANY(LOOP_INDEX(SITE_LEVEL_RANGE(1,M):P-1,N)>=LOOP_INDEX(P,N))) THEN 
            LOOP_INDEX_TEST=-1
            EXIT
          END IF
         END DO
       END IF
      IF (LOOP_INDEX_TEST==-1) THEN
        EXIT
      END IF
   END DO    
     IF (LOOP_INDEX_TEST==1) THEN
       TMP_COUNT=TMP_COUNT+1
       FOCK_OCCUP(:,TMP_COUNT)=LOOP_INDEX(:,N)
     END IF
  END DO
  
  SELECT CASE(OUT_FORM)
  CASE('SITE')
  
  CASE('TOTAL')
    IF (TOT_SITE>1) THEN
      DO N=2,TOT_SITE
        FOCK_OCCUP(SITE_LEVEL_RANGE(1,N):SITE_LEVEL_RANGE(2,N),:)&
        &=FOCK_OCCUP(SITE_LEVEL_RANGE(1,N):SITE_LEVEL_RANGE(2,N),:)+SUM(OCCUP_NUM(1,1:N-1))
      END DO
    END IF
  CASE DEFAULT
     WRITE(*,*) "OUT_FORM ERROR IN ML_FOCK_OCCUP! CHANGE TO 'SITE' OPTION! "
  END SELECT 

END SUBROUTINE

! FOCK STATE CONVERT ===========================================================  
! **** PURPOSE ****
! CONVERT THE FOCK_OCCUO FROM ML_FOCK_OCCUP (MUST USE 'TOTAL' OUT_FORM) TO FORMAL 
! FOCK OCCUPATION REPRESENTATION.  
! **** INPUT VARIABLES ****
! [OCCUP_NUM]: INTEGER, (2)X(TOT_SITE), THE SAME DEFINITION AS ML_FOCK_OCCUP
! [FOCK_OCCUP]: INTEGER, (TOT_COMB)X(TOT_PT), SHOULD GET FROM ML_FOCK_OCCUP
! [PH_TRANS]: INTEGER, 1X(TOT_SITE), TELLS PARTICLES OR HOLES FOR EACH SITE
! **** OUTPUT VARIABLES ****
! [FOCK_STATE]: INTEGER, (TOT_COMB)X(TOT_SINGLE_PT_STATE), THE FOCK STATE
! **** VERSION ****
! 1/24/2014 FIRST BUILT 
! **** COMMENT **** 
! 1. FUNCTION
! USING FORMAL FOCK STATE CAN FIX THE SIZE OF YOUR FOCK STATE MATRIX. IT IS HELPFUL
! FOR FURTHER CALCULATIONS
! 2. PH_TRANS
! THIS CODE REQIRES YOU TO SPECIFY HOW DID YOU LABEL YOUR OCCUPATIONS IN FOCK_OCCUP
! ON EACH SITE, +1(HOLE), -1(ELECTRON). IF IT IS HOLE, THE CODE ASSIGNED 0 FOR THE
! LABELED STATES AND 1 FOR NON-LABEL STATES AND VICE VERSA.

SUBROUTINE ML_FOCK_CONVERT(OCCUP_NUM,OCCUP_NUM_DIM,FOCK_OCCUP,FOCK_OCCUP_DIM,PH_TRANS,PH_TRANS_DIM,FOCK_STATE,FOCK_STATE_DIM)
  IMPLICIT NONE
  ! DIMENSION 
  INTEGER, INTENT(IN) :: OCCUP_NUM_DIM(2),FOCK_OCCUP_DIM(2), PH_TRANS_DIM, FOCK_STATE_DIM(2)
  ! INPUT
  INTEGER, INTENT(IN) :: OCCUP_NUM(OCCUP_NUM_DIM(1),OCCUP_NUM_DIM(2))
  INTEGER, INTENT(IN) :: FOCK_OCCUP(FOCK_OCCUP_DIM(1),FOCK_OCCUP_DIM(2)) 
  INTEGER, INTENT(IN) :: PH_TRANS(PH_TRANS_DIM)
  ! OUTPUT
  INTEGER, INTENT(OUT) :: FOCK_STATE(FOCK_STATE_DIM(1),FOCK_STATE_DIM(2))
  ! LOCAL(DUMMIES)
  INTEGER :: N, M, P
  ! LOCAL(VALUES)
  INTEGER :: TOT_COMB, TOT_LEVEL, TOT_SITE, F_INDEX, TOT_PT   
  ! LOCAL(ARRAYS)
  INTEGER :: SITE_LEVEL_RANGE(2,OCCUP_NUM_DIM(2))
  ! LOCAL(ALLOCATABLES)
  ! N/A
  ! VARIABLE INITIALIZATION
  FOCK_STATE=0; ! OUTPUT
  TOT_COMB=0; TOT_LEVEL=0; TOT_SITE=0; F_INDEX=0; TOT_PT=0! VALUES
  SITE_LEVEL_RANGE=0; ! ARRAYS
  
  ! PROGRAM START------------------------
  
  ! CHECK IF FOCK_COOUP IS IN 'TOTAL' FORM
  IF (COUNT(FOCK_OCCUP(:,1)==1)>1) THEN
    WRITE(*,*) "ERROR IN ML_FOCK_CONVERT! FOCK_OCCUP MUST BE IN 'TOTAL' FORM! "
    RETURN
  END IF
  
  ! GENERATE ALL NEEDED VARIABLES  
  TOT_COMB=FOCK_OCCUP_DIM(2)
  TOT_LEVEL=MAXVAL(FOCK_OCCUP(:,TOT_COMB))
  TOT_SITE=OCCUP_NUM_DIM(2)
  TOT_PT=SUM(OCCUP_NUM(2,:))
  SITE_LEVEL_RANGE(1,1)=1; SITE_LEVEL_RANGE(2,1)=OCCUP_NUM(1,1);
  IF (TOT_SITE>1) THEN
   DO N=2,TOT_SITE
      SITE_LEVEL_RANGE(1,N)=SITE_LEVEL_RANGE(2,N-1)+1
      SITE_LEVEL_RANGE(2,N)=SITE_LEVEL_RANGE(2,N-1)+OCCUP_NUM(1,N)
    END DO
  END IF

  ! GENERATE VACUUM STATE BASED ON PARTICLE-HOLE INPUT
  DO N=1,TOT_SITE
    SELECT CASE(PH_TRANS(N))
    CASE(+1)
      FOCK_STATE(SITE_LEVEL_RANGE(1,N):SITE_LEVEL_RANGE(2,N),:)=1   
    CASE(-1)
      FOCK_STATE(SITE_LEVEL_RANGE(1,N):SITE_LEVEL_RANGE(2,N),:)=0
    END SELECT
  END DO

  DO N=1,TOT_COMB
      DO M=1,TOT_PT
        F_INDEX=FOCK_OCCUP(M,N)
        SELECT CASE(FOCK_STATE(F_INDEX,N))
        CASE(+1)
          FOCK_STATE(F_INDEX,N)=0
        CASE(0)
          FOCK_STATE(F_INDEX,N)=1
        END SELECT
      END DO
  END DO
END SUBROUTINE

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

SUBROUTINE ML_FERMION_OP(FERMION_OP,FERMION_OP_DIM,FOCK_KET_IN,FOCK_KET_IN_DIM,FOCK_KET_OUT,FOCK_KET_OUT_DIM,FOCK_PHASE)
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
    WRITE(*,*) "ERROR IN ML_FERMION! 'FOCK_KET_IN' MUST HAVE THE SAME DIMENSION WITH 'FOCK_KET_OUT'!"
  END IF
  IF ( (MAXVAL(FERMION_OP(1,:))>FOCK_KET_IN_DIM) .OR. MINVAL(FERMION_OP(1,:)) <= 0 ) THEN
    WRITE(*,*) "ERROR IN ML_FERMION! 'FERMION_OP' HAS WRONG VALUES!"
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