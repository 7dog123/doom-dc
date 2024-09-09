TARGET = DCDoom.bin
FIRSTREAD = 1st_read.bin

include $(KOS_BASE)/Makefile.rules

OBJS1= \
	doomdef.o \
	doomstat.o \
	dstrings.o \
	dc_system.o \
	dc_sound.o \
	mus2mid.o \
	aica.o \
	dc_video.o \
	dc_net.o \
	dehacked.o \
	tables.o \
	f_finale.o \
	f_wipe.o \
	d_main.o \
	d_net.o \
	d_items.o \
	g_game.o

OBJS2= \
	m_menu.o \
	m_misc.o \
	m_argv.o \
	m_bbox.o \
	m_cheat.o \
	m_random.o \
	am_map.o \
	p_ceilng.o \
	p_doors.o \
	p_enemy.o \
	p_floor.o \
	p_inter.o \
	p_lights.o \
	p_map.o \
	p_maputl.o \
	p_plats.o \
	p_pspr.o \
	p_setup.o \
	p_sight.o \
	p_spec.o \
	p_switch.o \
	p_mobj.o \
	p_telept.o \
	p_tick.o \
	p_saveg.o \
	p_user.o

OBJS3 = \
	r_bsp.o \
	r_data.o \
	r_draw.o \
	r_main.o \
	r_plane.o \
	r_segs.o \
	r_sky.o \
	r_things.o \
	w_wad.o \
	wi_stuff.o \
	v_video.o \
	st_lib.o \
	st_stuff.o \
	hu_stuff.o \
	hu_lib.o \
	s_sound.o \
	z_zone.o \
	info.o \
	sounds.o \
	dc_main.o \
	dc_vmu.o \
	reqfile.o \
	danzeff/danzeff.o \
	danzeff/pspctrl_emu.o \
	m_fixed.o \
	m_swap.o \
	debug_dc.o

OBJS = $(OBJS1) $(OBJS2) $(OBJS3)

KOS_CFLAGS += -ffast-math -DNORMALUNIX -DUNROLL -Diabs=abs -fsigned-char
KOS_CFLAGS += -DDANZEFF_KOS
#KOS_CFLAGS += -I$(KOS_BASE)/../kos-ports/include/wildmidi

all: rm-elf $(TARGET)

clean:
	-rm -f $(TARGET) *.bin *.elf $(OBJS)

rm-elf:
	-rm -f $(TARGET) *.bin *.elf

DCDoom.elf: $(OBJS)
	$(KOS_CC) $(KOS_CFLAGS) $(KOS_LDFLAGS) -o DCDoom.elf $(KOS_START) \
		$(OBJS) -lWildMidi -lpng -lm -lz $(OBJEXTRA) $(KOS_LIBS)

DCDoom.bin: DCDoom.elf
	kos-objcopy -O binary -R .stack DCDoom.elf DCDoom.bin

# Create scrambled binary
$(FIRSTREAD): $(TARGET)
	$(KOS_CC_BASE)/../bin/scramble $(TARGET) $(FIRSTREAD)

# set this to your CDVD writer
CDRECORD_ID = /dev/cdrom

# Burn a bootable CD
selfboot: $(FIRSTREAD)
	mkisofs -G disc/ip.bin -l -J -R -o disc/session1.iso disc/data $(FIRSTREAD)
	dd if=disc/session1.iso bs=2048 count=17 of=disc/session2.iso
	dd if=/dev/zero bs=2048 count=283 >> disc/session2.iso
	cdrecord dev=$(CDRECORD_ID) speed=8 -multi -xa disc/session1.iso
	cdrecord dev=$(CDRECORD_ID) speed=8 -eject -xa disc/session2.iso
	rm disc/session?.iso
