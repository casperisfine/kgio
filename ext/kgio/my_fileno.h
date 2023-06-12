#include <ruby.h>
#ifdef HAVE_RUBY_IO_H
#  include <ruby/io.h>
#else
#  include <stdio.h>
#  include <rubyio.h>
#endif

#if ! HAVE_RB_IO_T
#  define rb_io_t OpenFile
#endif

#ifdef GetReadFile
#  define FPTR_TO_FD(fptr) (fileno(GetReadFile(fptr)))
#else
#  if !HAVE_RB_IO_T || (RUBY_VERSION_MAJOR == 1 && RUBY_VERSION_MINOR == 8)
#    define FPTR_TO_FD(fptr) fileno(fptr->f)
#  else
#    define FPTR_TO_FD(fptr) fptr->fd
#  endif
#endif

static int my_fileno(VALUE io)
{
#ifdef HAVE_RB_IO_DESCRIPTOR
	if (TYPE(io) != T_FILE)
		io = rb_convert_type(io, T_FILE, "IO", "to_io");

	return rb_io_descriptor(io);
#else
	rb_io_t *fptr;
	int fd;

	if (TYPE(io) != T_FILE)
		io = rb_convert_type(io, T_FILE, "IO", "to_io");
	GetOpenFile(io, fptr);
	fd = FPTR_TO_FD(fptr);

	if (fd < 0)
		rb_raise(rb_eIOError, "closed stream");
	return fd;
#endif
}
