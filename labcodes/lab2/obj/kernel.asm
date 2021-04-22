
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 14 5c 00 00       	call   c0105c76 <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 5e 10 c0 	movl   $0xc0105e00,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c 5e 10 c0 	movl   $0xc0105e1c,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 e0 42 00 00       	call   c0104370 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 bb 16 00 00       	call   c0101750 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 0d 18 00 00       	call   c01018a7 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 fe 0c 00 00       	call   c0100d9d <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 1a 16 00 00       	call   c01016be <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 f6 0b 00 00       	call   c0100cbe <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 21 5e 10 c0 	movl   $0xc0105e21,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 2f 5e 10 c0 	movl   $0xc0105e2f,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 3d 5e 10 c0 	movl   $0xc0105e3d,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 4b 5e 10 c0 	movl   $0xc0105e4b,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 59 5e 10 c0 	movl   $0xc0105e59,(%esp)
c01001e8:	e8 5b 01 00 00       	call   c0100348 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100204:	5d                   	pop    %ebp
c0100205:	c3                   	ret    

c0100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100206:	55                   	push   %ebp
c0100207:	89 e5                	mov    %esp,%ebp
c0100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020c:	e8 25 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100211:	c7 04 24 68 5e 10 c0 	movl   $0xc0105e68,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 88 5e 10 c0 	movl   $0xc0105e88,(%esp)
c010022e:	e8 15 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_kernel();
c0100233:	e8 c9 ff ff ff       	call   c0100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100238:	e8 f9 fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c010023d:	c9                   	leave  
c010023e:	c3                   	ret    

c010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010023f:	55                   	push   %ebp
c0100240:	89 e5                	mov    %esp,%ebp
c0100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100249:	74 13                	je     c010025e <readline+0x1f>
        cprintf("%s", prompt);
c010024b:	8b 45 08             	mov    0x8(%ebp),%eax
c010024e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100252:	c7 04 24 a7 5e 10 c0 	movl   $0xc0105ea7,(%esp)
c0100259:	e8 ea 00 00 00       	call   c0100348 <cprintf>
    }
    int i = 0, c;
c010025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100265:	e8 66 01 00 00       	call   c01003d0 <getchar>
c010026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100271:	79 07                	jns    c010027a <readline+0x3b>
            return NULL;
c0100273:	b8 00 00 00 00       	mov    $0x0,%eax
c0100278:	eb 79                	jmp    c01002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027e:	7e 28                	jle    c01002a8 <readline+0x69>
c0100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100287:	7f 1f                	jg     c01002a8 <readline+0x69>
            cputchar(c);
c0100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028c:	89 04 24             	mov    %eax,(%esp)
c010028f:	e8 da 00 00 00       	call   c010036e <cputchar>
            buf[i ++] = c;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100297:	8d 50 01             	lea    0x1(%eax),%edx
c010029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a0:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002a6:	eb 46                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ac:	75 17                	jne    c01002c5 <readline+0x86>
c01002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b2:	7e 11                	jle    c01002c5 <readline+0x86>
            cputchar(c);
c01002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af 00 00 00       	call   c010036e <cputchar>
            i --;
c01002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c3:	eb 29                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002c9:	74 06                	je     c01002d1 <readline+0x92>
c01002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002cf:	75 1d                	jne    c01002ee <readline+0xaf>
            cputchar(c);
c01002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d4:	89 04 24             	mov    %eax,(%esp)
c01002d7:	e8 92 00 00 00       	call   c010036e <cputchar>
            buf[i] = '\0';
c01002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002df:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e7:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002ec:	eb 05                	jmp    c01002f3 <readline+0xb4>
        }
    }
c01002ee:	e9 72 ff ff ff       	jmp    c0100265 <readline+0x26>
}
c01002f3:	c9                   	leave  
c01002f4:	c3                   	ret    

c01002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002f5:	55                   	push   %ebp
c01002f6:	89 e5                	mov    %esp,%ebp
c01002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fe:	89 04 24             	mov    %eax,(%esp)
c0100301:	e8 0d 13 00 00       	call   c0101613 <cons_putc>
    (*cnt) ++;
c0100306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100309:	8b 00                	mov    (%eax),%eax
c010030b:	8d 50 01             	lea    0x1(%eax),%edx
c010030e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100311:	89 10                	mov    %edx,(%eax)
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100329:	8b 45 08             	mov    0x8(%ebp),%eax
c010032c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100333:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100337:	c7 04 24 f5 02 10 c0 	movl   $0xc01002f5,(%esp)
c010033e:	e8 4c 51 00 00       	call   c010548f <vprintfmt>
    return cnt;
c0100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100346:	c9                   	leave  
c0100347:	c3                   	ret    

c0100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100348:	55                   	push   %ebp
c0100349:	89 e5                	mov    %esp,%ebp
c010034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100357:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035b:	8b 45 08             	mov    0x8(%ebp),%eax
c010035e:	89 04 24             	mov    %eax,(%esp)
c0100361:	e8 af ff ff ff       	call   c0100315 <vcprintf>
c0100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036c:	c9                   	leave  
c010036d:	c3                   	ret    

c010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036e:	55                   	push   %ebp
c010036f:	89 e5                	mov    %esp,%ebp
c0100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100374:	8b 45 08             	mov    0x8(%ebp),%eax
c0100377:	89 04 24             	mov    %eax,(%esp)
c010037a:	e8 94 12 00 00       	call   c0101613 <cons_putc>
}
c010037f:	c9                   	leave  
c0100380:	c3                   	ret    

c0100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100381:	55                   	push   %ebp
c0100382:	89 e5                	mov    %esp,%ebp
c0100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010038e:	eb 13                	jmp    c01003a3 <cputs+0x22>
        cputch(c, &cnt);
c0100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100397:	89 54 24 04          	mov    %edx,0x4(%esp)
c010039b:	89 04 24             	mov    %eax,(%esp)
c010039e:	e8 52 ff ff ff       	call   c01002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a6:	8d 50 01             	lea    0x1(%eax),%edx
c01003a9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ac:	0f b6 00             	movzbl (%eax),%eax
c01003af:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003b6:	75 d8                	jne    c0100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003c6:	e8 2a ff ff ff       	call   c01002f5 <cputch>
    return cnt;
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003ce:	c9                   	leave  
c01003cf:	c3                   	ret    

c01003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003d0:	55                   	push   %ebp
c01003d1:	89 e5                	mov    %esp,%ebp
c01003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d6:	e8 74 12 00 00       	call   c010164f <cons_getc>
c01003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e2:	74 f2                	je     c01003d6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f2:	8b 00                	mov    (%eax),%eax
c01003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01003fa:	8b 00                	mov    (%eax),%eax
c01003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100406:	e9 d2 00 00 00       	jmp    c01004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100411:	01 d0                	add    %edx,%eax
c0100413:	89 c2                	mov    %eax,%edx
c0100415:	c1 ea 1f             	shr    $0x1f,%edx
c0100418:	01 d0                	add    %edx,%eax
c010041a:	d1 f8                	sar    %eax
c010041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100425:	eb 04                	jmp    c010042b <stab_binsearch+0x42>
            m --;
c0100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100431:	7c 1f                	jl     c0100452 <stab_binsearch+0x69>
c0100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100436:	89 d0                	mov    %edx,%eax
c0100438:	01 c0                	add    %eax,%eax
c010043a:	01 d0                	add    %edx,%eax
c010043c:	c1 e0 02             	shl    $0x2,%eax
c010043f:	89 c2                	mov    %eax,%edx
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	01 d0                	add    %edx,%eax
c0100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010044a:	0f b6 c0             	movzbl %al,%eax
c010044d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100450:	75 d5                	jne    c0100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100458:	7d 0b                	jge    c0100465 <stab_binsearch+0x7c>
            l = true_m + 1;
c010045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045d:	83 c0 01             	add    $0x1,%eax
c0100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100463:	eb 78                	jmp    c01004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046f:	89 d0                	mov    %edx,%eax
c0100471:	01 c0                	add    %eax,%eax
c0100473:	01 d0                	add    %edx,%eax
c0100475:	c1 e0 02             	shl    $0x2,%eax
c0100478:	89 c2                	mov    %eax,%edx
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	01 d0                	add    %edx,%eax
c010047f:	8b 40 08             	mov    0x8(%eax),%eax
c0100482:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100485:	73 13                	jae    c010049a <stab_binsearch+0xb1>
            *region_left = m;
c0100487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100492:	83 c0 01             	add    $0x1,%eax
c0100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100498:	eb 43                	jmp    c01004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 d0                	mov    %edx,%eax
c010049f:	01 c0                	add    %eax,%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	c1 e0 02             	shl    $0x2,%eax
c01004a6:	89 c2                	mov    %eax,%edx
c01004a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ab:	01 d0                	add    %edx,%eax
c01004ad:	8b 40 08             	mov    0x8(%eax),%eax
c01004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004b3:	76 16                	jbe    c01004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	83 e8 01             	sub    $0x1,%eax
c01004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c9:	eb 12                	jmp    c01004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e3:	0f 8e 22 ff ff ff    	jle    c010040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ed:	75 0f                	jne    c01004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f2:	8b 00                	mov    (%eax),%eax
c01004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004fa:	89 10                	mov    %edx,(%eax)
c01004fc:	eb 3f                	jmp    c010053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100506:	eb 04                	jmp    c010050c <stab_binsearch+0x123>
c0100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010050c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050f:	8b 00                	mov    (%eax),%eax
c0100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100514:	7d 1f                	jge    c0100535 <stab_binsearch+0x14c>
c0100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100519:	89 d0                	mov    %edx,%eax
c010051b:	01 c0                	add    %eax,%eax
c010051d:	01 d0                	add    %edx,%eax
c010051f:	c1 e0 02             	shl    $0x2,%eax
c0100522:	89 c2                	mov    %eax,%edx
c0100524:	8b 45 08             	mov    0x8(%ebp),%eax
c0100527:	01 d0                	add    %edx,%eax
c0100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052d:	0f b6 c0             	movzbl %al,%eax
c0100530:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100533:	75 d3                	jne    c0100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053b:	89 10                	mov    %edx,(%eax)
    }
}
c010053d:	c9                   	leave  
c010053e:	c3                   	ret    

c010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010053f:	55                   	push   %ebp
c0100540:	89 e5                	mov    %esp,%ebp
c0100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	c7 00 ac 5e 10 c0    	movl   $0xc0105eac,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 ac 5e 10 c0 	movl   $0xc0105eac,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010056c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100575:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010057f:	c7 45 f4 58 71 10 c0 	movl   $0xc0107158,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 e4 1a 11 c0 	movl   $0xc0111ae4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec e5 1a 11 c0 	movl   $0xc0111ae5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 fc 44 11 c0 	movl   $0xc01144fc,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005a1:	76 0d                	jbe    c01005b0 <debuginfo_eip+0x71>
c01005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a6:	83 e8 01             	sub    $0x1,%eax
c01005a9:	0f b6 00             	movzbl (%eax),%eax
c01005ac:	84 c0                	test   %al,%al
c01005ae:	74 0a                	je     c01005ba <debuginfo_eip+0x7b>
        return -1;
c01005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005b5:	e9 c0 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c7:	29 c2                	sub    %eax,%edx
c01005c9:	89 d0                	mov    %edx,%eax
c01005cb:	c1 f8 02             	sar    $0x2,%eax
c01005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005d4:	83 e8 01             	sub    $0x1,%eax
c01005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005da:	8b 45 08             	mov    0x8(%ebp),%eax
c01005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005e8:	00 
c01005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005fa:	89 04 24             	mov    %eax,(%esp)
c01005fd:	e8 e7 fd ff ff       	call   c01003e9 <stab_binsearch>
    if (lfile == 0)
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	85 c0                	test   %eax,%eax
c0100607:	75 0a                	jne    c0100613 <debuginfo_eip+0xd4>
        return -1;
c0100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060e:	e9 67 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010061f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100622:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010062d:	00 
c010062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100631:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100638:	89 44 24 04          	mov    %eax,0x4(%esp)
c010063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063f:	89 04 24             	mov    %eax,(%esp)
c0100642:	e8 a2 fd ff ff       	call   c01003e9 <stab_binsearch>

    if (lfun <= rfun) {
c0100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010064d:	39 c2                	cmp    %eax,%edx
c010064f:	7f 7c                	jg     c01006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100654:	89 c2                	mov    %eax,%edx
c0100656:	89 d0                	mov    %edx,%eax
c0100658:	01 c0                	add    %eax,%eax
c010065a:	01 d0                	add    %edx,%eax
c010065c:	c1 e0 02             	shl    $0x2,%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	8b 10                	mov    (%eax),%edx
c0100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066e:	29 c1                	sub    %eax,%ecx
c0100670:	89 c8                	mov    %ecx,%eax
c0100672:	39 c2                	cmp    %eax,%edx
c0100674:	73 22                	jae    c0100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100679:	89 c2                	mov    %eax,%edx
c010067b:	89 d0                	mov    %edx,%eax
c010067d:	01 c0                	add    %eax,%eax
c010067f:	01 d0                	add    %edx,%eax
c0100681:	c1 e0 02             	shl    $0x2,%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100689:	01 d0                	add    %edx,%eax
c010068b:	8b 10                	mov    (%eax),%edx
c010068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100690:	01 c2                	add    %eax,%edx
c0100692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010069b:	89 c2                	mov    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	01 c0                	add    %eax,%eax
c01006a1:	01 d0                	add    %edx,%eax
c01006a3:	c1 e0 02             	shl    $0x2,%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ab:	01 d0                	add    %edx,%eax
c01006ad:	8b 50 08             	mov    0x8(%eax),%edx
c01006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	8b 40 10             	mov    0x10(%eax),%eax
c01006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006cb:	eb 15                	jmp    c01006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 40 08             	mov    0x8(%eax),%eax
c01006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ef:	00 
c01006f0:	89 04 24             	mov    %eax,(%esp)
c01006f3:	e8 f2 53 00 00       	call   c0105aea <strfind>
c01006f8:	89 c2                	mov    %eax,%edx
c01006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100700:	29 c2                	sub    %eax,%edx
c0100702:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100708:	8b 45 08             	mov    0x8(%ebp),%eax
c010070b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100716:	00 
c0100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010071a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100728:	89 04 24             	mov    %eax,(%esp)
c010072b:	e8 b9 fc ff ff       	call   c01003e9 <stab_binsearch>
    if (lline <= rline) {
c0100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100736:	39 c2                	cmp    %eax,%edx
c0100738:	7f 24                	jg     c010075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073d:	89 c2                	mov    %eax,%edx
c010073f:	89 d0                	mov    %edx,%eax
c0100741:	01 c0                	add    %eax,%eax
c0100743:	01 d0                	add    %edx,%eax
c0100745:	c1 e0 02             	shl    $0x2,%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074d:	01 d0                	add    %edx,%eax
c010074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100753:	0f b7 d0             	movzwl %ax,%edx
c0100756:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010075c:	eb 13                	jmp    c0100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100763:	e9 12 01 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076b:	83 e8 01             	sub    $0x1,%eax
c010076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100777:	39 c2                	cmp    %eax,%edx
c0100779:	7c 56                	jl     c01007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	89 d0                	mov    %edx,%eax
c0100782:	01 c0                	add    %eax,%eax
c0100784:	01 d0                	add    %edx,%eax
c0100786:	c1 e0 02             	shl    $0x2,%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100794:	3c 84                	cmp    $0x84,%al
c0100796:	74 39                	je     c01007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	89 d0                	mov    %edx,%eax
c010079f:	01 c0                	add    %eax,%eax
c01007a1:	01 d0                	add    %edx,%eax
c01007a3:	c1 e0 02             	shl    $0x2,%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ab:	01 d0                	add    %edx,%eax
c01007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b1:	3c 64                	cmp    $0x64,%al
c01007b3:	75 b3                	jne    c0100768 <debuginfo_eip+0x229>
c01007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	89 d0                	mov    %edx,%eax
c01007bc:	01 c0                	add    %eax,%eax
c01007be:	01 d0                	add    %edx,%eax
c01007c0:	c1 e0 02             	shl    $0x2,%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c8:	01 d0                	add    %edx,%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	85 c0                	test   %eax,%eax
c01007cf:	74 97                	je     c0100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007d7:	39 c2                	cmp    %eax,%edx
c01007d9:	7c 46                	jl     c0100821 <debuginfo_eip+0x2e2>
c01007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	89 d0                	mov    %edx,%eax
c01007e2:	01 c0                	add    %eax,%eax
c01007e4:	01 d0                	add    %edx,%eax
c01007e6:	c1 e0 02             	shl    $0x2,%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ee:	01 d0                	add    %edx,%eax
c01007f0:	8b 10                	mov    (%eax),%edx
c01007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007f8:	29 c1                	sub    %eax,%ecx
c01007fa:	89 c8                	mov    %ecx,%eax
c01007fc:	39 c2                	cmp    %eax,%edx
c01007fe:	73 21                	jae    c0100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	89 d0                	mov    %edx,%eax
c0100807:	01 c0                	add    %eax,%eax
c0100809:	01 d0                	add    %edx,%eax
c010080b:	c1 e0 02             	shl    $0x2,%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	01 d0                	add    %edx,%eax
c0100815:	8b 10                	mov    (%eax),%edx
c0100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010081a:	01 c2                	add    %eax,%edx
c010081c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100827:	39 c2                	cmp    %eax,%edx
c0100829:	7d 4a                	jge    c0100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082e:	83 c0 01             	add    $0x1,%eax
c0100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100834:	eb 18                	jmp    c010084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100836:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100839:	8b 40 14             	mov    0x14(%eax),%eax
c010083c:	8d 50 01             	lea    0x1(%eax),%edx
c010083f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100848:	83 c0 01             	add    $0x1,%eax
c010084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100854:	39 c2                	cmp    %eax,%edx
c0100856:	7d 1d                	jge    c0100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c a0                	cmp    $0xa0,%al
c0100873:	74 c1                	je     c0100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010087a:	c9                   	leave  
c010087b:	c3                   	ret    

c010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010087c:	55                   	push   %ebp
c010087d:	89 e5                	mov    %esp,%ebp
c010087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100882:	c7 04 24 b6 5e 10 c0 	movl   $0xc0105eb6,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 cf 5e 10 c0 	movl   $0xc0105ecf,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 ff 5d 10 	movl   $0xc0105dff,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 e7 5e 10 c0 	movl   $0xc0105ee7,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 ff 5e 10 c0 	movl   $0xc0105eff,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 17 5f 10 c0 	movl   $0xc0105f17,(%esp)
c01008d9:	e8 6a fa ff ff       	call   c0100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008de:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008ee:	29 c2                	sub    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	85 c0                	test   %eax,%eax
c01008fa:	0f 48 c2             	cmovs  %edx,%eax
c01008fd:	c1 f8 0a             	sar    $0xa,%eax
c0100900:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100904:	c7 04 24 30 5f 10 c0 	movl   $0xc0105f30,(%esp)
c010090b:	e8 38 fa ff ff       	call   c0100348 <cprintf>
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010091e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100922:	8b 45 08             	mov    0x8(%ebp),%eax
c0100925:	89 04 24             	mov    %eax,(%esp)
c0100928:	e8 12 fc ff ff       	call   c010053f <debuginfo_eip>
c010092d:	85 c0                	test   %eax,%eax
c010092f:	74 15                	je     c0100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100938:	c7 04 24 5a 5f 10 c0 	movl   $0xc0105f5a,(%esp)
c010093f:	e8 04 fa ff ff       	call   c0100348 <cprintf>
c0100944:	eb 6d                	jmp    c01009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010094d:	eb 1c                	jmp    c010096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100955:	01 d0                	add    %edx,%eax
c0100957:	0f b6 00             	movzbl (%eax),%eax
c010095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100963:	01 ca                	add    %ecx,%edx
c0100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100971:	7f dc                	jg     c010094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097c:	01 d0                	add    %edx,%eax
c010097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100984:	8b 55 08             	mov    0x8(%ebp),%edx
c0100987:	89 d1                	mov    %edx,%ecx
c0100989:	29 c1                	sub    %eax,%ecx
c010098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010099f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a7:	c7 04 24 76 5f 10 c0 	movl   $0xc0105f76,(%esp)
c01009ae:	e8 95 f9 ff ff       	call   c0100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009b3:	c9                   	leave  
c01009b4:	c3                   	ret    

c01009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b5:	55                   	push   %ebp
c01009b6:	89 e5                	mov    %esp,%ebp
c01009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009bb:	8b 45 04             	mov    0x4(%ebp),%eax
c01009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c4:	c9                   	leave  
c01009c5:	c3                   	ret    

c01009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c6:	55                   	push   %ebp
c01009c7:	89 e5                	mov    %esp,%ebp
c01009c9:	53                   	push   %ebx
c01009ca:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cd:	89 e8                	mov    %ebp,%eax
c01009cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */

    uint32_t ebp = read_ebp();
c01009d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c01009d8:	e8 d8 ff ff ff       	call   c01009b5 <read_eip>
c01009dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    for(i = 0;ebp != 0&&i < STACKFRAME_DEPTH;i++) {
c01009e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e7:	e9 81 00 00 00       	jmp    c0100a6d <print_stackframe+0xa7>
        // 参数位置定位
        uint32_t *arguments = (uint32_t*)ebp + 2;
c01009ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ef:	83 c0 08             	add    $0x8,%eax
c01009f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // 显示传入的参数
        cprintf("ebp:0x%08x eip:0x%08x args:0x%08x 0x%08x 0x%08x 0x%08x",ebp,eip,arguments[0],arguments[1],arguments[2],arguments[3]);
c01009f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01009f8:	83 c0 0c             	add    $0xc,%eax
c01009fb:	8b 18                	mov    (%eax),%ebx
c01009fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a00:	83 c0 08             	add    $0x8,%eax
c0100a03:	8b 08                	mov    (%eax),%ecx
c0100a05:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a08:	83 c0 04             	add    $0x4,%eax
c0100a0b:	8b 10                	mov    (%eax),%edx
c0100a0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a10:	8b 00                	mov    (%eax),%eax
c0100a12:	89 5c 24 18          	mov    %ebx,0x18(%esp)
c0100a16:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0100a1a:	89 54 24 10          	mov    %edx,0x10(%esp)
c0100a1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a25:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a30:	c7 04 24 88 5f 10 c0 	movl   $0xc0105f88,(%esp)
c0100a37:	e8 0c f9 ff ff       	call   c0100348 <cprintf>
        cprintf("\n");
c0100a3c:	c7 04 24 bf 5f 10 c0 	movl   $0xc0105fbf,(%esp)
c0100a43:	e8 00 f9 ff ff       	call   c0100348 <cprintf>
        print_debuginfo(eip - 1);
c0100a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a4b:	83 e8 01             	sub    $0x1,%eax
c0100a4e:	89 04 24             	mov    %eax,(%esp)
c0100a51:	e8 bc fe ff ff       	call   c0100912 <print_debuginfo>
        // 寻找上一个调用者栈低位置，即模拟函数返回的过程
        eip = ((uint32_t*)ebp)[1];
c0100a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a59:	83 c0 04             	add    $0x4,%eax
c0100a5c:	8b 00                	mov    (%eax),%eax
c0100a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t*)ebp)[0];
c0100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a64:	8b 00                	mov    (%eax),%eax
c0100a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
      */

    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    int i;
    for(i = 0;ebp != 0&&i < STACKFRAME_DEPTH;i++) {
c0100a69:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a71:	74 0a                	je     c0100a7d <print_stackframe+0xb7>
c0100a73:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a77:	0f 8e 6f ff ff ff    	jle    c01009ec <print_stackframe+0x26>
        // 寻找上一个调用者栈低位置，即模拟函数返回的过程
        eip = ((uint32_t*)ebp)[1];
        ebp = ((uint32_t*)ebp)[0];
    }

}
c0100a7d:	83 c4 44             	add    $0x44,%esp
c0100a80:	5b                   	pop    %ebx
c0100a81:	5d                   	pop    %ebp
c0100a82:	c3                   	ret    

c0100a83 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a90:	eb 0c                	jmp    c0100a9e <parse+0x1b>
            *buf ++ = '\0';
c0100a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a95:	8d 50 01             	lea    0x1(%eax),%edx
c0100a98:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9b:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa1:	0f b6 00             	movzbl (%eax),%eax
c0100aa4:	84 c0                	test   %al,%al
c0100aa6:	74 1d                	je     c0100ac5 <parse+0x42>
c0100aa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aab:	0f b6 00             	movzbl (%eax),%eax
c0100aae:	0f be c0             	movsbl %al,%eax
c0100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab5:	c7 04 24 44 60 10 c0 	movl   $0xc0106044,(%esp)
c0100abc:	e8 f6 4f 00 00       	call   c0105ab7 <strchr>
c0100ac1:	85 c0                	test   %eax,%eax
c0100ac3:	75 cd                	jne    c0100a92 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac8:	0f b6 00             	movzbl (%eax),%eax
c0100acb:	84 c0                	test   %al,%al
c0100acd:	75 02                	jne    c0100ad1 <parse+0x4e>
            break;
c0100acf:	eb 67                	jmp    c0100b38 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ad1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad5:	75 14                	jne    c0100aeb <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ade:	00 
c0100adf:	c7 04 24 49 60 10 c0 	movl   $0xc0106049,(%esp)
c0100ae6:	e8 5d f8 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aee:	8d 50 01             	lea    0x1(%eax),%edx
c0100af1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100afb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100afe:	01 c2                	add    %eax,%edx
c0100b00:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b03:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b05:	eb 04                	jmp    c0100b0b <parse+0x88>
            buf ++;
c0100b07:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0e:	0f b6 00             	movzbl (%eax),%eax
c0100b11:	84 c0                	test   %al,%al
c0100b13:	74 1d                	je     c0100b32 <parse+0xaf>
c0100b15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b18:	0f b6 00             	movzbl (%eax),%eax
c0100b1b:	0f be c0             	movsbl %al,%eax
c0100b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b22:	c7 04 24 44 60 10 c0 	movl   $0xc0106044,(%esp)
c0100b29:	e8 89 4f 00 00       	call   c0105ab7 <strchr>
c0100b2e:	85 c0                	test   %eax,%eax
c0100b30:	74 d5                	je     c0100b07 <parse+0x84>
            buf ++;
        }
    }
c0100b32:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b33:	e9 66 ff ff ff       	jmp    c0100a9e <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b3b:	c9                   	leave  
c0100b3c:	c3                   	ret    

c0100b3d <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3d:	55                   	push   %ebp
c0100b3e:	89 e5                	mov    %esp,%ebp
c0100b40:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b43:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4d:	89 04 24             	mov    %eax,(%esp)
c0100b50:	e8 2e ff ff ff       	call   c0100a83 <parse>
c0100b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5c:	75 0a                	jne    c0100b68 <runcmd+0x2b>
        return 0;
c0100b5e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b63:	e9 85 00 00 00       	jmp    c0100bed <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b6f:	eb 5c                	jmp    c0100bcd <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b71:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b77:	89 d0                	mov    %edx,%eax
c0100b79:	01 c0                	add    %eax,%eax
c0100b7b:	01 d0                	add    %edx,%eax
c0100b7d:	c1 e0 02             	shl    $0x2,%eax
c0100b80:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100b85:	8b 00                	mov    (%eax),%eax
c0100b87:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b8b:	89 04 24             	mov    %eax,(%esp)
c0100b8e:	e8 85 4e 00 00       	call   c0105a18 <strcmp>
c0100b93:	85 c0                	test   %eax,%eax
c0100b95:	75 32                	jne    c0100bc9 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9a:	89 d0                	mov    %edx,%eax
c0100b9c:	01 c0                	add    %eax,%eax
c0100b9e:	01 d0                	add    %edx,%eax
c0100ba0:	c1 e0 02             	shl    $0x2,%eax
c0100ba3:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100ba8:	8b 40 08             	mov    0x8(%eax),%eax
c0100bab:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bae:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bb4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bb8:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bbb:	83 c2 04             	add    $0x4,%edx
c0100bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc2:	89 0c 24             	mov    %ecx,(%esp)
c0100bc5:	ff d0                	call   *%eax
c0100bc7:	eb 24                	jmp    c0100bed <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd0:	83 f8 02             	cmp    $0x2,%eax
c0100bd3:	76 9c                	jbe    c0100b71 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdc:	c7 04 24 67 60 10 c0 	movl   $0xc0106067,(%esp)
c0100be3:	e8 60 f7 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bed:	c9                   	leave  
c0100bee:	c3                   	ret    

c0100bef <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bef:	55                   	push   %ebp
c0100bf0:	89 e5                	mov    %esp,%ebp
c0100bf2:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bf5:	c7 04 24 80 60 10 c0 	movl   $0xc0106080,(%esp)
c0100bfc:	e8 47 f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c01:	c7 04 24 a8 60 10 c0 	movl   $0xc01060a8,(%esp)
c0100c08:	e8 3b f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100c0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c11:	74 0b                	je     c0100c1e <kmonitor+0x2f>
        print_trapframe(tf);
c0100c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c16:	89 04 24             	mov    %eax,(%esp)
c0100c19:	e8 40 0e 00 00       	call   c0101a5e <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c1e:	c7 04 24 cd 60 10 c0 	movl   $0xc01060cd,(%esp)
c0100c25:	e8 15 f6 ff ff       	call   c010023f <readline>
c0100c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c31:	74 18                	je     c0100c4b <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c33:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3d:	89 04 24             	mov    %eax,(%esp)
c0100c40:	e8 f8 fe ff ff       	call   c0100b3d <runcmd>
c0100c45:	85 c0                	test   %eax,%eax
c0100c47:	79 02                	jns    c0100c4b <kmonitor+0x5c>
                break;
c0100c49:	eb 02                	jmp    c0100c4d <kmonitor+0x5e>
            }
        }
    }
c0100c4b:	eb d1                	jmp    c0100c1e <kmonitor+0x2f>
}
c0100c4d:	c9                   	leave  
c0100c4e:	c3                   	ret    

c0100c4f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c4f:	55                   	push   %ebp
c0100c50:	89 e5                	mov    %esp,%ebp
c0100c52:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5c:	eb 3f                	jmp    c0100c9d <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c61:	89 d0                	mov    %edx,%eax
c0100c63:	01 c0                	add    %eax,%eax
c0100c65:	01 d0                	add    %edx,%eax
c0100c67:	c1 e0 02             	shl    $0x2,%eax
c0100c6a:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c6f:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c75:	89 d0                	mov    %edx,%eax
c0100c77:	01 c0                	add    %eax,%eax
c0100c79:	01 d0                	add    %edx,%eax
c0100c7b:	c1 e0 02             	shl    $0x2,%eax
c0100c7e:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c83:	8b 00                	mov    (%eax),%eax
c0100c85:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8d:	c7 04 24 d1 60 10 c0 	movl   $0xc01060d1,(%esp)
c0100c94:	e8 af f6 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca0:	83 f8 02             	cmp    $0x2,%eax
c0100ca3:	76 b9                	jbe    c0100c5e <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100caa:	c9                   	leave  
c0100cab:	c3                   	ret    

c0100cac <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cac:	55                   	push   %ebp
c0100cad:	89 e5                	mov    %esp,%ebp
c0100caf:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb2:	e8 c5 fb ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbc:	c9                   	leave  
c0100cbd:	c3                   	ret    

c0100cbe <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cbe:	55                   	push   %ebp
c0100cbf:	89 e5                	mov    %esp,%ebp
c0100cc1:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc4:	e8 fd fc ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cce:	c9                   	leave  
c0100ccf:	c3                   	ret    

c0100cd0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd0:	55                   	push   %ebp
c0100cd1:	89 e5                	mov    %esp,%ebp
c0100cd3:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd6:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100cdb:	85 c0                	test   %eax,%eax
c0100cdd:	74 02                	je     c0100ce1 <__panic+0x11>
        goto panic_dead;
c0100cdf:	eb 59                	jmp    c0100d3a <__panic+0x6a>
    }
    is_panic = 1;
c0100ce1:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100ce8:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ceb:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cff:	c7 04 24 da 60 10 c0 	movl   $0xc01060da,(%esp)
c0100d06:	e8 3d f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d12:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d15:	89 04 24             	mov    %eax,(%esp)
c0100d18:	e8 f8 f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d1d:	c7 04 24 f6 60 10 c0 	movl   $0xc01060f6,(%esp)
c0100d24:	e8 1f f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d29:	c7 04 24 f8 60 10 c0 	movl   $0xc01060f8,(%esp)
c0100d30:	e8 13 f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100d35:	e8 8c fc ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d3a:	e8 85 09 00 00       	call   c01016c4 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d46:	e8 a4 fe ff ff       	call   c0100bef <kmonitor>
    }
c0100d4b:	eb f2                	jmp    c0100d3f <__panic+0x6f>

c0100d4d <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d4d:	55                   	push   %ebp
c0100d4e:	89 e5                	mov    %esp,%ebp
c0100d50:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d53:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d59:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d67:	c7 04 24 0a 61 10 c0 	movl   $0xc010610a,(%esp)
c0100d6e:	e8 d5 f5 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7a:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d7d:	89 04 24             	mov    %eax,(%esp)
c0100d80:	e8 90 f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d85:	c7 04 24 f6 60 10 c0 	movl   $0xc01060f6,(%esp)
c0100d8c:	e8 b7 f5 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100d91:	c9                   	leave  
c0100d92:	c3                   	ret    

c0100d93 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d93:	55                   	push   %ebp
c0100d94:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d96:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100d9b:	5d                   	pop    %ebp
c0100d9c:	c3                   	ret    

c0100d9d <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d9d:	55                   	push   %ebp
c0100d9e:	89 e5                	mov    %esp,%ebp
c0100da0:	83 ec 28             	sub    $0x28,%esp
c0100da3:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100da9:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100db1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100db5:	ee                   	out    %al,(%dx)
c0100db6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dbc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dc0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dc8:	ee                   	out    %al,(%dx)
c0100dc9:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dcf:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dd3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dd7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ddb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100ddc:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100de3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100de6:	c7 04 24 28 61 10 c0 	movl   $0xc0106128,(%esp)
c0100ded:	e8 56 f5 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100df2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100df9:	e8 24 09 00 00       	call   c0101722 <pic_enable>
}
c0100dfe:	c9                   	leave  
c0100dff:	c3                   	ret    

c0100e00 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e00:	55                   	push   %ebp
c0100e01:	89 e5                	mov    %esp,%ebp
c0100e03:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e06:	9c                   	pushf  
c0100e07:	58                   	pop    %eax
c0100e08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e0e:	25 00 02 00 00       	and    $0x200,%eax
c0100e13:	85 c0                	test   %eax,%eax
c0100e15:	74 0c                	je     c0100e23 <__intr_save+0x23>
        intr_disable();
c0100e17:	e8 a8 08 00 00       	call   c01016c4 <intr_disable>
        return 1;
c0100e1c:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e21:	eb 05                	jmp    c0100e28 <__intr_save+0x28>
    }
    return 0;
c0100e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e28:	c9                   	leave  
c0100e29:	c3                   	ret    

c0100e2a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e2a:	55                   	push   %ebp
c0100e2b:	89 e5                	mov    %esp,%ebp
c0100e2d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e34:	74 05                	je     c0100e3b <__intr_restore+0x11>
        intr_enable();
c0100e36:	e8 83 08 00 00       	call   c01016be <intr_enable>
    }
}
c0100e3b:	c9                   	leave  
c0100e3c:	c3                   	ret    

c0100e3d <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e3d:	55                   	push   %ebp
c0100e3e:	89 e5                	mov    %esp,%ebp
c0100e40:	83 ec 10             	sub    $0x10,%esp
c0100e43:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e49:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e4d:	89 c2                	mov    %eax,%edx
c0100e4f:	ec                   	in     (%dx),%al
c0100e50:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e53:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e59:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5d:	89 c2                	mov    %eax,%edx
c0100e5f:	ec                   	in     (%dx),%al
c0100e60:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e63:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e69:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6d:	89 c2                	mov    %eax,%edx
c0100e6f:	ec                   	in     (%dx),%al
c0100e70:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e73:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e79:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e7d:	89 c2                	mov    %eax,%edx
c0100e7f:	ec                   	in     (%dx),%al
c0100e80:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e83:	c9                   	leave  
c0100e84:	c3                   	ret    

