!------------------------------------------------------------------------
!  grads_sfc
!
!       This subroutine reads the .tmp file and outputs the iscatter and
!       horizontal GrADS data files.
!------------------------------------------------------------------------

subroutine grads_sfc(fileo,ifileo,nobs,nreal,iscater,igrads,isubtype,subtype)

   implicit none
 
   integer ifileo 
   real(4),allocatable,dimension(:,:)  :: rdiag
   character(8),allocatable,dimension(:) :: cdiag
   character(8) :: stid
   character(ifileo) :: fileo
   character(30) :: files,filein,filegrads
   character(2) :: subtype
   integer nobs,nreal,nlfag,nflg0,nlev,nlev0,iscater,igrads
   real(4) rtim,xlat0,xlon0,rlat,rlon
 
   integer(4):: isubtype
   integer i,j,ii,ilat,ilon,ipres,itime,iweight,ndup

   rtim=0.0
   nflg0=0
   xlat0=0.0
   xlon0=0.0
   nlev0=0
   stid='        '
  
   print *, 'nobs=',nobs
   print *, 'fileo=',fileo

!   write(subtype,'(i2)') isubtype
   filein=trim(fileo)//'_'//trim(subtype)//'.tmp'

   allocate(rdiag(nreal,nobs),cdiag(nobs))
   open(11,file=filein,form='unformatted')
   rewind(11)

   do i=1,nobs
      read(11) cdiag(i),rdiag(1:nreal,i)
   enddo

   !-------------------------------
   !  write the scatter data file
   !
   if(iscater ==1) then 
      files=trim(fileo)//'_'//trim(subtype)//'.scater'
      open(51,file=files,form='unformatted')

      write(51) nobs,nreal
      write(51) rdiag

      close(51)
   endif


   !-------------------------------
   !  write the horiz data file
   !
   if (igrads ==1 .AND. nobs > 0) then 
      filegrads=trim(fileo)//'_'//trim(subtype)//'_grads'

      open(21,file=filegrads,form='unformatted',status='new')    ! open output file

      ilat=1                           ! the position of lat
      ilon=2                           ! the position of lon
      ipres=4                          ! the position of pressure
      itime=6                          ! the position of relative time
      iweight=11                       ! the position of weight 

      !------------------------------
      !  rm any duplicate data
      !
      call rm_dups( rdiag,nobs,nreal,ilat,ilon,ipres,itime,iweight,ndup )

      ii=0
      do  i=1,nobs

         if(rdiag(iweight,i) >0.0) then
            ii=ii+1
            stid=cdiag(i)
            rlat=rdiag(ilat,i)
            rlon=rdiag(ilon,i)
            write(21) stid,rlat,rlon,rtim,1,1

            !  really not sure of this j=3,nreal write
            write(21) (rdiag(j,i),j=3,nreal)
         endif
      enddo

      print *, 'ii=',ii
  
      !------------------------------ 
      !  the end of file marker
      !
      stid='        '
      write(21) stid,xlat0,xlon0,rtim,nlev0,nflg0 
 
      close(21)
      close(11)
   else
      write(6,*) "No output file generated, nobs, igrads = ", nobs, igrads
   endif

   deallocate(rdiag,cdiag)
   return 
end


  
