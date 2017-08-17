! THIS FILE CONTAINS ALL ALGORITHM RELATED SUBROUTINES

! NESTED LOOP ==================================================================  
! **** PURPOSE **** 
! OUTPUT THE INDEICES OF A 1:N NESTED DO LOOP
! **** INPUT VARIABLES ****
! [LOOP_END]: INTEGER, NX1, THE ENDING VALUES OF EACH DO LOOP
! **** OUTPUT VARIABLES ****
! [LOOP_INDEX]: INTEGER, (LOOP_END_DIM)X(PRODUCT(LOOP_END)) 
! **** VERSION ****
! 1/20/2014 FIRST BUILT 
! **** COMMENT ****
! FOR ALGORITHM, SEE MY NOTES
! CREATE A VECTOR FOR LOOP_END, EX: [5,5,4,3,3], THE CODE GENERATES THE INDEX OF
! FIVE NESTED LOOPS, WHICH RANGES FROM 1:5,1:5,1:4,1:3,1:3. SO, LOOP_INDEX HAS
! SIZE OF (# OF LOOP-DEPTH)X(TOT_LOOPS) 
! 
SUBROUTINE PI_NESTED_LOOP(LOOP_END,LOOP_END_DIM,LOOP_INDEX,LOOP_INDEX_DIM)
  IMPLICIT NONE
  ! INPUT
  INTEGER, INTENT(IN) :: LOOP_END_DIM(1), LOOP_INDEX_DIM(2) ! DIMENSION
  INTEGER, INTENT(IN) :: LOOP_END(LOOP_END_DIM(1)) ! INPUT VRIABLE 
  ! OUTPUT
  INTEGER, INTENT(OUT) :: LOOP_INDEX(LOOP_INDEX_DIM(1),LOOP_INDEX_DIM(2))  ! OUTPUT VARIABLE
  ! LOCAL(DUMMY)
  INTEGER :: N, M
  ! LOCAL(VALUES)
  INTEGER :: TOT_DIV=0, TOT_LOOP=0 
  INTEGER :: N_REMAIN=0, PRODUCT_REMAIN=0, N_REMAIN_TMP=0
  ! LOCAL(ALLOCATABLE) 
  INTEGER, ALLOCATABLE :: LOOP_DIV(:), N_QUO(:)
  ! CLEAN VARIABLES
  LOOP_INDEX=0
  
  ! START PROGRAM 
  TOT_LOOP=PRODUCT(LOOP_END)
  TOT_DIV=SIZE(LOOP_END,1)-1
  ALLOCATE(LOOP_DIV(TOT_DIV)); LOOP_DIV=0
  ALLOCATE(N_QUO(TOT_DIV)); N_QUO=0
    
  PRODUCT_REMAIN=TOT_LOOP
  DO N=1,TOT_DIV
    PRODUCT_REMAIN=PRODUCT_REMAIN/LOOP_END(N)
    LOOP_DIV(N)=PRODUCT_REMAIN
  END DO
   
  DO N=1,TOT_LOOP
    N_REMAIN=MOD(N,LOOP_DIV(TOT_DIV))
    SELECT CASE(N_REMAIN)
    CASE(1)
      N_REMAIN_TMP=N
      DO M=1,TOT_DIV
        N_QUO(M)=FLOOR(REAL(N_REMAIN_TMP)/REAL(LOOP_DIV(M)))
        N_REMAIN_TMP=MOD(N_REMAIN_TMP,LOOP_DIV(M))
      END DO
      LOOP_INDEX(1:TOT_DIV,N)=N_QUO(:)+1
      LOOP_INDEX(TOT_DIV+1,N)=N_REMAIN_TMP
    CASE(0)
      LOOP_INDEX(:,N)=LOOP_INDEX(:,N-(LOOP_DIV(TOT_DIV)-1))
      LOOP_INDEX(TOT_DIV+1,N)=LOOP_INDEX(TOT_DIV+1,N)+(LOOP_DIV(TOT_DIV)-1)    
    CASE DEFAULT
      LOOP_INDEX(:,N)=LOOP_INDEX(:,N-(N_REMAIN-1));
      LOOP_INDEX(TOT_DIV+1,N)=LOOP_INDEX(TOT_DIV+1,N)+(N_REMAIN-1);    
    END SELECT
  END DO
END SUBROUTINE