c0100e85 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e85:	55                   	push   %ebp
c0100e86:	89 e5                	mov    %esp,%ebp
c0100e88:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e8b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e95:	0f b7 00             	movzwl (%eax),%eax
c0100e98:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e9f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea7:	0f b7 00             	movzwl (%eax),%eax
c0100eaa:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eae:	74 12                	je     c0100ec2 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eb0:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eb7:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ebe:	b4 03 
c0100ec0:	eb 13                	jmp    c0100ed5 <cga_init+0x50>
    } else {
        *cp = was;
c0100ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ec9:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ecc:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ed3:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ed5:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100edc:	0f b7 c0             	movzwl %ax,%eax
c0100edf:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ee3:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eeb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100eef:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ef0:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef7:	83 c0 01             	add    $0x1,%eax
c0100efa:	0f b7 c0             	movzwl %ax,%eax
c0100efd:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f01:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f05:	89 c2                	mov    %eax,%edx
c0100f07:	ec                   	in     (%dx),%al
c0100f08:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f0b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f0f:	0f b6 c0             	movzbl %al,%eax
c0100f12:	c1 e0 08             	shl    $0x8,%eax
c0100f15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f18:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f1f:	0f b7 c0             	movzwl %ax,%eax
c0100f22:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f26:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f2a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f2e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f32:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f33:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f3a:	83 c0 01             	add    $0x1,%eax
c0100f3d:	0f b7 c0             	movzwl %ax,%eax
c0100f40:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f44:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f48:	89 c2                	mov    %eax,%edx
c0100f4a:	ec                   	in     (%dx),%al
c0100f4b:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f4e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f52:	0f b6 c0             	movzbl %al,%eax
c0100f55:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f58:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f5b:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f63:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f69:	c9                   	leave  
c0100f6a:	c3                   	ret    

c0100f6b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f6b:	55                   	push   %ebp
c0100f6c:	89 e5                	mov    %esp,%ebp
c0100f6e:	83 ec 48             	sub    $0x48,%esp
c0100f71:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f77:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f7b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f7f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f83:	ee                   	out    %al,(%dx)
c0100f84:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f8a:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f8e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f92:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f96:	ee                   	out    %al,(%dx)
c0100f97:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f9d:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fa1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fa5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fa9:	ee                   	out    %al,(%dx)
c0100faa:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fb0:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fb4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fb8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fbc:	ee                   	out    %al,(%dx)
c0100fbd:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fc3:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fc7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fcf:	ee                   	out    %al,(%dx)
c0100fd0:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fd6:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fda:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fde:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe2:	ee                   	out    %al,(%dx)
c0100fe3:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fe9:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fed:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ff1:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100ff5:	ee                   	out    %al,(%dx)
c0100ff6:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffc:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101000:	89 c2                	mov    %eax,%edx
c0101002:	ec                   	in     (%dx),%al
c0101003:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101006:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010100a:	3c ff                	cmp    $0xff,%al
c010100c:	0f 95 c0             	setne  %al
c010100f:	0f b6 c0             	movzbl %al,%eax
c0101012:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101017:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101d:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101021:	89 c2                	mov    %eax,%edx
c0101023:	ec                   	in     (%dx),%al
c0101024:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101027:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010102d:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101031:	89 c2                	mov    %eax,%edx
c0101033:	ec                   	in     (%dx),%al
c0101034:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101037:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010103c:	85 c0                	test   %eax,%eax
c010103e:	74 0c                	je     c010104c <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101040:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101047:	e8 d6 06 00 00       	call   c0101722 <pic_enable>
    }
}
c010104c:	c9                   	leave  
c010104d:	c3                   	ret    

c010104e <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010104e:	55                   	push   %ebp
c010104f:	89 e5                	mov    %esp,%ebp
c0101051:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101054:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010105b:	eb 09                	jmp    c0101066 <lpt_putc_sub+0x18>
        delay();
c010105d:	e8 db fd ff ff       	call   c0100e3d <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101062:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101066:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010106c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101070:	89 c2                	mov    %eax,%edx
c0101072:	ec                   	in     (%dx),%al
c0101073:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101076:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010107a:	84 c0                	test   %al,%al
c010107c:	78 09                	js     c0101087 <lpt_putc_sub+0x39>
c010107e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101085:	7e d6                	jle    c010105d <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101087:	8b 45 08             	mov    0x8(%ebp),%eax
c010108a:	0f b6 c0             	movzbl %al,%eax
c010108d:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101093:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101096:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010109e:	ee                   	out    %al,(%dx)
c010109f:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010a5:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010a9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010ad:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b1:	ee                   	out    %al,(%dx)
c01010b2:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010b8:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010bc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c4:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010c5:	c9                   	leave  
c01010c6:	c3                   	ret    

c01010c7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010c7:	55                   	push   %ebp
c01010c8:	89 e5                	mov    %esp,%ebp
c01010ca:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010cd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010d1:	74 0d                	je     c01010e0 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d6:	89 04 24             	mov    %eax,(%esp)
c01010d9:	e8 70 ff ff ff       	call   c010104e <lpt_putc_sub>
c01010de:	eb 24                	jmp    c0101104 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010e0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e7:	e8 62 ff ff ff       	call   c010104e <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010ec:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010f3:	e8 56 ff ff ff       	call   c010104e <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010f8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010ff:	e8 4a ff ff ff       	call   c010104e <lpt_putc_sub>
    }
}
c0101104:	c9                   	leave  
c0101105:	c3                   	ret    

c0101106 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101106:	55                   	push   %ebp
c0101107:	89 e5                	mov    %esp,%ebp
c0101109:	53                   	push   %ebx
c010110a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010110d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101110:	b0 00                	mov    $0x0,%al
c0101112:	85 c0                	test   %eax,%eax
c0101114:	75 07                	jne    c010111d <cga_putc+0x17>
        c |= 0x0700;
c0101116:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010111d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101120:	0f b6 c0             	movzbl %al,%eax
c0101123:	83 f8 0a             	cmp    $0xa,%eax
c0101126:	74 4c                	je     c0101174 <cga_putc+0x6e>
c0101128:	83 f8 0d             	cmp    $0xd,%eax
c010112b:	74 57                	je     c0101184 <cga_putc+0x7e>
c010112d:	83 f8 08             	cmp    $0x8,%eax
c0101130:	0f 85 88 00 00 00    	jne    c01011be <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101136:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010113d:	66 85 c0             	test   %ax,%ax
c0101140:	74 30                	je     c0101172 <cga_putc+0x6c>
            crt_pos --;
c0101142:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101149:	83 e8 01             	sub    $0x1,%eax
c010114c:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101152:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101157:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c010115e:	0f b7 d2             	movzwl %dx,%edx
c0101161:	01 d2                	add    %edx,%edx
c0101163:	01 c2                	add    %eax,%edx
c0101165:	8b 45 08             	mov    0x8(%ebp),%eax
c0101168:	b0 00                	mov    $0x0,%al
c010116a:	83 c8 20             	or     $0x20,%eax
c010116d:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101170:	eb 72                	jmp    c01011e4 <cga_putc+0xde>
c0101172:	eb 70                	jmp    c01011e4 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101174:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010117b:	83 c0 50             	add    $0x50,%eax
c010117e:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101184:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010118b:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101192:	0f b7 c1             	movzwl %cx,%eax
c0101195:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010119b:	c1 e8 10             	shr    $0x10,%eax
c010119e:	89 c2                	mov    %eax,%edx
c01011a0:	66 c1 ea 06          	shr    $0x6,%dx
c01011a4:	89 d0                	mov    %edx,%eax
c01011a6:	c1 e0 02             	shl    $0x2,%eax
c01011a9:	01 d0                	add    %edx,%eax
c01011ab:	c1 e0 04             	shl    $0x4,%eax
c01011ae:	29 c1                	sub    %eax,%ecx
c01011b0:	89 ca                	mov    %ecx,%edx
c01011b2:	89 d8                	mov    %ebx,%eax
c01011b4:	29 d0                	sub    %edx,%eax
c01011b6:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011bc:	eb 26                	jmp    c01011e4 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011be:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011c4:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011cb:	8d 50 01             	lea    0x1(%eax),%edx
c01011ce:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011d5:	0f b7 c0             	movzwl %ax,%eax
c01011d8:	01 c0                	add    %eax,%eax
c01011da:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e0:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e3:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e4:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011eb:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011ef:	76 5b                	jbe    c010124c <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f1:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011fc:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101201:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101208:	00 
c0101209:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120d:	89 04 24             	mov    %eax,(%esp)
c0101210:	e8 a0 4a 00 00       	call   c0105cb5 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101215:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010121c:	eb 15                	jmp    c0101233 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010121e:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101223:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101226:	01 d2                	add    %edx,%edx
c0101228:	01 d0                	add    %edx,%eax
c010122a:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010122f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101233:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123a:	7e e2                	jle    c010121e <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010123c:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101243:	83 e8 50             	sub    $0x50,%eax
c0101246:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124c:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101253:	0f b7 c0             	movzwl %ax,%eax
c0101256:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125a:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010125e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101262:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101266:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101267:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010126e:	66 c1 e8 08          	shr    $0x8,%ax
c0101272:	0f b6 c0             	movzbl %al,%eax
c0101275:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010127c:	83 c2 01             	add    $0x1,%edx
c010127f:	0f b7 d2             	movzwl %dx,%edx
c0101282:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101286:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101289:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010128d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101291:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101292:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101299:	0f b7 c0             	movzwl %ax,%eax
c010129c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012a0:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012a4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012a8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012ac:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012ad:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012b4:	0f b6 c0             	movzbl %al,%eax
c01012b7:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012be:	83 c2 01             	add    $0x1,%edx
c01012c1:	0f b7 d2             	movzwl %dx,%edx
c01012c4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012c8:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012cb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012cf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012d3:	ee                   	out    %al,(%dx)
}
c01012d4:	83 c4 34             	add    $0x34,%esp
c01012d7:	5b                   	pop    %ebx
c01012d8:	5d                   	pop    %ebp
c01012d9:	c3                   	ret    

c01012da <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012da:	55                   	push   %ebp
c01012db:	89 e5                	mov    %esp,%ebp
c01012dd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e7:	eb 09                	jmp    c01012f2 <serial_putc_sub+0x18>
        delay();
c01012e9:	e8 4f fb ff ff       	call   c0100e3d <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012f2:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012f8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fc:	89 c2                	mov    %eax,%edx
c01012fe:	ec                   	in     (%dx),%al
c01012ff:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101302:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101306:	0f b6 c0             	movzbl %al,%eax
c0101309:	83 e0 20             	and    $0x20,%eax
c010130c:	85 c0                	test   %eax,%eax
c010130e:	75 09                	jne    c0101319 <serial_putc_sub+0x3f>
c0101310:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101317:	7e d0                	jle    c01012e9 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101319:	8b 45 08             	mov    0x8(%ebp),%eax
c010131c:	0f b6 c0             	movzbl %al,%eax
c010131f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101325:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101328:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101330:	ee                   	out    %al,(%dx)
}
c0101331:	c9                   	leave  
c0101332:	c3                   	ret    

c0101333 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101333:	55                   	push   %ebp
c0101334:	89 e5                	mov    %esp,%ebp
c0101336:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101339:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133d:	74 0d                	je     c010134c <serial_putc+0x19>
        serial_putc_sub(c);
c010133f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101342:	89 04 24             	mov    %eax,(%esp)
c0101345:	e8 90 ff ff ff       	call   c01012da <serial_putc_sub>
c010134a:	eb 24                	jmp    c0101370 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010134c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101353:	e8 82 ff ff ff       	call   c01012da <serial_putc_sub>
        serial_putc_sub(' ');
c0101358:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010135f:	e8 76 ff ff ff       	call   c01012da <serial_putc_sub>
        serial_putc_sub('\b');
c0101364:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136b:	e8 6a ff ff ff       	call   c01012da <serial_putc_sub>
    }
}
c0101370:	c9                   	leave  
c0101371:	c3                   	ret    

c0101372 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101372:	55                   	push   %ebp
c0101373:	89 e5                	mov    %esp,%ebp
c0101375:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101378:	eb 33                	jmp    c01013ad <cons_intr+0x3b>
        if (c != 0) {
c010137a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010137e:	74 2d                	je     c01013ad <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101380:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101385:	8d 50 01             	lea    0x1(%eax),%edx
c0101388:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c010138e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101391:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101397:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010139c:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a1:	75 0a                	jne    c01013ad <cons_intr+0x3b>
                cons.wpos = 0;
c01013a3:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013aa:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b0:	ff d0                	call   *%eax
c01013b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013b9:	75 bf                	jne    c010137a <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013bb:	c9                   	leave  
c01013bc:	c3                   	ret    

c01013bd <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bd:	55                   	push   %ebp
c01013be:	89 e5                	mov    %esp,%ebp
c01013c0:	83 ec 10             	sub    $0x10,%esp
c01013c3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013c9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cd:	89 c2                	mov    %eax,%edx
c01013cf:	ec                   	in     (%dx),%al
c01013d0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d7:	0f b6 c0             	movzbl %al,%eax
c01013da:	83 e0 01             	and    $0x1,%eax
c01013dd:	85 c0                	test   %eax,%eax
c01013df:	75 07                	jne    c01013e8 <serial_proc_data+0x2b>
        return -1;
c01013e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e6:	eb 2a                	jmp    c0101412 <serial_proc_data+0x55>
c01013e8:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ee:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f2:	89 c2                	mov    %eax,%edx
c01013f4:	ec                   	in     (%dx),%al
c01013f5:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013f8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fc:	0f b6 c0             	movzbl %al,%eax
c01013ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101402:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101406:	75 07                	jne    c010140f <serial_proc_data+0x52>
        c = '\b';
c0101408:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010140f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101412:	c9                   	leave  
c0101413:	c3                   	ret    

c0101414 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101414:	55                   	push   %ebp
c0101415:	89 e5                	mov    %esp,%ebp
c0101417:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141a:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010141f:	85 c0                	test   %eax,%eax
c0101421:	74 0c                	je     c010142f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101423:	c7 04 24 bd 13 10 c0 	movl   $0xc01013bd,(%esp)
c010142a:	e8 43 ff ff ff       	call   c0101372 <cons_intr>
    }
}
c010142f:	c9                   	leave  
c0101430:	c3                   	ret    

c0101431 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101431:	55                   	push   %ebp
c0101432:	89 e5                	mov    %esp,%ebp
c0101434:	83 ec 38             	sub    $0x38,%esp
c0101437:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010143d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101441:	89 c2                	mov    %eax,%edx
c0101443:	ec                   	in     (%dx),%al
c0101444:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101447:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144b:	0f b6 c0             	movzbl %al,%eax
c010144e:	83 e0 01             	and    $0x1,%eax
c0101451:	85 c0                	test   %eax,%eax
c0101453:	75 0a                	jne    c010145f <kbd_proc_data+0x2e>
        return -1;
c0101455:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145a:	e9 59 01 00 00       	jmp    c01015b8 <kbd_proc_data+0x187>
c010145f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101465:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101469:	89 c2                	mov    %eax,%edx
c010146b:	ec                   	in     (%dx),%al
c010146c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010146f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101473:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101476:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147a:	75 17                	jne    c0101493 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010147c:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101481:	83 c8 40             	or     $0x40,%eax
c0101484:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c0101489:	b8 00 00 00 00       	mov    $0x0,%eax
c010148e:	e9 25 01 00 00       	jmp    c01015b8 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101493:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101497:	84 c0                	test   %al,%al
c0101499:	79 47                	jns    c01014e2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149b:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014a0:	83 e0 40             	and    $0x40,%eax
c01014a3:	85 c0                	test   %eax,%eax
c01014a5:	75 09                	jne    c01014b0 <kbd_proc_data+0x7f>
c01014a7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ab:	83 e0 7f             	and    $0x7f,%eax
c01014ae:	eb 04                	jmp    c01014b4 <kbd_proc_data+0x83>
c01014b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bb:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014c2:	83 c8 40             	or     $0x40,%eax
c01014c5:	0f b6 c0             	movzbl %al,%eax
c01014c8:	f7 d0                	not    %eax
c01014ca:	89 c2                	mov    %eax,%edx
c01014cc:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d1:	21 d0                	and    %edx,%eax
c01014d3:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014d8:	b8 00 00 00 00       	mov    $0x0,%eax
c01014dd:	e9 d6 00 00 00       	jmp    c01015b8 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014e2:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e7:	83 e0 40             	and    $0x40,%eax
c01014ea:	85 c0                	test   %eax,%eax
c01014ec:	74 11                	je     c01014ff <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ee:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f2:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f7:	83 e0 bf             	and    $0xffffffbf,%eax
c01014fa:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c01014ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101503:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010150a:	0f b6 d0             	movzbl %al,%edx
c010150d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101512:	09 d0                	or     %edx,%eax
c0101514:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c0101519:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151d:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101524:	0f b6 d0             	movzbl %al,%edx
c0101527:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152c:	31 d0                	xor    %edx,%eax
c010152e:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101533:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101538:	83 e0 03             	and    $0x3,%eax
c010153b:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101542:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101546:	01 d0                	add    %edx,%eax
c0101548:	0f b6 00             	movzbl (%eax),%eax
c010154b:	0f b6 c0             	movzbl %al,%eax
c010154e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101551:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101556:	83 e0 08             	and    $0x8,%eax
c0101559:	85 c0                	test   %eax,%eax
c010155b:	74 22                	je     c010157f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010155d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101561:	7e 0c                	jle    c010156f <kbd_proc_data+0x13e>
c0101563:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101567:	7f 06                	jg     c010156f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101569:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156d:	eb 10                	jmp    c010157f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010156f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101573:	7e 0a                	jle    c010157f <kbd_proc_data+0x14e>
c0101575:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101579:	7f 04                	jg     c010157f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010157b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010157f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101584:	f7 d0                	not    %eax
c0101586:	83 e0 06             	and    $0x6,%eax
c0101589:	85 c0                	test   %eax,%eax
c010158b:	75 28                	jne    c01015b5 <kbd_proc_data+0x184>
c010158d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101594:	75 1f                	jne    c01015b5 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101596:	c7 04 24 43 61 10 c0 	movl   $0xc0106143,(%esp)
c010159d:	e8 a6 ed ff ff       	call   c0100348 <cprintf>
c01015a2:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015a8:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ac:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015b0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015b4:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015b8:	c9                   	leave  
c01015b9:	c3                   	ret    

c01015ba <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015ba:	55                   	push   %ebp
c01015bb:	89 e5                	mov    %esp,%ebp
c01015bd:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015c0:	c7 04 24 31 14 10 c0 	movl   $0xc0101431,(%esp)
c01015c7:	e8 a6 fd ff ff       	call   c0101372 <cons_intr>
}
c01015cc:	c9                   	leave  
c01015cd:	c3                   	ret    

c01015ce <kbd_init>:

static void
kbd_init(void) {
c01015ce:	55                   	push   %ebp
c01015cf:	89 e5                	mov    %esp,%ebp
c01015d1:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d4:	e8 e1 ff ff ff       	call   c01015ba <kbd_intr>
    pic_enable(IRQ_KBD);
c01015d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015e0:	e8 3d 01 00 00       	call   c0101722 <pic_enable>
}
c01015e5:	c9                   	leave  
c01015e6:	c3                   	ret    

c01015e7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e7:	55                   	push   %ebp
c01015e8:	89 e5                	mov    %esp,%ebp
c01015ea:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ed:	e8 93 f8 ff ff       	call   c0100e85 <cga_init>
    serial_init();
c01015f2:	e8 74 f9 ff ff       	call   c0100f6b <serial_init>
    kbd_init();
c01015f7:	e8 d2 ff ff ff       	call   c01015ce <kbd_init>
    if (!serial_exists) {
c01015fc:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101601:	85 c0                	test   %eax,%eax
c0101603:	75 0c                	jne    c0101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101605:	c7 04 24 4f 61 10 c0 	movl   $0xc010614f,(%esp)
c010160c:	e8 37 ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101611:	c9                   	leave  
c0101612:	c3                   	ret    

c0101613 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101613:	55                   	push   %ebp
c0101614:	89 e5                	mov    %esp,%ebp
c0101616:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101619:	e8 e2 f7 ff ff       	call   c0100e00 <__intr_save>
c010161e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101621:	8b 45 08             	mov    0x8(%ebp),%eax
c0101624:	89 04 24             	mov    %eax,(%esp)
c0101627:	e8 9b fa ff ff       	call   c01010c7 <lpt_putc>
        cga_putc(c);
c010162c:	8b 45 08             	mov    0x8(%ebp),%eax
c010162f:	89 04 24             	mov    %eax,(%esp)
c0101632:	e8 cf fa ff ff       	call   c0101106 <cga_putc>
        serial_putc(c);
c0101637:	8b 45 08             	mov    0x8(%ebp),%eax
c010163a:	89 04 24             	mov    %eax,(%esp)
c010163d:	e8 f1 fc ff ff       	call   c0101333 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101642:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101645:	89 04 24             	mov    %eax,(%esp)
c0101648:	e8 dd f7 ff ff       	call   c0100e2a <__intr_restore>
}
c010164d:	c9                   	leave  
c010164e:	c3                   	ret    

c010164f <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010164f:	55                   	push   %ebp
c0101650:	89 e5                	mov    %esp,%ebp
c0101652:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165c:	e8 9f f7 ff ff       	call   c0100e00 <__intr_save>
c0101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101664:	e8 ab fd ff ff       	call   c0101414 <serial_intr>
        kbd_intr();
c0101669:	e8 4c ff ff ff       	call   c01015ba <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010166e:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101674:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101679:	39 c2                	cmp    %eax,%edx
c010167b:	74 31                	je     c01016ae <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167d:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101682:	8d 50 01             	lea    0x1(%eax),%edx
c0101685:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c010168b:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101692:	0f b6 c0             	movzbl %al,%eax
c0101695:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101698:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169d:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a2:	75 0a                	jne    c01016ae <cons_getc+0x5f>
                cons.rpos = 0;
c01016a4:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016ab:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b1:	89 04 24             	mov    %eax,(%esp)
c01016b4:	e8 71 f7 ff ff       	call   c0100e2a <__intr_restore>
    return c;
c01016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016bc:	c9                   	leave  
c01016bd:	c3                   	ret    

c01016be <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016be:	55                   	push   %ebp
c01016bf:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016c1:	fb                   	sti    
    sti();
}
c01016c2:	5d                   	pop    %ebp
c01016c3:	c3                   	ret    

c01016c4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016c4:	55                   	push   %ebp
c01016c5:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016c7:	fa                   	cli    
    cli();
}
c01016c8:	5d                   	pop    %ebp
c01016c9:	c3                   	ret    

c01016ca <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016ca:	55                   	push   %ebp
c01016cb:	89 e5                	mov    %esp,%ebp
c01016cd:	83 ec 14             	sub    $0x14,%esp
c01016d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016db:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016e1:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016e6:	85 c0                	test   %eax,%eax
c01016e8:	74 36                	je     c0101720 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016ee:	0f b6 c0             	movzbl %al,%eax
c01016f1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016f7:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016fa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016fe:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101702:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101703:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101707:	66 c1 e8 08          	shr    $0x8,%ax
c010170b:	0f b6 c0             	movzbl %al,%eax
c010170e:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101714:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101717:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010171b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010171f:	ee                   	out    %al,(%dx)
    }
}
c0101720:	c9                   	leave  
c0101721:	c3                   	ret    

c0101722 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101722:	55                   	push   %ebp
c0101723:	89 e5                	mov    %esp,%ebp
c0101725:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101728:	8b 45 08             	mov    0x8(%ebp),%eax
c010172b:	ba 01 00 00 00       	mov    $0x1,%edx
c0101730:	89 c1                	mov    %eax,%ecx
c0101732:	d3 e2                	shl    %cl,%edx
c0101734:	89 d0                	mov    %edx,%eax
c0101736:	f7 d0                	not    %eax
c0101738:	89 c2                	mov    %eax,%edx
c010173a:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101741:	21 d0                	and    %edx,%eax
c0101743:	0f b7 c0             	movzwl %ax,%eax
c0101746:	89 04 24             	mov    %eax,(%esp)
c0101749:	e8 7c ff ff ff       	call   c01016ca <pic_setmask>
}
c010174e:	c9                   	leave  
c010174f:	c3                   	ret    

c0101750 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101750:	55                   	push   %ebp
c0101751:	89 e5                	mov    %esp,%ebp
c0101753:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101756:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010175d:	00 00 00 
c0101760:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101766:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010176a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010176e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101772:	ee                   	out    %al,(%dx)
c0101773:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101779:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010177d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101781:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101785:	ee                   	out    %al,(%dx)
c0101786:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010178c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101790:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101794:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101798:	ee                   	out    %al,(%dx)
c0101799:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c010179f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017a3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017a7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017ab:	ee                   	out    %al,(%dx)
c01017ac:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017b2:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017b6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017ba:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017be:	ee                   	out    %al,(%dx)
c01017bf:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017c5:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017c9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017cd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017d1:	ee                   	out    %al,(%dx)
c01017d2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017d8:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017dc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017e4:	ee                   	out    %al,(%dx)
c01017e5:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017eb:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017ef:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017f3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f7:	ee                   	out    %al,(%dx)
c01017f8:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01017fe:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101802:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101806:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010180a:	ee                   	out    %al,(%dx)
c010180b:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101811:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101815:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101819:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010181d:	ee                   	out    %al,(%dx)
c010181e:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101824:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101828:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010182c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101830:	ee                   	out    %al,(%dx)
c0101831:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101837:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010183b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010183f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101843:	ee                   	out    %al,(%dx)
c0101844:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010184a:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010184e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101852:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101856:	ee                   	out    %al,(%dx)
c0101857:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010185d:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101861:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101865:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101869:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010186a:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101871:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101875:	74 12                	je     c0101889 <pic_init+0x139>
        pic_setmask(irq_mask);
c0101877:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010187e:	0f b7 c0             	movzwl %ax,%eax
c0101881:	89 04 24             	mov    %eax,(%esp)
c0101884:	e8 41 fe ff ff       	call   c01016ca <pic_setmask>
    }
}
c0101889:	c9                   	leave  
c010188a:	c3                   	ret    

c010188b <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010188b:	55                   	push   %ebp
c010188c:	89 e5                	mov    %esp,%ebp
c010188e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101891:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101898:	00 
c0101899:	c7 04 24 80 61 10 c0 	movl   $0xc0106180,(%esp)
c01018a0:	e8 a3 ea ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018a5:	c9                   	leave  
c01018a6:	c3                   	ret    

c01018a7 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018a7:	55                   	push   %ebp
c01018a8:	89 e5                	mov    %esp,%ebp
c01018aa:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
extern uintptr_t __vectors[];
int i; 
for(i=0; i<256; i++)
c01018ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018b4:	e9 c3 00 00 00       	jmp    c010197c <idt_init+0xd5>
 {
 SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c01018b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018bc:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018c3:	89 c2                	mov    %eax,%edx
c01018c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c8:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018cf:	c0 
c01018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d3:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018da:	c0 08 00 
c01018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e0:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018e7:	c0 
c01018e8:	83 e2 e0             	and    $0xffffffe0,%edx
c01018eb:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f5:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018fc:	c0 
c01018fd:	83 e2 1f             	and    $0x1f,%edx
c0101900:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101907:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101911:	c0 
c0101912:	83 e2 f0             	and    $0xfffffff0,%edx
c0101915:	83 ca 0e             	or     $0xe,%edx
c0101918:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010191f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101922:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101929:	c0 
c010192a:	83 e2 ef             	and    $0xffffffef,%edx
c010192d:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101934:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101937:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010193e:	c0 
c010193f:	83 e2 9f             	and    $0xffffff9f,%edx
c0101942:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101949:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194c:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101953:	c0 
c0101954:	83 ca 80             	or     $0xffffff80,%edx
c0101957:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010195e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101961:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101968:	c1 e8 10             	shr    $0x10,%eax
c010196b:	89 c2                	mov    %eax,%edx
c010196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101970:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c0101977:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
extern uintptr_t __vectors[];
int i; 
for(i=0; i<256; i++)
c0101978:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010197c:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0101983:	0f 8e 30 ff ff ff    	jle    c01018b9 <idt_init+0x12>
 {
 SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
 
 }
 SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK],
c0101989:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c010198e:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c0101994:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c010199b:	08 00 
c010199d:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019a4:	83 e0 e0             	and    $0xffffffe0,%eax
c01019a7:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019ac:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019b3:	83 e0 1f             	and    $0x1f,%eax
c01019b6:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019bb:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019c2:	83 e0 f0             	and    $0xfffffff0,%eax
c01019c5:	83 c8 0e             	or     $0xe,%eax
c01019c8:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019cd:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019d4:	83 e0 ef             	and    $0xffffffef,%eax
c01019d7:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019dc:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019e3:	83 c8 60             	or     $0x60,%eax
c01019e6:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019eb:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019f2:	83 c8 80             	or     $0xffffff80,%eax
c01019f5:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019fa:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019ff:	c1 e8 10             	shr    $0x10,%eax
c0101a02:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a08:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a12:	0f 01 18             	lidtl  (%eax)
DPL_USER);
 
 lidt(&idt_pd);
 
}
c0101a15:	c9                   	leave  
c0101a16:	c3                   	ret    

c0101a17 <trapname>:

static const char *
trapname(int trapno) {
c0101a17:	55                   	push   %ebp
c0101a18:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1d:	83 f8 13             	cmp    $0x13,%eax
c0101a20:	77 0c                	ja     c0101a2e <trapname+0x17>
        return excnames[trapno];
c0101a22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a25:	8b 04 85 e0 64 10 c0 	mov    -0x3fef9b20(,%eax,4),%eax
c0101a2c:	eb 18                	jmp    c0101a46 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a2e:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a32:	7e 0d                	jle    c0101a41 <trapname+0x2a>
c0101a34:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a38:	7f 07                	jg     c0101a41 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a3a:	b8 8a 61 10 c0       	mov    $0xc010618a,%eax
c0101a3f:	eb 05                	jmp    c0101a46 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a41:	b8 9d 61 10 c0       	mov    $0xc010619d,%eax
}
c0101a46:	5d                   	pop    %ebp
c0101a47:	c3                   	ret    

c0101a48 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a48:	55                   	push   %ebp
c0101a49:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a52:	66 83 f8 08          	cmp    $0x8,%ax
c0101a56:	0f 94 c0             	sete   %al
c0101a59:	0f b6 c0             	movzbl %al,%eax
}
c0101a5c:	5d                   	pop    %ebp
c0101a5d:	c3                   	ret    

c0101a5e <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a5e:	55                   	push   %ebp
c0101a5f:	89 e5                	mov    %esp,%ebp
c0101a61:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a64:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a6b:	c7 04 24 de 61 10 c0 	movl   $0xc01061de,(%esp)
c0101a72:	e8 d1 e8 ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c0101a77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7a:	89 04 24             	mov    %eax,(%esp)
c0101a7d:	e8 a1 01 00 00       	call   c0101c23 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a85:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a89:	0f b7 c0             	movzwl %ax,%eax
c0101a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a90:	c7 04 24 ef 61 10 c0 	movl   $0xc01061ef,(%esp)
c0101a97:	e8 ac e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a9f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101aa3:	0f b7 c0             	movzwl %ax,%eax
c0101aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aaa:	c7 04 24 02 62 10 c0 	movl   $0xc0106202,(%esp)
c0101ab1:	e8 92 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101abd:	0f b7 c0             	movzwl %ax,%eax
c0101ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac4:	c7 04 24 15 62 10 c0 	movl   $0xc0106215,(%esp)
c0101acb:	e8 78 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad3:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ad7:	0f b7 c0             	movzwl %ax,%eax
c0101ada:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ade:	c7 04 24 28 62 10 c0 	movl   $0xc0106228,(%esp)
c0101ae5:	e8 5e e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101aea:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aed:	8b 40 30             	mov    0x30(%eax),%eax
c0101af0:	89 04 24             	mov    %eax,(%esp)
c0101af3:	e8 1f ff ff ff       	call   c0101a17 <trapname>
c0101af8:	8b 55 08             	mov    0x8(%ebp),%edx
c0101afb:	8b 52 30             	mov    0x30(%edx),%edx
c0101afe:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b02:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b06:	c7 04 24 3b 62 10 c0 	movl   $0xc010623b,(%esp)
c0101b0d:	e8 36 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b12:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b15:	8b 40 34             	mov    0x34(%eax),%eax
c0101b18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b1c:	c7 04 24 4d 62 10 c0 	movl   $0xc010624d,(%esp)
c0101b23:	e8 20 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b28:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2b:	8b 40 38             	mov    0x38(%eax),%eax
c0101b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b32:	c7 04 24 5c 62 10 c0 	movl   $0xc010625c,(%esp)
c0101b39:	e8 0a e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b41:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b45:	0f b7 c0             	movzwl %ax,%eax
c0101b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4c:	c7 04 24 6b 62 10 c0 	movl   $0xc010626b,(%esp)
c0101b53:	e8 f0 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5b:	8b 40 40             	mov    0x40(%eax),%eax
c0101b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b62:	c7 04 24 7e 62 10 c0 	movl   $0xc010627e,(%esp)
c0101b69:	e8 da e7 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b75:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b7c:	eb 3e                	jmp    c0101bbc <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b81:	8b 50 40             	mov    0x40(%eax),%edx
c0101b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b87:	21 d0                	and    %edx,%eax
c0101b89:	85 c0                	test   %eax,%eax
c0101b8b:	74 28                	je     c0101bb5 <print_trapframe+0x157>
c0101b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b90:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b97:	85 c0                	test   %eax,%eax
c0101b99:	74 1a                	je     c0101bb5 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b9e:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba9:	c7 04 24 8d 62 10 c0 	movl   $0xc010628d,(%esp)
c0101bb0:	e8 93 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bb9:	d1 65 f0             	shll   -0x10(%ebp)
c0101bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bbf:	83 f8 17             	cmp    $0x17,%eax
c0101bc2:	76 ba                	jbe    c0101b7e <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc7:	8b 40 40             	mov    0x40(%eax),%eax
c0101bca:	25 00 30 00 00       	and    $0x3000,%eax
c0101bcf:	c1 e8 0c             	shr    $0xc,%eax
c0101bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd6:	c7 04 24 91 62 10 c0 	movl   $0xc0106291,(%esp)
c0101bdd:	e8 66 e7 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101be2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be5:	89 04 24             	mov    %eax,(%esp)
c0101be8:	e8 5b fe ff ff       	call   c0101a48 <trap_in_kernel>
c0101bed:	85 c0                	test   %eax,%eax
c0101bef:	75 30                	jne    c0101c21 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101bf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf4:	8b 40 44             	mov    0x44(%eax),%eax
c0101bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bfb:	c7 04 24 9a 62 10 c0 	movl   $0xc010629a,(%esp)
c0101c02:	e8 41 e7 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c07:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0a:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c0e:	0f b7 c0             	movzwl %ax,%eax
c0101c11:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c15:	c7 04 24 a9 62 10 c0 	movl   $0xc01062a9,(%esp)
c0101c1c:	e8 27 e7 ff ff       	call   c0100348 <cprintf>
    }
}
c0101c21:	c9                   	leave  
c0101c22:	c3                   	ret    

