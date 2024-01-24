#gcc flags:
# -c assemble but do not link
# -g include debug information
# -o output
# -s make stripped libray

# uncomment the last part in line 10 to specify current working
# directory as the default search path for shared objects

CFLAGS =-Wall -Werror #-Wl,-rpath,$(shell pwd) 
LIBS = -L. -lmy_shared


all: main.o libmy_static.a libmy_shared.so
	cc $(LIBS) -o my_app main.o libmy_static.a $(CFLAGS)

main.o: main.c
	cc -c main.c $(CFLAGS)

libmy_static.a: libmy_static_a.o libmy_static_b.o
	ar -rsv libmy_static.a libmy_static_a.o libmy_static_b.o

libmy_static_a.o: libmy_static_a.c
	cc -c libmy_static_a.c -o libmy_static_a.o $(CFLAGS)

libmy_static_b.o: libmy_static_b.c
	cc -c libmy_static_b.c -o libmy_static_b.o $(CFLAGS)

libmy_shared.so: libmy_shared.o
	cc -shared -o libmy_shared.so libmy_shared.o
libmy_shared.o: libmy_shared.c
	cc -c -fPIC libmy_shared.c -o libmy_shared.o
	

.PHONY: clean
clean:
	rm *.o

