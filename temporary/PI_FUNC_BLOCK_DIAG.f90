! RMAT Block Diagonal ===============================================================
! **** PURPOSE **** 
! THIS CODE REORDER A REAL MATRIX TO AS BLOCK DIAGONAL AS POSSIBLE AND LABELS ALL
! VECTORS TO THEIR OWN GROUP.
! **** INPUT VARIABLES ****
! [M_IN]: REAL, (N)X(N), THE MATRIX TO REORDER 
! **** OUTPUT VARIABLES ****
! [M_OUT]: REAL, (N)X(N), THE REORDERED MATRIX
! [ROD_LABEL]: INTEGER, (N), SHOWS THE THE NEW ORDER OF VECTORS
! [GRP_LABEL]: INTEGER, (N), SHOWS WHICH GROUP DOES EACH VECTOR BELONG
! **** VERSION ****
! 1/27/2014 FIRST BUILT 
! **** COMMENT ****
! 1. ALGORITHM:
! FIND THE NON-ZERO COULLING OF EACH VECTOR. THEN TRY TO GROUP THEM.
! 2. ROD_LABEL:
! ALFER THE REORDERING, IT SHOWS HOW THE VECTORS ARE REORDERED.
! 3. GRP_LABEL:
! THIS IS A VECTOR WHICH TELLS YOU WHICH GROUP DOES EACH VECTOR (WITH NEW
! ORDERING) BELONG.
! EX: (/1,1,1...,1/) MEANS THERE IS ONLY ONE GROUP, NO BLOCK DIAONAL.
! EX:(/1,1,1,2,2...2/) MENAS THERE ARE TWO GROUP. FIRST THREE IS GROUP 1
! AND THE OTHERS ARE GROUP 2.
! 4. ABOUT ZERO MATRIX ELEMENT
! BECAUSE WE NEED TO SET A VALVE FOR REAL NUMBER TO BE CONSIDER AS ZERO,
! WE SET A PAREMETER VAL_FLITER=10**(-6) AND ANY INPUT MATRIX WILL BE
! "CLEANED" FOR ABSOLUTE VALUES SMALLER THAN THIS. CHANGE IT IF YOU WANT. 
! HOWEVER, IN PRACTICAL USAGE, IT IS STRONGLY RECOMMEND TO DO IT OUTIDE
! THE SUBROUTINE. THE VAL_FLITER IS SET FOR GENERAL PURPOSE TO IDENFITY
! WHAT IS ZERO FOR REAL-TYPE. IF YOU WANT TO IGNORE SMALL VALUES OF YOUR
! CALCULATION RESULTS, USE PI_CLEAN_CMAT BEFORE PLUG IN. 