c0101c23 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c23:	55                   	push   %ebp
c0101c24:	89 e5                	mov    %esp,%ebp
c0101c26:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2c:	8b 00                	mov    (%eax),%eax
c0101c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c32:	c7 04 24 bc 62 10 c0 	movl   $0xc01062bc,(%esp)
c0101c39:	e8 0a e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c41:	8b 40 04             	mov    0x4(%eax),%eax
c0101c44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c48:	c7 04 24 cb 62 10 c0 	movl   $0xc01062cb,(%esp)
c0101c4f:	e8 f4 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c57:	8b 40 08             	mov    0x8(%eax),%eax
c0101c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5e:	c7 04 24 da 62 10 c0 	movl   $0xc01062da,(%esp)
c0101c65:	e8 de e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6d:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c74:	c7 04 24 e9 62 10 c0 	movl   $0xc01062e9,(%esp)
c0101c7b:	e8 c8 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c83:	8b 40 10             	mov    0x10(%eax),%eax
c0101c86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c8a:	c7 04 24 f8 62 10 c0 	movl   $0xc01062f8,(%esp)
c0101c91:	e8 b2 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c99:	8b 40 14             	mov    0x14(%eax),%eax
c0101c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca0:	c7 04 24 07 63 10 c0 	movl   $0xc0106307,(%esp)
c0101ca7:	e8 9c e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101caf:	8b 40 18             	mov    0x18(%eax),%eax
c0101cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb6:	c7 04 24 16 63 10 c0 	movl   $0xc0106316,(%esp)
c0101cbd:	e8 86 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc5:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ccc:	c7 04 24 25 63 10 c0 	movl   $0xc0106325,(%esp)
c0101cd3:	e8 70 e6 ff ff       	call   c0100348 <cprintf>
}
c0101cd8:	c9                   	leave  
c0101cd9:	c3                   	ret    

c0101cda <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cda:	55                   	push   %ebp
c0101cdb:	89 e5                	mov    %esp,%ebp
c0101cdd:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce3:	8b 40 30             	mov    0x30(%eax),%eax
c0101ce6:	83 f8 2f             	cmp    $0x2f,%eax
c0101ce9:	77 1e                	ja     c0101d09 <trap_dispatch+0x2f>
c0101ceb:	83 f8 2e             	cmp    $0x2e,%eax
c0101cee:	0f 83 bf 00 00 00    	jae    c0101db3 <trap_dispatch+0xd9>
c0101cf4:	83 f8 21             	cmp    $0x21,%eax
c0101cf7:	74 40                	je     c0101d39 <trap_dispatch+0x5f>
c0101cf9:	83 f8 24             	cmp    $0x24,%eax
c0101cfc:	74 15                	je     c0101d13 <trap_dispatch+0x39>
c0101cfe:	83 f8 20             	cmp    $0x20,%eax
c0101d01:	0f 84 af 00 00 00    	je     c0101db6 <trap_dispatch+0xdc>
c0101d07:	eb 72                	jmp    c0101d7b <trap_dispatch+0xa1>
c0101d09:	83 e8 78             	sub    $0x78,%eax
c0101d0c:	83 f8 01             	cmp    $0x1,%eax
c0101d0f:	77 6a                	ja     c0101d7b <trap_dispatch+0xa1>
c0101d11:	eb 4c                	jmp    c0101d5f <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d13:	e8 37 f9 ff ff       	call   c010164f <cons_getc>
c0101d18:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d1b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d1f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d23:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d2b:	c7 04 24 34 63 10 c0 	movl   $0xc0106334,(%esp)
c0101d32:	e8 11 e6 ff ff       	call   c0100348 <cprintf>
        break;
c0101d37:	eb 7e                	jmp    c0101db7 <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d39:	e8 11 f9 ff ff       	call   c010164f <cons_getc>
c0101d3e:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d41:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d45:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d49:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d51:	c7 04 24 46 63 10 c0 	movl   $0xc0106346,(%esp)
c0101d58:	e8 eb e5 ff ff       	call   c0100348 <cprintf>
        break;
c0101d5d:	eb 58                	jmp    c0101db7 <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d5f:	c7 44 24 08 55 63 10 	movl   $0xc0106355,0x8(%esp)
c0101d66:	c0 
c0101d67:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0101d6e:	00 
c0101d6f:	c7 04 24 65 63 10 c0 	movl   $0xc0106365,(%esp)
c0101d76:	e8 55 ef ff ff       	call   c0100cd0 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d7e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d82:	0f b7 c0             	movzwl %ax,%eax
c0101d85:	83 e0 03             	and    $0x3,%eax
c0101d88:	85 c0                	test   %eax,%eax
c0101d8a:	75 2b                	jne    c0101db7 <trap_dispatch+0xdd>
            print_trapframe(tf);
c0101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8f:	89 04 24             	mov    %eax,(%esp)
c0101d92:	e8 c7 fc ff ff       	call   c0101a5e <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d97:	c7 44 24 08 76 63 10 	movl   $0xc0106376,0x8(%esp)
c0101d9e:	c0 
c0101d9f:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0101da6:	00 
c0101da7:	c7 04 24 65 63 10 c0 	movl   $0xc0106365,(%esp)
c0101dae:	e8 1d ef ff ff       	call   c0100cd0 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101db3:	90                   	nop
c0101db4:	eb 01                	jmp    c0101db7 <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
c0101db6:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101db7:	c9                   	leave  
c0101db8:	c3                   	ret    

c0101db9 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101db9:	55                   	push   %ebp
c0101dba:	89 e5                	mov    %esp,%ebp
c0101dbc:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dc2:	89 04 24             	mov    %eax,(%esp)
c0101dc5:	e8 10 ff ff ff       	call   c0101cda <trap_dispatch>
}
c0101dca:	c9                   	leave  
c0101dcb:	c3                   	ret    

c0101dcc <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101dcc:	1e                   	push   %ds
    pushl %es
c0101dcd:	06                   	push   %es
    pushl %fs
c0101dce:	0f a0                	push   %fs
    pushl %gs
c0101dd0:	0f a8                	push   %gs
    pushal
c0101dd2:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101dd3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101dd8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101dda:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101ddc:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101ddd:	e8 d7 ff ff ff       	call   c0101db9 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101de2:	5c                   	pop    %esp

c0101de3 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101de3:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101de4:	0f a9                	pop    %gs
    popl %fs
c0101de6:	0f a1                	pop    %fs
    popl %es
c0101de8:	07                   	pop    %es
    popl %ds
c0101de9:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101dea:	83 c4 08             	add    $0x8,%esp
    iret
c0101ded:	cf                   	iret   

c0101dee <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101dee:	6a 00                	push   $0x0
  pushl $0
c0101df0:	6a 00                	push   $0x0
  jmp __alltraps
c0101df2:	e9 d5 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101df7 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101df7:	6a 00                	push   $0x0
  pushl $1
c0101df9:	6a 01                	push   $0x1
  jmp __alltraps
c0101dfb:	e9 cc ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e00 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e00:	6a 00                	push   $0x0
  pushl $2
c0101e02:	6a 02                	push   $0x2
  jmp __alltraps
c0101e04:	e9 c3 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e09 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e09:	6a 00                	push   $0x0
  pushl $3
c0101e0b:	6a 03                	push   $0x3
  jmp __alltraps
c0101e0d:	e9 ba ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e12 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e12:	6a 00                	push   $0x0
  pushl $4
c0101e14:	6a 04                	push   $0x4
  jmp __alltraps
c0101e16:	e9 b1 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e1b <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e1b:	6a 00                	push   $0x0
  pushl $5
c0101e1d:	6a 05                	push   $0x5
  jmp __alltraps
c0101e1f:	e9 a8 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e24 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e24:	6a 00                	push   $0x0
  pushl $6
c0101e26:	6a 06                	push   $0x6
  jmp __alltraps
c0101e28:	e9 9f ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e2d <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e2d:	6a 00                	push   $0x0
  pushl $7
c0101e2f:	6a 07                	push   $0x7
  jmp __alltraps
c0101e31:	e9 96 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e36 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e36:	6a 08                	push   $0x8
  jmp __alltraps
c0101e38:	e9 8f ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e3d <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e3d:	6a 00                	push   $0x0
  pushl $9
c0101e3f:	6a 09                	push   $0x9
  jmp __alltraps
c0101e41:	e9 86 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e46 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e46:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e48:	e9 7f ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e4d <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e4d:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e4f:	e9 78 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e54 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e54:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e56:	e9 71 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e5b <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e5b:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e5d:	e9 6a ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e62 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e62:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e64:	e9 63 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e69 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $15
c0101e6b:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e6d:	e9 5a ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e72 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e72:	6a 00                	push   $0x0
  pushl $16
c0101e74:	6a 10                	push   $0x10
  jmp __alltraps
c0101e76:	e9 51 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e7b <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e7b:	6a 11                	push   $0x11
  jmp __alltraps
c0101e7d:	e9 4a ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e82 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e82:	6a 00                	push   $0x0
  pushl $18
c0101e84:	6a 12                	push   $0x12
  jmp __alltraps
c0101e86:	e9 41 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e8b <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e8b:	6a 00                	push   $0x0
  pushl $19
c0101e8d:	6a 13                	push   $0x13
  jmp __alltraps
c0101e8f:	e9 38 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e94 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e94:	6a 00                	push   $0x0
  pushl $20
c0101e96:	6a 14                	push   $0x14
  jmp __alltraps
c0101e98:	e9 2f ff ff ff       	jmp    c0101dcc <__alltraps>

c0101e9d <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e9d:	6a 00                	push   $0x0
  pushl $21
c0101e9f:	6a 15                	push   $0x15
  jmp __alltraps
c0101ea1:	e9 26 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101ea6 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101ea6:	6a 00                	push   $0x0
  pushl $22
c0101ea8:	6a 16                	push   $0x16
  jmp __alltraps
c0101eaa:	e9 1d ff ff ff       	jmp    c0101dcc <__alltraps>

c0101eaf <vector23>:
.globl vector23
vector23:
  pushl $0
c0101eaf:	6a 00                	push   $0x0
  pushl $23
c0101eb1:	6a 17                	push   $0x17
  jmp __alltraps
c0101eb3:	e9 14 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101eb8 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101eb8:	6a 00                	push   $0x0
  pushl $24
c0101eba:	6a 18                	push   $0x18
  jmp __alltraps
c0101ebc:	e9 0b ff ff ff       	jmp    c0101dcc <__alltraps>

c0101ec1 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101ec1:	6a 00                	push   $0x0
  pushl $25
c0101ec3:	6a 19                	push   $0x19
  jmp __alltraps
c0101ec5:	e9 02 ff ff ff       	jmp    c0101dcc <__alltraps>

c0101eca <vector26>:
.globl vector26
vector26:
  pushl $0
c0101eca:	6a 00                	push   $0x0
  pushl $26
c0101ecc:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101ece:	e9 f9 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101ed3 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101ed3:	6a 00                	push   $0x0
  pushl $27
c0101ed5:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101ed7:	e9 f0 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101edc <vector28>:
.globl vector28
vector28:
  pushl $0
c0101edc:	6a 00                	push   $0x0
  pushl $28
c0101ede:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ee0:	e9 e7 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101ee5 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101ee5:	6a 00                	push   $0x0
  pushl $29
c0101ee7:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101ee9:	e9 de fe ff ff       	jmp    c0101dcc <__alltraps>

c0101eee <vector30>:
.globl vector30
vector30:
  pushl $0
c0101eee:	6a 00                	push   $0x0
  pushl $30
c0101ef0:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101ef2:	e9 d5 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101ef7 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101ef7:	6a 00                	push   $0x0
  pushl $31
c0101ef9:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101efb:	e9 cc fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f00 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f00:	6a 00                	push   $0x0
  pushl $32
c0101f02:	6a 20                	push   $0x20
  jmp __alltraps
c0101f04:	e9 c3 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f09 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f09:	6a 00                	push   $0x0
  pushl $33
c0101f0b:	6a 21                	push   $0x21
  jmp __alltraps
c0101f0d:	e9 ba fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f12 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f12:	6a 00                	push   $0x0
  pushl $34
c0101f14:	6a 22                	push   $0x22
  jmp __alltraps
c0101f16:	e9 b1 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f1b <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f1b:	6a 00                	push   $0x0
  pushl $35
c0101f1d:	6a 23                	push   $0x23
  jmp __alltraps
c0101f1f:	e9 a8 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f24 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f24:	6a 00                	push   $0x0
  pushl $36
c0101f26:	6a 24                	push   $0x24
  jmp __alltraps
c0101f28:	e9 9f fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f2d <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f2d:	6a 00                	push   $0x0
  pushl $37
c0101f2f:	6a 25                	push   $0x25
  jmp __alltraps
c0101f31:	e9 96 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f36 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f36:	6a 00                	push   $0x0
  pushl $38
c0101f38:	6a 26                	push   $0x26
  jmp __alltraps
c0101f3a:	e9 8d fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f3f <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f3f:	6a 00                	push   $0x0
  pushl $39
c0101f41:	6a 27                	push   $0x27
  jmp __alltraps
c0101f43:	e9 84 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f48 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f48:	6a 00                	push   $0x0
  pushl $40
c0101f4a:	6a 28                	push   $0x28
  jmp __alltraps
c0101f4c:	e9 7b fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f51 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f51:	6a 00                	push   $0x0
  pushl $41
c0101f53:	6a 29                	push   $0x29
  jmp __alltraps
c0101f55:	e9 72 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f5a <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f5a:	6a 00                	push   $0x0
  pushl $42
c0101f5c:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f5e:	e9 69 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f63 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f63:	6a 00                	push   $0x0
  pushl $43
c0101f65:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f67:	e9 60 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f6c <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f6c:	6a 00                	push   $0x0
  pushl $44
c0101f6e:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f70:	e9 57 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f75 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f75:	6a 00                	push   $0x0
  pushl $45
c0101f77:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f79:	e9 4e fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f7e <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f7e:	6a 00                	push   $0x0
  pushl $46
c0101f80:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f82:	e9 45 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f87 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f87:	6a 00                	push   $0x0
  pushl $47
c0101f89:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f8b:	e9 3c fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f90 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f90:	6a 00                	push   $0x0
  pushl $48
c0101f92:	6a 30                	push   $0x30
  jmp __alltraps
c0101f94:	e9 33 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101f99 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f99:	6a 00                	push   $0x0
  pushl $49
c0101f9b:	6a 31                	push   $0x31
  jmp __alltraps
c0101f9d:	e9 2a fe ff ff       	jmp    c0101dcc <__alltraps>

c0101fa2 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101fa2:	6a 00                	push   $0x0
  pushl $50
c0101fa4:	6a 32                	push   $0x32
  jmp __alltraps
c0101fa6:	e9 21 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101fab <vector51>:
.globl vector51
vector51:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $51
c0101fad:	6a 33                	push   $0x33
  jmp __alltraps
c0101faf:	e9 18 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101fb4 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101fb4:	6a 00                	push   $0x0
  pushl $52
c0101fb6:	6a 34                	push   $0x34
  jmp __alltraps
c0101fb8:	e9 0f fe ff ff       	jmp    c0101dcc <__alltraps>

c0101fbd <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fbd:	6a 00                	push   $0x0
  pushl $53
c0101fbf:	6a 35                	push   $0x35
  jmp __alltraps
c0101fc1:	e9 06 fe ff ff       	jmp    c0101dcc <__alltraps>

c0101fc6 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101fc6:	6a 00                	push   $0x0
  pushl $54
c0101fc8:	6a 36                	push   $0x36
  jmp __alltraps
c0101fca:	e9 fd fd ff ff       	jmp    c0101dcc <__alltraps>

c0101fcf <vector55>:
.globl vector55
vector55:
  pushl $0
c0101fcf:	6a 00                	push   $0x0
  pushl $55
c0101fd1:	6a 37                	push   $0x37
  jmp __alltraps
c0101fd3:	e9 f4 fd ff ff       	jmp    c0101dcc <__alltraps>

c0101fd8 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101fd8:	6a 00                	push   $0x0
  pushl $56
c0101fda:	6a 38                	push   $0x38
  jmp __alltraps
c0101fdc:	e9 eb fd ff ff       	jmp    c0101dcc <__alltraps>

c0101fe1 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101fe1:	6a 00                	push   $0x0
  pushl $57
c0101fe3:	6a 39                	push   $0x39
  jmp __alltraps
c0101fe5:	e9 e2 fd ff ff       	jmp    c0101dcc <__alltraps>

c0101fea <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fea:	6a 00                	push   $0x0
  pushl $58
c0101fec:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101fee:	e9 d9 fd ff ff       	jmp    c0101dcc <__alltraps>

c0101ff3 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101ff3:	6a 00                	push   $0x0
  pushl $59
c0101ff5:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101ff7:	e9 d0 fd ff ff       	jmp    c0101dcc <__alltraps>

c0101ffc <vector60>:
.globl vector60
vector60:
  pushl $0
c0101ffc:	6a 00                	push   $0x0
  pushl $60
c0101ffe:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102000:	e9 c7 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102005 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102005:	6a 00                	push   $0x0
  pushl $61
c0102007:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102009:	e9 be fd ff ff       	jmp    c0101dcc <__alltraps>

c010200e <vector62>:
.globl vector62
vector62:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $62
c0102010:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102012:	e9 b5 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102017 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $63
c0102019:	6a 3f                	push   $0x3f
  jmp __alltraps
c010201b:	e9 ac fd ff ff       	jmp    c0101dcc <__alltraps>

c0102020 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $64
c0102022:	6a 40                	push   $0x40
  jmp __alltraps
c0102024:	e9 a3 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102029 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $65
c010202b:	6a 41                	push   $0x41
  jmp __alltraps
c010202d:	e9 9a fd ff ff       	jmp    c0101dcc <__alltraps>

c0102032 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $66
c0102034:	6a 42                	push   $0x42
  jmp __alltraps
c0102036:	e9 91 fd ff ff       	jmp    c0101dcc <__alltraps>

c010203b <vector67>:
.globl vector67
vector67:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $67
c010203d:	6a 43                	push   $0x43
  jmp __alltraps
c010203f:	e9 88 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102044 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $68
c0102046:	6a 44                	push   $0x44
  jmp __alltraps
c0102048:	e9 7f fd ff ff       	jmp    c0101dcc <__alltraps>

c010204d <vector69>:
.globl vector69
vector69:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $69
c010204f:	6a 45                	push   $0x45
  jmp __alltraps
c0102051:	e9 76 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102056 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102056:	6a 00                	push   $0x0
  pushl $70
c0102058:	6a 46                	push   $0x46
  jmp __alltraps
c010205a:	e9 6d fd ff ff       	jmp    c0101dcc <__alltraps>

c010205f <vector71>:
.globl vector71
vector71:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $71
c0102061:	6a 47                	push   $0x47
  jmp __alltraps
c0102063:	e9 64 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102068 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $72
c010206a:	6a 48                	push   $0x48
  jmp __alltraps
c010206c:	e9 5b fd ff ff       	jmp    c0101dcc <__alltraps>

c0102071 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102071:	6a 00                	push   $0x0
  pushl $73
c0102073:	6a 49                	push   $0x49
  jmp __alltraps
c0102075:	e9 52 fd ff ff       	jmp    c0101dcc <__alltraps>

c010207a <vector74>:
.globl vector74
vector74:
  pushl $0
c010207a:	6a 00                	push   $0x0
  pushl $74
c010207c:	6a 4a                	push   $0x4a
  jmp __alltraps
c010207e:	e9 49 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102083 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102083:	6a 00                	push   $0x0
  pushl $75
c0102085:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102087:	e9 40 fd ff ff       	jmp    c0101dcc <__alltraps>

c010208c <vector76>:
.globl vector76
vector76:
  pushl $0
c010208c:	6a 00                	push   $0x0
  pushl $76
c010208e:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102090:	e9 37 fd ff ff       	jmp    c0101dcc <__alltraps>

c0102095 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102095:	6a 00                	push   $0x0
  pushl $77
c0102097:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102099:	e9 2e fd ff ff       	jmp    c0101dcc <__alltraps>

c010209e <vector78>:
.globl vector78
vector78:
  pushl $0
c010209e:	6a 00                	push   $0x0
  pushl $78
c01020a0:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020a2:	e9 25 fd ff ff       	jmp    c0101dcc <__alltraps>

c01020a7 <vector79>:
.globl vector79
vector79:
  pushl $0
c01020a7:	6a 00                	push   $0x0
  pushl $79
c01020a9:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020ab:	e9 1c fd ff ff       	jmp    c0101dcc <__alltraps>

c01020b0 <vector80>:
.globl vector80
vector80:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $80
c01020b2:	6a 50                	push   $0x50
  jmp __alltraps
c01020b4:	e9 13 fd ff ff       	jmp    c0101dcc <__alltraps>

c01020b9 <vector81>:
.globl vector81
vector81:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $81
c01020bb:	6a 51                	push   $0x51
  jmp __alltraps
c01020bd:	e9 0a fd ff ff       	jmp    c0101dcc <__alltraps>

c01020c2 <vector82>:
.globl vector82
vector82:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $82
c01020c4:	6a 52                	push   $0x52
  jmp __alltraps
c01020c6:	e9 01 fd ff ff       	jmp    c0101dcc <__alltraps>

c01020cb <vector83>:
.globl vector83
vector83:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $83
c01020cd:	6a 53                	push   $0x53
  jmp __alltraps
c01020cf:	e9 f8 fc ff ff       	jmp    c0101dcc <__alltraps>

c01020d4 <vector84>:
.globl vector84
vector84:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $84
c01020d6:	6a 54                	push   $0x54
  jmp __alltraps
c01020d8:	e9 ef fc ff ff       	jmp    c0101dcc <__alltraps>

c01020dd <vector85>:
.globl vector85
vector85:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $85
c01020df:	6a 55                	push   $0x55
  jmp __alltraps
c01020e1:	e9 e6 fc ff ff       	jmp    c0101dcc <__alltraps>

c01020e6 <vector86>:
.globl vector86
vector86:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $86
c01020e8:	6a 56                	push   $0x56
  jmp __alltraps
c01020ea:	e9 dd fc ff ff       	jmp    c0101dcc <__alltraps>

c01020ef <vector87>:
.globl vector87
vector87:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $87
c01020f1:	6a 57                	push   $0x57
  jmp __alltraps
c01020f3:	e9 d4 fc ff ff       	jmp    c0101dcc <__alltraps>

c01020f8 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020f8:	6a 00                	push   $0x0
  pushl $88
c01020fa:	6a 58                	push   $0x58
  jmp __alltraps
c01020fc:	e9 cb fc ff ff       	jmp    c0101dcc <__alltraps>

c0102101 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102101:	6a 00                	push   $0x0
  pushl $89
c0102103:	6a 59                	push   $0x59
  jmp __alltraps
c0102105:	e9 c2 fc ff ff       	jmp    c0101dcc <__alltraps>

c010210a <vector90>:
.globl vector90
vector90:
  pushl $0
c010210a:	6a 00                	push   $0x0
  pushl $90
c010210c:	6a 5a                	push   $0x5a
  jmp __alltraps
c010210e:	e9 b9 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102113 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102113:	6a 00                	push   $0x0
  pushl $91
c0102115:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102117:	e9 b0 fc ff ff       	jmp    c0101dcc <__alltraps>

c010211c <vector92>:
.globl vector92
vector92:
  pushl $0
c010211c:	6a 00                	push   $0x0
  pushl $92
c010211e:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102120:	e9 a7 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102125 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102125:	6a 00                	push   $0x0
  pushl $93
c0102127:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102129:	e9 9e fc ff ff       	jmp    c0101dcc <__alltraps>

c010212e <vector94>:
.globl vector94
vector94:
  pushl $0
c010212e:	6a 00                	push   $0x0
  pushl $94
c0102130:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102132:	e9 95 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102137 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102137:	6a 00                	push   $0x0
  pushl $95
c0102139:	6a 5f                	push   $0x5f
  jmp __alltraps
c010213b:	e9 8c fc ff ff       	jmp    c0101dcc <__alltraps>

c0102140 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102140:	6a 00                	push   $0x0
  pushl $96
c0102142:	6a 60                	push   $0x60
  jmp __alltraps
c0102144:	e9 83 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102149 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102149:	6a 00                	push   $0x0
  pushl $97
c010214b:	6a 61                	push   $0x61
  jmp __alltraps
c010214d:	e9 7a fc ff ff       	jmp    c0101dcc <__alltraps>

c0102152 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102152:	6a 00                	push   $0x0
  pushl $98
c0102154:	6a 62                	push   $0x62
  jmp __alltraps
c0102156:	e9 71 fc ff ff       	jmp    c0101dcc <__alltraps>

c010215b <vector99>:
.globl vector99
vector99:
  pushl $0
c010215b:	6a 00                	push   $0x0
  pushl $99
c010215d:	6a 63                	push   $0x63
  jmp __alltraps
c010215f:	e9 68 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102164 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102164:	6a 00                	push   $0x0
  pushl $100
c0102166:	6a 64                	push   $0x64
  jmp __alltraps
c0102168:	e9 5f fc ff ff       	jmp    c0101dcc <__alltraps>

c010216d <vector101>:
.globl vector101
vector101:
  pushl $0
c010216d:	6a 00                	push   $0x0
  pushl $101
c010216f:	6a 65                	push   $0x65
  jmp __alltraps
c0102171:	e9 56 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102176 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102176:	6a 00                	push   $0x0
  pushl $102
c0102178:	6a 66                	push   $0x66
  jmp __alltraps
c010217a:	e9 4d fc ff ff       	jmp    c0101dcc <__alltraps>

c010217f <vector103>:
.globl vector103
vector103:
  pushl $0
c010217f:	6a 00                	push   $0x0
  pushl $103
c0102181:	6a 67                	push   $0x67
  jmp __alltraps
c0102183:	e9 44 fc ff ff       	jmp    c0101dcc <__alltraps>

c0102188 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102188:	6a 00                	push   $0x0
  pushl $104
c010218a:	6a 68                	push   $0x68
  jmp __alltraps
c010218c:	e9 3b fc ff ff       	jmp    c0101dcc <__alltraps>

c0102191 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102191:	6a 00                	push   $0x0
  pushl $105
c0102193:	6a 69                	push   $0x69
  jmp __alltraps
c0102195:	e9 32 fc ff ff       	jmp    c0101dcc <__alltraps>

c010219a <vector106>:
.globl vector106
vector106:
  pushl $0
c010219a:	6a 00                	push   $0x0
  pushl $106
c010219c:	6a 6a                	push   $0x6a
  jmp __alltraps
c010219e:	e9 29 fc ff ff       	jmp    c0101dcc <__alltraps>

c01021a3 <vector107>:
.globl vector107
vector107:
  pushl $0
c01021a3:	6a 00                	push   $0x0
  pushl $107
c01021a5:	6a 6b                	push   $0x6b
  jmp __alltraps
c01021a7:	e9 20 fc ff ff       	jmp    c0101dcc <__alltraps>

c01021ac <vector108>:
.globl vector108
vector108:
  pushl $0
c01021ac:	6a 00                	push   $0x0
  pushl $108
c01021ae:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021b0:	e9 17 fc ff ff       	jmp    c0101dcc <__alltraps>

c01021b5 <vector109>:
.globl vector109
vector109:
  pushl $0
c01021b5:	6a 00                	push   $0x0
  pushl $109
c01021b7:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021b9:	e9 0e fc ff ff       	jmp    c0101dcc <__alltraps>

c01021be <vector110>:
.globl vector110
vector110:
  pushl $0
c01021be:	6a 00                	push   $0x0
  pushl $110
c01021c0:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021c2:	e9 05 fc ff ff       	jmp    c0101dcc <__alltraps>

c01021c7 <vector111>:
.globl vector111
vector111:
  pushl $0
c01021c7:	6a 00                	push   $0x0
  pushl $111
c01021c9:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021cb:	e9 fc fb ff ff       	jmp    c0101dcc <__alltraps>

c01021d0 <vector112>:
.globl vector112
vector112:
  pushl $0
c01021d0:	6a 00                	push   $0x0
  pushl $112
c01021d2:	6a 70                	push   $0x70
  jmp __alltraps
c01021d4:	e9 f3 fb ff ff       	jmp    c0101dcc <__alltraps>

c01021d9 <vector113>:
.globl vector113
vector113:
  pushl $0
c01021d9:	6a 00                	push   $0x0
  pushl $113
c01021db:	6a 71                	push   $0x71
  jmp __alltraps
c01021dd:	e9 ea fb ff ff       	jmp    c0101dcc <__alltraps>

c01021e2 <vector114>:
.globl vector114
vector114:
  pushl $0
c01021e2:	6a 00                	push   $0x0
  pushl $114
c01021e4:	6a 72                	push   $0x72
  jmp __alltraps
c01021e6:	e9 e1 fb ff ff       	jmp    c0101dcc <__alltraps>

c01021eb <vector115>:
.globl vector115
vector115:
  pushl $0
c01021eb:	6a 00                	push   $0x0
  pushl $115
c01021ed:	6a 73                	push   $0x73
  jmp __alltraps
c01021ef:	e9 d8 fb ff ff       	jmp    c0101dcc <__alltraps>

c01021f4 <vector116>:
.globl vector116
vector116:
  pushl $0
c01021f4:	6a 00                	push   $0x0
  pushl $116
c01021f6:	6a 74                	push   $0x74
  jmp __alltraps
c01021f8:	e9 cf fb ff ff       	jmp    c0101dcc <__alltraps>

c01021fd <vector117>:
.globl vector117
vector117:
  pushl $0
c01021fd:	6a 00                	push   $0x0
  pushl $117
c01021ff:	6a 75                	push   $0x75
  jmp __alltraps
c0102201:	e9 c6 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102206 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $118
c0102208:	6a 76                	push   $0x76
  jmp __alltraps
c010220a:	e9 bd fb ff ff       	jmp    c0101dcc <__alltraps>

c010220f <vector119>:
.globl vector119
vector119:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $119
c0102211:	6a 77                	push   $0x77
  jmp __alltraps
c0102213:	e9 b4 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102218 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102218:	6a 00                	push   $0x0
  pushl $120
c010221a:	6a 78                	push   $0x78
  jmp __alltraps
c010221c:	e9 ab fb ff ff       	jmp    c0101dcc <__alltraps>

c0102221 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $121
c0102223:	6a 79                	push   $0x79
  jmp __alltraps
c0102225:	e9 a2 fb ff ff       	jmp    c0101dcc <__alltraps>

c010222a <vector122>:
.globl vector122
vector122:
  pushl $0
c010222a:	6a 00                	push   $0x0
  pushl $122
c010222c:	6a 7a                	push   $0x7a
  jmp __alltraps
c010222e:	e9 99 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102233 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102233:	6a 00                	push   $0x0
  pushl $123
c0102235:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102237:	e9 90 fb ff ff       	jmp    c0101dcc <__alltraps>

c010223c <vector124>:
.globl vector124
vector124:
  pushl $0
c010223c:	6a 00                	push   $0x0
  pushl $124
c010223e:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102240:	e9 87 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102245 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $125
c0102247:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102249:	e9 7e fb ff ff       	jmp    c0101dcc <__alltraps>

c010224e <vector126>:
.globl vector126
vector126:
  pushl $0
c010224e:	6a 00                	push   $0x0
  pushl $126
c0102250:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102252:	e9 75 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102257 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102257:	6a 00                	push   $0x0
  pushl $127
c0102259:	6a 7f                	push   $0x7f
  jmp __alltraps
c010225b:	e9 6c fb ff ff       	jmp    c0101dcc <__alltraps>

c0102260 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102260:	6a 00                	push   $0x0
  pushl $128
c0102262:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102267:	e9 60 fb ff ff       	jmp    c0101dcc <__alltraps>

c010226c <vector129>:
.globl vector129
vector129:
  pushl $0
c010226c:	6a 00                	push   $0x0
  pushl $129
c010226e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102273:	e9 54 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102278 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102278:	6a 00                	push   $0x0
  pushl $130
c010227a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010227f:	e9 48 fb ff ff       	jmp    c0101dcc <__alltraps>

c0102284 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102284:	6a 00                	push   $0x0
  pushl $131
c0102286:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010228b:	e9 3c fb ff ff       	jmp    c0101dcc <__alltraps>

c0102290 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102290:	6a 00                	push   $0x0
  pushl $132
c0102292:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102297:	e9 30 fb ff ff       	jmp    c0101dcc <__alltraps>

c010229c <vector133>:
.globl vector133
vector133:
  pushl $0
c010229c:	6a 00                	push   $0x0
  pushl $133
c010229e:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022a3:	e9 24 fb ff ff       	jmp    c0101dcc <__alltraps>

c01022a8 <vector134>:
.globl vector134
vector134:
  pushl $0
c01022a8:	6a 00                	push   $0x0
  pushl $134
c01022aa:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022af:	e9 18 fb ff ff       	jmp    c0101dcc <__alltraps>

c01022b4 <vector135>:
.globl vector135
vector135:
  pushl $0
c01022b4:	6a 00                	push   $0x0
  pushl $135
c01022b6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022bb:	e9 0c fb ff ff       	jmp    c0101dcc <__alltraps>

c01022c0 <vector136>:
.globl vector136
vector136:
  pushl $0
c01022c0:	6a 00                	push   $0x0
  pushl $136
c01022c2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022c7:	e9 00 fb ff ff       	jmp    c0101dcc <__alltraps>

c01022cc <vector137>:
.globl vector137
vector137:
  pushl $0
c01022cc:	6a 00                	push   $0x0
  pushl $137
c01022ce:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01022d3:	e9 f4 fa ff ff       	jmp    c0101dcc <__alltraps>

c01022d8 <vector138>:
.globl vector138
vector138:
  pushl $0
c01022d8:	6a 00                	push   $0x0
  pushl $138
c01022da:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022df:	e9 e8 fa ff ff       	jmp    c0101dcc <__alltraps>

c01022e4 <vector139>:
.globl vector139
vector139:
  pushl $0
c01022e4:	6a 00                	push   $0x0
  pushl $139
c01022e6:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022eb:	e9 dc fa ff ff       	jmp    c0101dcc <__alltraps>

c01022f0 <vector140>:
.globl vector140
vector140:
  pushl $0
c01022f0:	6a 00                	push   $0x0
  pushl $140
c01022f2:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022f7:	e9 d0 fa ff ff       	jmp    c0101dcc <__alltraps>

c01022fc <vector141>:
.globl vector141
vector141:
  pushl $0
c01022fc:	6a 00                	push   $0x0
  pushl $141
c01022fe:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102303:	e9 c4 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102308 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102308:	6a 00                	push   $0x0
  pushl $142
c010230a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010230f:	e9 b8 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102314 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102314:	6a 00                	push   $0x0
  pushl $143
c0102316:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010231b:	e9 ac fa ff ff       	jmp    c0101dcc <__alltraps>

c0102320 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102320:	6a 00                	push   $0x0
  pushl $144
c0102322:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102327:	e9 a0 fa ff ff       	jmp    c0101dcc <__alltraps>

c010232c <vector145>:
.globl vector145
vector145:
  pushl $0
c010232c:	6a 00                	push   $0x0
  pushl $145
c010232e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102333:	e9 94 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102338 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102338:	6a 00                	push   $0x0
  pushl $146
c010233a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010233f:	e9 88 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102344 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102344:	6a 00                	push   $0x0
  pushl $147
c0102346:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010234b:	e9 7c fa ff ff       	jmp    c0101dcc <__alltraps>

c0102350 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102350:	6a 00                	push   $0x0
  pushl $148
c0102352:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102357:	e9 70 fa ff ff       	jmp    c0101dcc <__alltraps>

c010235c <vector149>:
.globl vector149
vector149:
  pushl $0
c010235c:	6a 00                	push   $0x0
  pushl $149
c010235e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102363:	e9 64 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102368 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102368:	6a 00                	push   $0x0
  pushl $150
c010236a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010236f:	e9 58 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102374 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102374:	6a 00                	push   $0x0
  pushl $151
c0102376:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010237b:	e9 4c fa ff ff       	jmp    c0101dcc <__alltraps>

c0102380 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102380:	6a 00                	push   $0x0
  pushl $152
c0102382:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102387:	e9 40 fa ff ff       	jmp    c0101dcc <__alltraps>

c010238c <vector153>:
.globl vector153
vector153:
  pushl $0
c010238c:	6a 00                	push   $0x0
  pushl $153
c010238e:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102393:	e9 34 fa ff ff       	jmp    c0101dcc <__alltraps>

c0102398 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102398:	6a 00                	push   $0x0
  pushl $154
c010239a:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010239f:	e9 28 fa ff ff       	jmp    c0101dcc <__alltraps>

c01023a4 <vector155>:
.globl vector155
vector155:
  pushl $0
c01023a4:	6a 00                	push   $0x0
  pushl $155
c01023a6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023ab:	e9 1c fa ff ff       	jmp    c0101dcc <__alltraps>

c01023b0 <vector156>:
.globl vector156
vector156:
  pushl $0
c01023b0:	6a 00                	push   $0x0
  pushl $156
c01023b2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023b7:	e9 10 fa ff ff       	jmp    c0101dcc <__alltraps>

c01023bc <vector157>:
.globl vector157
vector157:
  pushl $0
c01023bc:	6a 00                	push   $0x0
  pushl $157
c01023be:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023c3:	e9 04 fa ff ff       	jmp    c0101dcc <__alltraps>

c01023c8 <vector158>:
.globl vector158
vector158:
  pushl $0
c01023c8:	6a 00                	push   $0x0
  pushl $158
c01023ca:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01023cf:	e9 f8 f9 ff ff       	jmp    c0101dcc <__alltraps>

c01023d4 <vector159>:
.globl vector159
vector159:
  pushl $0
c01023d4:	6a 00                	push   $0x0
  pushl $159
c01023d6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023db:	e9 ec f9 ff ff       	jmp    c0101dcc <__alltraps>

c01023e0 <vector160>:
.globl vector160
vector160:
  pushl $0
c01023e0:	6a 00                	push   $0x0
  pushl $160
c01023e2:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023e7:	e9 e0 f9 ff ff       	jmp    c0101dcc <__alltraps>

c01023ec <vector161>:
.globl vector161
vector161:
  pushl $0
c01023ec:	6a 00                	push   $0x0
  pushl $161
c01023ee:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023f3:	e9 d4 f9 ff ff       	jmp    c0101dcc <__alltraps>

c01023f8 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023f8:	6a 00                	push   $0x0
  pushl $162
c01023fa:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023ff:	e9 c8 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102404 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102404:	6a 00                	push   $0x0
  pushl $163
c0102406:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010240b:	e9 bc f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102410 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102410:	6a 00                	push   $0x0
  pushl $164
c0102412:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102417:	e9 b0 f9 ff ff       	jmp    c0101dcc <__alltraps>

c010241c <vector165>:
.globl vector165
vector165:
  pushl $0
c010241c:	6a 00                	push   $0x0
  pushl $165
c010241e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102423:	e9 a4 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102428 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102428:	6a 00                	push   $0x0
  pushl $166
c010242a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010242f:	e9 98 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102434 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102434:	6a 00                	push   $0x0
  pushl $167
c0102436:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010243b:	e9 8c f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102440 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102440:	6a 00                	push   $0x0
  pushl $168
c0102442:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102447:	e9 80 f9 ff ff       	jmp    c0101dcc <__alltraps>

c010244c <vector169>:
.globl vector169
vector169:
  pushl $0
c010244c:	6a 00                	push   $0x0
  pushl $169
c010244e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102453:	e9 74 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102458 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102458:	6a 00                	push   $0x0
  pushl $170
c010245a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010245f:	e9 68 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102464 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102464:	6a 00                	push   $0x0
  pushl $171
c0102466:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010246b:	e9 5c f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102470 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102470:	6a 00                	push   $0x0
  pushl $172
c0102472:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102477:	e9 50 f9 ff ff       	jmp    c0101dcc <__alltraps>

c010247c <vector173>:
.globl vector173
vector173:
  pushl $0
c010247c:	6a 00                	push   $0x0
  pushl $173
c010247e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102483:	e9 44 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102488 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102488:	6a 00                	push   $0x0
  pushl $174
c010248a:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010248f:	e9 38 f9 ff ff       	jmp    c0101dcc <__alltraps>

c0102494 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102494:	6a 00                	push   $0x0
  pushl $175
c0102496:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010249b:	e9 2c f9 ff ff       	jmp    c0101dcc <__alltraps>

c01024a0 <vector176>:
.globl vector176
vector176:
  pushl $0
c01024a0:	6a 00                	push   $0x0
  pushl $176
c01024a2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01024a7:	e9 20 f9 ff ff       	jmp    c0101dcc <__alltraps>

c01024ac <vector177>:
.globl vector177
vector177:
  pushl $0
c01024ac:	6a 00                	push   $0x0
  pushl $177
c01024ae:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024b3:	e9 14 f9 ff ff       	jmp    c0101dcc <__alltraps>

c01024b8 <vector178>:
.globl vector178
vector178:
  pushl $0
c01024b8:	6a 00                	push   $0x0
  pushl $178
c01024ba:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024bf:	e9 08 f9 ff ff       	jmp    c0101dcc <__alltraps>

c01024c4 <vector179>:
.globl vector179
vector179:
  pushl $0
c01024c4:	6a 00                	push   $0x0
  pushl $179
c01024c6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024cb:	e9 fc f8 ff ff       	jmp    c0101dcc <__alltraps>

c01024d0 <vector180>:
.globl vector180
vector180:
  pushl $0
c01024d0:	6a 00                	push   $0x0
  pushl $180
c01024d2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01024d7:	e9 f0 f8 ff ff       	jmp    c0101dcc <__alltraps>

c01024dc <vector181>:
.globl vector181
vector181:
  pushl $0
c01024dc:	6a 00                	push   $0x0
  pushl $181
c01024de:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024e3:	e9 e4 f8 ff ff       	jmp    c0101dcc <__alltraps>

c01024e8 <vector182>:
.globl vector182
vector182:
  pushl $0
c01024e8:	6a 00                	push   $0x0
  pushl $182
c01024ea:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024ef:	e9 d8 f8 ff ff       	jmp    c0101dcc <__alltraps>

c01024f4 <vector183>:
.globl vector183
vector183:
  pushl $0
c01024f4:	6a 00                	push   $0x0
  pushl $183
c01024f6:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024fb:	e9 cc f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102500 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102500:	6a 00                	push   $0x0
  pushl $184
c0102502:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102507:	e9 c0 f8 ff ff       	jmp    c0101dcc <__alltraps>

c010250c <vector185>:
.globl vector185
vector185:
  pushl $0
c010250c:	6a 00                	push   $0x0
  pushl $185
c010250e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102513:	e9 b4 f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102518 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102518:	6a 00                	push   $0x0
  pushl $186
c010251a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010251f:	e9 a8 f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102524 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102524:	6a 00                	push   $0x0
  pushl $187
c0102526:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010252b:	e9 9c f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102530 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102530:	6a 00                	push   $0x0
  pushl $188
c0102532:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102537:	e9 90 f8 ff ff       	jmp    c0101dcc <__alltraps>

c010253c <vector189>:
.globl vector189
vector189:
  pushl $0
c010253c:	6a 00                	push   $0x0
  pushl $189
c010253e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102543:	e9 84 f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102548 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102548:	6a 00                	push   $0x0
  pushl $190
c010254a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010254f:	e9 78 f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102554 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102554:	6a 00                	push   $0x0
  pushl $191
c0102556:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010255b:	e9 6c f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102560 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102560:	6a 00                	push   $0x0
  pushl $192
c0102562:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102567:	e9 60 f8 ff ff       	jmp    c0101dcc <__alltraps>

c010256c <vector193>:
.globl vector193
vector193:
  pushl $0
c010256c:	6a 00                	push   $0x0
  pushl $193
c010256e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102573:	e9 54 f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102578 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102578:	6a 00                	push   $0x0
  pushl $194
c010257a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010257f:	e9 48 f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102584 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102584:	6a 00                	push   $0x0
  pushl $195
c0102586:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010258b:	e9 3c f8 ff ff       	jmp    c0101dcc <__alltraps>

c0102590 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102590:	6a 00                	push   $0x0
  pushl $196
c0102592:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102597:	e9 30 f8 ff ff       	jmp    c0101dcc <__alltraps>

c010259c <vector197>:
.globl vector197
vector197:
  pushl $0
c010259c:	6a 00                	push   $0x0
  pushl $197
c010259e:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025a3:	e9 24 f8 ff ff       	jmp    c0101dcc <__alltraps>

c01025a8 <vector198>:
.globl vector198
vector198:
  pushl $0
c01025a8:	6a 00                	push   $0x0
  pushl $198
c01025aa:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025af:	e9 18 f8 ff ff       	jmp    c0101dcc <__alltraps>

c01025b4 <vector199>:
.globl vector199
vector199:
  pushl $0
c01025b4:	6a 00                	push   $0x0
  pushl $199
c01025b6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025bb:	e9 0c f8 ff ff       	jmp    c0101dcc <__alltraps>

c01025c0 <vector200>:
.globl vector200
vector200:
  pushl $0
c01025c0:	6a 00                	push   $0x0
  pushl $200
c01025c2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025c7:	e9 00 f8 ff ff       	jmp    c0101dcc <__alltraps>

c01025cc <vector201>:
.globl vector201
vector201:
  pushl $0
c01025cc:	6a 00                	push   $0x0
  pushl $201
c01025ce:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01025d3:	e9 f4 f7 ff ff       	jmp    c0101dcc <__alltraps>

c01025d8 <vector202>:
.globl vector202
vector202:
  pushl $0
c01025d8:	6a 00                	push   $0x0
  pushl $202
c01025da:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025df:	e9 e8 f7 ff ff       	jmp    c0101dcc <__alltraps>

c01025e4 <vector203>:
.globl vector203
vector203:
  pushl $0
c01025e4:	6a 00                	push   $0x0
  pushl $203
c01025e6:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025eb:	e9 dc f7 ff ff       	jmp    c0101dcc <__alltraps>

c01025f0 <vector204>:
.globl vector204
vector204:
  pushl $0
c01025f0:	6a 00                	push   $0x0
  pushl $204
c01025f2:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025f7:	e9 d0 f7 ff ff       	jmp    c0101dcc <__alltraps>

c01025fc <vector205>:
.globl vector205
vector205:
  pushl $0
c01025fc:	6a 00                	push   $0x0
  pushl $205
c01025fe:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102603:	e9 c4 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102608 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102608:	6a 00                	push   $0x0
  pushl $206
c010260a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010260f:	e9 b8 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102614 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102614:	6a 00                	push   $0x0
  pushl $207
c0102616:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010261b:	e9 ac f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102620 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102620:	6a 00                	push   $0x0
  pushl $208
c0102622:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102627:	e9 a0 f7 ff ff       	jmp    c0101dcc <__alltraps>

c010262c <vector209>:
.globl vector209
vector209:
  pushl $0
c010262c:	6a 00                	push   $0x0
  pushl $209
c010262e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102633:	e9 94 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102638 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102638:	6a 00                	push   $0x0
  pushl $210
c010263a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010263f:	e9 88 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102644 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102644:	6a 00                	push   $0x0
  pushl $211
c0102646:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010264b:	e9 7c f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102650 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102650:	6a 00                	push   $0x0
  pushl $212
c0102652:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102657:	e9 70 f7 ff ff       	jmp    c0101dcc <__alltraps>

c010265c <vector213>:
.globl vector213
vector213:
  pushl $0
c010265c:	6a 00                	push   $0x0
  pushl $213
c010265e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102663:	e9 64 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102668 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102668:	6a 00                	push   $0x0
  pushl $214
c010266a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010266f:	e9 58 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102674 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102674:	6a 00                	push   $0x0
  pushl $215
c0102676:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010267b:	e9 4c f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102680 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102680:	6a 00                	push   $0x0
  pushl $216
c0102682:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102687:	e9 40 f7 ff ff       	jmp    c0101dcc <__alltraps>

c010268c <vector217>:
.globl vector217
vector217:
  pushl $0
c010268c:	6a 00                	push   $0x0
  pushl $217
c010268e:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102693:	e9 34 f7 ff ff       	jmp    c0101dcc <__alltraps>

c0102698 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102698:	6a 00                	push   $0x0
  pushl $218
c010269a:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010269f:	e9 28 f7 ff ff       	jmp    c0101dcc <__alltraps>

c01026a4 <vector219>:
.globl vector219
vector219:
  pushl $0
c01026a4:	6a 00                	push   $0x0
  pushl $219
c01026a6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026ab:	e9 1c f7 ff ff       	jmp    c0101dcc <__alltraps>

c01026b0 <vector220>:
.globl vector220
vector220:
  pushl $0
c01026b0:	6a 00                	push   $0x0
  pushl $220
c01026b2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026b7:	e9 10 f7 ff ff       	jmp    c0101dcc <__alltraps>

c01026bc <vector221>:
.globl vector221
vector221:
  pushl $0
c01026bc:	6a 00                	push   $0x0
  pushl $221
c01026be:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026c3:	e9 04 f7 ff ff       	jmp    c0101dcc <__alltraps>

c01026c8 <vector222>:
.globl vector222
vector222:
  pushl $0
c01026c8:	6a 00                	push   $0x0
  pushl $222
c01026ca:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01026cf:	e9 f8 f6 ff ff       	jmp    c0101dcc <__alltraps>

c01026d4 <vector223>:
.globl vector223
vector223:
  pushl $0
c01026d4:	6a 00                	push   $0x0
  pushl $223
c01026d6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026db:	e9 ec f6 ff ff       	jmp    c0101dcc <__alltraps>

c01026e0 <vector224>:
.globl vector224
vector224:
  pushl $0
c01026e0:	6a 00                	push   $0x0
  pushl $224
c01026e2:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026e7:	e9 e0 f6 ff ff       	jmp    c0101dcc <__alltraps>

c01026ec <vector225>:
.globl vector225
vector225:
  pushl $0
c01026ec:	6a 00                	push   $0x0
  pushl $225
c01026ee:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026f3:	e9 d4 f6 ff ff       	jmp    c0101dcc <__alltraps>

c01026f8 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026f8:	6a 00                	push   $0x0
  pushl $226
c01026fa:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026ff:	e9 c8 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102704 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102704:	6a 00                	push   $0x0
  pushl $227
c0102706:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010270b:	e9 bc f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102710 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102710:	6a 00                	push   $0x0
  pushl $228
c0102712:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102717:	e9 b0 f6 ff ff       	jmp    c0101dcc <__alltraps>

c010271c <vector229>:
.globl vector229
vector229:
  pushl $0
c010271c:	6a 00                	push   $0x0
  pushl $229
c010271e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102723:	e9 a4 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102728 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102728:	6a 00                	push   $0x0
  pushl $230
c010272a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010272f:	e9 98 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102734 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102734:	6a 00                	push   $0x0
  pushl $231
c0102736:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010273b:	e9 8c f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102740 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102740:	6a 00                	push   $0x0
  pushl $232
c0102742:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102747:	e9 80 f6 ff ff       	jmp    c0101dcc <__alltraps>

c010274c <vector233>:
.globl vector233
vector233:
  pushl $0
c010274c:	6a 00                	push   $0x0
  pushl $233
c010274e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102753:	e9 74 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102758 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102758:	6a 00                	push   $0x0
  pushl $234
c010275a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010275f:	e9 68 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102764 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102764:	6a 00                	push   $0x0
  pushl $235
c0102766:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010276b:	e9 5c f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102770 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102770:	6a 00                	push   $0x0
  pushl $236
c0102772:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102777:	e9 50 f6 ff ff       	jmp    c0101dcc <__alltraps>

c010277c <vector237>:
.globl vector237
vector237:
  pushl $0
c010277c:	6a 00                	push   $0x0
  pushl $237
c010277e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102783:	e9 44 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102788 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102788:	6a 00                	push   $0x0
  pushl $238
c010278a:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010278f:	e9 38 f6 ff ff       	jmp    c0101dcc <__alltraps>

c0102794 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102794:	6a 00                	push   $0x0
  pushl $239
c0102796:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010279b:	e9 2c f6 ff ff       	jmp    c0101dcc <__alltraps>

c01027a0 <vector240>:
.globl vector240
vector240:
  pushl $0
c01027a0:	6a 00                	push   $0x0
  pushl $240
c01027a2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01027a7:	e9 20 f6 ff ff       	jmp    c0101dcc <__alltraps>

c01027ac <vector241>:
.globl vector241
vector241:
  pushl $0
c01027ac:	6a 00                	push   $0x0
  pushl $241
c01027ae:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027b3:	e9 14 f6 ff ff       	jmp    c0101dcc <__alltraps>

c01027b8 <vector242>:
.globl vector242
vector242:
  pushl $0
c01027b8:	6a 00                	push   $0x0
  pushl $242
c01027ba:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027bf:	e9 08 f6 ff ff       	jmp    c0101dcc <__alltraps>

c01027c4 <vector243>:
.globl vector243
vector243:
  pushl $0
c01027c4:	6a 00                	push   $0x0
  pushl $243
c01027c6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027cb:	e9 fc f5 ff ff       	jmp    c0101dcc <__alltraps>

c01027d0 <vector244>:
.globl vector244
vector244:
  pushl $0
c01027d0:	6a 00                	push   $0x0
  pushl $244
c01027d2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01027d7:	e9 f0 f5 ff ff       	jmp    c0101dcc <__alltraps>

c01027dc <vector245>:
.globl vector245
vector245:
  pushl $0
c01027dc:	6a 00                	push   $0x0
  pushl $245
c01027de:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027e3:	e9 e4 f5 ff ff       	jmp    c0101dcc <__alltraps>

c01027e8 <vector246>:
.globl vector246
vector246:
  pushl $0
c01027e8:	6a 00                	push   $0x0
  pushl $246
c01027ea:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027ef:	e9 d8 f5 ff ff       	jmp    c0101dcc <__alltraps>

c01027f4 <vector247>:
.globl vector247
vector247:
  pushl $0
c01027f4:	6a 00                	push   $0x0
  pushl $247
c01027f6:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027fb:	e9 cc f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102800 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102800:	6a 00                	push   $0x0
  pushl $248
c0102802:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102807:	e9 c0 f5 ff ff       	jmp    c0101dcc <__alltraps>

c010280c <vector249>:
.globl vector249
vector249:
  pushl $0
c010280c:	6a 00                	push   $0x0
  pushl $249
c010280e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102813:	e9 b4 f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102818 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102818:	6a 00                	push   $0x0
  pushl $250
c010281a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010281f:	e9 a8 f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102824 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102824:	6a 00                	push   $0x0
  pushl $251
c0102826:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010282b:	e9 9c f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102830 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102830:	6a 00                	push   $0x0
  pushl $252
c0102832:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102837:	e9 90 f5 ff ff       	jmp    c0101dcc <__alltraps>

c010283c <vector253>:
.globl vector253
vector253:
  pushl $0
c010283c:	6a 00                	push   $0x0
  pushl $253
c010283e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102843:	e9 84 f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102848 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102848:	6a 00                	push   $0x0
  pushl $254
c010284a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010284f:	e9 78 f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102854 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102854:	6a 00                	push   $0x0
  pushl $255
c0102856:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010285b:	e9 6c f5 ff ff       	jmp    c0101dcc <__alltraps>

c0102860 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102860:	55                   	push   %ebp
c0102861:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102863:	8b 55 08             	mov    0x8(%ebp),%edx
c0102866:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010286b:	29 c2                	sub    %eax,%edx
c010286d:	89 d0                	mov    %edx,%eax
c010286f:	c1 f8 02             	sar    $0x2,%eax
c0102872:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102878:	5d                   	pop    %ebp
c0102879:	c3                   	ret    

c010287a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010287a:	55                   	push   %ebp
c010287b:	89 e5                	mov    %esp,%ebp
c010287d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102880:	8b 45 08             	mov    0x8(%ebp),%eax
c0102883:	89 04 24             	mov    %eax,(%esp)
c0102886:	e8 d5 ff ff ff       	call   c0102860 <page2ppn>
c010288b:	c1 e0 0c             	shl    $0xc,%eax
}
c010288e:	c9                   	leave  
c010288f:	c3                   	ret    

c0102890 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102890:	55                   	push   %ebp
c0102891:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102893:	8b 45 08             	mov    0x8(%ebp),%eax
c0102896:	8b 00                	mov    (%eax),%eax
}
c0102898:	5d                   	pop    %ebp
c0102899:	c3                   	ret    

c010289a <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010289a:	55                   	push   %ebp
c010289b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010289d:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01028a3:	89 10                	mov    %edx,(%eax)
}
c01028a5:	5d                   	pop    %ebp
c01028a6:	c3                   	ret    

c01028a7 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01028a7:	55                   	push   %ebp
c01028a8:	89 e5                	mov    %esp,%ebp
c01028aa:	83 ec 10             	sub    $0x10,%esp
c01028ad:	c7 45 fc 10 af 11 c0 	movl   $0xc011af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01028b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01028ba:	89 50 04             	mov    %edx,0x4(%eax)
c01028bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028c0:	8b 50 04             	mov    0x4(%eax),%edx
c01028c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028c6:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01028c8:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01028cf:	00 00 00 
}
c01028d2:	c9                   	leave  
c01028d3:	c3                   	ret    

c01028d4 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01028d4:	55                   	push   %ebp
c01028d5:	89 e5                	mov    %esp,%ebp
c01028d7:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01028da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01028de:	75 24                	jne    c0102904 <default_init_memmap+0x30>
c01028e0:	c7 44 24 0c 30 65 10 	movl   $0xc0106530,0xc(%esp)
c01028e7:	c0 
c01028e8:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01028ef:	c0 
c01028f0:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01028f7:	00 
c01028f8:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01028ff:	e8 cc e3 ff ff       	call   c0100cd0 <__panic>
    struct Page *p = base;
c0102904:	8b 45 08             	mov    0x8(%ebp),%eax
c0102907:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010290a:	eb 7d                	jmp    c0102989 <default_init_memmap+0xb5>
        assert(PageReserved(p));//确认本页是否为保留页
c010290c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010290f:	83 c0 04             	add    $0x4,%eax
c0102912:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102919:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010291c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010291f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102922:	0f a3 10             	bt     %edx,(%eax)
c0102925:	19 c0                	sbb    %eax,%eax
c0102927:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010292a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010292e:	0f 95 c0             	setne  %al
c0102931:	0f b6 c0             	movzbl %al,%eax
c0102934:	85 c0                	test   %eax,%eax
c0102936:	75 24                	jne    c010295c <default_init_memmap+0x88>
c0102938:	c7 44 24 0c 61 65 10 	movl   $0xc0106561,0xc(%esp)
c010293f:	c0 
c0102940:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102947:	c0 
c0102948:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010294f:	00 
c0102950:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102957:	e8 74 e3 ff ff       	call   c0100cd0 <__panic>
        //设置标志位
        p->flags = p->property = 0;
c010295c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010295f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102966:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102969:	8b 50 08             	mov    0x8(%eax),%edx
c010296c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010296f:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);//清空引用
c0102972:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102979:	00 
c010297a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010297d:	89 04 24             	mov    %eax,(%esp)
c0102980:	e8 15 ff ff ff       	call   c010289a <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102985:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102989:	8b 55 0c             	mov    0xc(%ebp),%edx
c010298c:	89 d0                	mov    %edx,%eax
c010298e:	c1 e0 02             	shl    $0x2,%eax
c0102991:	01 d0                	add    %edx,%eax
c0102993:	c1 e0 02             	shl    $0x2,%eax
c0102996:	89 c2                	mov    %eax,%edx
c0102998:	8b 45 08             	mov    0x8(%ebp),%eax
c010299b:	01 d0                	add    %edx,%eax
c010299d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01029a0:	0f 85 66 ff ff ff    	jne    c010290c <default_init_memmap+0x38>
        //设置标志位
        p->flags = p->property = 0;
        set_page_ref(p, 0);//清空引用
        
    }
    base->property = n; //头一个空闲页 要设置数量
c01029a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029ac:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01029af:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b2:	83 c0 04             	add    $0x4,%eax
c01029b5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01029bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01029bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01029c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01029c5:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;  //说明连续有n个空闲页，属于空闲链表
c01029c8:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c01029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029d1:	01 d0                	add    %edx,%eax
c01029d3:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    list_add_before(&free_list, &(p->page_link));
c01029d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029db:	83 c0 0c             	add    $0xc,%eax
c01029de:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
c01029e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01029e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029eb:	8b 00                	mov    (%eax),%eax
c01029ed:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01029f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01029f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01029f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01029fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a02:	89 10                	mov    %edx,(%eax)
c0102a04:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a07:	8b 10                	mov    (%eax),%edx
c0102a09:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a0c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102a0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a12:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a15:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102a18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a1b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102a1e:	89 10                	mov    %edx,(%eax)
}
c0102a20:	c9                   	leave  
c0102a21:	c3                   	ret    

c0102a22 <default_alloc_pages>:


static struct Page *
default_alloc_pages(size_t n) {
c0102a22:	55                   	push   %ebp
c0102a23:	89 e5                	mov    %esp,%ebp
c0102a25:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102a28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a2c:	75 24                	jne    c0102a52 <default_alloc_pages+0x30>
c0102a2e:	c7 44 24 0c 30 65 10 	movl   $0xc0106530,0xc(%esp)
c0102a35:	c0 
c0102a36:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102a3d:	c0 
c0102a3e:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0102a45:	00 
c0102a46:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102a4d:	e8 7e e2 ff ff       	call   c0100cd0 <__panic>
    if (n > nr_free) { //如果所有的空闲页的加起来的大小都不够，那直接返回NULL
c0102a52:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102a57:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a5a:	73 0a                	jae    c0102a66 <default_alloc_pages+0x44>
        return NULL;
c0102a5c:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a61:	e9 46 01 00 00       	jmp    c0102bac <default_alloc_pages+0x18a>
    }
    struct Page *page = NULL;
c0102a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
c0102a6d:	c7 45 f0 10 af 11 c0 	movl   $0xc011af10,-0x10(%ebp)
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
c0102a74:	eb 1c                	jmp    c0102a92 <default_alloc_pages+0x70>
        // 此处 le2page 就是将 le 的地址 - page_link 在 Page 的偏移 从而找到 Page 的地址
        struct Page *p = le2page(le, page_link);//将地址转换成页的结构
c0102a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a79:	83 e8 0c             	sub    $0xc,%eax
c0102a7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
c0102a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a82:	8b 40 08             	mov    0x8(%eax),%eax
c0102a85:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a88:	72 08                	jb     c0102a92 <default_alloc_pages+0x70>
            page = p;
c0102a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102a90:	eb 18                	jmp    c0102aaa <default_alloc_pages+0x88>
c0102a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102a98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a9b:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
c0102a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102aa1:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102aa8:	75 cc                	jne    c0102a76 <default_alloc_pages+0x54>
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102aaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102aae:	0f 84 f5 00 00 00    	je     c0102ba9 <default_alloc_pages+0x187>
        if (page->property > n) {
c0102ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ab7:	8b 40 08             	mov    0x8(%eax),%eax
c0102aba:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102abd:	0f 86 95 00 00 00    	jbe    c0102b58 <default_alloc_pages+0x136>
            struct Page *p = page + n;
c0102ac3:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ac6:	89 d0                	mov    %edx,%eax
c0102ac8:	c1 e0 02             	shl    $0x2,%eax
c0102acb:	01 d0                	add    %edx,%eax
c0102acd:	c1 e0 02             	shl    $0x2,%eax
c0102ad0:	89 c2                	mov    %eax,%edx
c0102ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ad5:	01 d0                	add    %edx,%eax
c0102ad7:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//如果选中的第一个连续的块大于n，只取其中的大小为n的块
c0102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102add:	8b 40 08             	mov    0x8(%eax),%eax
c0102ae0:	2b 45 08             	sub    0x8(%ebp),%eax
c0102ae3:	89 c2                	mov    %eax,%edx
c0102ae5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ae8:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102aee:	83 c0 04             	add    $0x4,%eax
c0102af1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102af8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102afb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102afe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102b01:	0f ab 10             	bts    %edx,(%eax)
            // 将多出来的插入到 被分配掉的页块 后面
            list_add(le, &(p->page_link));
c0102b04:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b07:	8d 50 0c             	lea    0xc(%eax),%edx
c0102b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0102b10:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102b13:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b16:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102b19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102b1c:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102b1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b22:	8b 40 04             	mov    0x4(%eax),%eax
c0102b25:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b28:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102b2b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b2e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0102b31:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b34:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102b37:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102b3a:	89 10                	mov    %edx,(%eax)
c0102b3c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102b3f:	8b 10                	mov    (%eax),%edx
c0102b41:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102b44:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b47:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b4a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102b4d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b50:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b53:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102b56:	89 10                	mov    %edx,(%eax)
        }
        // 最后在空闲页链表中删除掉原来的空闲页
        list_del(&(page->page_link));
c0102b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b5b:	83 c0 0c             	add    $0xc,%eax
c0102b5e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102b61:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102b64:	8b 40 04             	mov    0x4(%eax),%eax
c0102b67:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102b6a:	8b 12                	mov    (%edx),%edx
c0102b6c:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102b6f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102b72:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102b75:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102b78:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102b7b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102b7e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102b81:	89 10                	mov    %edx,(%eax)
	
        nr_free -= n;//当前空闲页的数目减n
c0102b83:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102b88:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b8b:	a3 18 af 11 c0       	mov    %eax,0xc011af18
        ClearPageProperty(page);
c0102b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b93:	83 c0 04             	add    $0x4,%eax
c0102b96:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102b9d:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ba0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102ba3:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102ba6:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102bac:	c9                   	leave  
c0102bad:	c3                   	ret    

c0102bae <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102bae:	55                   	push   %ebp
c0102baf:	89 e5                	mov    %esp,%ebp
c0102bb1:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102bb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102bbb:	75 24                	jne    c0102be1 <default_free_pages+0x33>
c0102bbd:	c7 44 24 0c 30 65 10 	movl   $0xc0106530,0xc(%esp)
c0102bc4:	c0 
c0102bc5:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102bcc:	c0 
c0102bcd:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c0102bd4:	00 
c0102bd5:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102bdc:	e8 ef e0 ff ff       	call   c0100cd0 <__panic>
    struct Page *p = base;
c0102be1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102be4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102be7:	e9 9d 00 00 00       	jmp    c0102c89 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bef:	83 c0 04             	add    $0x4,%eax
c0102bf2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102bf9:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102bfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bff:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102c02:	0f a3 10             	bt     %edx,(%eax)
c0102c05:	19 c0                	sbb    %eax,%eax
c0102c07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102c0a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102c0e:	0f 95 c0             	setne  %al
c0102c11:	0f b6 c0             	movzbl %al,%eax
c0102c14:	85 c0                	test   %eax,%eax
c0102c16:	75 2c                	jne    c0102c44 <default_free_pages+0x96>
c0102c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c1b:	83 c0 04             	add    $0x4,%eax
c0102c1e:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102c25:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c28:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c2b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102c2e:	0f a3 10             	bt     %edx,(%eax)
c0102c31:	19 c0                	sbb    %eax,%eax
c0102c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102c36:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102c3a:	0f 95 c0             	setne  %al
c0102c3d:	0f b6 c0             	movzbl %al,%eax
c0102c40:	85 c0                	test   %eax,%eax
c0102c42:	74 24                	je     c0102c68 <default_free_pages+0xba>
c0102c44:	c7 44 24 0c 74 65 10 	movl   $0xc0106574,0xc(%esp)
c0102c4b:	c0 
c0102c4c:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102c53:	c0 
c0102c54:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c0102c5b:	00 
c0102c5c:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102c63:	e8 68 e0 ff ff       	call   c0100cd0 <__panic>
        p->flags = 0;//修改标志位
c0102c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c6b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102c72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c79:	00 
c0102c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c7d:	89 04 24             	mov    %eax,(%esp)
c0102c80:	e8 15 fc ff ff       	call   c010289a <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102c85:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102c89:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c8c:	89 d0                	mov    %edx,%eax
c0102c8e:	c1 e0 02             	shl    $0x2,%eax
c0102c91:	01 d0                	add    %edx,%eax
c0102c93:	c1 e0 02             	shl    $0x2,%eax
c0102c96:	89 c2                	mov    %eax,%edx
c0102c98:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c9b:	01 d0                	add    %edx,%eax
c0102c9d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ca0:	0f 85 46 ff ff ff    	jne    c0102bec <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;//修改标志位
        set_page_ref(p, 0);
    }
    base->property = n;//设置连续大小为n
c0102ca6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102cac:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cb2:	83 c0 04             	add    $0x4,%eax
c0102cb5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102cbc:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102cbf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102cc2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102cc5:	0f ab 10             	bts    %edx,(%eax)
c0102cc8:	c7 45 cc 10 af 11 c0 	movl   $0xc011af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102ccf:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102cd2:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 合并到合适的页块中
    while (le != &free_list) {
c0102cd8:	e9 08 01 00 00       	jmp    c0102de5 <default_free_pages+0x237>
        p = le2page(le, page_link);//获取链表对应的Page
c0102cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ce0:	83 e8 0c             	sub    $0xc,%eax
c0102ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ce9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102cec:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102cef:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102cf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cf8:	8b 50 08             	mov    0x8(%eax),%edx
c0102cfb:	89 d0                	mov    %edx,%eax
c0102cfd:	c1 e0 02             	shl    $0x2,%eax
c0102d00:	01 d0                	add    %edx,%eax
c0102d02:	c1 e0 02             	shl    $0x2,%eax
c0102d05:	89 c2                	mov    %eax,%edx
c0102d07:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d0a:	01 d0                	add    %edx,%eax
c0102d0c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102d0f:	75 5a                	jne    c0102d6b <default_free_pages+0x1bd>
            base->property += p->property;
c0102d11:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d14:	8b 50 08             	mov    0x8(%eax),%edx
c0102d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d1a:	8b 40 08             	mov    0x8(%eax),%eax
c0102d1d:	01 c2                	add    %eax,%edx
c0102d1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d22:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d28:	83 c0 04             	add    $0x4,%eax
c0102d2b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102d32:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d35:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102d38:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102d3b:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d41:	83 c0 0c             	add    $0xc,%eax
c0102d44:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d47:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d4a:	8b 40 04             	mov    0x4(%eax),%eax
c0102d4d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d50:	8b 12                	mov    (%edx),%edx
c0102d52:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102d55:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102d58:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d5b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d5e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102d61:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102d64:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102d67:	89 10                	mov    %edx,(%eax)
c0102d69:	eb 7a                	jmp    c0102de5 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d6e:	8b 50 08             	mov    0x8(%eax),%edx
c0102d71:	89 d0                	mov    %edx,%eax
c0102d73:	c1 e0 02             	shl    $0x2,%eax
c0102d76:	01 d0                	add    %edx,%eax
c0102d78:	c1 e0 02             	shl    $0x2,%eax
c0102d7b:	89 c2                	mov    %eax,%edx
c0102d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d80:	01 d0                	add    %edx,%eax
c0102d82:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102d85:	75 5e                	jne    c0102de5 <default_free_pages+0x237>
            p->property += base->property;
c0102d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d8a:	8b 50 08             	mov    0x8(%eax),%edx
c0102d8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d90:	8b 40 08             	mov    0x8(%eax),%eax
c0102d93:	01 c2                	add    %eax,%edx
c0102d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d98:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d9e:	83 c0 04             	add    $0x4,%eax
c0102da1:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102da8:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102dab:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102dae:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102db1:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102db7:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dbd:	83 c0 0c             	add    $0xc,%eax
c0102dc0:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102dc3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102dc6:	8b 40 04             	mov    0x4(%eax),%eax
c0102dc9:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102dcc:	8b 12                	mov    (%edx),%edx
c0102dce:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102dd1:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102dd4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102dd7:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102dda:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102ddd:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102de0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102de3:	89 10                	mov    %edx,(%eax)
    }
    base->property = n;//设置连续大小为n
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    // 合并到合适的页块中
    while (le != &free_list) {
c0102de5:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102dec:	0f 85 eb fe ff ff    	jne    c0102cdd <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0102df2:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102df8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102dfb:	01 d0                	add    %edx,%eax
c0102dfd:	a3 18 af 11 c0       	mov    %eax,0xc011af18
c0102e02:	c7 45 9c 10 af 11 c0 	movl   $0xc011af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102e09:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102e0c:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0102e0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
c0102e12:	eb 36                	jmp    c0102e4a <default_free_pages+0x29c>
        p = le2page(le, page_link);
c0102e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e17:	83 e8 0c             	sub    $0xc,%eax
c0102e1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0102e1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e20:	8b 50 08             	mov    0x8(%eax),%edx
c0102e23:	89 d0                	mov    %edx,%eax
c0102e25:	c1 e0 02             	shl    $0x2,%eax
c0102e28:	01 d0                	add    %edx,%eax
c0102e2a:	c1 e0 02             	shl    $0x2,%eax
c0102e2d:	89 c2                	mov    %eax,%edx
c0102e2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e32:	01 d0                	add    %edx,%eax
c0102e34:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e37:	77 02                	ja     c0102e3b <default_free_pages+0x28d>
            break;
c0102e39:	eb 18                	jmp    c0102e53 <default_free_pages+0x2a5>
c0102e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e3e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102e41:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e44:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0102e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
c0102e4a:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102e51:	75 c1                	jne    c0102e14 <default_free_pages+0x266>
        if (base + base->property <= p) {
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));//将每一空闲块对应的链表插入空闲链表中
c0102e53:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e56:	8d 50 0c             	lea    0xc(%eax),%edx
c0102e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e5c:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102e5f:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102e62:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102e65:	8b 00                	mov    (%eax),%eax
c0102e67:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e6a:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0102e6d:	89 45 88             	mov    %eax,-0x78(%ebp)
c0102e70:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102e73:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102e76:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102e79:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102e7c:	89 10                	mov    %edx,(%eax)
c0102e7e:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102e81:	8b 10                	mov    (%eax),%edx
c0102e83:	8b 45 88             	mov    -0x78(%ebp),%eax
c0102e86:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102e89:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e8c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102e8f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102e92:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e95:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102e98:	89 10                	mov    %edx,(%eax)
}
c0102e9a:	c9                   	leave  
c0102e9b:	c3                   	ret    

c0102e9c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102e9c:	55                   	push   %ebp
c0102e9d:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102e9f:	a1 18 af 11 c0       	mov    0xc011af18,%eax
}
c0102ea4:	5d                   	pop    %ebp
c0102ea5:	c3                   	ret    

c0102ea6 <basic_check>:

static void
basic_check(void) {
c0102ea6:	55                   	push   %ebp
c0102ea7:	89 e5                	mov    %esp,%ebp
c0102ea9:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102eac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ebc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102ebf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102ec6:	e8 ce 0e 00 00       	call   c0103d99 <alloc_pages>
c0102ecb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102ece:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102ed2:	75 24                	jne    c0102ef8 <basic_check+0x52>
c0102ed4:	c7 44 24 0c 99 65 10 	movl   $0xc0106599,0xc(%esp)
c0102edb:	c0 
c0102edc:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102ee3:	c0 
c0102ee4:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0102eeb:	00 
c0102eec:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102ef3:	e8 d8 dd ff ff       	call   c0100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102ef8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102eff:	e8 95 0e 00 00       	call   c0103d99 <alloc_pages>
c0102f04:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102f0b:	75 24                	jne    c0102f31 <basic_check+0x8b>
c0102f0d:	c7 44 24 0c b5 65 10 	movl   $0xc01065b5,0xc(%esp)
c0102f14:	c0 
c0102f15:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102f1c:	c0 
c0102f1d:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0102f24:	00 
c0102f25:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102f2c:	e8 9f dd ff ff       	call   c0100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102f31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f38:	e8 5c 0e 00 00       	call   c0103d99 <alloc_pages>
c0102f3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f44:	75 24                	jne    c0102f6a <basic_check+0xc4>
c0102f46:	c7 44 24 0c d1 65 10 	movl   $0xc01065d1,0xc(%esp)
c0102f4d:	c0 
c0102f4e:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102f55:	c0 
c0102f56:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102f5d:	00 
c0102f5e:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102f65:	e8 66 dd ff ff       	call   c0100cd0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102f6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f6d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102f70:	74 10                	je     c0102f82 <basic_check+0xdc>
c0102f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f75:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102f78:	74 08                	je     c0102f82 <basic_check+0xdc>
c0102f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f7d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102f80:	75 24                	jne    c0102fa6 <basic_check+0x100>
c0102f82:	c7 44 24 0c f0 65 10 	movl   $0xc01065f0,0xc(%esp)
c0102f89:	c0 
c0102f8a:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102f91:	c0 
c0102f92:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0102f99:	00 
c0102f9a:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102fa1:	e8 2a dd ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102fa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fa9:	89 04 24             	mov    %eax,(%esp)
c0102fac:	e8 df f8 ff ff       	call   c0102890 <page_ref>
c0102fb1:	85 c0                	test   %eax,%eax
c0102fb3:	75 1e                	jne    c0102fd3 <basic_check+0x12d>
c0102fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fb8:	89 04 24             	mov    %eax,(%esp)
c0102fbb:	e8 d0 f8 ff ff       	call   c0102890 <page_ref>
c0102fc0:	85 c0                	test   %eax,%eax
c0102fc2:	75 0f                	jne    c0102fd3 <basic_check+0x12d>
c0102fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fc7:	89 04 24             	mov    %eax,(%esp)
c0102fca:	e8 c1 f8 ff ff       	call   c0102890 <page_ref>
c0102fcf:	85 c0                	test   %eax,%eax
c0102fd1:	74 24                	je     c0102ff7 <basic_check+0x151>
c0102fd3:	c7 44 24 0c 14 66 10 	movl   $0xc0106614,0xc(%esp)
c0102fda:	c0 
c0102fdb:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0102fe2:	c0 
c0102fe3:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0102fea:	00 
c0102feb:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0102ff2:	e8 d9 dc ff ff       	call   c0100cd0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0102ff7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ffa:	89 04 24             	mov    %eax,(%esp)
c0102ffd:	e8 78 f8 ff ff       	call   c010287a <page2pa>
c0103002:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103008:	c1 e2 0c             	shl    $0xc,%edx
c010300b:	39 d0                	cmp    %edx,%eax
c010300d:	72 24                	jb     c0103033 <basic_check+0x18d>
c010300f:	c7 44 24 0c 50 66 10 	movl   $0xc0106650,0xc(%esp)
c0103016:	c0 
c0103017:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010301e:	c0 
c010301f:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0103026:	00 
c0103027:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010302e:	e8 9d dc ff ff       	call   c0100cd0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103033:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103036:	89 04 24             	mov    %eax,(%esp)
c0103039:	e8 3c f8 ff ff       	call   c010287a <page2pa>
c010303e:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103044:	c1 e2 0c             	shl    $0xc,%edx
c0103047:	39 d0                	cmp    %edx,%eax
c0103049:	72 24                	jb     c010306f <basic_check+0x1c9>
c010304b:	c7 44 24 0c 6d 66 10 	movl   $0xc010666d,0xc(%esp)
c0103052:	c0 
c0103053:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010305a:	c0 
c010305b:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103062:	00 
c0103063:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010306a:	e8 61 dc ff ff       	call   c0100cd0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010306f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103072:	89 04 24             	mov    %eax,(%esp)
c0103075:	e8 00 f8 ff ff       	call   c010287a <page2pa>
c010307a:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103080:	c1 e2 0c             	shl    $0xc,%edx
c0103083:	39 d0                	cmp    %edx,%eax
c0103085:	72 24                	jb     c01030ab <basic_check+0x205>
c0103087:	c7 44 24 0c 8a 66 10 	movl   $0xc010668a,0xc(%esp)
c010308e:	c0 
c010308f:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103096:	c0 
c0103097:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010309e:	00 
c010309f:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01030a6:	e8 25 dc ff ff       	call   c0100cd0 <__panic>

    list_entry_t free_list_store = free_list;
c01030ab:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c01030b0:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c01030b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01030bc:	c7 45 e0 10 af 11 c0 	movl   $0xc011af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01030c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01030c9:	89 50 04             	mov    %edx,0x4(%eax)
c01030cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030cf:	8b 50 04             	mov    0x4(%eax),%edx
c01030d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030d5:	89 10                	mov    %edx,(%eax)
c01030d7:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01030de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01030e1:	8b 40 04             	mov    0x4(%eax),%eax
c01030e4:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01030e7:	0f 94 c0             	sete   %al
c01030ea:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01030ed:	85 c0                	test   %eax,%eax
c01030ef:	75 24                	jne    c0103115 <basic_check+0x26f>
c01030f1:	c7 44 24 0c a7 66 10 	movl   $0xc01066a7,0xc(%esp)
c01030f8:	c0 
c01030f9:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103100:	c0 
c0103101:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103108:	00 
c0103109:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103110:	e8 bb db ff ff       	call   c0100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
c0103115:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c010311a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010311d:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0103124:	00 00 00 

    assert(alloc_page() == NULL);
c0103127:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010312e:	e8 66 0c 00 00       	call   c0103d99 <alloc_pages>
c0103133:	85 c0                	test   %eax,%eax
c0103135:	74 24                	je     c010315b <basic_check+0x2b5>
c0103137:	c7 44 24 0c be 66 10 	movl   $0xc01066be,0xc(%esp)
c010313e:	c0 
c010313f:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103146:	c0 
c0103147:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c010314e:	00 
c010314f:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103156:	e8 75 db ff ff       	call   c0100cd0 <__panic>

    free_page(p0);
c010315b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103162:	00 
c0103163:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103166:	89 04 24             	mov    %eax,(%esp)
c0103169:	e8 63 0c 00 00       	call   c0103dd1 <free_pages>
    free_page(p1);
c010316e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103175:	00 
c0103176:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103179:	89 04 24             	mov    %eax,(%esp)
c010317c:	e8 50 0c 00 00       	call   c0103dd1 <free_pages>
    free_page(p2);
c0103181:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103188:	00 
c0103189:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010318c:	89 04 24             	mov    %eax,(%esp)
c010318f:	e8 3d 0c 00 00       	call   c0103dd1 <free_pages>
    assert(nr_free == 3);
c0103194:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103199:	83 f8 03             	cmp    $0x3,%eax
c010319c:	74 24                	je     c01031c2 <basic_check+0x31c>
c010319e:	c7 44 24 0c d3 66 10 	movl   $0xc01066d3,0xc(%esp)
c01031a5:	c0 
c01031a6:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01031ad:	c0 
c01031ae:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01031b5:	00 
c01031b6:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01031bd:	e8 0e db ff ff       	call   c0100cd0 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01031c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031c9:	e8 cb 0b 00 00       	call   c0103d99 <alloc_pages>
c01031ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01031d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01031d5:	75 24                	jne    c01031fb <basic_check+0x355>
c01031d7:	c7 44 24 0c 99 65 10 	movl   $0xc0106599,0xc(%esp)
c01031de:	c0 
c01031df:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01031e6:	c0 
c01031e7:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01031ee:	00 
c01031ef:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01031f6:	e8 d5 da ff ff       	call   c0100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01031fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103202:	e8 92 0b 00 00       	call   c0103d99 <alloc_pages>
c0103207:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010320a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010320e:	75 24                	jne    c0103234 <basic_check+0x38e>
c0103210:	c7 44 24 0c b5 65 10 	movl   $0xc01065b5,0xc(%esp)
c0103217:	c0 
c0103218:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010321f:	c0 
c0103220:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0103227:	00 
c0103228:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010322f:	e8 9c da ff ff       	call   c0100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103234:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010323b:	e8 59 0b 00 00       	call   c0103d99 <alloc_pages>
c0103240:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103243:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103247:	75 24                	jne    c010326d <basic_check+0x3c7>
c0103249:	c7 44 24 0c d1 65 10 	movl   $0xc01065d1,0xc(%esp)
c0103250:	c0 
c0103251:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103258:	c0 
c0103259:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0103260:	00 
c0103261:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103268:	e8 63 da ff ff       	call   c0100cd0 <__panic>

    assert(alloc_page() == NULL);
c010326d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103274:	e8 20 0b 00 00       	call   c0103d99 <alloc_pages>
c0103279:	85 c0                	test   %eax,%eax
c010327b:	74 24                	je     c01032a1 <basic_check+0x3fb>
c010327d:	c7 44 24 0c be 66 10 	movl   $0xc01066be,0xc(%esp)
c0103284:	c0 
c0103285:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010328c:	c0 
c010328d:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103294:	00 
c0103295:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010329c:	e8 2f da ff ff       	call   c0100cd0 <__panic>

    free_page(p0);
c01032a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032a8:	00 
c01032a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032ac:	89 04 24             	mov    %eax,(%esp)
c01032af:	e8 1d 0b 00 00       	call   c0103dd1 <free_pages>
c01032b4:	c7 45 d8 10 af 11 c0 	movl   $0xc011af10,-0x28(%ebp)
c01032bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01032be:	8b 40 04             	mov    0x4(%eax),%eax
c01032c1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01032c4:	0f 94 c0             	sete   %al
c01032c7:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01032ca:	85 c0                	test   %eax,%eax
c01032cc:	74 24                	je     c01032f2 <basic_check+0x44c>
c01032ce:	c7 44 24 0c e0 66 10 	movl   $0xc01066e0,0xc(%esp)
c01032d5:	c0 
c01032d6:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01032dd:	c0 
c01032de:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01032e5:	00 
c01032e6:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01032ed:	e8 de d9 ff ff       	call   c0100cd0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01032f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032f9:	e8 9b 0a 00 00       	call   c0103d99 <alloc_pages>
c01032fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103301:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103304:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103307:	74 24                	je     c010332d <basic_check+0x487>
c0103309:	c7 44 24 0c f8 66 10 	movl   $0xc01066f8,0xc(%esp)
c0103310:	c0 
c0103311:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103318:	c0 
c0103319:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0103320:	00 
c0103321:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103328:	e8 a3 d9 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c010332d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103334:	e8 60 0a 00 00       	call   c0103d99 <alloc_pages>
c0103339:	85 c0                	test   %eax,%eax
c010333b:	74 24                	je     c0103361 <basic_check+0x4bb>
c010333d:	c7 44 24 0c be 66 10 	movl   $0xc01066be,0xc(%esp)
c0103344:	c0 
c0103345:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010334c:	c0 
c010334d:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0103354:	00 
c0103355:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010335c:	e8 6f d9 ff ff       	call   c0100cd0 <__panic>

    assert(nr_free == 0);
c0103361:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103366:	85 c0                	test   %eax,%eax
c0103368:	74 24                	je     c010338e <basic_check+0x4e8>
c010336a:	c7 44 24 0c 11 67 10 	movl   $0xc0106711,0xc(%esp)
c0103371:	c0 
c0103372:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103379:	c0 
c010337a:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0103381:	00 
c0103382:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103389:	e8 42 d9 ff ff       	call   c0100cd0 <__panic>
    free_list = free_list_store;
c010338e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103391:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103394:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c0103399:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    nr_free = nr_free_store;
c010339f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033a2:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_page(p);
c01033a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033ae:	00 
c01033af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01033b2:	89 04 24             	mov    %eax,(%esp)
c01033b5:	e8 17 0a 00 00       	call   c0103dd1 <free_pages>
    free_page(p1);
c01033ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033c1:	00 
c01033c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033c5:	89 04 24             	mov    %eax,(%esp)
c01033c8:	e8 04 0a 00 00       	call   c0103dd1 <free_pages>
    free_page(p2);
c01033cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033d4:	00 
c01033d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d8:	89 04 24             	mov    %eax,(%esp)
c01033db:	e8 f1 09 00 00       	call   c0103dd1 <free_pages>
}
c01033e0:	c9                   	leave  
c01033e1:	c3                   	ret    

c01033e2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01033e2:	55                   	push   %ebp
c01033e3:	89 e5                	mov    %esp,%ebp
c01033e5:	53                   	push   %ebx
c01033e6:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c01033ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01033f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01033fa:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103401:	eb 6b                	jmp    c010346e <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103403:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103406:	83 e8 0c             	sub    $0xc,%eax
c0103409:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010340c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010340f:	83 c0 04             	add    $0x4,%eax
c0103412:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103419:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010341c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010341f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103422:	0f a3 10             	bt     %edx,(%eax)
c0103425:	19 c0                	sbb    %eax,%eax
c0103427:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010342a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010342e:	0f 95 c0             	setne  %al
c0103431:	0f b6 c0             	movzbl %al,%eax
c0103434:	85 c0                	test   %eax,%eax
c0103436:	75 24                	jne    c010345c <default_check+0x7a>
c0103438:	c7 44 24 0c 1e 67 10 	movl   $0xc010671e,0xc(%esp)
c010343f:	c0 
c0103440:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103447:	c0 
c0103448:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010344f:	00 
c0103450:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103457:	e8 74 d8 ff ff       	call   c0100cd0 <__panic>
        count ++, total += p->property;
c010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103460:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103463:	8b 50 08             	mov    0x8(%eax),%edx
c0103466:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103469:	01 d0                	add    %edx,%eax
c010346b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010346e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103471:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103474:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103477:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010347a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010347d:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c0103484:	0f 85 79 ff ff ff    	jne    c0103403 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c010348a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010348d:	e8 71 09 00 00       	call   c0103e03 <nr_free_pages>
c0103492:	39 c3                	cmp    %eax,%ebx
c0103494:	74 24                	je     c01034ba <default_check+0xd8>
c0103496:	c7 44 24 0c 2e 67 10 	movl   $0xc010672e,0xc(%esp)
c010349d:	c0 
c010349e:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01034a5:	c0 
c01034a6:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01034ad:	00 
c01034ae:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01034b5:	e8 16 d8 ff ff       	call   c0100cd0 <__panic>

    basic_check();
c01034ba:	e8 e7 f9 ff ff       	call   c0102ea6 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01034bf:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01034c6:	e8 ce 08 00 00       	call   c0103d99 <alloc_pages>
c01034cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01034ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01034d2:	75 24                	jne    c01034f8 <default_check+0x116>
c01034d4:	c7 44 24 0c 47 67 10 	movl   $0xc0106747,0xc(%esp)
c01034db:	c0 
c01034dc:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01034e3:	c0 
c01034e4:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01034eb:	00 
c01034ec:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01034f3:	e8 d8 d7 ff ff       	call   c0100cd0 <__panic>
    assert(!PageProperty(p0));
c01034f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034fb:	83 c0 04             	add    $0x4,%eax
c01034fe:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103505:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103508:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010350b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010350e:	0f a3 10             	bt     %edx,(%eax)
c0103511:	19 c0                	sbb    %eax,%eax
c0103513:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103516:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010351a:	0f 95 c0             	setne  %al
c010351d:	0f b6 c0             	movzbl %al,%eax
c0103520:	85 c0                	test   %eax,%eax
c0103522:	74 24                	je     c0103548 <default_check+0x166>
c0103524:	c7 44 24 0c 52 67 10 	movl   $0xc0106752,0xc(%esp)
c010352b:	c0 
c010352c:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103533:	c0 
c0103534:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c010353b:	00 
c010353c:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103543:	e8 88 d7 ff ff       	call   c0100cd0 <__panic>

    list_entry_t free_list_store = free_list;
c0103548:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c010354d:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c0103553:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103556:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103559:	c7 45 b4 10 af 11 c0 	movl   $0xc011af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103560:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103563:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103566:	89 50 04             	mov    %edx,0x4(%eax)
c0103569:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010356c:	8b 50 04             	mov    0x4(%eax),%edx
c010356f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103572:	89 10                	mov    %edx,(%eax)
c0103574:	c7 45 b0 10 af 11 c0 	movl   $0xc011af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010357b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010357e:	8b 40 04             	mov    0x4(%eax),%eax
c0103581:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103584:	0f 94 c0             	sete   %al
c0103587:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010358a:	85 c0                	test   %eax,%eax
c010358c:	75 24                	jne    c01035b2 <default_check+0x1d0>
c010358e:	c7 44 24 0c a7 66 10 	movl   $0xc01066a7,0xc(%esp)
c0103595:	c0 
c0103596:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010359d:	c0 
c010359e:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01035a5:	00 
c01035a6:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01035ad:	e8 1e d7 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c01035b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035b9:	e8 db 07 00 00       	call   c0103d99 <alloc_pages>
c01035be:	85 c0                	test   %eax,%eax
c01035c0:	74 24                	je     c01035e6 <default_check+0x204>
c01035c2:	c7 44 24 0c be 66 10 	movl   $0xc01066be,0xc(%esp)
c01035c9:	c0 
c01035ca:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01035d1:	c0 
c01035d2:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01035d9:	00 
c01035da:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01035e1:	e8 ea d6 ff ff       	call   c0100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
c01035e6:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01035eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01035ee:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01035f5:	00 00 00 

    free_pages(p0 + 2, 3);
c01035f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035fb:	83 c0 28             	add    $0x28,%eax
c01035fe:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103605:	00 
c0103606:	89 04 24             	mov    %eax,(%esp)
c0103609:	e8 c3 07 00 00       	call   c0103dd1 <free_pages>
    assert(alloc_pages(4) == NULL);
c010360e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103615:	e8 7f 07 00 00       	call   c0103d99 <alloc_pages>
c010361a:	85 c0                	test   %eax,%eax
c010361c:	74 24                	je     c0103642 <default_check+0x260>
c010361e:	c7 44 24 0c 64 67 10 	movl   $0xc0106764,0xc(%esp)
c0103625:	c0 
c0103626:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010362d:	c0 
c010362e:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0103635:	00 
c0103636:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010363d:	e8 8e d6 ff ff       	call   c0100cd0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103645:	83 c0 28             	add    $0x28,%eax
c0103648:	83 c0 04             	add    $0x4,%eax
c010364b:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103652:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103655:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103658:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010365b:	0f a3 10             	bt     %edx,(%eax)
c010365e:	19 c0                	sbb    %eax,%eax
c0103660:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103663:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103667:	0f 95 c0             	setne  %al
c010366a:	0f b6 c0             	movzbl %al,%eax
c010366d:	85 c0                	test   %eax,%eax
c010366f:	74 0e                	je     c010367f <default_check+0x29d>
c0103671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103674:	83 c0 28             	add    $0x28,%eax
c0103677:	8b 40 08             	mov    0x8(%eax),%eax
c010367a:	83 f8 03             	cmp    $0x3,%eax
c010367d:	74 24                	je     c01036a3 <default_check+0x2c1>
c010367f:	c7 44 24 0c 7c 67 10 	movl   $0xc010677c,0xc(%esp)
c0103686:	c0 
c0103687:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010368e:	c0 
c010368f:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0103696:	00 
c0103697:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010369e:	e8 2d d6 ff ff       	call   c0100cd0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01036a3:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01036aa:	e8 ea 06 00 00       	call   c0103d99 <alloc_pages>
c01036af:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01036b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01036b6:	75 24                	jne    c01036dc <default_check+0x2fa>
c01036b8:	c7 44 24 0c a8 67 10 	movl   $0xc01067a8,0xc(%esp)
c01036bf:	c0 
c01036c0:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01036c7:	c0 
c01036c8:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c01036cf:	00 
c01036d0:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01036d7:	e8 f4 d5 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c01036dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036e3:	e8 b1 06 00 00       	call   c0103d99 <alloc_pages>
c01036e8:	85 c0                	test   %eax,%eax
c01036ea:	74 24                	je     c0103710 <default_check+0x32e>
c01036ec:	c7 44 24 0c be 66 10 	movl   $0xc01066be,0xc(%esp)
c01036f3:	c0 
c01036f4:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01036fb:	c0 
c01036fc:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0103703:	00 
c0103704:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010370b:	e8 c0 d5 ff ff       	call   c0100cd0 <__panic>
    assert(p0 + 2 == p1);
c0103710:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103713:	83 c0 28             	add    $0x28,%eax
c0103716:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103719:	74 24                	je     c010373f <default_check+0x35d>
c010371b:	c7 44 24 0c c6 67 10 	movl   $0xc01067c6,0xc(%esp)
c0103722:	c0 
c0103723:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010372a:	c0 
c010372b:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0103732:	00 
c0103733:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010373a:	e8 91 d5 ff ff       	call   c0100cd0 <__panic>

    p2 = p0 + 1;
c010373f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103742:	83 c0 14             	add    $0x14,%eax
c0103745:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103748:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010374f:	00 
c0103750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103753:	89 04 24             	mov    %eax,(%esp)
c0103756:	e8 76 06 00 00       	call   c0103dd1 <free_pages>
    free_pages(p1, 3);
c010375b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103762:	00 
c0103763:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103766:	89 04 24             	mov    %eax,(%esp)
c0103769:	e8 63 06 00 00       	call   c0103dd1 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010376e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103771:	83 c0 04             	add    $0x4,%eax
c0103774:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010377b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010377e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103781:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103784:	0f a3 10             	bt     %edx,(%eax)
c0103787:	19 c0                	sbb    %eax,%eax
c0103789:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010378c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103790:	0f 95 c0             	setne  %al
c0103793:	0f b6 c0             	movzbl %al,%eax
c0103796:	85 c0                	test   %eax,%eax
c0103798:	74 0b                	je     c01037a5 <default_check+0x3c3>
c010379a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010379d:	8b 40 08             	mov    0x8(%eax),%eax
c01037a0:	83 f8 01             	cmp    $0x1,%eax
c01037a3:	74 24                	je     c01037c9 <default_check+0x3e7>
c01037a5:	c7 44 24 0c d4 67 10 	movl   $0xc01067d4,0xc(%esp)
c01037ac:	c0 
c01037ad:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01037b4:	c0 
c01037b5:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c01037bc:	00 
c01037bd:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01037c4:	e8 07 d5 ff ff       	call   c0100cd0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01037c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037cc:	83 c0 04             	add    $0x4,%eax
c01037cf:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01037d6:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037d9:	8b 45 90             	mov    -0x70(%ebp),%eax
c01037dc:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01037df:	0f a3 10             	bt     %edx,(%eax)
c01037e2:	19 c0                	sbb    %eax,%eax
c01037e4:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01037e7:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01037eb:	0f 95 c0             	setne  %al
c01037ee:	0f b6 c0             	movzbl %al,%eax
c01037f1:	85 c0                	test   %eax,%eax
c01037f3:	74 0b                	je     c0103800 <default_check+0x41e>
c01037f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037f8:	8b 40 08             	mov    0x8(%eax),%eax
c01037fb:	83 f8 03             	cmp    $0x3,%eax
c01037fe:	74 24                	je     c0103824 <default_check+0x442>
c0103800:	c7 44 24 0c fc 67 10 	movl   $0xc01067fc,0xc(%esp)
c0103807:	c0 
c0103808:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010380f:	c0 
c0103810:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0103817:	00 
c0103818:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010381f:	e8 ac d4 ff ff       	call   c0100cd0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103824:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010382b:	e8 69 05 00 00       	call   c0103d99 <alloc_pages>
c0103830:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103833:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103836:	83 e8 14             	sub    $0x14,%eax
c0103839:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010383c:	74 24                	je     c0103862 <default_check+0x480>
c010383e:	c7 44 24 0c 22 68 10 	movl   $0xc0106822,0xc(%esp)
c0103845:	c0 
c0103846:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010384d:	c0 
c010384e:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103855:	00 
c0103856:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010385d:	e8 6e d4 ff ff       	call   c0100cd0 <__panic>
    free_page(p0);
c0103862:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103869:	00 
c010386a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010386d:	89 04 24             	mov    %eax,(%esp)
c0103870:	e8 5c 05 00 00       	call   c0103dd1 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103875:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010387c:	e8 18 05 00 00       	call   c0103d99 <alloc_pages>
c0103881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103884:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103887:	83 c0 14             	add    $0x14,%eax
c010388a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010388d:	74 24                	je     c01038b3 <default_check+0x4d1>
c010388f:	c7 44 24 0c 40 68 10 	movl   $0xc0106840,0xc(%esp)
c0103896:	c0 
c0103897:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010389e:	c0 
c010389f:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01038a6:	00 
c01038a7:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01038ae:	e8 1d d4 ff ff       	call   c0100cd0 <__panic>

    free_pages(p0, 2);
c01038b3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01038ba:	00 
c01038bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038be:	89 04 24             	mov    %eax,(%esp)
c01038c1:	e8 0b 05 00 00       	call   c0103dd1 <free_pages>
    free_page(p2);
c01038c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038cd:	00 
c01038ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038d1:	89 04 24             	mov    %eax,(%esp)
c01038d4:	e8 f8 04 00 00       	call   c0103dd1 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01038d9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01038e0:	e8 b4 04 00 00       	call   c0103d99 <alloc_pages>
c01038e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01038ec:	75 24                	jne    c0103912 <default_check+0x530>
c01038ee:	c7 44 24 0c 60 68 10 	movl   $0xc0106860,0xc(%esp)
c01038f5:	c0 
c01038f6:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01038fd:	c0 
c01038fe:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0103905:	00 
c0103906:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010390d:	e8 be d3 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c0103912:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103919:	e8 7b 04 00 00       	call   c0103d99 <alloc_pages>
c010391e:	85 c0                	test   %eax,%eax
c0103920:	74 24                	je     c0103946 <default_check+0x564>
c0103922:	c7 44 24 0c be 66 10 	movl   $0xc01066be,0xc(%esp)
c0103929:	c0 
c010392a:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103931:	c0 
c0103932:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103939:	00 
c010393a:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103941:	e8 8a d3 ff ff       	call   c0100cd0 <__panic>

    assert(nr_free == 0);
c0103946:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c010394b:	85 c0                	test   %eax,%eax
c010394d:	74 24                	je     c0103973 <default_check+0x591>
c010394f:	c7 44 24 0c 11 67 10 	movl   $0xc0106711,0xc(%esp)
c0103956:	c0 
c0103957:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c010395e:	c0 
c010395f:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0103966:	00 
c0103967:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c010396e:	e8 5d d3 ff ff       	call   c0100cd0 <__panic>
    nr_free = nr_free_store;
c0103973:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103976:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_list = free_list_store;
c010397b:	8b 45 80             	mov    -0x80(%ebp),%eax
c010397e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103981:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c0103986:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    free_pages(p0, 5);
c010398c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103993:	00 
c0103994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103997:	89 04 24             	mov    %eax,(%esp)
c010399a:	e8 32 04 00 00       	call   c0103dd1 <free_pages>

    le = &free_list;
c010399f:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01039a6:	eb 5b                	jmp    c0103a03 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
c01039a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039ab:	8b 40 04             	mov    0x4(%eax),%eax
c01039ae:	8b 00                	mov    (%eax),%eax
c01039b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01039b3:	75 0d                	jne    c01039c2 <default_check+0x5e0>
c01039b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039b8:	8b 00                	mov    (%eax),%eax
c01039ba:	8b 40 04             	mov    0x4(%eax),%eax
c01039bd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01039c0:	74 24                	je     c01039e6 <default_check+0x604>
c01039c2:	c7 44 24 0c 80 68 10 	movl   $0xc0106880,0xc(%esp)
c01039c9:	c0 
c01039ca:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c01039d1:	c0 
c01039d2:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01039d9:	00 
c01039da:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c01039e1:	e8 ea d2 ff ff       	call   c0100cd0 <__panic>
        struct Page *p = le2page(le, page_link);
c01039e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039e9:	83 e8 0c             	sub    $0xc,%eax
c01039ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01039ef:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01039f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01039f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01039f9:	8b 40 08             	mov    0x8(%eax),%eax
c01039fc:	29 c2                	sub    %eax,%edx
c01039fe:	89 d0                	mov    %edx,%eax
c0103a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a06:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103a09:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103a0c:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a12:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c0103a19:	75 8d                	jne    c01039a8 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0103a1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a1f:	74 24                	je     c0103a45 <default_check+0x663>
c0103a21:	c7 44 24 0c ad 68 10 	movl   $0xc01068ad,0xc(%esp)
c0103a28:	c0 
c0103a29:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103a30:	c0 
c0103a31:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0103a38:	00 
c0103a39:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103a40:	e8 8b d2 ff ff       	call   c0100cd0 <__panic>
    assert(total == 0);
c0103a45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a49:	74 24                	je     c0103a6f <default_check+0x68d>
c0103a4b:	c7 44 24 0c b8 68 10 	movl   $0xc01068b8,0xc(%esp)
c0103a52:	c0 
c0103a53:	c7 44 24 08 36 65 10 	movl   $0xc0106536,0x8(%esp)
c0103a5a:	c0 
c0103a5b:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0103a62:	00 
c0103a63:	c7 04 24 4b 65 10 c0 	movl   $0xc010654b,(%esp)
c0103a6a:	e8 61 d2 ff ff       	call   c0100cd0 <__panic>
}
c0103a6f:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103a75:	5b                   	pop    %ebx
c0103a76:	5d                   	pop    %ebp
c0103a77:	c3                   	ret    

c0103a78 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103a78:	55                   	push   %ebp
c0103a79:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103a7b:	8b 55 08             	mov    0x8(%ebp),%edx
c0103a7e:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103a83:	29 c2                	sub    %eax,%edx
c0103a85:	89 d0                	mov    %edx,%eax
c0103a87:	c1 f8 02             	sar    $0x2,%eax
c0103a8a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103a90:	5d                   	pop    %ebp
c0103a91:	c3                   	ret    

c0103a92 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103a92:	55                   	push   %ebp
c0103a93:	89 e5                	mov    %esp,%ebp
c0103a95:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a9b:	89 04 24             	mov    %eax,(%esp)
c0103a9e:	e8 d5 ff ff ff       	call   c0103a78 <page2ppn>
c0103aa3:	c1 e0 0c             	shl    $0xc,%eax
}
c0103aa6:	c9                   	leave  
c0103aa7:	c3                   	ret    

c0103aa8 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103aa8:	55                   	push   %ebp
c0103aa9:	89 e5                	mov    %esp,%ebp
c0103aab:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103aae:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab1:	c1 e8 0c             	shr    $0xc,%eax
c0103ab4:	89 c2                	mov    %eax,%edx
c0103ab6:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103abb:	39 c2                	cmp    %eax,%edx
c0103abd:	72 1c                	jb     c0103adb <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103abf:	c7 44 24 08 f4 68 10 	movl   $0xc01068f4,0x8(%esp)
c0103ac6:	c0 
c0103ac7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103ace:	00 
c0103acf:	c7 04 24 13 69 10 c0 	movl   $0xc0106913,(%esp)
c0103ad6:	e8 f5 d1 ff ff       	call   c0100cd0 <__panic>
    }
    return &pages[PPN(pa)];
c0103adb:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103ae1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ae4:	c1 e8 0c             	shr    $0xc,%eax
c0103ae7:	89 c2                	mov    %eax,%edx
c0103ae9:	89 d0                	mov    %edx,%eax
c0103aeb:	c1 e0 02             	shl    $0x2,%eax
c0103aee:	01 d0                	add    %edx,%eax
c0103af0:	c1 e0 02             	shl    $0x2,%eax
c0103af3:	01 c8                	add    %ecx,%eax
}
c0103af5:	c9                   	leave  
c0103af6:	c3                   	ret    

c0103af7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103af7:	55                   	push   %ebp
c0103af8:	89 e5                	mov    %esp,%ebp
c0103afa:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103afd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b00:	89 04 24             	mov    %eax,(%esp)
c0103b03:	e8 8a ff ff ff       	call   c0103a92 <page2pa>
c0103b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b0e:	c1 e8 0c             	shr    $0xc,%eax
c0103b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b14:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b19:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103b1c:	72 23                	jb     c0103b41 <page2kva+0x4a>
c0103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b25:	c7 44 24 08 24 69 10 	movl   $0xc0106924,0x8(%esp)
c0103b2c:	c0 
c0103b2d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103b34:	00 
c0103b35:	c7 04 24 13 69 10 c0 	movl   $0xc0106913,(%esp)
c0103b3c:	e8 8f d1 ff ff       	call   c0100cd0 <__panic>
c0103b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b44:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103b49:	c9                   	leave  
c0103b4a:	c3                   	ret    

c0103b4b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103b4b:	55                   	push   %ebp
c0103b4c:	89 e5                	mov    %esp,%ebp
c0103b4e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b54:	83 e0 01             	and    $0x1,%eax
c0103b57:	85 c0                	test   %eax,%eax
c0103b59:	75 1c                	jne    c0103b77 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103b5b:	c7 44 24 08 48 69 10 	movl   $0xc0106948,0x8(%esp)
c0103b62:	c0 
c0103b63:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103b6a:	00 
c0103b6b:	c7 04 24 13 69 10 c0 	movl   $0xc0106913,(%esp)
c0103b72:	e8 59 d1 ff ff       	call   c0100cd0 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b7f:	89 04 24             	mov    %eax,(%esp)
c0103b82:	e8 21 ff ff ff       	call   c0103aa8 <pa2page>
}
c0103b87:	c9                   	leave  
c0103b88:	c3                   	ret    

