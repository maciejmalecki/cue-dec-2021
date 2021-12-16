#import "common/lib/mem-global.asm"
#import "common/lib/invoke-global.asm"
#import "chipset/lib/mos6510-global.asm"
#import "chipset/lib/cia.asm"
#import "chipset/lib/vic2-global.asm"
#import "bomba-meta.asm"

.segmentdef Code [start=$0810]
.file [name="./demo.prg", segments="Code", modify="BasicUpstart", _start=$0810]
.segment Code

.label CHARSET_ADDR = $E000
.label SCREEN_ADDR = $C000

start:
    jsr configureC64
    jsr unpackData
    jsr configureVic2
    loop:
        jmp loop

    configureC64:
    sei
    .namespace c64lib {
        configureMemory(RAM_IO_RAM)
        disableNMI()
        disableCIAInterrupts()
    }
    cli
    rts

unpackData: {
    // charset
    c64lib_pushParamW(charset)
    c64lib_pushParamW(CHARSET_ADDR)
    c64lib_pushParamW(endCharset - charset)
    jsr copyLargeMemForward
    // color RAM
    c64lib_pushParamW(charsetColours)
    c64lib_pushParamW(c64lib. COLOR_RAM)
    c64lib_pushParamW(endCharsetColours - charsetColours)
    jsr copyLargeMemForward
    // screen colours
    c64lib_pushParamW(charsetScreenColours)
    c64lib_pushParamW(SCREEN_ADDR)
    c64lib_pushParamW(endCharsetScreenColours - charsetScreenColours)
    jsr copyLargeMemForward
    rts
}

configureVic2:
    lda #backgroundColour0
    sta c64lib.BORDER_COL
    sta c64lib.BG_COL_0
    .namespace c64lib {
        setVideoMode(MULTICOLOR_BITMAP_MODE)
        setVICBank(0)
        configureBitmapMemory(0, 1)
    }
    rts


copyLargeMemForward:
#import "common/lib/sub/copy-large-mem-forward.asm"

charset:
    .import binary "bomba-charset.bin"
endCharset:
charsetColours:
    .import binary "bomba-colours.bin"
endCharsetColours:
charsetScreenColours:
    .import binary "bomba-screen-colours.bin"
endCharsetScreenColours:
