SUBROUTINE ML_PRINT_CMAT( DESC, M, N, A, LDA )
  IMPLICIT NONE
  CHARACTER*(*)    DESC
  INTEGER          M, N, LDA
  COMPLEX          A( LDA, * )
  INTEGER          I, J
  
  WRITE(*,*)
  WRITE(*,*) DESC
  DO I = 1, M
      WRITE(*,9998) ( A( I, J ), J = 1, N )
  END DO

  9998 FORMAT( 11(:,1X,'(',F6.2,',',F6.2,')') )
  RETURN
END SUBROUTINE

! PRINT REAL MATRIX --------------------------------------------------------   
SUBROUTINE ML_PRINT_RMAT( DESC, M, N, A, LDA )
  IMPLICIT NONE
  CHARACTER*(*)    DESC
  INTEGER          M, N, LDA
  REAL             A( LDA, * )  
  INTEGER          I, J

  WRITE(*,*)
  WRITE(*,*) DESC
  DO I = 1, M
      WRITE(*,9998) ( A( I, J ), J = 1, N )
  END DO

  9998 FORMAT( 11(:,1X,F6.2) )
  RETURN
END SUBROUTINE