c0103b89 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103b89:	55                   	push   %ebp
c0103b8a:	89 e5                	mov    %esp,%ebp
c0103b8c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103b8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b97:	89 04 24             	mov    %eax,(%esp)
c0103b9a:	e8 09 ff ff ff       	call   c0103aa8 <pa2page>
}
c0103b9f:	c9                   	leave  
c0103ba0:	c3                   	ret    

c0103ba1 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103ba1:	55                   	push   %ebp
c0103ba2:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba7:	8b 00                	mov    (%eax),%eax
}
c0103ba9:	5d                   	pop    %ebp
c0103baa:	c3                   	ret    

c0103bab <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
c0103bab:	55                   	push   %ebp
c0103bac:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103bae:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bb1:	8b 00                	mov    (%eax),%eax
c0103bb3:	8d 50 01             	lea    0x1(%eax),%edx
c0103bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bb9:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103bbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bbe:	8b 00                	mov    (%eax),%eax
}
c0103bc0:	5d                   	pop    %ebp
c0103bc1:	c3                   	ret    

c0103bc2 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103bc2:	55                   	push   %ebp
c0103bc3:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103bc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bc8:	8b 00                	mov    (%eax),%eax
c0103bca:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103bcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd5:	8b 00                	mov    (%eax),%eax
}
c0103bd7:	5d                   	pop    %ebp
c0103bd8:	c3                   	ret    

c0103bd9 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103bd9:	55                   	push   %ebp
c0103bda:	89 e5                	mov    %esp,%ebp
c0103bdc:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103bdf:	9c                   	pushf  
c0103be0:	58                   	pop    %eax
c0103be1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103be7:	25 00 02 00 00       	and    $0x200,%eax
c0103bec:	85 c0                	test   %eax,%eax
c0103bee:	74 0c                	je     c0103bfc <__intr_save+0x23>
        intr_disable();
c0103bf0:	e8 cf da ff ff       	call   c01016c4 <intr_disable>
        return 1;
c0103bf5:	b8 01 00 00 00       	mov    $0x1,%eax
c0103bfa:	eb 05                	jmp    c0103c01 <__intr_save+0x28>
    }
    return 0;
c0103bfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103c01:	c9                   	leave  
c0103c02:	c3                   	ret    

c0103c03 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103c03:	55                   	push   %ebp
c0103c04:	89 e5                	mov    %esp,%ebp
c0103c06:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103c09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103c0d:	74 05                	je     c0103c14 <__intr_restore+0x11>
        intr_enable();
c0103c0f:	e8 aa da ff ff       	call   c01016be <intr_enable>
    }
}
c0103c14:	c9                   	leave  
c0103c15:	c3                   	ret    

c0103c16 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103c16:	55                   	push   %ebp
c0103c17:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103c19:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c1c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103c1f:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c24:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103c26:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c2b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103c2d:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c32:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103c34:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c39:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103c3b:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c40:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103c42:	ea 49 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103c49
}
c0103c49:	5d                   	pop    %ebp
c0103c4a:	c3                   	ret    

c0103c4b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103c4b:	55                   	push   %ebp
c0103c4c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103c4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c51:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103c56:	5d                   	pop    %ebp
c0103c57:	c3                   	ret    

c0103c58 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103c58:	55                   	push   %ebp
c0103c59:	89 e5                	mov    %esp,%ebp
c0103c5b:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103c5e:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103c63:	89 04 24             	mov    %eax,(%esp)
c0103c66:	e8 e0 ff ff ff       	call   c0103c4b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103c6b:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103c72:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103c74:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103c7b:	68 00 
c0103c7d:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c82:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103c88:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c8d:	c1 e8 10             	shr    $0x10,%eax
c0103c90:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103c95:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c9c:	83 e0 f0             	and    $0xfffffff0,%eax
c0103c9f:	83 c8 09             	or     $0x9,%eax
c0103ca2:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103ca7:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103cae:	83 e0 ef             	and    $0xffffffef,%eax
c0103cb1:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103cb6:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103cbd:	83 e0 9f             	and    $0xffffff9f,%eax
c0103cc0:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103cc5:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103ccc:	83 c8 80             	or     $0xffffff80,%eax
c0103ccf:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103cd4:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cdb:	83 e0 f0             	and    $0xfffffff0,%eax
c0103cde:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103ce3:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cea:	83 e0 ef             	and    $0xffffffef,%eax
c0103ced:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cf2:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cf9:	83 e0 df             	and    $0xffffffdf,%eax
c0103cfc:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d01:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d08:	83 c8 40             	or     $0x40,%eax
c0103d0b:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d10:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d17:	83 e0 7f             	and    $0x7f,%eax
c0103d1a:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d1f:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103d24:	c1 e8 18             	shr    $0x18,%eax
c0103d27:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103d2c:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103d33:	e8 de fe ff ff       	call   c0103c16 <lgdt>
c0103d38:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103d3e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103d42:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103d45:	c9                   	leave  
c0103d46:	c3                   	ret    

c0103d47 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103d47:	55                   	push   %ebp
c0103d48:	89 e5                	mov    %esp,%ebp
c0103d4a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103d4d:	c7 05 1c af 11 c0 d8 	movl   $0xc01068d8,0xc011af1c
c0103d54:	68 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103d57:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d5c:	8b 00                	mov    (%eax),%eax
c0103d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d62:	c7 04 24 74 69 10 c0 	movl   $0xc0106974,(%esp)
c0103d69:	e8 da c5 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0103d6e:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d73:	8b 40 04             	mov    0x4(%eax),%eax
c0103d76:	ff d0                	call   *%eax
}
c0103d78:	c9                   	leave  
c0103d79:	c3                   	ret    

c0103d7a <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103d7a:	55                   	push   %ebp
c0103d7b:	89 e5                	mov    %esp,%ebp
c0103d7d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103d80:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d85:	8b 40 08             	mov    0x8(%eax),%eax
c0103d88:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103d8b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d8f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d92:	89 14 24             	mov    %edx,(%esp)
c0103d95:	ff d0                	call   *%eax
}
c0103d97:	c9                   	leave  
c0103d98:	c3                   	ret    

c0103d99 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103d99:	55                   	push   %ebp
c0103d9a:	89 e5                	mov    %esp,%ebp
c0103d9c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103d9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103da6:	e8 2e fe ff ff       	call   c0103bd9 <__intr_save>
c0103dab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103dae:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103db3:	8b 40 0c             	mov    0xc(%eax),%eax
c0103db6:	8b 55 08             	mov    0x8(%ebp),%edx
c0103db9:	89 14 24             	mov    %edx,(%esp)
c0103dbc:	ff d0                	call   *%eax
c0103dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103dc4:	89 04 24             	mov    %eax,(%esp)
c0103dc7:	e8 37 fe ff ff       	call   c0103c03 <__intr_restore>
    return page;
c0103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103dcf:	c9                   	leave  
c0103dd0:	c3                   	ret    

c0103dd1 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103dd1:	55                   	push   %ebp
c0103dd2:	89 e5                	mov    %esp,%ebp
c0103dd4:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103dd7:	e8 fd fd ff ff       	call   c0103bd9 <__intr_save>
c0103ddc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103ddf:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103de4:	8b 40 10             	mov    0x10(%eax),%eax
c0103de7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103dea:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dee:	8b 55 08             	mov    0x8(%ebp),%edx
c0103df1:	89 14 24             	mov    %edx,(%esp)
c0103df4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103df9:	89 04 24             	mov    %eax,(%esp)
c0103dfc:	e8 02 fe ff ff       	call   c0103c03 <__intr_restore>
}
c0103e01:	c9                   	leave  
c0103e02:	c3                   	ret    

c0103e03 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103e03:	55                   	push   %ebp
c0103e04:	89 e5                	mov    %esp,%ebp
c0103e06:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e09:	e8 cb fd ff ff       	call   c0103bd9 <__intr_save>
c0103e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103e11:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103e16:	8b 40 14             	mov    0x14(%eax),%eax
c0103e19:	ff d0                	call   *%eax
c0103e1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e21:	89 04 24             	mov    %eax,(%esp)
c0103e24:	e8 da fd ff ff       	call   c0103c03 <__intr_restore>
    return ret;
c0103e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103e2c:	c9                   	leave  
c0103e2d:	c3                   	ret    

c0103e2e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103e2e:	55                   	push   %ebp
c0103e2f:	89 e5                	mov    %esp,%ebp
c0103e31:	57                   	push   %edi
c0103e32:	56                   	push   %esi
c0103e33:	53                   	push   %ebx
c0103e34:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103e3a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103e41:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103e48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103e4f:	c7 04 24 8b 69 10 c0 	movl   $0xc010698b,(%esp)
c0103e56:	e8 ed c4 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e5b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103e62:	e9 15 01 00 00       	jmp    c0103f7c <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103e67:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e6d:	89 d0                	mov    %edx,%eax
c0103e6f:	c1 e0 02             	shl    $0x2,%eax
c0103e72:	01 d0                	add    %edx,%eax
c0103e74:	c1 e0 02             	shl    $0x2,%eax
c0103e77:	01 c8                	add    %ecx,%eax
c0103e79:	8b 50 08             	mov    0x8(%eax),%edx
c0103e7c:	8b 40 04             	mov    0x4(%eax),%eax
c0103e7f:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103e82:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103e85:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e88:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e8b:	89 d0                	mov    %edx,%eax
c0103e8d:	c1 e0 02             	shl    $0x2,%eax
c0103e90:	01 d0                	add    %edx,%eax
c0103e92:	c1 e0 02             	shl    $0x2,%eax
c0103e95:	01 c8                	add    %ecx,%eax
c0103e97:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103e9a:	8b 58 10             	mov    0x10(%eax),%ebx
c0103e9d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ea0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103ea3:	01 c8                	add    %ecx,%eax
c0103ea5:	11 da                	adc    %ebx,%edx
c0103ea7:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103eaa:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103ead:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103eb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eb3:	89 d0                	mov    %edx,%eax
c0103eb5:	c1 e0 02             	shl    $0x2,%eax
c0103eb8:	01 d0                	add    %edx,%eax
c0103eba:	c1 e0 02             	shl    $0x2,%eax
c0103ebd:	01 c8                	add    %ecx,%eax
c0103ebf:	83 c0 14             	add    $0x14,%eax
c0103ec2:	8b 00                	mov    (%eax),%eax
c0103ec4:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103eca:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103ecd:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103ed0:	83 c0 ff             	add    $0xffffffff,%eax
c0103ed3:	83 d2 ff             	adc    $0xffffffff,%edx
c0103ed6:	89 c6                	mov    %eax,%esi
c0103ed8:	89 d7                	mov    %edx,%edi
c0103eda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ee0:	89 d0                	mov    %edx,%eax
c0103ee2:	c1 e0 02             	shl    $0x2,%eax
c0103ee5:	01 d0                	add    %edx,%eax
c0103ee7:	c1 e0 02             	shl    $0x2,%eax
c0103eea:	01 c8                	add    %ecx,%eax
c0103eec:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103eef:	8b 58 10             	mov    0x10(%eax),%ebx
c0103ef2:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103ef8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103efc:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103f00:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103f04:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103f07:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103f0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f0e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103f12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103f16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103f1a:	c7 04 24 98 69 10 c0 	movl   $0xc0106998,(%esp)
c0103f21:	e8 22 c4 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103f26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f29:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f2c:	89 d0                	mov    %edx,%eax
c0103f2e:	c1 e0 02             	shl    $0x2,%eax
c0103f31:	01 d0                	add    %edx,%eax
c0103f33:	c1 e0 02             	shl    $0x2,%eax
c0103f36:	01 c8                	add    %ecx,%eax
c0103f38:	83 c0 14             	add    $0x14,%eax
c0103f3b:	8b 00                	mov    (%eax),%eax
c0103f3d:	83 f8 01             	cmp    $0x1,%eax
c0103f40:	75 36                	jne    c0103f78 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103f42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f48:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f4b:	77 2b                	ja     c0103f78 <page_init+0x14a>
c0103f4d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f50:	72 05                	jb     c0103f57 <page_init+0x129>
c0103f52:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103f55:	73 21                	jae    c0103f78 <page_init+0x14a>
c0103f57:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f5b:	77 1b                	ja     c0103f78 <page_init+0x14a>
c0103f5d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f61:	72 09                	jb     c0103f6c <page_init+0x13e>
c0103f63:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103f6a:	77 0c                	ja     c0103f78 <page_init+0x14a>
                maxpa = end;
c0103f6c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f6f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f72:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103f75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103f78:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103f7c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f7f:	8b 00                	mov    (%eax),%eax
c0103f81:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103f84:	0f 8f dd fe ff ff    	jg     c0103e67 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103f8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f8e:	72 1d                	jb     c0103fad <page_init+0x17f>
c0103f90:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f94:	77 09                	ja     c0103f9f <page_init+0x171>
c0103f96:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103f9d:	76 0e                	jbe    c0103fad <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103f9f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103fa6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fb0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103fb3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103fb7:	c1 ea 0c             	shr    $0xc,%edx
c0103fba:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103fbf:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103fc6:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0103fcb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103fce:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103fd1:	01 d0                	add    %edx,%eax
c0103fd3:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103fd6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103fd9:	ba 00 00 00 00       	mov    $0x0,%edx
c0103fde:	f7 75 ac             	divl   -0x54(%ebp)
c0103fe1:	89 d0                	mov    %edx,%eax
c0103fe3:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103fe6:	29 c2                	sub    %eax,%edx
c0103fe8:	89 d0                	mov    %edx,%eax
c0103fea:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    for (i = 0; i < npage; i ++) {
c0103fef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103ff6:	eb 2f                	jmp    c0104027 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103ff8:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103ffe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104001:	89 d0                	mov    %edx,%eax
c0104003:	c1 e0 02             	shl    $0x2,%eax
c0104006:	01 d0                	add    %edx,%eax
c0104008:	c1 e0 02             	shl    $0x2,%eax
c010400b:	01 c8                	add    %ecx,%eax
c010400d:	83 c0 04             	add    $0x4,%eax
c0104010:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104017:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010401a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010401d:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104020:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104023:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104027:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010402a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010402f:	39 c2                	cmp    %eax,%edx
c0104031:	72 c5                	jb     c0103ff8 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104033:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104039:	89 d0                	mov    %edx,%eax
c010403b:	c1 e0 02             	shl    $0x2,%eax
c010403e:	01 d0                	add    %edx,%eax
c0104040:	c1 e0 02             	shl    $0x2,%eax
c0104043:	89 c2                	mov    %eax,%edx
c0104045:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010404a:	01 d0                	add    %edx,%eax
c010404c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010404f:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104056:	77 23                	ja     c010407b <page_init+0x24d>
c0104058:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010405b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010405f:	c7 44 24 08 c8 69 10 	movl   $0xc01069c8,0x8(%esp)
c0104066:	c0 
c0104067:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010406e:	00 
c010406f:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104076:	e8 55 cc ff ff       	call   c0100cd0 <__panic>
c010407b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010407e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104083:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104086:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010408d:	e9 74 01 00 00       	jmp    c0104206 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104092:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104095:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104098:	89 d0                	mov    %edx,%eax
c010409a:	c1 e0 02             	shl    $0x2,%eax
c010409d:	01 d0                	add    %edx,%eax
c010409f:	c1 e0 02             	shl    $0x2,%eax
c01040a2:	01 c8                	add    %ecx,%eax
c01040a4:	8b 50 08             	mov    0x8(%eax),%edx
c01040a7:	8b 40 04             	mov    0x4(%eax),%eax
c01040aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01040ad:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01040b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040b6:	89 d0                	mov    %edx,%eax
c01040b8:	c1 e0 02             	shl    $0x2,%eax
c01040bb:	01 d0                	add    %edx,%eax
c01040bd:	c1 e0 02             	shl    $0x2,%eax
c01040c0:	01 c8                	add    %ecx,%eax
c01040c2:	8b 48 0c             	mov    0xc(%eax),%ecx
c01040c5:	8b 58 10             	mov    0x10(%eax),%ebx
c01040c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01040ce:	01 c8                	add    %ecx,%eax
c01040d0:	11 da                	adc    %ebx,%edx
c01040d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01040d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01040d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040de:	89 d0                	mov    %edx,%eax
c01040e0:	c1 e0 02             	shl    $0x2,%eax
c01040e3:	01 d0                	add    %edx,%eax
c01040e5:	c1 e0 02             	shl    $0x2,%eax
c01040e8:	01 c8                	add    %ecx,%eax
c01040ea:	83 c0 14             	add    $0x14,%eax
c01040ed:	8b 00                	mov    (%eax),%eax
c01040ef:	83 f8 01             	cmp    $0x1,%eax
c01040f2:	0f 85 0a 01 00 00    	jne    c0104202 <page_init+0x3d4>
            if (begin < freemem) {
c01040f8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040fb:	ba 00 00 00 00       	mov    $0x0,%edx
c0104100:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104103:	72 17                	jb     c010411c <page_init+0x2ee>
c0104105:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104108:	77 05                	ja     c010410f <page_init+0x2e1>
c010410a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010410d:	76 0d                	jbe    c010411c <page_init+0x2ee>
                begin = freemem;
c010410f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104112:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104115:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010411c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104120:	72 1d                	jb     c010413f <page_init+0x311>
c0104122:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104126:	77 09                	ja     c0104131 <page_init+0x303>
c0104128:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010412f:	76 0e                	jbe    c010413f <page_init+0x311>
                end = KMEMSIZE;
c0104131:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104138:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010413f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104142:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104145:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104148:	0f 87 b4 00 00 00    	ja     c0104202 <page_init+0x3d4>
c010414e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104151:	72 09                	jb     c010415c <page_init+0x32e>
c0104153:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104156:	0f 83 a6 00 00 00    	jae    c0104202 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c010415c:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104163:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104166:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104169:	01 d0                	add    %edx,%eax
c010416b:	83 e8 01             	sub    $0x1,%eax
c010416e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104171:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104174:	ba 00 00 00 00       	mov    $0x0,%edx
c0104179:	f7 75 9c             	divl   -0x64(%ebp)
c010417c:	89 d0                	mov    %edx,%eax
c010417e:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104181:	29 c2                	sub    %eax,%edx
c0104183:	89 d0                	mov    %edx,%eax
c0104185:	ba 00 00 00 00       	mov    $0x0,%edx
c010418a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010418d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104190:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104193:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104196:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104199:	ba 00 00 00 00       	mov    $0x0,%edx
c010419e:	89 c7                	mov    %eax,%edi
c01041a0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01041a6:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01041a9:	89 d0                	mov    %edx,%eax
c01041ab:	83 e0 00             	and    $0x0,%eax
c01041ae:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01041b1:	8b 45 80             	mov    -0x80(%ebp),%eax
c01041b4:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01041b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01041ba:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01041bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041c3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041c6:	77 3a                	ja     c0104202 <page_init+0x3d4>
c01041c8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041cb:	72 05                	jb     c01041d2 <page_init+0x3a4>
c01041cd:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01041d0:	73 30                	jae    c0104202 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01041d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01041d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01041d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01041db:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01041de:	29 c8                	sub    %ecx,%eax
c01041e0:	19 da                	sbb    %ebx,%edx
c01041e2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01041e6:	c1 ea 0c             	shr    $0xc,%edx
c01041e9:	89 c3                	mov    %eax,%ebx
c01041eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041ee:	89 04 24             	mov    %eax,(%esp)
c01041f1:	e8 b2 f8 ff ff       	call   c0103aa8 <pa2page>
c01041f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041fa:	89 04 24             	mov    %eax,(%esp)
c01041fd:	e8 78 fb ff ff       	call   c0103d7a <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104202:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104206:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104209:	8b 00                	mov    (%eax),%eax
c010420b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010420e:	0f 8f 7e fe ff ff    	jg     c0104092 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104214:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010421a:	5b                   	pop    %ebx
c010421b:	5e                   	pop    %esi
c010421c:	5f                   	pop    %edi
c010421d:	5d                   	pop    %ebp
c010421e:	c3                   	ret    

c010421f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010421f:	55                   	push   %ebp
c0104220:	89 e5                	mov    %esp,%ebp
c0104222:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104225:	8b 45 14             	mov    0x14(%ebp),%eax
c0104228:	8b 55 0c             	mov    0xc(%ebp),%edx
c010422b:	31 d0                	xor    %edx,%eax
c010422d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104232:	85 c0                	test   %eax,%eax
c0104234:	74 24                	je     c010425a <boot_map_segment+0x3b>
c0104236:	c7 44 24 0c fa 69 10 	movl   $0xc01069fa,0xc(%esp)
c010423d:	c0 
c010423e:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104245:	c0 
c0104246:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010424d:	00 
c010424e:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104255:	e8 76 ca ff ff       	call   c0100cd0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010425a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104261:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104264:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104269:	89 c2                	mov    %eax,%edx
c010426b:	8b 45 10             	mov    0x10(%ebp),%eax
c010426e:	01 c2                	add    %eax,%edx
c0104270:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104273:	01 d0                	add    %edx,%eax
c0104275:	83 e8 01             	sub    $0x1,%eax
c0104278:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010427b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010427e:	ba 00 00 00 00       	mov    $0x0,%edx
c0104283:	f7 75 f0             	divl   -0x10(%ebp)
c0104286:	89 d0                	mov    %edx,%eax
c0104288:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010428b:	29 c2                	sub    %eax,%edx
c010428d:	89 d0                	mov    %edx,%eax
c010428f:	c1 e8 0c             	shr    $0xc,%eax
c0104292:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104295:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104298:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010429b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010429e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042a3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01042a6:	8b 45 14             	mov    0x14(%ebp),%eax
c01042a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01042ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042b4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01042b7:	eb 6b                	jmp    c0104324 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01042b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01042c0:	00 
c01042c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01042cb:	89 04 24             	mov    %eax,(%esp)
c01042ce:	e8 82 01 00 00       	call   c0104455 <get_pte>
c01042d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01042d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042da:	75 24                	jne    c0104300 <boot_map_segment+0xe1>
c01042dc:	c7 44 24 0c 26 6a 10 	movl   $0xc0106a26,0xc(%esp)
c01042e3:	c0 
c01042e4:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01042eb:	c0 
c01042ec:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01042f3:	00 
c01042f4:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01042fb:	e8 d0 c9 ff ff       	call   c0100cd0 <__panic>
        *ptep = pa | PTE_P | perm;
c0104300:	8b 45 18             	mov    0x18(%ebp),%eax
c0104303:	8b 55 14             	mov    0x14(%ebp),%edx
c0104306:	09 d0                	or     %edx,%eax
c0104308:	83 c8 01             	or     $0x1,%eax
c010430b:	89 c2                	mov    %eax,%edx
c010430d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104310:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104312:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104316:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010431d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104324:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104328:	75 8f                	jne    c01042b9 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010432a:	c9                   	leave  
c010432b:	c3                   	ret    

c010432c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010432c:	55                   	push   %ebp
c010432d:	89 e5                	mov    %esp,%ebp
c010432f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104332:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104339:	e8 5b fa ff ff       	call   c0103d99 <alloc_pages>
c010433e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104341:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104345:	75 1c                	jne    c0104363 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104347:	c7 44 24 08 33 6a 10 	movl   $0xc0106a33,0x8(%esp)
c010434e:	c0 
c010434f:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104356:	00 
c0104357:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c010435e:	e8 6d c9 ff ff       	call   c0100cd0 <__panic>
    }
    return page2kva(p);
c0104363:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104366:	89 04 24             	mov    %eax,(%esp)
c0104369:	e8 89 f7 ff ff       	call   c0103af7 <page2kva>
}
c010436e:	c9                   	leave  
c010436f:	c3                   	ret    

c0104370 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104370:	55                   	push   %ebp
c0104371:	89 e5                	mov    %esp,%ebp
c0104373:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104376:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010437b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010437e:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104385:	77 23                	ja     c01043aa <pmm_init+0x3a>
c0104387:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010438a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010438e:	c7 44 24 08 c8 69 10 	movl   $0xc01069c8,0x8(%esp)
c0104395:	c0 
c0104396:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010439d:	00 
c010439e:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01043a5:	e8 26 c9 ff ff       	call   c0100cd0 <__panic>
c01043aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043ad:	05 00 00 00 40       	add    $0x40000000,%eax
c01043b2:	a3 20 af 11 c0       	mov    %eax,0xc011af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01043b7:	e8 8b f9 ff ff       	call   c0103d47 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01043bc:	e8 6d fa ff ff       	call   c0103e2e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01043c1:	e8 4c 02 00 00       	call   c0104612 <check_alloc_page>

    check_pgdir();
c01043c6:	e8 65 02 00 00       	call   c0104630 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01043cb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043d0:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01043d6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043de:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01043e5:	77 23                	ja     c010440a <pmm_init+0x9a>
c01043e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043ee:	c7 44 24 08 c8 69 10 	movl   $0xc01069c8,0x8(%esp)
c01043f5:	c0 
c01043f6:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01043fd:	00 
c01043fe:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104405:	e8 c6 c8 ff ff       	call   c0100cd0 <__panic>
c010440a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010440d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104412:	83 c8 03             	or     $0x3,%eax
c0104415:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104417:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010441c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104423:	00 
c0104424:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010442b:	00 
c010442c:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104433:	38 
c0104434:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010443b:	c0 
c010443c:	89 04 24             	mov    %eax,(%esp)
c010443f:	e8 db fd ff ff       	call   c010421f <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104444:	e8 0f f8 ff ff       	call   c0103c58 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104449:	e8 7d 08 00 00       	call   c0104ccb <check_boot_pgdir>

    print_pgdir();
c010444e:	e8 05 0d 00 00       	call   c0105158 <print_pgdir>

}
c0104453:	c9                   	leave  
c0104454:	c3                   	ret    

c0104455 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104455:	55                   	push   %ebp
c0104456:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c0104458:	5d                   	pop    %ebp
c0104459:	c3                   	ret    

c010445a <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010445a:	55                   	push   %ebp
c010445b:	89 e5                	mov    %esp,%ebp
c010445d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104460:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104467:	00 
c0104468:	8b 45 0c             	mov    0xc(%ebp),%eax
c010446b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010446f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104472:	89 04 24             	mov    %eax,(%esp)
c0104475:	e8 db ff ff ff       	call   c0104455 <get_pte>
c010447a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010447d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104481:	74 08                	je     c010448b <get_page+0x31>
        *ptep_store = ptep;
c0104483:	8b 45 10             	mov    0x10(%ebp),%eax
c0104486:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104489:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010448b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010448f:	74 1b                	je     c01044ac <get_page+0x52>
c0104491:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104494:	8b 00                	mov    (%eax),%eax
c0104496:	83 e0 01             	and    $0x1,%eax
c0104499:	85 c0                	test   %eax,%eax
c010449b:	74 0f                	je     c01044ac <get_page+0x52>
        return pte2page(*ptep);
c010449d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044a0:	8b 00                	mov    (%eax),%eax
c01044a2:	89 04 24             	mov    %eax,(%esp)
c01044a5:	e8 a1 f6 ff ff       	call   c0103b4b <pte2page>
c01044aa:	eb 05                	jmp    c01044b1 <get_page+0x57>
    }
    return NULL;
c01044ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01044b1:	c9                   	leave  
c01044b2:	c3                   	ret    

c01044b3 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01044b3:	55                   	push   %ebp
c01044b4:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c01044b6:	5d                   	pop    %ebp
c01044b7:	c3                   	ret    

c01044b8 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01044b8:	55                   	push   %ebp
c01044b9:	89 e5                	mov    %esp,%ebp
c01044bb:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01044be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044c5:	00 
c01044c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01044d0:	89 04 24             	mov    %eax,(%esp)
c01044d3:	e8 7d ff ff ff       	call   c0104455 <get_pte>
c01044d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c01044db:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01044df:	74 19                	je     c01044fa <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01044e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01044e4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01044e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01044f2:	89 04 24             	mov    %eax,(%esp)
c01044f5:	e8 b9 ff ff ff       	call   c01044b3 <page_remove_pte>
    }
}
c01044fa:	c9                   	leave  
c01044fb:	c3                   	ret    

c01044fc <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01044fc:	55                   	push   %ebp
c01044fd:	89 e5                	mov    %esp,%ebp
c01044ff:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104502:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104509:	00 
c010450a:	8b 45 10             	mov    0x10(%ebp),%eax
c010450d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104511:	8b 45 08             	mov    0x8(%ebp),%eax
c0104514:	89 04 24             	mov    %eax,(%esp)
c0104517:	e8 39 ff ff ff       	call   c0104455 <get_pte>
c010451c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010451f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104523:	75 0a                	jne    c010452f <page_insert+0x33>
        return -E_NO_MEM;
c0104525:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010452a:	e9 84 00 00 00       	jmp    c01045b3 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010452f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104532:	89 04 24             	mov    %eax,(%esp)
c0104535:	e8 71 f6 ff ff       	call   c0103bab <page_ref_inc>
    if (*ptep & PTE_P) {
c010453a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010453d:	8b 00                	mov    (%eax),%eax
c010453f:	83 e0 01             	and    $0x1,%eax
c0104542:	85 c0                	test   %eax,%eax
c0104544:	74 3e                	je     c0104584 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104549:	8b 00                	mov    (%eax),%eax
c010454b:	89 04 24             	mov    %eax,(%esp)
c010454e:	e8 f8 f5 ff ff       	call   c0103b4b <pte2page>
c0104553:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104556:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104559:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010455c:	75 0d                	jne    c010456b <page_insert+0x6f>
            page_ref_dec(page);
c010455e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104561:	89 04 24             	mov    %eax,(%esp)
c0104564:	e8 59 f6 ff ff       	call   c0103bc2 <page_ref_dec>
c0104569:	eb 19                	jmp    c0104584 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010456e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104572:	8b 45 10             	mov    0x10(%ebp),%eax
c0104575:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104579:	8b 45 08             	mov    0x8(%ebp),%eax
c010457c:	89 04 24             	mov    %eax,(%esp)
c010457f:	e8 2f ff ff ff       	call   c01044b3 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104584:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104587:	89 04 24             	mov    %eax,(%esp)
c010458a:	e8 03 f5 ff ff       	call   c0103a92 <page2pa>
c010458f:	0b 45 14             	or     0x14(%ebp),%eax
c0104592:	83 c8 01             	or     $0x1,%eax
c0104595:	89 c2                	mov    %eax,%edx
c0104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010459a:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010459c:	8b 45 10             	mov    0x10(%ebp),%eax
c010459f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a6:	89 04 24             	mov    %eax,(%esp)
c01045a9:	e8 07 00 00 00       	call   c01045b5 <tlb_invalidate>
    return 0;
c01045ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045b3:	c9                   	leave  
c01045b4:	c3                   	ret    

c01045b5 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01045b5:	55                   	push   %ebp
c01045b6:	89 e5                	mov    %esp,%ebp
c01045b8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01045bb:	0f 20 d8             	mov    %cr3,%eax
c01045be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01045c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01045c4:	89 c2                	mov    %eax,%edx
c01045c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045cc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01045d3:	77 23                	ja     c01045f8 <tlb_invalidate+0x43>
c01045d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045dc:	c7 44 24 08 c8 69 10 	movl   $0xc01069c8,0x8(%esp)
c01045e3:	c0 
c01045e4:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c01045eb:	00 
c01045ec:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01045f3:	e8 d8 c6 ff ff       	call   c0100cd0 <__panic>
c01045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045fb:	05 00 00 00 40       	add    $0x40000000,%eax
c0104600:	39 c2                	cmp    %eax,%edx
c0104602:	75 0c                	jne    c0104610 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104604:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104607:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010460a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010460d:	0f 01 38             	invlpg (%eax)
    }
}
c0104610:	c9                   	leave  
c0104611:	c3                   	ret    

c0104612 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104612:	55                   	push   %ebp
c0104613:	89 e5                	mov    %esp,%ebp
c0104615:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104618:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c010461d:	8b 40 18             	mov    0x18(%eax),%eax
c0104620:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104622:	c7 04 24 4c 6a 10 c0 	movl   $0xc0106a4c,(%esp)
c0104629:	e8 1a bd ff ff       	call   c0100348 <cprintf>
}
c010462e:	c9                   	leave  
c010462f:	c3                   	ret    

c0104630 <check_pgdir>:

static void
check_pgdir(void) {
c0104630:	55                   	push   %ebp
c0104631:	89 e5                	mov    %esp,%ebp
c0104633:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104636:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010463b:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104640:	76 24                	jbe    c0104666 <check_pgdir+0x36>
c0104642:	c7 44 24 0c 6b 6a 10 	movl   $0xc0106a6b,0xc(%esp)
c0104649:	c0 
c010464a:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104651:	c0 
c0104652:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0104659:	00 
c010465a:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104661:	e8 6a c6 ff ff       	call   c0100cd0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104666:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010466b:	85 c0                	test   %eax,%eax
c010466d:	74 0e                	je     c010467d <check_pgdir+0x4d>
c010466f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104674:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104679:	85 c0                	test   %eax,%eax
c010467b:	74 24                	je     c01046a1 <check_pgdir+0x71>
c010467d:	c7 44 24 0c 88 6a 10 	movl   $0xc0106a88,0xc(%esp)
c0104684:	c0 
c0104685:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c010468c:	c0 
c010468d:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0104694:	00 
c0104695:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c010469c:	e8 2f c6 ff ff       	call   c0100cd0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01046a1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01046a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01046ad:	00 
c01046ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01046b5:	00 
c01046b6:	89 04 24             	mov    %eax,(%esp)
c01046b9:	e8 9c fd ff ff       	call   c010445a <get_page>
c01046be:	85 c0                	test   %eax,%eax
c01046c0:	74 24                	je     c01046e6 <check_pgdir+0xb6>
c01046c2:	c7 44 24 0c c0 6a 10 	movl   $0xc0106ac0,0xc(%esp)
c01046c9:	c0 
c01046ca:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01046d1:	c0 
c01046d2:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c01046d9:	00 
c01046da:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01046e1:	e8 ea c5 ff ff       	call   c0100cd0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01046e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046ed:	e8 a7 f6 ff ff       	call   c0103d99 <alloc_pages>
c01046f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01046f5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01046fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104701:	00 
c0104702:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104709:	00 
c010470a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010470d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104711:	89 04 24             	mov    %eax,(%esp)
c0104714:	e8 e3 fd ff ff       	call   c01044fc <page_insert>
c0104719:	85 c0                	test   %eax,%eax
c010471b:	74 24                	je     c0104741 <check_pgdir+0x111>
c010471d:	c7 44 24 0c e8 6a 10 	movl   $0xc0106ae8,0xc(%esp)
c0104724:	c0 
c0104725:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c010472c:	c0 
c010472d:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0104734:	00 
c0104735:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c010473c:	e8 8f c5 ff ff       	call   c0100cd0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104741:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104746:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010474d:	00 
c010474e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104755:	00 
c0104756:	89 04 24             	mov    %eax,(%esp)
c0104759:	e8 f7 fc ff ff       	call   c0104455 <get_pte>
c010475e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104761:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104765:	75 24                	jne    c010478b <check_pgdir+0x15b>
c0104767:	c7 44 24 0c 14 6b 10 	movl   $0xc0106b14,0xc(%esp)
c010476e:	c0 
c010476f:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104776:	c0 
c0104777:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c010477e:	00 
c010477f:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104786:	e8 45 c5 ff ff       	call   c0100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
c010478b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010478e:	8b 00                	mov    (%eax),%eax
c0104790:	89 04 24             	mov    %eax,(%esp)
c0104793:	e8 b3 f3 ff ff       	call   c0103b4b <pte2page>
c0104798:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010479b:	74 24                	je     c01047c1 <check_pgdir+0x191>
c010479d:	c7 44 24 0c 41 6b 10 	movl   $0xc0106b41,0xc(%esp)
c01047a4:	c0 
c01047a5:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01047ac:	c0 
c01047ad:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c01047b4:	00 
c01047b5:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01047bc:	e8 0f c5 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p1) == 1);
c01047c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c4:	89 04 24             	mov    %eax,(%esp)
c01047c7:	e8 d5 f3 ff ff       	call   c0103ba1 <page_ref>
c01047cc:	83 f8 01             	cmp    $0x1,%eax
c01047cf:	74 24                	je     c01047f5 <check_pgdir+0x1c5>
c01047d1:	c7 44 24 0c 57 6b 10 	movl   $0xc0106b57,0xc(%esp)
c01047d8:	c0 
c01047d9:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01047e0:	c0 
c01047e1:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c01047e8:	00 
c01047e9:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01047f0:	e8 db c4 ff ff       	call   c0100cd0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01047f5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01047fa:	8b 00                	mov    (%eax),%eax
c01047fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104801:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104804:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104807:	c1 e8 0c             	shr    $0xc,%eax
c010480a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010480d:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104812:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104815:	72 23                	jb     c010483a <check_pgdir+0x20a>
c0104817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010481a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010481e:	c7 44 24 08 24 69 10 	movl   $0xc0106924,0x8(%esp)
c0104825:	c0 
c0104826:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c010482d:	00 
c010482e:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104835:	e8 96 c4 ff ff       	call   c0100cd0 <__panic>
c010483a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010483d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104842:	83 c0 04             	add    $0x4,%eax
c0104845:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104848:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010484d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104854:	00 
c0104855:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010485c:	00 
c010485d:	89 04 24             	mov    %eax,(%esp)
c0104860:	e8 f0 fb ff ff       	call   c0104455 <get_pte>
c0104865:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104868:	74 24                	je     c010488e <check_pgdir+0x25e>
c010486a:	c7 44 24 0c 6c 6b 10 	movl   $0xc0106b6c,0xc(%esp)
c0104871:	c0 
c0104872:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104879:	c0 
c010487a:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c0104881:	00 
c0104882:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104889:	e8 42 c4 ff ff       	call   c0100cd0 <__panic>

    p2 = alloc_page();