SUBROUTINE PI_BDIAG_RMAT(M_IN,M_IN_DIM,M_OUT,M_OUT_DIM,ROD_LABEL,ROD_LABEL_DIM,GRP_LABEL,GRP_LABEL_DIM)
	IMPLICIT NONE
	! DIMENSION
	INTEGER, INTENT(IN) :: M_IN_DIM(2), M_OUT_DIM(2), ROD_LABEL_DIM, GRP_LABEL_DIM
	! INPUT
	REAL, INTENT(IN) :: M_IN(M_IN_DIM(1),M_IN_DIM(2))
	! OUTPUT
	REAL, INTENT(OUT) :: M_OUT(M_OUT_DIM(1),M_OUT_DIM(2))
	INTEGER, INTENT(OUT) :: ROD_LABEL(ROD_LABEL_DIM)
	INTEGER, INTENT(OUT) :: GRP_LABEL(GRP_LABEL_DIM)
	! LOCAL(DUMMY)
	INTEGER :: N, M
	! LOCAL(VALUE)
	INTEGER :: TOT_VECT, TOT_COUNT
	REAL :: VAL_FLITER
	! LOCAL(ARRAY)
	INTEGER :: TOT_VECT_NZ(M_IN_DIM(1)), RO_RECORD(ROD_LABEL_DIM)
	REAL :: UNI_MAT(M_IN_DIM(1),M_IN_DIM(2))
	! LOCAL(ALLOCATABLE)
	INTEGER, ALLOCATABLE :: NZ_INDEX(:,:) 
	REAL, ALLOCATABLE :: OFF_DIAG_U(:,:), OFF_DIAG_L(:,:)
	! VARIABLE INITIALIZATION
	M_OUT=0; ROD_LABEL=0; GRP_LABEL=0; ! OUTPUT
	VAL_FLITER=0; TOT_COUNT=0; VAL_FLITER=(10.0)**(-6.0)  ! LOCAL(VALUE)
	TOT_VECT_NZ=0; RO_RECORD=1; UNI_MAT=0.0 ! LOCAL(ARRAY)
	
	! START PROGRAM ----------------
	
	! CHECK INPUT VARIABLES
	IF (M_IN_DIM(1) /= M_IN_DIM(2)) THEN
		WRITE(*,*) "ERROR IN PI_BDIAG_RMAT! 'M_IN' MUST BE A SQUARE MATRIX!"
	END IF
	! CLEAN INPUT MATRIX
	CALL PI_CLEAN_RMAT(M_IN,SHAPE(M_IN),VAL_FLITER)
	
	! GENERATES ALL VARIABLES
	TOT_VECT=M_IN_DIM(1)
	DO N=1,TOT_VECT-1
		TOT_VECT_NZ(N)=COUNT(ABS(M_IN(:,N))>VAL_FLITER)
	END DO

	! FIND ALL COUPLED VECTORS
	ALLOCATE(NZ_INDEX(MAXVAL(TOT_VECT_NZ),TOT_VECT)); NZ_INDEX=0
    
	DO N=1,TOT_VECT
		CALL PI_FIND_VECT(ABS(M_IN(:,N))>VAL_FLITER,SHAPE(M_IN(:,N))&
		&,NZ_INDEX(:,N),SHAPE(NZ_INDEX(:,N)))
	END DO
	
	! REORDER ALL VECTORS
	TOT_COUNT=0
	DO N=1,TOT_VECT
		DO M=1,MAXVAL(TOT_VECT_NZ)
			IF (NZ_INDEX(M,N)/=0) THEN
				IF (RO_RECORD(NZ_INDEX(M,N))/=0) THEN
					TOT_COUNT=TOT_COUNT+1
					ROD_LABEL(TOT_COUNT)=NZ_INDEX(M,N)
					RO_RECORD(NZ_INDEX(M,N))=0
				END IF
			END IF
		END DO
	END DO
	
	! GENERATE UNITARY MATRIX
	DO N=1,TOT_VECT
		UNI_MAT(ROD_LABEL(N),N)=1.0
	END DO
	M_OUT= MATMUL(TRANSPOSE(UNI_MAT),MATMUL(M_IN,(UNI_MAT)))
	
	! CHECK IF ALL OFF DIAG-BLOCK ZERO. IF YES, THERE IS A GROUP!
	ALLOCATE(OFF_DIAG_U(1,1)); OFF_DIAG_U=0
	ALLOCATE(OFF_DIAG_L(1,1)); OFF_DIAG_L=0
	TOT_COUNT=1 ! COUNT TOTAL GROUP
	DO N=1,TOT_VECT
		GRP_LABEL(N)=TOT_COUNT
		IF (N/=TOT_VECT) THEN
			DEALLOCATE(OFF_DIAG_U)
			DEALLOCATE(OFF_DIAG_L)
			ALLOCATE(OFF_DIAG_U(N,TOT_VECT-N)); OFF_DIAG_U=0 
			ALLOCATE(OFF_DIAG_L(TOT_VECT-N,N)); OFF_DIAG_L=0
			OFF_DIAG_U=M_OUT(1:N,N+1:)
			OFF_DIAG_L=M_OUT(N+1:,1:N)
			
			IF (COUNT(ABS(OFF_DIAG_U) > VAL_FLITER) == 0 &
			& .AND. COUNT(ABS(OFF_DIAG_L) > VAL_FLITER) == 0) THEN
				TOT_COUNT=TOT_COUNT+1
			END IF				
		END IF
	END DO
END SUBROUTINE	

