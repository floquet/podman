program cotest
  implicit none
  integer :: me[*]
  me = this_image()
  print *, "Hello from Coarray Fortran!"
  print *, "This is image", me, "of", num_images()
end program cotest