c010488e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104895:	e8 ff f4 ff ff       	call   c0103d99 <alloc_pages>
c010489a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010489d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048a2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01048a9:	00 
c01048aa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01048b1:	00 
c01048b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01048b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048b9:	89 04 24             	mov    %eax,(%esp)
c01048bc:	e8 3b fc ff ff       	call   c01044fc <page_insert>
c01048c1:	85 c0                	test   %eax,%eax
c01048c3:	74 24                	je     c01048e9 <check_pgdir+0x2b9>
c01048c5:	c7 44 24 0c 94 6b 10 	movl   $0xc0106b94,0xc(%esp)
c01048cc:	c0 
c01048cd:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01048d4:	c0 
c01048d5:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c01048dc:	00 
c01048dd:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01048e4:	e8 e7 c3 ff ff       	call   c0100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01048e9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048f5:	00 
c01048f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01048fd:	00 
c01048fe:	89 04 24             	mov    %eax,(%esp)
c0104901:	e8 4f fb ff ff       	call   c0104455 <get_pte>
c0104906:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104909:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010490d:	75 24                	jne    c0104933 <check_pgdir+0x303>
c010490f:	c7 44 24 0c cc 6b 10 	movl   $0xc0106bcc,0xc(%esp)
c0104916:	c0 
c0104917:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c010491e:	c0 
c010491f:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0104926:	00 
c0104927:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c010492e:	e8 9d c3 ff ff       	call   c0100cd0 <__panic>
    assert(*ptep & PTE_U);
c0104933:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104936:	8b 00                	mov    (%eax),%eax
c0104938:	83 e0 04             	and    $0x4,%eax
c010493b:	85 c0                	test   %eax,%eax
c010493d:	75 24                	jne    c0104963 <check_pgdir+0x333>
c010493f:	c7 44 24 0c fc 6b 10 	movl   $0xc0106bfc,0xc(%esp)
c0104946:	c0 
c0104947:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c010494e:	c0 
c010494f:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0104956:	00 
c0104957:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c010495e:	e8 6d c3 ff ff       	call   c0100cd0 <__panic>
    assert(*ptep & PTE_W);
c0104963:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104966:	8b 00                	mov    (%eax),%eax
c0104968:	83 e0 02             	and    $0x2,%eax
c010496b:	85 c0                	test   %eax,%eax
c010496d:	75 24                	jne    c0104993 <check_pgdir+0x363>
c010496f:	c7 44 24 0c 0a 6c 10 	movl   $0xc0106c0a,0xc(%esp)
c0104976:	c0 
c0104977:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c010497e:	c0 
c010497f:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0104986:	00 
c0104987:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c010498e:	e8 3d c3 ff ff       	call   c0100cd0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104993:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104998:	8b 00                	mov    (%eax),%eax
c010499a:	83 e0 04             	and    $0x4,%eax
c010499d:	85 c0                	test   %eax,%eax
c010499f:	75 24                	jne    c01049c5 <check_pgdir+0x395>
c01049a1:	c7 44 24 0c 18 6c 10 	movl   $0xc0106c18,0xc(%esp)
c01049a8:	c0 
c01049a9:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01049b0:	c0 
c01049b1:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c01049b8:	00 
c01049b9:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01049c0:	e8 0b c3 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 1);
c01049c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049c8:	89 04 24             	mov    %eax,(%esp)
c01049cb:	e8 d1 f1 ff ff       	call   c0103ba1 <page_ref>
c01049d0:	83 f8 01             	cmp    $0x1,%eax
c01049d3:	74 24                	je     c01049f9 <check_pgdir+0x3c9>
c01049d5:	c7 44 24 0c 2e 6c 10 	movl   $0xc0106c2e,0xc(%esp)
c01049dc:	c0 
c01049dd:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c01049e4:	c0 
c01049e5:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01049ec:	00 
c01049ed:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c01049f4:	e8 d7 c2 ff ff       	call   c0100cd0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01049f9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01049fe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104a05:	00 
c0104a06:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104a0d:	00 
c0104a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a11:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a15:	89 04 24             	mov    %eax,(%esp)
c0104a18:	e8 df fa ff ff       	call   c01044fc <page_insert>
c0104a1d:	85 c0                	test   %eax,%eax
c0104a1f:	74 24                	je     c0104a45 <check_pgdir+0x415>
c0104a21:	c7 44 24 0c 40 6c 10 	movl   $0xc0106c40,0xc(%esp)
c0104a28:	c0 
c0104a29:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104a30:	c0 
c0104a31:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0104a38:	00 
c0104a39:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104a40:	e8 8b c2 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p1) == 2);
c0104a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a48:	89 04 24             	mov    %eax,(%esp)
c0104a4b:	e8 51 f1 ff ff       	call   c0103ba1 <page_ref>
c0104a50:	83 f8 02             	cmp    $0x2,%eax
c0104a53:	74 24                	je     c0104a79 <check_pgdir+0x449>
c0104a55:	c7 44 24 0c 6c 6c 10 	movl   $0xc0106c6c,0xc(%esp)
c0104a5c:	c0 
c0104a5d:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104a64:	c0 
c0104a65:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0104a6c:	00 
c0104a6d:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104a74:	e8 57 c2 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 0);
c0104a79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a7c:	89 04 24             	mov    %eax,(%esp)
c0104a7f:	e8 1d f1 ff ff       	call   c0103ba1 <page_ref>
c0104a84:	85 c0                	test   %eax,%eax
c0104a86:	74 24                	je     c0104aac <check_pgdir+0x47c>
c0104a88:	c7 44 24 0c 7e 6c 10 	movl   $0xc0106c7e,0xc(%esp)
c0104a8f:	c0 
c0104a90:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104a97:	c0 
c0104a98:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0104a9f:	00 
c0104aa0:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104aa7:	e8 24 c2 ff ff       	call   c0100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104aac:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ab1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ab8:	00 
c0104ab9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ac0:	00 
c0104ac1:	89 04 24             	mov    %eax,(%esp)
c0104ac4:	e8 8c f9 ff ff       	call   c0104455 <get_pte>
c0104ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104acc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ad0:	75 24                	jne    c0104af6 <check_pgdir+0x4c6>
c0104ad2:	c7 44 24 0c cc 6b 10 	movl   $0xc0106bcc,0xc(%esp)
c0104ad9:	c0 
c0104ada:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104ae1:	c0 
c0104ae2:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0104ae9:	00 
c0104aea:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104af1:	e8 da c1 ff ff       	call   c0100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
c0104af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104af9:	8b 00                	mov    (%eax),%eax
c0104afb:	89 04 24             	mov    %eax,(%esp)
c0104afe:	e8 48 f0 ff ff       	call   c0103b4b <pte2page>
c0104b03:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b06:	74 24                	je     c0104b2c <check_pgdir+0x4fc>
c0104b08:	c7 44 24 0c 41 6b 10 	movl   $0xc0106b41,0xc(%esp)
c0104b0f:	c0 
c0104b10:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104b17:	c0 
c0104b18:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0104b1f:	00 
c0104b20:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104b27:	e8 a4 c1 ff ff       	call   c0100cd0 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b2f:	8b 00                	mov    (%eax),%eax
c0104b31:	83 e0 04             	and    $0x4,%eax
c0104b34:	85 c0                	test   %eax,%eax
c0104b36:	74 24                	je     c0104b5c <check_pgdir+0x52c>
c0104b38:	c7 44 24 0c 90 6c 10 	movl   $0xc0106c90,0xc(%esp)
c0104b3f:	c0 
c0104b40:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104b47:	c0 
c0104b48:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0104b4f:	00 
c0104b50:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104b57:	e8 74 c1 ff ff       	call   c0100cd0 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104b5c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b68:	00 
c0104b69:	89 04 24             	mov    %eax,(%esp)
c0104b6c:	e8 47 f9 ff ff       	call   c01044b8 <page_remove>
    assert(page_ref(p1) == 1);
c0104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b74:	89 04 24             	mov    %eax,(%esp)
c0104b77:	e8 25 f0 ff ff       	call   c0103ba1 <page_ref>
c0104b7c:	83 f8 01             	cmp    $0x1,%eax
c0104b7f:	74 24                	je     c0104ba5 <check_pgdir+0x575>
c0104b81:	c7 44 24 0c 57 6b 10 	movl   $0xc0106b57,0xc(%esp)
c0104b88:	c0 
c0104b89:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104b90:	c0 
c0104b91:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0104b98:	00 
c0104b99:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104ba0:	e8 2b c1 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 0);
c0104ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ba8:	89 04 24             	mov    %eax,(%esp)
c0104bab:	e8 f1 ef ff ff       	call   c0103ba1 <page_ref>
c0104bb0:	85 c0                	test   %eax,%eax
c0104bb2:	74 24                	je     c0104bd8 <check_pgdir+0x5a8>
c0104bb4:	c7 44 24 0c 7e 6c 10 	movl   $0xc0106c7e,0xc(%esp)
c0104bbb:	c0 
c0104bbc:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104bc3:	c0 
c0104bc4:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104bcb:	00 
c0104bcc:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104bd3:	e8 f8 c0 ff ff       	call   c0100cd0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104bd8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104bdd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104be4:	00 
c0104be5:	89 04 24             	mov    %eax,(%esp)
c0104be8:	e8 cb f8 ff ff       	call   c01044b8 <page_remove>
    assert(page_ref(p1) == 0);
c0104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf0:	89 04 24             	mov    %eax,(%esp)
c0104bf3:	e8 a9 ef ff ff       	call   c0103ba1 <page_ref>
c0104bf8:	85 c0                	test   %eax,%eax
c0104bfa:	74 24                	je     c0104c20 <check_pgdir+0x5f0>
c0104bfc:	c7 44 24 0c a5 6c 10 	movl   $0xc0106ca5,0xc(%esp)
c0104c03:	c0 
c0104c04:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104c0b:	c0 
c0104c0c:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0104c13:	00 
c0104c14:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104c1b:	e8 b0 c0 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 0);
c0104c20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c23:	89 04 24             	mov    %eax,(%esp)
c0104c26:	e8 76 ef ff ff       	call   c0103ba1 <page_ref>
c0104c2b:	85 c0                	test   %eax,%eax
c0104c2d:	74 24                	je     c0104c53 <check_pgdir+0x623>
c0104c2f:	c7 44 24 0c 7e 6c 10 	movl   $0xc0106c7e,0xc(%esp)
c0104c36:	c0 
c0104c37:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104c3e:	c0 
c0104c3f:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104c46:	00 
c0104c47:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104c4e:	e8 7d c0 ff ff       	call   c0100cd0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104c53:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c58:	8b 00                	mov    (%eax),%eax
c0104c5a:	89 04 24             	mov    %eax,(%esp)
c0104c5d:	e8 27 ef ff ff       	call   c0103b89 <pde2page>
c0104c62:	89 04 24             	mov    %eax,(%esp)
c0104c65:	e8 37 ef ff ff       	call   c0103ba1 <page_ref>
c0104c6a:	83 f8 01             	cmp    $0x1,%eax
c0104c6d:	74 24                	je     c0104c93 <check_pgdir+0x663>
c0104c6f:	c7 44 24 0c b8 6c 10 	movl   $0xc0106cb8,0xc(%esp)
c0104c76:	c0 
c0104c77:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104c7e:	c0 
c0104c7f:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104c86:	00 
c0104c87:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104c8e:	e8 3d c0 ff ff       	call   c0100cd0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104c93:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c98:	8b 00                	mov    (%eax),%eax
c0104c9a:	89 04 24             	mov    %eax,(%esp)
c0104c9d:	e8 e7 ee ff ff       	call   c0103b89 <pde2page>
c0104ca2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ca9:	00 
c0104caa:	89 04 24             	mov    %eax,(%esp)
c0104cad:	e8 1f f1 ff ff       	call   c0103dd1 <free_pages>
    boot_pgdir[0] = 0;
c0104cb2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104cb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104cbd:	c7 04 24 df 6c 10 c0 	movl   $0xc0106cdf,(%esp)
c0104cc4:	e8 7f b6 ff ff       	call   c0100348 <cprintf>
}
c0104cc9:	c9                   	leave  
c0104cca:	c3                   	ret    

c0104ccb <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104ccb:	55                   	push   %ebp
c0104ccc:	89 e5                	mov    %esp,%ebp
c0104cce:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104cd1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104cd8:	e9 ca 00 00 00       	jmp    c0104da7 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ce0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ce6:	c1 e8 0c             	shr    $0xc,%eax
c0104ce9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104cec:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104cf1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104cf4:	72 23                	jb     c0104d19 <check_boot_pgdir+0x4e>
c0104cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104cfd:	c7 44 24 08 24 69 10 	movl   $0xc0106924,0x8(%esp)
c0104d04:	c0 
c0104d05:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104d0c:	00 
c0104d0d:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104d14:	e8 b7 bf ff ff       	call   c0100cd0 <__panic>
c0104d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d1c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104d21:	89 c2                	mov    %eax,%edx
c0104d23:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d2f:	00 
c0104d30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104d34:	89 04 24             	mov    %eax,(%esp)
c0104d37:	e8 19 f7 ff ff       	call   c0104455 <get_pte>
c0104d3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104d3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104d43:	75 24                	jne    c0104d69 <check_boot_pgdir+0x9e>
c0104d45:	c7 44 24 0c fc 6c 10 	movl   $0xc0106cfc,0xc(%esp)
c0104d4c:	c0 
c0104d4d:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104d54:	c0 
c0104d55:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104d5c:	00 
c0104d5d:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104d64:	e8 67 bf ff ff       	call   c0100cd0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d6c:	8b 00                	mov    (%eax),%eax
c0104d6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104d73:	89 c2                	mov    %eax,%edx
c0104d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d78:	39 c2                	cmp    %eax,%edx
c0104d7a:	74 24                	je     c0104da0 <check_boot_pgdir+0xd5>
c0104d7c:	c7 44 24 0c 39 6d 10 	movl   $0xc0106d39,0xc(%esp)
c0104d83:	c0 
c0104d84:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104d8b:	c0 
c0104d8c:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104d93:	00 
c0104d94:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104d9b:	e8 30 bf ff ff       	call   c0100cd0 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104da0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104da7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104daa:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104daf:	39 c2                	cmp    %eax,%edx
c0104db1:	0f 82 26 ff ff ff    	jb     c0104cdd <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104db7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dbc:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104dc1:	8b 00                	mov    (%eax),%eax
c0104dc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104dc8:	89 c2                	mov    %eax,%edx
c0104dca:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104dd2:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104dd9:	77 23                	ja     c0104dfe <check_boot_pgdir+0x133>
c0104ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dde:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104de2:	c7 44 24 08 c8 69 10 	movl   $0xc01069c8,0x8(%esp)
c0104de9:	c0 
c0104dea:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104df1:	00 
c0104df2:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104df9:	e8 d2 be ff ff       	call   c0100cd0 <__panic>
c0104dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e01:	05 00 00 00 40       	add    $0x40000000,%eax
c0104e06:	39 c2                	cmp    %eax,%edx
c0104e08:	74 24                	je     c0104e2e <check_boot_pgdir+0x163>
c0104e0a:	c7 44 24 0c 50 6d 10 	movl   $0xc0106d50,0xc(%esp)
c0104e11:	c0 
c0104e12:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104e19:	c0 
c0104e1a:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104e21:	00 
c0104e22:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104e29:	e8 a2 be ff ff       	call   c0100cd0 <__panic>

    assert(boot_pgdir[0] == 0);
c0104e2e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e33:	8b 00                	mov    (%eax),%eax
c0104e35:	85 c0                	test   %eax,%eax
c0104e37:	74 24                	je     c0104e5d <check_boot_pgdir+0x192>
c0104e39:	c7 44 24 0c 84 6d 10 	movl   $0xc0106d84,0xc(%esp)
c0104e40:	c0 
c0104e41:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104e48:	c0 
c0104e49:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104e50:	00 
c0104e51:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104e58:	e8 73 be ff ff       	call   c0100cd0 <__panic>

    struct Page *p;
    p = alloc_page();
c0104e5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e64:	e8 30 ef ff ff       	call   c0103d99 <alloc_pages>
c0104e69:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104e6c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e71:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104e78:	00 
c0104e79:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104e80:	00 
c0104e81:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104e84:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e88:	89 04 24             	mov    %eax,(%esp)
c0104e8b:	e8 6c f6 ff ff       	call   c01044fc <page_insert>
c0104e90:	85 c0                	test   %eax,%eax
c0104e92:	74 24                	je     c0104eb8 <check_boot_pgdir+0x1ed>
c0104e94:	c7 44 24 0c 98 6d 10 	movl   $0xc0106d98,0xc(%esp)
c0104e9b:	c0 
c0104e9c:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104ea3:	c0 
c0104ea4:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104eab:	00 
c0104eac:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104eb3:	e8 18 be ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p) == 1);
c0104eb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ebb:	89 04 24             	mov    %eax,(%esp)
c0104ebe:	e8 de ec ff ff       	call   c0103ba1 <page_ref>
c0104ec3:	83 f8 01             	cmp    $0x1,%eax
c0104ec6:	74 24                	je     c0104eec <check_boot_pgdir+0x221>
c0104ec8:	c7 44 24 0c c6 6d 10 	movl   $0xc0106dc6,0xc(%esp)
c0104ecf:	c0 
c0104ed0:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104ed7:	c0 
c0104ed8:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0104edf:	00 
c0104ee0:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104ee7:	e8 e4 bd ff ff       	call   c0100cd0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104eec:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ef1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104ef8:	00 
c0104ef9:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104f00:	00 
c0104f01:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f04:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f08:	89 04 24             	mov    %eax,(%esp)
c0104f0b:	e8 ec f5 ff ff       	call   c01044fc <page_insert>
c0104f10:	85 c0                	test   %eax,%eax
c0104f12:	74 24                	je     c0104f38 <check_boot_pgdir+0x26d>
c0104f14:	c7 44 24 0c d8 6d 10 	movl   $0xc0106dd8,0xc(%esp)
c0104f1b:	c0 
c0104f1c:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104f23:	c0 
c0104f24:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104f2b:	00 
c0104f2c:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104f33:	e8 98 bd ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p) == 2);
c0104f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f3b:	89 04 24             	mov    %eax,(%esp)
c0104f3e:	e8 5e ec ff ff       	call   c0103ba1 <page_ref>
c0104f43:	83 f8 02             	cmp    $0x2,%eax
c0104f46:	74 24                	je     c0104f6c <check_boot_pgdir+0x2a1>
c0104f48:	c7 44 24 0c 0f 6e 10 	movl   $0xc0106e0f,0xc(%esp)
c0104f4f:	c0 
c0104f50:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104f57:	c0 
c0104f58:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0104f5f:	00 
c0104f60:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104f67:	e8 64 bd ff ff       	call   c0100cd0 <__panic>

    const char *str = "ucore: Hello world!!";
c0104f6c:	c7 45 dc 20 6e 10 c0 	movl   $0xc0106e20,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0104f73:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f7a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104f81:	e8 19 0a 00 00       	call   c010599f <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104f86:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0104f8d:	00 
c0104f8e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104f95:	e8 7e 0a 00 00       	call   c0105a18 <strcmp>
c0104f9a:	85 c0                	test   %eax,%eax
c0104f9c:	74 24                	je     c0104fc2 <check_boot_pgdir+0x2f7>
c0104f9e:	c7 44 24 0c 38 6e 10 	movl   $0xc0106e38,0xc(%esp)
c0104fa5:	c0 
c0104fa6:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104fad:	c0 
c0104fae:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104fb5:	00 
c0104fb6:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0104fbd:	e8 0e bd ff ff       	call   c0100cd0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0104fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fc5:	89 04 24             	mov    %eax,(%esp)
c0104fc8:	e8 2a eb ff ff       	call   c0103af7 <page2kva>
c0104fcd:	05 00 01 00 00       	add    $0x100,%eax
c0104fd2:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0104fd5:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104fdc:	e8 66 09 00 00       	call   c0105947 <strlen>
c0104fe1:	85 c0                	test   %eax,%eax
c0104fe3:	74 24                	je     c0105009 <check_boot_pgdir+0x33e>
c0104fe5:	c7 44 24 0c 70 6e 10 	movl   $0xc0106e70,0xc(%esp)
c0104fec:	c0 
c0104fed:	c7 44 24 08 11 6a 10 	movl   $0xc0106a11,0x8(%esp)
c0104ff4:	c0 
c0104ff5:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104ffc:	00 
c0104ffd:	c7 04 24 ec 69 10 c0 	movl   $0xc01069ec,(%esp)
c0105004:	e8 c7 bc ff ff       	call   c0100cd0 <__panic>

    free_page(p);
c0105009:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105010:	00 
c0105011:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105014:	89 04 24             	mov    %eax,(%esp)
c0105017:	e8 b5 ed ff ff       	call   c0103dd1 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010501c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105021:	8b 00                	mov    (%eax),%eax
c0105023:	89 04 24             	mov    %eax,(%esp)
c0105026:	e8 5e eb ff ff       	call   c0103b89 <pde2page>
c010502b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105032:	00 
c0105033:	89 04 24             	mov    %eax,(%esp)
c0105036:	e8 96 ed ff ff       	call   c0103dd1 <free_pages>
    boot_pgdir[0] = 0;
c010503b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105040:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105046:	c7 04 24 94 6e 10 c0 	movl   $0xc0106e94,(%esp)
c010504d:	e8 f6 b2 ff ff       	call   c0100348 <cprintf>
}
c0105052:	c9                   	leave  
c0105053:	c3                   	ret    

c0105054 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105054:	55                   	push   %ebp
c0105055:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105057:	8b 45 08             	mov    0x8(%ebp),%eax
c010505a:	83 e0 04             	and    $0x4,%eax
c010505d:	85 c0                	test   %eax,%eax
c010505f:	74 07                	je     c0105068 <perm2str+0x14>
c0105061:	b8 75 00 00 00       	mov    $0x75,%eax
c0105066:	eb 05                	jmp    c010506d <perm2str+0x19>
c0105068:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010506d:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0105072:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105079:	8b 45 08             	mov    0x8(%ebp),%eax
c010507c:	83 e0 02             	and    $0x2,%eax
c010507f:	85 c0                	test   %eax,%eax
c0105081:	74 07                	je     c010508a <perm2str+0x36>
c0105083:	b8 77 00 00 00       	mov    $0x77,%eax
c0105088:	eb 05                	jmp    c010508f <perm2str+0x3b>
c010508a:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010508f:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0105094:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c010509b:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c01050a0:	5d                   	pop    %ebp
c01050a1:	c3                   	ret    

c01050a2 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01050a2:	55                   	push   %ebp
c01050a3:	89 e5                	mov    %esp,%ebp
c01050a5:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01050a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01050ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01050ae:	72 0a                	jb     c01050ba <get_pgtable_items+0x18>
        return 0;
c01050b0:	b8 00 00 00 00       	mov    $0x0,%eax
c01050b5:	e9 9c 00 00 00       	jmp    c0105156 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c01050ba:	eb 04                	jmp    c01050c0 <get_pgtable_items+0x1e>
        start ++;
c01050bc:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01050c0:	8b 45 10             	mov    0x10(%ebp),%eax
c01050c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01050c6:	73 18                	jae    c01050e0 <get_pgtable_items+0x3e>
c01050c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01050cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01050d2:	8b 45 14             	mov    0x14(%ebp),%eax
c01050d5:	01 d0                	add    %edx,%eax
c01050d7:	8b 00                	mov    (%eax),%eax
c01050d9:	83 e0 01             	and    $0x1,%eax
c01050dc:	85 c0                	test   %eax,%eax
c01050de:	74 dc                	je     c01050bc <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c01050e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01050e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01050e6:	73 69                	jae    c0105151 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01050e8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01050ec:	74 08                	je     c01050f6 <get_pgtable_items+0x54>
            *left_store = start;
c01050ee:	8b 45 18             	mov    0x18(%ebp),%eax
c01050f1:	8b 55 10             	mov    0x10(%ebp),%edx
c01050f4:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01050f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01050f9:	8d 50 01             	lea    0x1(%eax),%edx
c01050fc:	89 55 10             	mov    %edx,0x10(%ebp)
c01050ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105106:	8b 45 14             	mov    0x14(%ebp),%eax
c0105109:	01 d0                	add    %edx,%eax
c010510b:	8b 00                	mov    (%eax),%eax
c010510d:	83 e0 07             	and    $0x7,%eax
c0105110:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105113:	eb 04                	jmp    c0105119 <get_pgtable_items+0x77>
            start ++;
c0105115:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105119:	8b 45 10             	mov    0x10(%ebp),%eax
c010511c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010511f:	73 1d                	jae    c010513e <get_pgtable_items+0x9c>
c0105121:	8b 45 10             	mov    0x10(%ebp),%eax
c0105124:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010512b:	8b 45 14             	mov    0x14(%ebp),%eax
c010512e:	01 d0                	add    %edx,%eax
c0105130:	8b 00                	mov    (%eax),%eax
c0105132:	83 e0 07             	and    $0x7,%eax
c0105135:	89 c2                	mov    %eax,%edx
c0105137:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010513a:	39 c2                	cmp    %eax,%edx
c010513c:	74 d7                	je     c0105115 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c010513e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105142:	74 08                	je     c010514c <get_pgtable_items+0xaa>
            *right_store = start;
c0105144:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105147:	8b 55 10             	mov    0x10(%ebp),%edx
c010514a:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010514c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010514f:	eb 05                	jmp    c0105156 <get_pgtable_items+0xb4>
    }
    return 0;
c0105151:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105156:	c9                   	leave  
c0105157:	c3                   	ret    

c0105158 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105158:	55                   	push   %ebp
c0105159:	89 e5                	mov    %esp,%ebp
c010515b:	57                   	push   %edi
c010515c:	56                   	push   %esi
c010515d:	53                   	push   %ebx
c010515e:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105161:	c7 04 24 b4 6e 10 c0 	movl   $0xc0106eb4,(%esp)
c0105168:	e8 db b1 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c010516d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105174:	e9 fa 00 00 00       	jmp    c0105273 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010517c:	89 04 24             	mov    %eax,(%esp)
c010517f:	e8 d0 fe ff ff       	call   c0105054 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105184:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105187:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010518a:	29 d1                	sub    %edx,%ecx
c010518c:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010518e:	89 d6                	mov    %edx,%esi
c0105190:	c1 e6 16             	shl    $0x16,%esi
c0105193:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105196:	89 d3                	mov    %edx,%ebx
c0105198:	c1 e3 16             	shl    $0x16,%ebx
c010519b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010519e:	89 d1                	mov    %edx,%ecx
c01051a0:	c1 e1 16             	shl    $0x16,%ecx
c01051a3:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01051a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01051a9:	29 d7                	sub    %edx,%edi
c01051ab:	89 fa                	mov    %edi,%edx
c01051ad:	89 44 24 14          	mov    %eax,0x14(%esp)
c01051b1:	89 74 24 10          	mov    %esi,0x10(%esp)
c01051b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01051b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01051bd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01051c1:	c7 04 24 e5 6e 10 c0 	movl   $0xc0106ee5,(%esp)
c01051c8:	e8 7b b1 ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01051cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051d0:	c1 e0 0a             	shl    $0xa,%eax
c01051d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01051d6:	eb 54                	jmp    c010522c <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01051d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051db:	89 04 24             	mov    %eax,(%esp)
c01051de:	e8 71 fe ff ff       	call   c0105054 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01051e3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01051e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01051e9:	29 d1                	sub    %edx,%ecx
c01051eb:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01051ed:	89 d6                	mov    %edx,%esi
c01051ef:	c1 e6 0c             	shl    $0xc,%esi
c01051f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01051f5:	89 d3                	mov    %edx,%ebx
c01051f7:	c1 e3 0c             	shl    $0xc,%ebx
c01051fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01051fd:	c1 e2 0c             	shl    $0xc,%edx
c0105200:	89 d1                	mov    %edx,%ecx
c0105202:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105205:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105208:	29 d7                	sub    %edx,%edi
c010520a:	89 fa                	mov    %edi,%edx
c010520c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105210:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105214:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010521c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105220:	c7 04 24 04 6f 10 c0 	movl   $0xc0106f04,(%esp)
c0105227:	e8 1c b1 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010522c:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105231:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105234:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105237:	89 ce                	mov    %ecx,%esi
c0105239:	c1 e6 0a             	shl    $0xa,%esi
c010523c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010523f:	89 cb                	mov    %ecx,%ebx
c0105241:	c1 e3 0a             	shl    $0xa,%ebx
c0105244:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105247:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010524b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010524e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105252:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105256:	89 44 24 08          	mov    %eax,0x8(%esp)
c010525a:	89 74 24 04          	mov    %esi,0x4(%esp)
c010525e:	89 1c 24             	mov    %ebx,(%esp)
c0105261:	e8 3c fe ff ff       	call   c01050a2 <get_pgtable_items>
c0105266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105269:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010526d:	0f 85 65 ff ff ff    	jne    c01051d8 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105273:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105278:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010527b:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010527e:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105282:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105285:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105289:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010528d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105291:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105298:	00 
c0105299:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01052a0:	e8 fd fd ff ff       	call   c01050a2 <get_pgtable_items>
c01052a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01052a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01052ac:	0f 85 c7 fe ff ff    	jne    c0105179 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01052b2:	c7 04 24 28 6f 10 c0 	movl   $0xc0106f28,(%esp)
c01052b9:	e8 8a b0 ff ff       	call   c0100348 <cprintf>
}
c01052be:	83 c4 4c             	add    $0x4c,%esp
c01052c1:	5b                   	pop    %ebx
c01052c2:	5e                   	pop    %esi
c01052c3:	5f                   	pop    %edi
c01052c4:	5d                   	pop    %ebp
c01052c5:	c3                   	ret    

c01052c6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01052c6:	55                   	push   %ebp
c01052c7:	89 e5                	mov    %esp,%ebp
c01052c9:	83 ec 58             	sub    $0x58,%esp
c01052cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01052cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01052d2:	8b 45 14             	mov    0x14(%ebp),%eax
c01052d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01052d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01052db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052de:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01052e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01052e4:	8b 45 18             	mov    0x18(%ebp),%eax
c01052e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01052ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01052f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01052f3:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01052f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105300:	74 1c                	je     c010531e <printnum+0x58>
c0105302:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105305:	ba 00 00 00 00       	mov    $0x0,%edx
c010530a:	f7 75 e4             	divl   -0x1c(%ebp)
c010530d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105310:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105313:	ba 00 00 00 00       	mov    $0x0,%edx
c0105318:	f7 75 e4             	divl   -0x1c(%ebp)
c010531b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010531e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105321:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105324:	f7 75 e4             	divl   -0x1c(%ebp)
c0105327:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010532a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010532d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105330:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105333:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105336:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105339:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010533c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010533f:	8b 45 18             	mov    0x18(%ebp),%eax
c0105342:	ba 00 00 00 00       	mov    $0x0,%edx
c0105347:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010534a:	77 56                	ja     c01053a2 <printnum+0xdc>
c010534c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010534f:	72 05                	jb     c0105356 <printnum+0x90>
c0105351:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105354:	77 4c                	ja     c01053a2 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105356:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105359:	8d 50 ff             	lea    -0x1(%eax),%edx
c010535c:	8b 45 20             	mov    0x20(%ebp),%eax
c010535f:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105363:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105367:	8b 45 18             	mov    0x18(%ebp),%eax
c010536a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010536e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105371:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105374:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105378:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010537c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010537f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105383:	8b 45 08             	mov    0x8(%ebp),%eax
c0105386:	89 04 24             	mov    %eax,(%esp)
c0105389:	e8 38 ff ff ff       	call   c01052c6 <printnum>
c010538e:	eb 1c                	jmp    c01053ac <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105390:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105393:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105397:	8b 45 20             	mov    0x20(%ebp),%eax
c010539a:	89 04 24             	mov    %eax,(%esp)
c010539d:	8b 45 08             	mov    0x8(%ebp),%eax
c01053a0:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01053a2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01053a6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01053aa:	7f e4                	jg     c0105390 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01053ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053af:	05 dc 6f 10 c0       	add    $0xc0106fdc,%eax
c01053b4:	0f b6 00             	movzbl (%eax),%eax
c01053b7:	0f be c0             	movsbl %al,%eax
c01053ba:	8b 55 0c             	mov    0xc(%ebp),%edx
c01053bd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053c1:	89 04 24             	mov    %eax,(%esp)
c01053c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01053c7:	ff d0                	call   *%eax
}
c01053c9:	c9                   	leave  
c01053ca:	c3                   	ret    

c01053cb <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01053cb:	55                   	push   %ebp
c01053cc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01053ce:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01053d2:	7e 14                	jle    c01053e8 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01053d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01053d7:	8b 00                	mov    (%eax),%eax
c01053d9:	8d 48 08             	lea    0x8(%eax),%ecx
c01053dc:	8b 55 08             	mov    0x8(%ebp),%edx
c01053df:	89 0a                	mov    %ecx,(%edx)
c01053e1:	8b 50 04             	mov    0x4(%eax),%edx
c01053e4:	8b 00                	mov    (%eax),%eax
c01053e6:	eb 30                	jmp    c0105418 <getuint+0x4d>
    }
    else if (lflag) {
c01053e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01053ec:	74 16                	je     c0105404 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01053ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f1:	8b 00                	mov    (%eax),%eax
c01053f3:	8d 48 04             	lea    0x4(%eax),%ecx
c01053f6:	8b 55 08             	mov    0x8(%ebp),%edx
c01053f9:	89 0a                	mov    %ecx,(%edx)
c01053fb:	8b 00                	mov    (%eax),%eax
c01053fd:	ba 00 00 00 00       	mov    $0x0,%edx
c0105402:	eb 14                	jmp    c0105418 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105404:	8b 45 08             	mov    0x8(%ebp),%eax
c0105407:	8b 00                	mov    (%eax),%eax
c0105409:	8d 48 04             	lea    0x4(%eax),%ecx
c010540c:	8b 55 08             	mov    0x8(%ebp),%edx
c010540f:	89 0a                	mov    %ecx,(%edx)
c0105411:	8b 00                	mov    (%eax),%eax
c0105413:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105418:	5d                   	pop    %ebp
c0105419:	c3                   	ret    

c010541a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010541a:	55                   	push   %ebp
c010541b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010541d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105421:	7e 14                	jle    c0105437 <getint+0x1d>
        return va_arg(*ap, long long);
c0105423:	8b 45 08             	mov    0x8(%ebp),%eax
c0105426:	8b 00                	mov    (%eax),%eax
c0105428:	8d 48 08             	lea    0x8(%eax),%ecx
c010542b:	8b 55 08             	mov    0x8(%ebp),%edx
c010542e:	89 0a                	mov    %ecx,(%edx)
c0105430:	8b 50 04             	mov    0x4(%eax),%edx
c0105433:	8b 00                	mov    (%eax),%eax
c0105435:	eb 28                	jmp    c010545f <getint+0x45>
    }
    else if (lflag) {
c0105437:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010543b:	74 12                	je     c010544f <getint+0x35>
        return va_arg(*ap, long);
c010543d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105440:	8b 00                	mov    (%eax),%eax
c0105442:	8d 48 04             	lea    0x4(%eax),%ecx
c0105445:	8b 55 08             	mov    0x8(%ebp),%edx
c0105448:	89 0a                	mov    %ecx,(%edx)
c010544a:	8b 00                	mov    (%eax),%eax
c010544c:	99                   	cltd   
c010544d:	eb 10                	jmp    c010545f <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010544f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105452:	8b 00                	mov    (%eax),%eax
c0105454:	8d 48 04             	lea    0x4(%eax),%ecx
c0105457:	8b 55 08             	mov    0x8(%ebp),%edx
c010545a:	89 0a                	mov    %ecx,(%edx)
c010545c:	8b 00                	mov    (%eax),%eax
c010545e:	99                   	cltd   
    }
}
c010545f:	5d                   	pop    %ebp
c0105460:	c3                   	ret    