! CMAT Block Diagonal ===============================================================
! **** PURPOSE **** 
! THIS CODE REORDER A COMPLEX MATRIX TO AS BLOCK DIAGONAL AS POSSIBLE AND LABELS ALL
! VECTORS TO THEIR OWN GROUP. 
! **** INPUT VARIABLES ****
! [M_IN]: COMPLEX, (N)X(N), THE MATRIX TO REORDER 
! **** OUTPUT VARIABLES ****
! [M_OUT]: COMPLEX, (N)X(N), THE REORDERED MATRIX
! [ROD_LABEL]: INTEGER, (N), SHOWS THE THE NEW ORDER OF VECTORS
! [GRP_LABEL]: INTEGER, (N), SHOWS WHICH GROUP DOES EACH VECTOR BELONG
! **** VERSION ****
! 1/27/2014 FIRST BUILT 
! **** COMMENT ****
! 1. ALGORITHM:
! FIND THE NON-ZERO COULLING OF EACH VECTOR. THEN TRY TO GROUP THEM.
! 2. ROD_LABEL:
! ALFER THE REORDERING, IT SHOWS HOW THE VECTORS ARE REORDERED.
! 3. GRP_LABEL:
! THIS IS A VECTOR WHICH TELLS YOU WHICH GROUP DOES EACH VECTOR (WITH NEW
! ORDERING) BELONG.
! EX: (/1,1,1...,1/) MEANS THERE IS ONLY ONE GROUP, NO BLOCK DIAONAL.
! EX:(/1,1,1,2,2...2/) MENAS THERE ARE TWO GROUP. FIRST THREE IS GROUP 1
! AND THE OTHERS ARE GROUP 2.
! 4. ABOUT ZERO MATRIX ELEMENT
! BECAUSE WE NEED TO SET A VALVE FOR REAL NUMBER TO BE CONSIDER AS ZERO,
! WE SET A PAREMETER VAL_FLITER=10**(-6) AND ANY INPUT MATRIX WILL BE
! "CLEANED" FOR ABSOLUTE VALUES SMALLER THAN THIS. CHANGE IT IF YOU WANT. 
! HOWEVER, IN PRACTICAL USAGE, IT IS STRONGLY RECOMMEND TO DO IT OUTIDE
! THE SUBROUTINE. THE VAL_FLITER IS SET FOR GENERAL PURPOSE TO IDENFITY
! WHAT IS ZERO FOR REAL-TYPE. IF YOU WANT TO IGNORE SMALL VALUES OF YOUR
! CALCULATION RESULTS, USE PI_CLEAN_CMAT BEFORE PLUG IN. 

