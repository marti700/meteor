bbbuild3:
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -g main.s reset_handler.s -o mains.o
	arm-none-eabi-ld -T linker.ld mains.o -o main.elf
	arm-none-eabi-objcopy -O ihex main.elf main.hex

bbbbuild1:
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -g main1.s -o main1.o
	arm-none-eabi-ld -T linker.ld main1.o -o main1.elf
	arm-none-eabi-objcopy -O ihex main1.elf main1.hex

bbbbuild:
	arm-none-eabi-gcc -nostdlib -mthumb -mcpu=cortex-m4 -T linker.ld  main1.s reset_handler.s -o ff2.elf
	arm-none-eabi-objcopy -O ihex ff2.elf ff2.hex

compile:
	arm-none-eabi-gcc -nostdlib -mthumb -mcpu=cortex-m4 -T linker.ld  main.s reset_handler.s -o ./build/meteor.elf
	arm-none-eabi-objcopy -O ihex ./build/meteor.elf ./build/meteor.hex

clean:
	rm ./build/meteor.elf
	rm ./build/meteor.hex

clean3:
	rm main.elf
	rm main.hex
	rm mains.o

clean1:
	rm main1.elf
	rm main1.hex
	rm main1.o

aja:
	arm-none-eabi-gcc -nostdlib -mthumb -mcpu=cortex-m4 -T ./microbit/startup.ld ./microbit/*.c -o ./microbit/build/microbit.elf