c0105461 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105461:	55                   	push   %ebp
c0105462:	89 e5                	mov    %esp,%ebp
c0105464:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105467:	8d 45 14             	lea    0x14(%ebp),%eax
c010546a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010546d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105470:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105474:	8b 45 10             	mov    0x10(%ebp),%eax
c0105477:	89 44 24 08          	mov    %eax,0x8(%esp)
c010547b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010547e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105482:	8b 45 08             	mov    0x8(%ebp),%eax
c0105485:	89 04 24             	mov    %eax,(%esp)
c0105488:	e8 02 00 00 00       	call   c010548f <vprintfmt>
    va_end(ap);
}
c010548d:	c9                   	leave  
c010548e:	c3                   	ret    

c010548f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010548f:	55                   	push   %ebp
c0105490:	89 e5                	mov    %esp,%ebp
c0105492:	56                   	push   %esi
c0105493:	53                   	push   %ebx
c0105494:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105497:	eb 18                	jmp    c01054b1 <vprintfmt+0x22>
            if (ch == '\0') {
c0105499:	85 db                	test   %ebx,%ebx
c010549b:	75 05                	jne    c01054a2 <vprintfmt+0x13>
                return;
c010549d:	e9 d1 03 00 00       	jmp    c0105873 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01054a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054a9:	89 1c 24             	mov    %ebx,(%esp)
c01054ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01054af:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01054b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01054b4:	8d 50 01             	lea    0x1(%eax),%edx
c01054b7:	89 55 10             	mov    %edx,0x10(%ebp)
c01054ba:	0f b6 00             	movzbl (%eax),%eax
c01054bd:	0f b6 d8             	movzbl %al,%ebx
c01054c0:	83 fb 25             	cmp    $0x25,%ebx
c01054c3:	75 d4                	jne    c0105499 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01054c5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01054c9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01054d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01054d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01054dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054e0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01054e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01054e6:	8d 50 01             	lea    0x1(%eax),%edx
c01054e9:	89 55 10             	mov    %edx,0x10(%ebp)
c01054ec:	0f b6 00             	movzbl (%eax),%eax
c01054ef:	0f b6 d8             	movzbl %al,%ebx
c01054f2:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01054f5:	83 f8 55             	cmp    $0x55,%eax
c01054f8:	0f 87 44 03 00 00    	ja     c0105842 <vprintfmt+0x3b3>
c01054fe:	8b 04 85 00 70 10 c0 	mov    -0x3fef9000(,%eax,4),%eax
c0105505:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105507:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010550b:	eb d6                	jmp    c01054e3 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010550d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105511:	eb d0                	jmp    c01054e3 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105513:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010551a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010551d:	89 d0                	mov    %edx,%eax
c010551f:	c1 e0 02             	shl    $0x2,%eax
c0105522:	01 d0                	add    %edx,%eax
c0105524:	01 c0                	add    %eax,%eax
c0105526:	01 d8                	add    %ebx,%eax
c0105528:	83 e8 30             	sub    $0x30,%eax
c010552b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010552e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105531:	0f b6 00             	movzbl (%eax),%eax
c0105534:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105537:	83 fb 2f             	cmp    $0x2f,%ebx
c010553a:	7e 0b                	jle    c0105547 <vprintfmt+0xb8>
c010553c:	83 fb 39             	cmp    $0x39,%ebx
c010553f:	7f 06                	jg     c0105547 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105541:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0105545:	eb d3                	jmp    c010551a <vprintfmt+0x8b>
            goto process_precision;
c0105547:	eb 33                	jmp    c010557c <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0105549:	8b 45 14             	mov    0x14(%ebp),%eax
c010554c:	8d 50 04             	lea    0x4(%eax),%edx
c010554f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105552:	8b 00                	mov    (%eax),%eax
c0105554:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105557:	eb 23                	jmp    c010557c <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0105559:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010555d:	79 0c                	jns    c010556b <vprintfmt+0xdc>
                width = 0;
c010555f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105566:	e9 78 ff ff ff       	jmp    c01054e3 <vprintfmt+0x54>
c010556b:	e9 73 ff ff ff       	jmp    c01054e3 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0105570:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105577:	e9 67 ff ff ff       	jmp    c01054e3 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010557c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105580:	79 12                	jns    c0105594 <vprintfmt+0x105>
                width = precision, precision = -1;
c0105582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105585:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105588:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010558f:	e9 4f ff ff ff       	jmp    c01054e3 <vprintfmt+0x54>
c0105594:	e9 4a ff ff ff       	jmp    c01054e3 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105599:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010559d:	e9 41 ff ff ff       	jmp    c01054e3 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01055a2:	8b 45 14             	mov    0x14(%ebp),%eax
c01055a5:	8d 50 04             	lea    0x4(%eax),%edx
c01055a8:	89 55 14             	mov    %edx,0x14(%ebp)
c01055ab:	8b 00                	mov    (%eax),%eax
c01055ad:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055b0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055b4:	89 04 24             	mov    %eax,(%esp)
c01055b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ba:	ff d0                	call   *%eax
            break;
c01055bc:	e9 ac 02 00 00       	jmp    c010586d <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01055c1:	8b 45 14             	mov    0x14(%ebp),%eax
c01055c4:	8d 50 04             	lea    0x4(%eax),%edx
c01055c7:	89 55 14             	mov    %edx,0x14(%ebp)
c01055ca:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01055cc:	85 db                	test   %ebx,%ebx
c01055ce:	79 02                	jns    c01055d2 <vprintfmt+0x143>
                err = -err;
c01055d0:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01055d2:	83 fb 06             	cmp    $0x6,%ebx
c01055d5:	7f 0b                	jg     c01055e2 <vprintfmt+0x153>
c01055d7:	8b 34 9d c0 6f 10 c0 	mov    -0x3fef9040(,%ebx,4),%esi
c01055de:	85 f6                	test   %esi,%esi
c01055e0:	75 23                	jne    c0105605 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01055e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01055e6:	c7 44 24 08 ed 6f 10 	movl   $0xc0106fed,0x8(%esp)
c01055ed:	c0 
c01055ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f8:	89 04 24             	mov    %eax,(%esp)
c01055fb:	e8 61 fe ff ff       	call   c0105461 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105600:	e9 68 02 00 00       	jmp    c010586d <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105605:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105609:	c7 44 24 08 f6 6f 10 	movl   $0xc0106ff6,0x8(%esp)
c0105610:	c0 
c0105611:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105614:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105618:	8b 45 08             	mov    0x8(%ebp),%eax
c010561b:	89 04 24             	mov    %eax,(%esp)
c010561e:	e8 3e fe ff ff       	call   c0105461 <printfmt>
            }
            break;
c0105623:	e9 45 02 00 00       	jmp    c010586d <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105628:	8b 45 14             	mov    0x14(%ebp),%eax
c010562b:	8d 50 04             	lea    0x4(%eax),%edx
c010562e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105631:	8b 30                	mov    (%eax),%esi
c0105633:	85 f6                	test   %esi,%esi
c0105635:	75 05                	jne    c010563c <vprintfmt+0x1ad>
                p = "(null)";
c0105637:	be f9 6f 10 c0       	mov    $0xc0106ff9,%esi
            }
            if (width > 0 && padc != '-') {
c010563c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105640:	7e 3e                	jle    c0105680 <vprintfmt+0x1f1>
c0105642:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105646:	74 38                	je     c0105680 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105648:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010564b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010564e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105652:	89 34 24             	mov    %esi,(%esp)
c0105655:	e8 15 03 00 00       	call   c010596f <strnlen>
c010565a:	29 c3                	sub    %eax,%ebx
c010565c:	89 d8                	mov    %ebx,%eax
c010565e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105661:	eb 17                	jmp    c010567a <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105663:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105667:	8b 55 0c             	mov    0xc(%ebp),%edx
c010566a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010566e:	89 04 24             	mov    %eax,(%esp)
c0105671:	8b 45 08             	mov    0x8(%ebp),%eax
c0105674:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105676:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010567a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010567e:	7f e3                	jg     c0105663 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105680:	eb 38                	jmp    c01056ba <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105682:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105686:	74 1f                	je     c01056a7 <vprintfmt+0x218>
c0105688:	83 fb 1f             	cmp    $0x1f,%ebx
c010568b:	7e 05                	jle    c0105692 <vprintfmt+0x203>
c010568d:	83 fb 7e             	cmp    $0x7e,%ebx
c0105690:	7e 15                	jle    c01056a7 <vprintfmt+0x218>
                    putch('?', putdat);
c0105692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105695:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105699:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01056a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01056a3:	ff d0                	call   *%eax
c01056a5:	eb 0f                	jmp    c01056b6 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c01056a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056ae:	89 1c 24             	mov    %ebx,(%esp)
c01056b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b4:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01056b6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01056ba:	89 f0                	mov    %esi,%eax
c01056bc:	8d 70 01             	lea    0x1(%eax),%esi
c01056bf:	0f b6 00             	movzbl (%eax),%eax
c01056c2:	0f be d8             	movsbl %al,%ebx
c01056c5:	85 db                	test   %ebx,%ebx
c01056c7:	74 10                	je     c01056d9 <vprintfmt+0x24a>
c01056c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01056cd:	78 b3                	js     c0105682 <vprintfmt+0x1f3>
c01056cf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01056d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01056d7:	79 a9                	jns    c0105682 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01056d9:	eb 17                	jmp    c01056f2 <vprintfmt+0x263>
                putch(' ', putdat);
c01056db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01056e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01056ec:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01056ee:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01056f2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056f6:	7f e3                	jg     c01056db <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c01056f8:	e9 70 01 00 00       	jmp    c010586d <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01056fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105700:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105704:	8d 45 14             	lea    0x14(%ebp),%eax
c0105707:	89 04 24             	mov    %eax,(%esp)
c010570a:	e8 0b fd ff ff       	call   c010541a <getint>
c010570f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105712:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105715:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105718:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010571b:	85 d2                	test   %edx,%edx
c010571d:	79 26                	jns    c0105745 <vprintfmt+0x2b6>
                putch('-', putdat);
c010571f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105722:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105726:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010572d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105730:	ff d0                	call   *%eax
                num = -(long long)num;
c0105732:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105735:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105738:	f7 d8                	neg    %eax
c010573a:	83 d2 00             	adc    $0x0,%edx
c010573d:	f7 da                	neg    %edx
c010573f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105742:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105745:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010574c:	e9 a8 00 00 00       	jmp    c01057f9 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105751:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105754:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105758:	8d 45 14             	lea    0x14(%ebp),%eax
c010575b:	89 04 24             	mov    %eax,(%esp)
c010575e:	e8 68 fc ff ff       	call   c01053cb <getuint>
c0105763:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105766:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105769:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105770:	e9 84 00 00 00       	jmp    c01057f9 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105775:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105778:	89 44 24 04          	mov    %eax,0x4(%esp)
c010577c:	8d 45 14             	lea    0x14(%ebp),%eax
c010577f:	89 04 24             	mov    %eax,(%esp)
c0105782:	e8 44 fc ff ff       	call   c01053cb <getuint>
c0105787:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010578a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010578d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105794:	eb 63                	jmp    c01057f9 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105796:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105799:	89 44 24 04          	mov    %eax,0x4(%esp)
c010579d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01057a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a7:	ff d0                	call   *%eax
            putch('x', putdat);
c01057a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01057b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ba:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01057bc:	8b 45 14             	mov    0x14(%ebp),%eax
c01057bf:	8d 50 04             	lea    0x4(%eax),%edx
c01057c2:	89 55 14             	mov    %edx,0x14(%ebp)
c01057c5:	8b 00                	mov    (%eax),%eax
c01057c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01057d1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01057d8:	eb 1f                	jmp    c01057f9 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01057da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057e1:	8d 45 14             	lea    0x14(%ebp),%eax
c01057e4:	89 04 24             	mov    %eax,(%esp)
c01057e7:	e8 df fb ff ff       	call   c01053cb <getuint>
c01057ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01057f2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01057f9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01057fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105800:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105804:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105807:	89 54 24 14          	mov    %edx,0x14(%esp)
c010580b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010580f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105812:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105815:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105819:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010581d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105820:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105824:	8b 45 08             	mov    0x8(%ebp),%eax
c0105827:	89 04 24             	mov    %eax,(%esp)
c010582a:	e8 97 fa ff ff       	call   c01052c6 <printnum>
            break;
c010582f:	eb 3c                	jmp    c010586d <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105831:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105834:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105838:	89 1c 24             	mov    %ebx,(%esp)
c010583b:	8b 45 08             	mov    0x8(%ebp),%eax
c010583e:	ff d0                	call   *%eax
            break;
c0105840:	eb 2b                	jmp    c010586d <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105842:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105845:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105849:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105850:	8b 45 08             	mov    0x8(%ebp),%eax
c0105853:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105855:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105859:	eb 04                	jmp    c010585f <vprintfmt+0x3d0>
c010585b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010585f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105862:	83 e8 01             	sub    $0x1,%eax
c0105865:	0f b6 00             	movzbl (%eax),%eax
c0105868:	3c 25                	cmp    $0x25,%al
c010586a:	75 ef                	jne    c010585b <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010586c:	90                   	nop
        }
    }
c010586d:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010586e:	e9 3e fc ff ff       	jmp    c01054b1 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105873:	83 c4 40             	add    $0x40,%esp
c0105876:	5b                   	pop    %ebx
c0105877:	5e                   	pop    %esi
c0105878:	5d                   	pop    %ebp
c0105879:	c3                   	ret    

c010587a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010587a:	55                   	push   %ebp
c010587b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010587d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105880:	8b 40 08             	mov    0x8(%eax),%eax
c0105883:	8d 50 01             	lea    0x1(%eax),%edx
c0105886:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105889:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010588c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010588f:	8b 10                	mov    (%eax),%edx
c0105891:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105894:	8b 40 04             	mov    0x4(%eax),%eax
c0105897:	39 c2                	cmp    %eax,%edx
c0105899:	73 12                	jae    c01058ad <sprintputch+0x33>
        *b->buf ++ = ch;
c010589b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010589e:	8b 00                	mov    (%eax),%eax
c01058a0:	8d 48 01             	lea    0x1(%eax),%ecx
c01058a3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01058a6:	89 0a                	mov    %ecx,(%edx)
c01058a8:	8b 55 08             	mov    0x8(%ebp),%edx
c01058ab:	88 10                	mov    %dl,(%eax)
    }
}
c01058ad:	5d                   	pop    %ebp
c01058ae:	c3                   	ret    

c01058af <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01058af:	55                   	push   %ebp
c01058b0:	89 e5                	mov    %esp,%ebp
c01058b2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01058b5:	8d 45 14             	lea    0x14(%ebp),%eax
c01058b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01058bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058be:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01058c5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01058d3:	89 04 24             	mov    %eax,(%esp)
c01058d6:	e8 08 00 00 00       	call   c01058e3 <vsnprintf>
c01058db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01058de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01058e1:	c9                   	leave  
c01058e2:	c3                   	ret    

c01058e3 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01058e3:	55                   	push   %ebp
c01058e4:	89 e5                	mov    %esp,%ebp
c01058e6:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01058e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01058ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01058f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01058f8:	01 d0                	add    %edx,%eax
c01058fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105904:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105908:	74 0a                	je     c0105914 <vsnprintf+0x31>
c010590a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010590d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105910:	39 c2                	cmp    %eax,%edx
c0105912:	76 07                	jbe    c010591b <vsnprintf+0x38>
        return -E_INVAL;
c0105914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105919:	eb 2a                	jmp    c0105945 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010591b:	8b 45 14             	mov    0x14(%ebp),%eax
c010591e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105922:	8b 45 10             	mov    0x10(%ebp),%eax
c0105925:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105929:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010592c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105930:	c7 04 24 7a 58 10 c0 	movl   $0xc010587a,(%esp)
c0105937:	e8 53 fb ff ff       	call   c010548f <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010593c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010593f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105942:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105945:	c9                   	leave  
c0105946:	c3                   	ret    

c0105947 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105947:	55                   	push   %ebp
c0105948:	89 e5                	mov    %esp,%ebp
c010594a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010594d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105954:	eb 04                	jmp    c010595a <strlen+0x13>
        cnt ++;
c0105956:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010595a:	8b 45 08             	mov    0x8(%ebp),%eax
c010595d:	8d 50 01             	lea    0x1(%eax),%edx
c0105960:	89 55 08             	mov    %edx,0x8(%ebp)
c0105963:	0f b6 00             	movzbl (%eax),%eax
c0105966:	84 c0                	test   %al,%al
c0105968:	75 ec                	jne    c0105956 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010596a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010596d:	c9                   	leave  
c010596e:	c3                   	ret    

c010596f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010596f:	55                   	push   %ebp
c0105970:	89 e5                	mov    %esp,%ebp
c0105972:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105975:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010597c:	eb 04                	jmp    c0105982 <strnlen+0x13>
        cnt ++;
c010597e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105982:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105985:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105988:	73 10                	jae    c010599a <strnlen+0x2b>
c010598a:	8b 45 08             	mov    0x8(%ebp),%eax
c010598d:	8d 50 01             	lea    0x1(%eax),%edx
c0105990:	89 55 08             	mov    %edx,0x8(%ebp)
c0105993:	0f b6 00             	movzbl (%eax),%eax
c0105996:	84 c0                	test   %al,%al
c0105998:	75 e4                	jne    c010597e <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010599a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010599d:	c9                   	leave  
c010599e:	c3                   	ret    

c010599f <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010599f:	55                   	push   %ebp
c01059a0:	89 e5                	mov    %esp,%ebp
c01059a2:	57                   	push   %edi
c01059a3:	56                   	push   %esi
c01059a4:	83 ec 20             	sub    $0x20,%esp
c01059a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01059b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01059b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b9:	89 d1                	mov    %edx,%ecx
c01059bb:	89 c2                	mov    %eax,%edx
c01059bd:	89 ce                	mov    %ecx,%esi
c01059bf:	89 d7                	mov    %edx,%edi
c01059c1:	ac                   	lods   %ds:(%esi),%al
c01059c2:	aa                   	stos   %al,%es:(%edi)
c01059c3:	84 c0                	test   %al,%al
c01059c5:	75 fa                	jne    c01059c1 <strcpy+0x22>
c01059c7:	89 fa                	mov    %edi,%edx
c01059c9:	89 f1                	mov    %esi,%ecx
c01059cb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01059ce:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01059d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01059d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01059d7:	83 c4 20             	add    $0x20,%esp
c01059da:	5e                   	pop    %esi
c01059db:	5f                   	pop    %edi
c01059dc:	5d                   	pop    %ebp
c01059dd:	c3                   	ret    

c01059de <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01059de:	55                   	push   %ebp
c01059df:	89 e5                	mov    %esp,%ebp
c01059e1:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01059e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01059ea:	eb 21                	jmp    c0105a0d <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c01059ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ef:	0f b6 10             	movzbl (%eax),%edx
c01059f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01059f5:	88 10                	mov    %dl,(%eax)
c01059f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01059fa:	0f b6 00             	movzbl (%eax),%eax
c01059fd:	84 c0                	test   %al,%al
c01059ff:	74 04                	je     c0105a05 <strncpy+0x27>
            src ++;
c0105a01:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105a05:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105a09:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105a0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a11:	75 d9                	jne    c01059ec <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105a13:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105a16:	c9                   	leave  
c0105a17:	c3                   	ret    

c0105a18 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105a18:	55                   	push   %ebp
c0105a19:	89 e5                	mov    %esp,%ebp
c0105a1b:	57                   	push   %edi
c0105a1c:	56                   	push   %esi
c0105a1d:	83 ec 20             	sub    $0x20,%esp
c0105a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a26:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105a2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a32:	89 d1                	mov    %edx,%ecx
c0105a34:	89 c2                	mov    %eax,%edx
c0105a36:	89 ce                	mov    %ecx,%esi
c0105a38:	89 d7                	mov    %edx,%edi
c0105a3a:	ac                   	lods   %ds:(%esi),%al
c0105a3b:	ae                   	scas   %es:(%edi),%al
c0105a3c:	75 08                	jne    c0105a46 <strcmp+0x2e>
c0105a3e:	84 c0                	test   %al,%al
c0105a40:	75 f8                	jne    c0105a3a <strcmp+0x22>
c0105a42:	31 c0                	xor    %eax,%eax
c0105a44:	eb 04                	jmp    c0105a4a <strcmp+0x32>
c0105a46:	19 c0                	sbb    %eax,%eax
c0105a48:	0c 01                	or     $0x1,%al
c0105a4a:	89 fa                	mov    %edi,%edx
c0105a4c:	89 f1                	mov    %esi,%ecx
c0105a4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a51:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105a54:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105a57:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105a5a:	83 c4 20             	add    $0x20,%esp
c0105a5d:	5e                   	pop    %esi
c0105a5e:	5f                   	pop    %edi
c0105a5f:	5d                   	pop    %ebp
c0105a60:	c3                   	ret    

c0105a61 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105a61:	55                   	push   %ebp
c0105a62:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105a64:	eb 0c                	jmp    c0105a72 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105a66:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105a6e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105a72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a76:	74 1a                	je     c0105a92 <strncmp+0x31>
c0105a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a7b:	0f b6 00             	movzbl (%eax),%eax
c0105a7e:	84 c0                	test   %al,%al
c0105a80:	74 10                	je     c0105a92 <strncmp+0x31>
c0105a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a85:	0f b6 10             	movzbl (%eax),%edx
c0105a88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a8b:	0f b6 00             	movzbl (%eax),%eax
c0105a8e:	38 c2                	cmp    %al,%dl
c0105a90:	74 d4                	je     c0105a66 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105a92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a96:	74 18                	je     c0105ab0 <strncmp+0x4f>
c0105a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a9b:	0f b6 00             	movzbl (%eax),%eax
c0105a9e:	0f b6 d0             	movzbl %al,%edx
c0105aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa4:	0f b6 00             	movzbl (%eax),%eax
c0105aa7:	0f b6 c0             	movzbl %al,%eax
c0105aaa:	29 c2                	sub    %eax,%edx
c0105aac:	89 d0                	mov    %edx,%eax
c0105aae:	eb 05                	jmp    c0105ab5 <strncmp+0x54>
c0105ab0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ab5:	5d                   	pop    %ebp
c0105ab6:	c3                   	ret    

c0105ab7 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105ab7:	55                   	push   %ebp
c0105ab8:	89 e5                	mov    %esp,%ebp
c0105aba:	83 ec 04             	sub    $0x4,%esp
c0105abd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ac0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ac3:	eb 14                	jmp    c0105ad9 <strchr+0x22>
        if (*s == c) {
c0105ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ac8:	0f b6 00             	movzbl (%eax),%eax
c0105acb:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105ace:	75 05                	jne    c0105ad5 <strchr+0x1e>
            return (char *)s;
c0105ad0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad3:	eb 13                	jmp    c0105ae8 <strchr+0x31>
        }
        s ++;
c0105ad5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105ad9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105adc:	0f b6 00             	movzbl (%eax),%eax
c0105adf:	84 c0                	test   %al,%al
c0105ae1:	75 e2                	jne    c0105ac5 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ae8:	c9                   	leave  
c0105ae9:	c3                   	ret    

c0105aea <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105aea:	55                   	push   %ebp
c0105aeb:	89 e5                	mov    %esp,%ebp
c0105aed:	83 ec 04             	sub    $0x4,%esp
c0105af0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105af3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105af6:	eb 11                	jmp    c0105b09 <strfind+0x1f>
        if (*s == c) {
c0105af8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105afb:	0f b6 00             	movzbl (%eax),%eax
c0105afe:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b01:	75 02                	jne    c0105b05 <strfind+0x1b>
            break;
c0105b03:	eb 0e                	jmp    c0105b13 <strfind+0x29>
        }
        s ++;
c0105b05:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105b09:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0c:	0f b6 00             	movzbl (%eax),%eax
c0105b0f:	84 c0                	test   %al,%al
c0105b11:	75 e5                	jne    c0105af8 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105b13:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105b16:	c9                   	leave  
c0105b17:	c3                   	ret    

c0105b18 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105b18:	55                   	push   %ebp
c0105b19:	89 e5                	mov    %esp,%ebp
c0105b1b:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105b1e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105b25:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105b2c:	eb 04                	jmp    c0105b32 <strtol+0x1a>
        s ++;
c0105b2e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b35:	0f b6 00             	movzbl (%eax),%eax
c0105b38:	3c 20                	cmp    $0x20,%al
c0105b3a:	74 f2                	je     c0105b2e <strtol+0x16>
c0105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b3f:	0f b6 00             	movzbl (%eax),%eax
c0105b42:	3c 09                	cmp    $0x9,%al
c0105b44:	74 e8                	je     c0105b2e <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b49:	0f b6 00             	movzbl (%eax),%eax
c0105b4c:	3c 2b                	cmp    $0x2b,%al
c0105b4e:	75 06                	jne    c0105b56 <strtol+0x3e>
        s ++;
c0105b50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105b54:	eb 15                	jmp    c0105b6b <strtol+0x53>
    }
    else if (*s == '-') {
c0105b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b59:	0f b6 00             	movzbl (%eax),%eax
c0105b5c:	3c 2d                	cmp    $0x2d,%al
c0105b5e:	75 0b                	jne    c0105b6b <strtol+0x53>
        s ++, neg = 1;
c0105b60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105b64:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105b6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b6f:	74 06                	je     c0105b77 <strtol+0x5f>
c0105b71:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105b75:	75 24                	jne    c0105b9b <strtol+0x83>
c0105b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b7a:	0f b6 00             	movzbl (%eax),%eax
c0105b7d:	3c 30                	cmp    $0x30,%al
c0105b7f:	75 1a                	jne    c0105b9b <strtol+0x83>
c0105b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b84:	83 c0 01             	add    $0x1,%eax
c0105b87:	0f b6 00             	movzbl (%eax),%eax
c0105b8a:	3c 78                	cmp    $0x78,%al
c0105b8c:	75 0d                	jne    c0105b9b <strtol+0x83>
        s += 2, base = 16;
c0105b8e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105b92:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105b99:	eb 2a                	jmp    c0105bc5 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105b9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b9f:	75 17                	jne    c0105bb8 <strtol+0xa0>
c0105ba1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba4:	0f b6 00             	movzbl (%eax),%eax
c0105ba7:	3c 30                	cmp    $0x30,%al
c0105ba9:	75 0d                	jne    c0105bb8 <strtol+0xa0>
        s ++, base = 8;
c0105bab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105baf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105bb6:	eb 0d                	jmp    c0105bc5 <strtol+0xad>
    }
    else if (base == 0) {
c0105bb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105bbc:	75 07                	jne    c0105bc5 <strtol+0xad>
        base = 10;
c0105bbe:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105bc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc8:	0f b6 00             	movzbl (%eax),%eax
c0105bcb:	3c 2f                	cmp    $0x2f,%al
c0105bcd:	7e 1b                	jle    c0105bea <strtol+0xd2>
c0105bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd2:	0f b6 00             	movzbl (%eax),%eax
c0105bd5:	3c 39                	cmp    $0x39,%al
c0105bd7:	7f 11                	jg     c0105bea <strtol+0xd2>
            dig = *s - '0';
c0105bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bdc:	0f b6 00             	movzbl (%eax),%eax
c0105bdf:	0f be c0             	movsbl %al,%eax
c0105be2:	83 e8 30             	sub    $0x30,%eax
c0105be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105be8:	eb 48                	jmp    c0105c32 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105bea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bed:	0f b6 00             	movzbl (%eax),%eax
c0105bf0:	3c 60                	cmp    $0x60,%al
c0105bf2:	7e 1b                	jle    c0105c0f <strtol+0xf7>
c0105bf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf7:	0f b6 00             	movzbl (%eax),%eax
c0105bfa:	3c 7a                	cmp    $0x7a,%al
c0105bfc:	7f 11                	jg     c0105c0f <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105bfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c01:	0f b6 00             	movzbl (%eax),%eax
c0105c04:	0f be c0             	movsbl %al,%eax
c0105c07:	83 e8 57             	sub    $0x57,%eax
c0105c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c0d:	eb 23                	jmp    c0105c32 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105c0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c12:	0f b6 00             	movzbl (%eax),%eax
c0105c15:	3c 40                	cmp    $0x40,%al
c0105c17:	7e 3d                	jle    c0105c56 <strtol+0x13e>
c0105c19:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c1c:	0f b6 00             	movzbl (%eax),%eax
c0105c1f:	3c 5a                	cmp    $0x5a,%al
c0105c21:	7f 33                	jg     c0105c56 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105c23:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c26:	0f b6 00             	movzbl (%eax),%eax
c0105c29:	0f be c0             	movsbl %al,%eax
c0105c2c:	83 e8 37             	sub    $0x37,%eax
c0105c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c35:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c38:	7c 02                	jl     c0105c3c <strtol+0x124>
            break;
c0105c3a:	eb 1a                	jmp    c0105c56 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105c3c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c40:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105c43:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105c47:	89 c2                	mov    %eax,%edx
c0105c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c4c:	01 d0                	add    %edx,%eax
c0105c4e:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105c51:	e9 6f ff ff ff       	jmp    c0105bc5 <strtol+0xad>

    if (endptr) {
c0105c56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c5a:	74 08                	je     c0105c64 <strtol+0x14c>
        *endptr = (char *) s;
c0105c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c5f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c62:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105c64:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105c68:	74 07                	je     c0105c71 <strtol+0x159>
c0105c6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105c6d:	f7 d8                	neg    %eax
c0105c6f:	eb 03                	jmp    c0105c74 <strtol+0x15c>
c0105c71:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105c74:	c9                   	leave  
c0105c75:	c3                   	ret    

c0105c76 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105c76:	55                   	push   %ebp
c0105c77:	89 e5                	mov    %esp,%ebp
c0105c79:	57                   	push   %edi
c0105c7a:	83 ec 24             	sub    $0x24,%esp
c0105c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c80:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105c83:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105c87:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c8a:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105c8d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105c90:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c93:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105c96:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105c99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105c9d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105ca0:	89 d7                	mov    %edx,%edi
c0105ca2:	f3 aa                	rep stos %al,%es:(%edi)
c0105ca4:	89 fa                	mov    %edi,%edx
c0105ca6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105ca9:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105cac:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105caf:	83 c4 24             	add    $0x24,%esp
c0105cb2:	5f                   	pop    %edi
c0105cb3:	5d                   	pop    %ebp
c0105cb4:	c3                   	ret    

c0105cb5 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105cb5:	55                   	push   %ebp
c0105cb6:	89 e5                	mov    %esp,%ebp
c0105cb8:	57                   	push   %edi
c0105cb9:	56                   	push   %esi
c0105cba:	53                   	push   %ebx
c0105cbb:	83 ec 30             	sub    $0x30,%esp
c0105cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105cca:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ccd:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cd3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105cd6:	73 42                	jae    c0105d1a <memmove+0x65>
c0105cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ce1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ce4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ce7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105cea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ced:	c1 e8 02             	shr    $0x2,%eax
c0105cf0:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105cf2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105cf5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cf8:	89 d7                	mov    %edx,%edi
c0105cfa:	89 c6                	mov    %eax,%esi
c0105cfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105cfe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105d01:	83 e1 03             	and    $0x3,%ecx
c0105d04:	74 02                	je     c0105d08 <memmove+0x53>
c0105d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d08:	89 f0                	mov    %esi,%eax
c0105d0a:	89 fa                	mov    %edi,%edx
c0105d0c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105d0f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105d12:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d18:	eb 36                	jmp    c0105d50 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d1d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d23:	01 c2                	add    %eax,%edx
c0105d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d28:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d2e:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d34:	89 c1                	mov    %eax,%ecx
c0105d36:	89 d8                	mov    %ebx,%eax
c0105d38:	89 d6                	mov    %edx,%esi
c0105d3a:	89 c7                	mov    %eax,%edi
c0105d3c:	fd                   	std    
c0105d3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d3f:	fc                   	cld    
c0105d40:	89 f8                	mov    %edi,%eax
c0105d42:	89 f2                	mov    %esi,%edx
c0105d44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105d47:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105d4a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105d50:	83 c4 30             	add    $0x30,%esp
c0105d53:	5b                   	pop    %ebx
c0105d54:	5e                   	pop    %esi
c0105d55:	5f                   	pop    %edi
c0105d56:	5d                   	pop    %ebp
c0105d57:	c3                   	ret    

c0105d58 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105d58:	55                   	push   %ebp
c0105d59:	89 e5                	mov    %esp,%ebp
c0105d5b:	57                   	push   %edi
c0105d5c:	56                   	push   %esi
c0105d5d:	83 ec 20             	sub    $0x20,%esp
c0105d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d63:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d6c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105d72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d75:	c1 e8 02             	shr    $0x2,%eax
c0105d78:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d80:	89 d7                	mov    %edx,%edi
c0105d82:	89 c6                	mov    %eax,%esi
c0105d84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105d86:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105d89:	83 e1 03             	and    $0x3,%ecx
c0105d8c:	74 02                	je     c0105d90 <memcpy+0x38>
c0105d8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d90:	89 f0                	mov    %esi,%eax
c0105d92:	89 fa                	mov    %edi,%edx
c0105d94:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105d97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105d9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105da0:	83 c4 20             	add    $0x20,%esp
c0105da3:	5e                   	pop    %esi
c0105da4:	5f                   	pop    %edi
c0105da5:	5d                   	pop    %ebp
c0105da6:	c3                   	ret    

c0105da7 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105da7:	55                   	push   %ebp
c0105da8:	89 e5                	mov    %esp,%ebp
c0105daa:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105dad:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105db3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105db6:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105db9:	eb 30                	jmp    c0105deb <memcmp+0x44>
        if (*s1 != *s2) {
c0105dbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105dbe:	0f b6 10             	movzbl (%eax),%edx
c0105dc1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dc4:	0f b6 00             	movzbl (%eax),%eax
c0105dc7:	38 c2                	cmp    %al,%dl
c0105dc9:	74 18                	je     c0105de3 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105dce:	0f b6 00             	movzbl (%eax),%eax
c0105dd1:	0f b6 d0             	movzbl %al,%edx
c0105dd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dd7:	0f b6 00             	movzbl (%eax),%eax
c0105dda:	0f b6 c0             	movzbl %al,%eax
c0105ddd:	29 c2                	sub    %eax,%edx
c0105ddf:	89 d0                	mov    %edx,%eax
c0105de1:	eb 1a                	jmp    c0105dfd <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105de3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105de7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105deb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dee:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105df1:	89 55 10             	mov    %edx,0x10(%ebp)
c0105df4:	85 c0                	test   %eax,%eax
c0105df6:	75 c3                	jne    c0105dbb <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105dfd:	c9                   	leave  
c0105dfe:	c3                   	ret    
