AS = as
LD = ld

OBJS = main.o read.o display.o execute.o concat.o end.o not_found.o

shell: $(OBJS)
	$(LD) -o $@ $(OBJS) $(LDFLAGS)

%.o: %.s
	$(AS) -o $@ $< $(ASFLAGS)

clean:
	rm -f $(OBJS) shell