SUBROUTINE PI_BDIAG_CMAT(M_IN,M_IN_DIM,M_OUT,M_OUT_DIM,ROD_LABEL,ROD_LABEL_DIM,GRP_LABEL,GRP_LABEL_DIM)
	IMPLICIT NONE
	! DIMENSION
	INTEGER, INTENT(IN) :: M_IN_DIM(2), M_OUT_DIM(2), ROD_LABEL_DIM, GRP_LABEL_DIM
	! INPUT
	COMPLEX, INTENT(IN) :: M_IN(M_IN_DIM(1),M_IN_DIM(2))
	! OUTPUT
	COMPLEX, INTENT(OUT) :: M_OUT(M_OUT_DIM(1),M_OUT_DIM(2))
	INTEGER, INTENT(OUT) :: ROD_LABEL(ROD_LABEL_DIM)
	INTEGER, INTENT(OUT) :: GRP_LABEL(GRP_LABEL_DIM)
	! LOCAL(DUMMY)
	INTEGER :: N, M
	! LOCAL(VALUE)
	INTEGER :: TOT_VECT, TOT_COUNT
	REAL :: VAL_FLITER
	! LOCAL(ARRAY)
	INTEGER :: TOT_VECT_NZ(M_IN_DIM(1)), RO_RECORD(ROD_LABEL_DIM)
	REAL :: UNI_MAT(M_IN_DIM(1),M_IN_DIM(2))
	! LOCAL(ALLOCATABLE)
	INTEGER, ALLOCATABLE :: NZ_INDEX(:,:) 
	COMPLEX, ALLOCATABLE :: OFF_DIAG_U(:,:), OFF_DIAG_L(:,:)
	! VARIABLE INITIALIZATION
	M_OUT=0; ROD_LABEL=0; GRP_LABEL=0; ! OUTPUT
	VAL_FLITER=0; TOT_COUNT=0; VAL_FLITER=(10.0)**(-6.0)  ! LOCAL(VALUE)
	TOT_VECT_NZ=0; RO_RECORD=1; UNI_MAT=0.0 ! LOCAL(ARRAY)
	
	! START PROGRAM ----------------
	
	! CHECK INPUT VARIABLES
	IF (M_IN_DIM(1) /= M_IN_DIM(2)) THEN
		WRITE(*,*) "ERROR IN PI_BDIAG_RMAT! 'M_IN' MUST BE A SQUARE MATRIX!"
	END IF
	! CLEAN INPUT MATRIX
	CALL PI_CLEAN_CMAT(M_IN,SHAPE(M_IN),VAL_FLITER)
	
	! GENERATES ALL VARIABLES
	TOT_VECT=M_IN_DIM(1)
	DO N=1,TOT_VECT-1
		TOT_VECT_NZ(N)=COUNT(ABS(M_IN(:,N))>VAL_FLITER)
	END DO

	! FIND ALL COUPLED VECTORS
	ALLOCATE(NZ_INDEX(MAXVAL(TOT_VECT_NZ),TOT_VECT)); NZ_INDEX=0
    
	DO N=1,TOT_VECT
		CALL PI_FIND_VECT(ABS(M_IN(:,N))>VAL_FLITER,SHAPE(M_IN(:,N))&
		&,NZ_INDEX(:,N),SHAPE(NZ_INDEX(:,N)))
	END DO
	
	! REORDER ALL VECTORS
	TOT_COUNT=0
	DO N=1,TOT_VECT
		DO M=1,MAXVAL(TOT_VECT_NZ)
			IF (NZ_INDEX(M,N)/=0) THEN
				IF (RO_RECORD(NZ_INDEX(M,N))/=0) THEN
					TOT_COUNT=TOT_COUNT+1
					ROD_LABEL(TOT_COUNT)=NZ_INDEX(M,N)
					RO_RECORD(NZ_INDEX(M,N))=0
				END IF
			END IF
		END DO
	END DO
	
	! GENERATE UNITARY MATRIX
	DO N=1,TOT_VECT
		UNI_MAT(ROD_LABEL(N),N)=1.0
	END DO
	M_OUT= MATMUL(TRANSPOSE(UNI_MAT),MATMUL(M_IN,(UNI_MAT)))
	
	! CHECK IF ALL OFF DIAG-BLOCK ZERO. IF YES, THERE IS A GROUP!
	ALLOCATE(OFF_DIAG_U(1,1)); OFF_DIAG_U=0
	ALLOCATE(OFF_DIAG_L(1,1)); OFF_DIAG_L=0
	TOT_COUNT=1 ! COUNT TOTAL GROUP
	DO N=1,TOT_VECT
		GRP_LABEL(N)=TOT_COUNT
		IF (N/=TOT_VECT) THEN
			DEALLOCATE(OFF_DIAG_U)
			DEALLOCATE(OFF_DIAG_L)
			ALLOCATE(OFF_DIAG_U(N,TOT_VECT-N)); OFF_DIAG_U=0 
			ALLOCATE(OFF_DIAG_L(TOT_VECT-N,N)); OFF_DIAG_L=0
			OFF_DIAG_U=M_OUT(1:N,N+1:)
			OFF_DIAG_L=M_OUT(N+1:,1:N)
			
			IF (COUNT(ABS(OFF_DIAG_U) > VAL_FLITER) == 0 &
			& .AND. COUNT(ABS(OFF_DIAG_L) > VAL_FLITER) == 0) THEN
				TOT_COUNT=TOT_COUNT+1
			END IF				
		END IF
	END DO
END SUBROUTINE	







