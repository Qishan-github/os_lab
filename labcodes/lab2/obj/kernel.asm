
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
c010005d:	e8 79 5d 00 00       	call   c0105ddb <memset>

    cons_init();                // init the console
c0100062:	e8 82 15 00 00       	call   c01015e9 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 5f 10 c0 	movl   $0xc0105f80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 5f 10 c0 	movl   $0xc0105f9c,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 b6 42 00 00       	call   c0104346 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 bd 16 00 00       	call   c0101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 0f 18 00 00       	call   c01018a9 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 00 0d 00 00       	call   c0100d9f <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 1c 16 00 00       	call   c01016c0 <intr_enable>
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
c01000c3:	e8 f8 0b 00 00       	call   c0100cc0 <mon_backtrace>
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
c0100161:	c7 04 24 a1 5f 10 c0 	movl   $0xc0105fa1,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 5f 10 c0 	movl   $0xc0105faf,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 bd 5f 10 c0 	movl   $0xc0105fbd,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 cb 5f 10 c0 	movl   $0xc0105fcb,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 d9 5f 10 c0 	movl   $0xc0105fd9,(%esp)
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
c0100211:	c7 04 24 e8 5f 10 c0 	movl   $0xc0105fe8,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 08 60 10 c0 	movl   $0xc0106008,(%esp)
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
c0100252:	c7 04 24 27 60 10 c0 	movl   $0xc0106027,(%esp)
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
c0100301:	e8 0f 13 00 00       	call   c0101615 <cons_putc>
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
c010033e:	e8 b1 52 00 00       	call   c01055f4 <vprintfmt>
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
c010037a:	e8 96 12 00 00       	call   c0101615 <cons_putc>
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
c01003d6:	e8 76 12 00 00       	call   c0101651 <cons_getc>
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
c0100548:	c7 00 2c 60 10 c0    	movl   $0xc010602c,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 2c 60 10 c0 	movl   $0xc010602c,0x8(%eax)
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
c010057f:	c7 45 f4 b8 72 10 c0 	movl   $0xc01072b8,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 b4 1e 11 c0 	movl   $0xc0111eb4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec b5 1e 11 c0 	movl   $0xc0111eb5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 dd 48 11 c0 	movl   $0xc01148dd,-0x18(%ebp)

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
c01006f3:	e8 57 55 00 00       	call   c0105c4f <strfind>
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
c0100882:	c7 04 24 36 60 10 c0 	movl   $0xc0106036,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 4f 60 10 c0 	movl   $0xc010604f,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 64 5f 10 	movl   $0xc0105f64,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 67 60 10 c0 	movl   $0xc0106067,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 7f 60 10 c0 	movl   $0xc010607f,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 97 60 10 c0 	movl   $0xc0106097,(%esp)
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
c0100904:	c7 04 24 b0 60 10 c0 	movl   $0xc01060b0,(%esp)
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
c0100938:	c7 04 24 da 60 10 c0 	movl   $0xc01060da,(%esp)
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
c01009a7:	c7 04 24 f6 60 10 c0 	movl   $0xc01060f6,(%esp)
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
c01009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cc:	89 e8                	mov    %ebp,%eax
c01009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c01009d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009d7:	e8 d9 ff ff ff       	call   c01009b5 <read_eip>
c01009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e6:	e9 88 00 00 00       	jmp    c0100a73 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f9:	c7 04 24 08 61 10 c0 	movl   $0xc0106108,(%esp)
c0100a00:	e8 43 f9 ff ff       	call   c0100348 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a08:	83 c0 08             	add    $0x8,%eax
c0100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a15:	eb 25                	jmp    c0100a3c <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a24:	01 d0                	add    %edx,%eax
c0100a26:	8b 00                	mov    (%eax),%eax
c0100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2c:	c7 04 24 24 61 10 c0 	movl   $0xc0106124,(%esp)
c0100a33:	e8 10 f9 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100a38:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a3c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a40:	7e d5                	jle    c0100a17 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100a42:	c7 04 24 2c 61 10 c0 	movl   $0xc010612c,(%esp)
c0100a49:	e8 fa f8 ff ff       	call   c0100348 <cprintf>
        print_debuginfo(eip - 1);
c0100a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a51:	83 e8 01             	sub    $0x1,%eax
c0100a54:	89 04 24             	mov    %eax,(%esp)
c0100a57:	e8 b6 fe ff ff       	call   c0100912 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5f:	83 c0 04             	add    $0x4,%eax
c0100a62:	8b 00                	mov    (%eax),%eax
c0100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6a:	8b 00                	mov    (%eax),%eax
c0100a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a6f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a77:	74 0a                	je     c0100a83 <print_stackframe+0xbd>
c0100a79:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a7d:	0f 8e 68 ff ff ff    	jle    c01009eb <print_stackframe+0x25>
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }

}
c0100a83:	c9                   	leave  
c0100a84:	c3                   	ret    

c0100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a85:	55                   	push   %ebp
c0100a86:	89 e5                	mov    %esp,%ebp
c0100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a92:	eb 0c                	jmp    c0100aa0 <parse+0x1b>
            *buf ++ = '\0';
c0100a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a97:	8d 50 01             	lea    0x1(%eax),%edx
c0100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa3:	0f b6 00             	movzbl (%eax),%eax
c0100aa6:	84 c0                	test   %al,%al
c0100aa8:	74 1d                	je     c0100ac7 <parse+0x42>
c0100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aad:	0f b6 00             	movzbl (%eax),%eax
c0100ab0:	0f be c0             	movsbl %al,%eax
c0100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab7:	c7 04 24 b0 61 10 c0 	movl   $0xc01061b0,(%esp)
c0100abe:	e8 59 51 00 00       	call   c0105c1c <strchr>
c0100ac3:	85 c0                	test   %eax,%eax
c0100ac5:	75 cd                	jne    c0100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aca:	0f b6 00             	movzbl (%eax),%eax
c0100acd:	84 c0                	test   %al,%al
c0100acf:	75 02                	jne    c0100ad3 <parse+0x4e>
            break;
c0100ad1:	eb 67                	jmp    c0100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad7:	75 14                	jne    c0100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ae0:	00 
c0100ae1:	c7 04 24 b5 61 10 c0 	movl   $0xc01061b5,(%esp)
c0100ae8:	e8 5b f8 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af0:	8d 50 01             	lea    0x1(%eax),%edx
c0100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b00:	01 c2                	add    %eax,%edx
c0100b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b07:	eb 04                	jmp    c0100b0d <parse+0x88>
            buf ++;
c0100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b10:	0f b6 00             	movzbl (%eax),%eax
c0100b13:	84 c0                	test   %al,%al
c0100b15:	74 1d                	je     c0100b34 <parse+0xaf>
c0100b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1a:	0f b6 00             	movzbl (%eax),%eax
c0100b1d:	0f be c0             	movsbl %al,%eax
c0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b24:	c7 04 24 b0 61 10 c0 	movl   $0xc01061b0,(%esp)
c0100b2b:	e8 ec 50 00 00       	call   c0105c1c <strchr>
c0100b30:	85 c0                	test   %eax,%eax
c0100b32:	74 d5                	je     c0100b09 <parse+0x84>
            buf ++;
        }
    }
c0100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b35:	e9 66 ff ff ff       	jmp    c0100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4f:	89 04 24             	mov    %eax,(%esp)
c0100b52:	e8 2e ff ff ff       	call   c0100a85 <parse>
c0100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5e:	75 0a                	jne    c0100b6a <runcmd+0x2b>
        return 0;
c0100b60:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b65:	e9 85 00 00 00       	jmp    c0100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b71:	eb 5c                	jmp    c0100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b79:	89 d0                	mov    %edx,%eax
c0100b7b:	01 c0                	add    %eax,%eax
c0100b7d:	01 d0                	add    %edx,%eax
c0100b7f:	c1 e0 02             	shl    $0x2,%eax
c0100b82:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100b87:	8b 00                	mov    (%eax),%eax
c0100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b8d:	89 04 24             	mov    %eax,(%esp)
c0100b90:	e8 e8 4f 00 00       	call   c0105b7d <strcmp>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 32                	jne    c0100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9c:	89 d0                	mov    %edx,%eax
c0100b9e:	01 c0                	add    %eax,%eax
c0100ba0:	01 d0                	add    %edx,%eax
c0100ba2:	c1 e0 02             	shl    $0x2,%eax
c0100ba5:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100baa:	8b 40 08             	mov    0x8(%eax),%eax
c0100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bbd:	83 c2 04             	add    $0x4,%edx
c0100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc4:	89 0c 24             	mov    %ecx,(%esp)
c0100bc7:	ff d0                	call   *%eax
c0100bc9:	eb 24                	jmp    c0100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd2:	83 f8 02             	cmp    $0x2,%eax
c0100bd5:	76 9c                	jbe    c0100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bde:	c7 04 24 d3 61 10 c0 	movl   $0xc01061d3,(%esp)
c0100be5:	e8 5e f7 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bef:	c9                   	leave  
c0100bf0:	c3                   	ret    

c0100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf1:	55                   	push   %ebp
c0100bf2:	89 e5                	mov    %esp,%ebp
c0100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bf7:	c7 04 24 ec 61 10 c0 	movl   $0xc01061ec,(%esp)
c0100bfe:	e8 45 f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c03:	c7 04 24 14 62 10 c0 	movl   $0xc0106214,(%esp)
c0100c0a:	e8 39 f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c13:	74 0b                	je     c0100c20 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c18:	89 04 24             	mov    %eax,(%esp)
c0100c1b:	e8 c2 0d 00 00       	call   c01019e2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c20:	c7 04 24 39 62 10 c0 	movl   $0xc0106239,(%esp)
c0100c27:	e8 13 f6 ff ff       	call   c010023f <readline>
c0100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c33:	74 18                	je     c0100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3f:	89 04 24             	mov    %eax,(%esp)
c0100c42:	e8 f8 fe ff ff       	call   c0100b3f <runcmd>
c0100c47:	85 c0                	test   %eax,%eax
c0100c49:	79 02                	jns    c0100c4d <kmonitor+0x5c>
                break;
c0100c4b:	eb 02                	jmp    c0100c4f <kmonitor+0x5e>
            }
        }
    }
c0100c4d:	eb d1                	jmp    c0100c20 <kmonitor+0x2f>
}
c0100c4f:	c9                   	leave  
c0100c50:	c3                   	ret    

c0100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c51:	55                   	push   %ebp
c0100c52:	89 e5                	mov    %esp,%ebp
c0100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5e:	eb 3f                	jmp    c0100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c63:	89 d0                	mov    %edx,%eax
c0100c65:	01 c0                	add    %eax,%eax
c0100c67:	01 d0                	add    %edx,%eax
c0100c69:	c1 e0 02             	shl    $0x2,%eax
c0100c6c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c71:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c77:	89 d0                	mov    %edx,%eax
c0100c79:	01 c0                	add    %eax,%eax
c0100c7b:	01 d0                	add    %edx,%eax
c0100c7d:	c1 e0 02             	shl    $0x2,%eax
c0100c80:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c85:	8b 00                	mov    (%eax),%eax
c0100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8f:	c7 04 24 3d 62 10 c0 	movl   $0xc010623d,(%esp)
c0100c96:	e8 ad f6 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca2:	83 f8 02             	cmp    $0x2,%eax
c0100ca5:	76 b9                	jbe    c0100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cac:	c9                   	leave  
c0100cad:	c3                   	ret    

c0100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cae:	55                   	push   %ebp
c0100caf:	89 e5                	mov    %esp,%ebp
c0100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb4:	e8 c3 fb ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbe:	c9                   	leave  
c0100cbf:	c3                   	ret    

c0100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cc0:	55                   	push   %ebp
c0100cc1:	89 e5                	mov    %esp,%ebp
c0100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc6:	e8 fb fc ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd0:	c9                   	leave  
c0100cd1:	c3                   	ret    

c0100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd2:	55                   	push   %ebp
c0100cd3:	89 e5                	mov    %esp,%ebp
c0100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd8:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100cdd:	85 c0                	test   %eax,%eax
c0100cdf:	74 02                	je     c0100ce3 <__panic+0x11>
        goto panic_dead;
c0100ce1:	eb 59                	jmp    c0100d3c <__panic+0x6a>
    }
    is_panic = 1;
c0100ce3:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ced:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d01:	c7 04 24 46 62 10 c0 	movl   $0xc0106246,(%esp)
c0100d08:	e8 3b f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d14:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d17:	89 04 24             	mov    %eax,(%esp)
c0100d1a:	e8 f6 f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d1f:	c7 04 24 62 62 10 c0 	movl   $0xc0106262,(%esp)
c0100d26:	e8 1d f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d2b:	c7 04 24 64 62 10 c0 	movl   $0xc0106264,(%esp)
c0100d32:	e8 11 f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100d37:	e8 8a fc ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d3c:	e8 85 09 00 00       	call   c01016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d48:	e8 a4 fe ff ff       	call   c0100bf1 <kmonitor>
    }
c0100d4d:	eb f2                	jmp    c0100d41 <__panic+0x6f>

c0100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d4f:	55                   	push   %ebp
c0100d50:	89 e5                	mov    %esp,%ebp
c0100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d55:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d69:	c7 04 24 76 62 10 c0 	movl   $0xc0106276,(%esp)
c0100d70:	e8 d3 f5 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d7f:	89 04 24             	mov    %eax,(%esp)
c0100d82:	e8 8e f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d87:	c7 04 24 62 62 10 c0 	movl   $0xc0106262,(%esp)
c0100d8e:	e8 b5 f5 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100d93:	c9                   	leave  
c0100d94:	c3                   	ret    

c0100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d95:	55                   	push   %ebp
c0100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d98:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100d9d:	5d                   	pop    %ebp
c0100d9e:	c3                   	ret    

c0100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d9f:	55                   	push   %ebp
c0100da0:	89 e5                	mov    %esp,%ebp
c0100da2:	83 ec 28             	sub    $0x28,%esp
c0100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100db7:	ee                   	out    %al,(%dx)
c0100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dca:	ee                   	out    %al,(%dx)
c0100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dde:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100de8:	c7 04 24 94 62 10 c0 	movl   $0xc0106294,(%esp)
c0100def:	e8 54 f5 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dfb:	e8 24 09 00 00       	call   c0101724 <pic_enable>
}
c0100e00:	c9                   	leave  
c0100e01:	c3                   	ret    

c0100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e02:	55                   	push   %ebp
c0100e03:	89 e5                	mov    %esp,%ebp
c0100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e08:	9c                   	pushf  
c0100e09:	58                   	pop    %eax
c0100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e10:	25 00 02 00 00       	and    $0x200,%eax
c0100e15:	85 c0                	test   %eax,%eax
c0100e17:	74 0c                	je     c0100e25 <__intr_save+0x23>
        intr_disable();
c0100e19:	e8 a8 08 00 00       	call   c01016c6 <intr_disable>
        return 1;
c0100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e23:	eb 05                	jmp    c0100e2a <__intr_save+0x28>
    }
    return 0;
c0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e36:	74 05                	je     c0100e3d <__intr_restore+0x11>
        intr_enable();
c0100e38:	e8 83 08 00 00       	call   c01016c0 <intr_enable>
    }
}
c0100e3d:	c9                   	leave  
c0100e3e:	c3                   	ret    

c0100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e3f:	55                   	push   %ebp
c0100e40:	89 e5                	mov    %esp,%ebp
c0100e42:	83 ec 10             	sub    $0x10,%esp
c0100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e4f:	89 c2                	mov    %eax,%edx
c0100e51:	ec                   	in     (%dx),%al
c0100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5f:	89 c2                	mov    %eax,%edx
c0100e61:	ec                   	in     (%dx),%al
c0100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6f:	89 c2                	mov    %eax,%edx
c0100e71:	ec                   	in     (%dx),%al
c0100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e7f:	89 c2                	mov    %eax,%edx
c0100e81:	ec                   	in     (%dx),%al
c0100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e85:	c9                   	leave  
c0100e86:	c3                   	ret    

c0100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e87:	55                   	push   %ebp
c0100e88:	89 e5                	mov    %esp,%ebp
c0100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea9:	0f b7 00             	movzwl (%eax),%eax
c0100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eb0:	74 12                	je     c0100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eb9:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ec0:	b4 03 
c0100ec2:	eb 13                	jmp    c0100ed7 <cga_init+0x50>
    } else {
        *cp = was;
c0100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ece:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ed7:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ede:	0f b7 c0             	movzwl %ax,%eax
c0100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ef2:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef9:	83 c0 01             	add    $0x1,%eax
c0100efc:	0f b7 c0             	movzwl %ax,%eax
c0100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f07:	89 c2                	mov    %eax,%edx
c0100f09:	ec                   	in     (%dx),%al
c0100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f11:	0f b6 c0             	movzbl %al,%eax
c0100f14:	c1 e0 08             	shl    $0x8,%eax
c0100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f1a:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f35:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f3c:	83 c0 01             	add    $0x1,%eax
c0100f3f:	0f b7 c0             	movzwl %ax,%eax
c0100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f4a:	89 c2                	mov    %eax,%edx
c0100f4c:	ec                   	in     (%dx),%al
c0100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f54:	0f b6 c0             	movzbl %al,%eax
c0100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f5d:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f65:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f6b:	c9                   	leave  
c0100f6c:	c3                   	ret    

c0100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f6d:	55                   	push   %ebp
c0100f6e:	89 e5                	mov    %esp,%ebp
c0100f70:	83 ec 48             	sub    $0x48,%esp
c0100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f85:	ee                   	out    %al,(%dx)
c0100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f98:	ee                   	out    %al,(%dx)
c0100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fab:	ee                   	out    %al,(%dx)
c0100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fbe:	ee                   	out    %al,(%dx)
c0100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fd1:	ee                   	out    %al,(%dx)
c0100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe4:	ee                   	out    %al,(%dx)
c0100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100ff7:	ee                   	out    %al,(%dx)
c0100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101002:	89 c2                	mov    %eax,%edx
c0101004:	ec                   	in     (%dx),%al
c0101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010100c:	3c ff                	cmp    $0xff,%al
c010100e:	0f 95 c0             	setne  %al
c0101011:	0f b6 c0             	movzbl %al,%eax
c0101014:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101023:	89 c2                	mov    %eax,%edx
c0101025:	ec                   	in     (%dx),%al
c0101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101033:	89 c2                	mov    %eax,%edx
c0101035:	ec                   	in     (%dx),%al
c0101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101039:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010103e:	85 c0                	test   %eax,%eax
c0101040:	74 0c                	je     c010104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101049:	e8 d6 06 00 00       	call   c0101724 <pic_enable>
    }
}
c010104e:	c9                   	leave  
c010104f:	c3                   	ret    

c0101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101050:	55                   	push   %ebp
c0101051:	89 e5                	mov    %esp,%ebp
c0101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010105d:	eb 09                	jmp    c0101068 <lpt_putc_sub+0x18>
        delay();
c010105f:	e8 db fd ff ff       	call   c0100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101072:	89 c2                	mov    %eax,%edx
c0101074:	ec                   	in     (%dx),%al
c0101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010107c:	84 c0                	test   %al,%al
c010107e:	78 09                	js     c0101089 <lpt_putc_sub+0x39>
c0101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101087:	7e d6                	jle    c010105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101089:	8b 45 08             	mov    0x8(%ebp),%eax
c010108c:	0f b6 c0             	movzbl %al,%eax
c010108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010a0:	ee                   	out    %al,(%dx)
c01010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b3:	ee                   	out    %al,(%dx)
c01010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010c7:	c9                   	leave  
c01010c8:	c3                   	ret    

c01010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010c9:	55                   	push   %ebp
c01010ca:	89 e5                	mov    %esp,%ebp
c01010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010d3:	74 0d                	je     c01010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d8:	89 04 24             	mov    %eax,(%esp)
c01010db:	e8 70 ff ff ff       	call   c0101050 <lpt_putc_sub>
c01010e0:	eb 24                	jmp    c0101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e9:	e8 62 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010f5:	e8 56 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101101:	e8 4a ff ff ff       	call   c0101050 <lpt_putc_sub>
    }
}
c0101106:	c9                   	leave  
c0101107:	c3                   	ret    

c0101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101108:	55                   	push   %ebp
c0101109:	89 e5                	mov    %esp,%ebp
c010110b:	53                   	push   %ebx
c010110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010110f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101112:	b0 00                	mov    $0x0,%al
c0101114:	85 c0                	test   %eax,%eax
c0101116:	75 07                	jne    c010111f <cga_putc+0x17>
        c |= 0x0700;
c0101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010111f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101122:	0f b6 c0             	movzbl %al,%eax
c0101125:	83 f8 0a             	cmp    $0xa,%eax
c0101128:	74 4c                	je     c0101176 <cga_putc+0x6e>
c010112a:	83 f8 0d             	cmp    $0xd,%eax
c010112d:	74 57                	je     c0101186 <cga_putc+0x7e>
c010112f:	83 f8 08             	cmp    $0x8,%eax
c0101132:	0f 85 88 00 00 00    	jne    c01011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101138:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010113f:	66 85 c0             	test   %ax,%ax
c0101142:	74 30                	je     c0101174 <cga_putc+0x6c>
            crt_pos --;
c0101144:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010114b:	83 e8 01             	sub    $0x1,%eax
c010114e:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101154:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101159:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c0101160:	0f b7 d2             	movzwl %dx,%edx
c0101163:	01 d2                	add    %edx,%edx
c0101165:	01 c2                	add    %eax,%edx
c0101167:	8b 45 08             	mov    0x8(%ebp),%eax
c010116a:	b0 00                	mov    $0x0,%al
c010116c:	83 c8 20             	or     $0x20,%eax
c010116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101172:	eb 72                	jmp    c01011e6 <cga_putc+0xde>
c0101174:	eb 70                	jmp    c01011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101176:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010117d:	83 c0 50             	add    $0x50,%eax
c0101180:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101186:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010118d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101194:	0f b7 c1             	movzwl %cx,%eax
c0101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010119d:	c1 e8 10             	shr    $0x10,%eax
c01011a0:	89 c2                	mov    %eax,%edx
c01011a2:	66 c1 ea 06          	shr    $0x6,%dx
c01011a6:	89 d0                	mov    %edx,%eax
c01011a8:	c1 e0 02             	shl    $0x2,%eax
c01011ab:	01 d0                	add    %edx,%eax
c01011ad:	c1 e0 04             	shl    $0x4,%eax
c01011b0:	29 c1                	sub    %eax,%ecx
c01011b2:	89 ca                	mov    %ecx,%edx
c01011b4:	89 d8                	mov    %ebx,%eax
c01011b6:	29 d0                	sub    %edx,%eax
c01011b8:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011be:	eb 26                	jmp    c01011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011c0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011c6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011cd:	8d 50 01             	lea    0x1(%eax),%edx
c01011d0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011d7:	0f b7 c0             	movzwl %ax,%eax
c01011da:	01 c0                	add    %eax,%eax
c01011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011df:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011f1:	76 5b                	jbe    c010124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f3:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011fe:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120a:	00 
c010120b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120f:	89 04 24             	mov    %eax,(%esp)
c0101212:	e8 03 4c 00 00       	call   c0105e1a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010121e:	eb 15                	jmp    c0101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101220:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101228:	01 d2                	add    %edx,%edx
c010122a:	01 d0                	add    %edx,%eax
c010122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123c:	7e e2                	jle    c0101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010123e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101245:	83 e8 50             	sub    $0x50,%eax
c0101248:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124e:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101255:	0f b7 c0             	movzwl %ax,%eax
c0101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101269:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101270:	66 c1 e8 08          	shr    $0x8,%ax
c0101274:	0f b6 c0             	movzbl %al,%eax
c0101277:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010127e:	83 c2 01             	add    $0x1,%edx
c0101281:	0f b7 d2             	movzwl %dx,%edx
c0101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101288:	88 45 ed             	mov    %al,-0x13(%ebp)
c010128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101294:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010129b:	0f b7 c0             	movzwl %ax,%eax
c010129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012af:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012b6:	0f b6 c0             	movzbl %al,%eax
c01012b9:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012c0:	83 c2 01             	add    $0x1,%edx
c01012c3:	0f b7 d2             	movzwl %dx,%edx
c01012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012d5:	ee                   	out    %al,(%dx)
}
c01012d6:	83 c4 34             	add    $0x34,%esp
c01012d9:	5b                   	pop    %ebx
c01012da:	5d                   	pop    %ebp
c01012db:	c3                   	ret    

c01012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012dc:	55                   	push   %ebp
c01012dd:	89 e5                	mov    %esp,%ebp
c01012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e9:	eb 09                	jmp    c01012f4 <serial_putc_sub+0x18>
        delay();
c01012eb:	e8 4f fb ff ff       	call   c0100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fe:	89 c2                	mov    %eax,%edx
c0101300:	ec                   	in     (%dx),%al
c0101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101308:	0f b6 c0             	movzbl %al,%eax
c010130b:	83 e0 20             	and    $0x20,%eax
c010130e:	85 c0                	test   %eax,%eax
c0101310:	75 09                	jne    c010131b <serial_putc_sub+0x3f>
c0101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101319:	7e d0                	jle    c01012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010131b:	8b 45 08             	mov    0x8(%ebp),%eax
c010131e:	0f b6 c0             	movzbl %al,%eax
c0101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101332:	ee                   	out    %al,(%dx)
}
c0101333:	c9                   	leave  
c0101334:	c3                   	ret    

c0101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101335:	55                   	push   %ebp
c0101336:	89 e5                	mov    %esp,%ebp
c0101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133f:	74 0d                	je     c010134e <serial_putc+0x19>
        serial_putc_sub(c);
c0101341:	8b 45 08             	mov    0x8(%ebp),%eax
c0101344:	89 04 24             	mov    %eax,(%esp)
c0101347:	e8 90 ff ff ff       	call   c01012dc <serial_putc_sub>
c010134c:	eb 24                	jmp    c0101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101355:	e8 82 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub(' ');
c010135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101361:	e8 76 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub('\b');
c0101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136d:	e8 6a ff ff ff       	call   c01012dc <serial_putc_sub>
    }
}
c0101372:	c9                   	leave  
c0101373:	c3                   	ret    

c0101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101374:	55                   	push   %ebp
c0101375:	89 e5                	mov    %esp,%ebp
c0101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010137a:	eb 33                	jmp    c01013af <cons_intr+0x3b>
        if (c != 0) {
c010137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101380:	74 2d                	je     c01013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101382:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101387:	8d 50 01             	lea    0x1(%eax),%edx
c010138a:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101393:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101399:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010139e:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a3:	75 0a                	jne    c01013af <cons_intr+0x3b>
                cons.wpos = 0;
c01013a5:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013af:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b2:	ff d0                	call   *%eax
c01013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013bb:	75 bf                	jne    c010137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013bd:	c9                   	leave  
c01013be:	c3                   	ret    

c01013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bf:	55                   	push   %ebp
c01013c0:	89 e5                	mov    %esp,%ebp
c01013c2:	83 ec 10             	sub    $0x10,%esp
c01013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cf:	89 c2                	mov    %eax,%edx
c01013d1:	ec                   	in     (%dx),%al
c01013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d9:	0f b6 c0             	movzbl %al,%eax
c01013dc:	83 e0 01             	and    $0x1,%eax
c01013df:	85 c0                	test   %eax,%eax
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x2b>
        return -1;
c01013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e8:	eb 2a                	jmp    c0101414 <serial_proc_data+0x55>
c01013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f4:	89 c2                	mov    %eax,%edx
c01013f6:	ec                   	in     (%dx),%al
c01013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fe:	0f b6 c0             	movzbl %al,%eax
c0101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101408:	75 07                	jne    c0101411 <serial_proc_data+0x52>
        c = '\b';
c010140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101421:	85 c0                	test   %eax,%eax
c0101423:	74 0c                	je     c0101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101425:	c7 04 24 bf 13 10 c0 	movl   $0xc01013bf,(%esp)
c010142c:	e8 43 ff ff ff       	call   c0101374 <cons_intr>
    }
}
c0101431:	c9                   	leave  
c0101432:	c3                   	ret    

c0101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101433:	55                   	push   %ebp
c0101434:	89 e5                	mov    %esp,%ebp
c0101436:	83 ec 38             	sub    $0x38,%esp
c0101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101443:	89 c2                	mov    %eax,%edx
c0101445:	ec                   	in     (%dx),%al
c0101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144d:	0f b6 c0             	movzbl %al,%eax
c0101450:	83 e0 01             	and    $0x1,%eax
c0101453:	85 c0                	test   %eax,%eax
c0101455:	75 0a                	jne    c0101461 <kbd_proc_data+0x2e>
        return -1;
c0101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145c:	e9 59 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
c0101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010146b:	89 c2                	mov    %eax,%edx
c010146d:	ec                   	in     (%dx),%al
c010146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147c:	75 17                	jne    c0101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010147e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101483:	83 c8 40             	or     $0x40,%eax
c0101486:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010148b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101490:	e9 25 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101499:	84 c0                	test   %al,%al
c010149b:	79 47                	jns    c01014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014a2:	83 e0 40             	and    $0x40,%eax
c01014a5:	85 c0                	test   %eax,%eax
c01014a7:	75 09                	jne    c01014b2 <kbd_proc_data+0x7f>
c01014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ad:	83 e0 7f             	and    $0x7f,%eax
c01014b0:	eb 04                	jmp    c01014b6 <kbd_proc_data+0x83>
c01014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bd:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014c4:	83 c8 40             	or     $0x40,%eax
c01014c7:	0f b6 c0             	movzbl %al,%eax
c01014ca:	f7 d0                	not    %eax
c01014cc:	89 c2                	mov    %eax,%edx
c01014ce:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d3:	21 d0                	and    %edx,%eax
c01014d5:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014da:	b8 00 00 00 00       	mov    $0x0,%eax
c01014df:	e9 d6 00 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014e4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e9:	83 e0 40             	and    $0x40,%eax
c01014ec:	85 c0                	test   %eax,%eax
c01014ee:	74 11                	je     c0101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f9:	83 e0 bf             	and    $0xffffffbf,%eax
c01014fc:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c0101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101505:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010150c:	0f b6 d0             	movzbl %al,%edx
c010150f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101514:	09 d0                	or     %edx,%eax
c0101516:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151f:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101526:	0f b6 d0             	movzbl %al,%edx
c0101529:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152e:	31 d0                	xor    %edx,%eax
c0101530:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101535:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010153a:	83 e0 03             	and    $0x3,%eax
c010153d:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101548:	01 d0                	add    %edx,%eax
c010154a:	0f b6 00             	movzbl (%eax),%eax
c010154d:	0f b6 c0             	movzbl %al,%eax
c0101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101553:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101558:	83 e0 08             	and    $0x8,%eax
c010155b:	85 c0                	test   %eax,%eax
c010155d:	74 22                	je     c0101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101563:	7e 0c                	jle    c0101571 <kbd_proc_data+0x13e>
c0101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101569:	7f 06                	jg     c0101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156f:	eb 10                	jmp    c0101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101575:	7e 0a                	jle    c0101581 <kbd_proc_data+0x14e>
c0101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010157b:	7f 04                	jg     c0101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101581:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101586:	f7 d0                	not    %eax
c0101588:	83 e0 06             	and    $0x6,%eax
c010158b:	85 c0                	test   %eax,%eax
c010158d:	75 28                	jne    c01015b7 <kbd_proc_data+0x184>
c010158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101596:	75 1f                	jne    c01015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101598:	c7 04 24 af 62 10 c0 	movl   $0xc01062af,(%esp)
c010159f:	e8 a4 ed ff ff       	call   c0100348 <cprintf>
c01015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015ba:	c9                   	leave  
c01015bb:	c3                   	ret    

c01015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015bc:	55                   	push   %ebp
c01015bd:	89 e5                	mov    %esp,%ebp
c01015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015c2:	c7 04 24 33 14 10 c0 	movl   $0xc0101433,(%esp)
c01015c9:	e8 a6 fd ff ff       	call   c0101374 <cons_intr>
}
c01015ce:	c9                   	leave  
c01015cf:	c3                   	ret    

c01015d0 <kbd_init>:

static void
kbd_init(void) {
c01015d0:	55                   	push   %ebp
c01015d1:	89 e5                	mov    %esp,%ebp
c01015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d6:	e8 e1 ff ff ff       	call   c01015bc <kbd_intr>
    pic_enable(IRQ_KBD);
c01015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015e2:	e8 3d 01 00 00       	call   c0101724 <pic_enable>
}
c01015e7:	c9                   	leave  
c01015e8:	c3                   	ret    

c01015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e9:	55                   	push   %ebp
c01015ea:	89 e5                	mov    %esp,%ebp
c01015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ef:	e8 93 f8 ff ff       	call   c0100e87 <cga_init>
    serial_init();
c01015f4:	e8 74 f9 ff ff       	call   c0100f6d <serial_init>
    kbd_init();
c01015f9:	e8 d2 ff ff ff       	call   c01015d0 <kbd_init>
    if (!serial_exists) {
c01015fe:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101603:	85 c0                	test   %eax,%eax
c0101605:	75 0c                	jne    c0101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101607:	c7 04 24 bb 62 10 c0 	movl   $0xc01062bb,(%esp)
c010160e:	e8 35 ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101613:	c9                   	leave  
c0101614:	c3                   	ret    

c0101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101615:	55                   	push   %ebp
c0101616:	89 e5                	mov    %esp,%ebp
c0101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010161b:	e8 e2 f7 ff ff       	call   c0100e02 <__intr_save>
c0101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101623:	8b 45 08             	mov    0x8(%ebp),%eax
c0101626:	89 04 24             	mov    %eax,(%esp)
c0101629:	e8 9b fa ff ff       	call   c01010c9 <lpt_putc>
        cga_putc(c);
c010162e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101631:	89 04 24             	mov    %eax,(%esp)
c0101634:	e8 cf fa ff ff       	call   c0101108 <cga_putc>
        serial_putc(c);
c0101639:	8b 45 08             	mov    0x8(%ebp),%eax
c010163c:	89 04 24             	mov    %eax,(%esp)
c010163f:	e8 f1 fc ff ff       	call   c0101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101647:	89 04 24             	mov    %eax,(%esp)
c010164a:	e8 dd f7 ff ff       	call   c0100e2c <__intr_restore>
}
c010164f:	c9                   	leave  
c0101650:	c3                   	ret    

c0101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101651:	55                   	push   %ebp
c0101652:	89 e5                	mov    %esp,%ebp
c0101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165e:	e8 9f f7 ff ff       	call   c0100e02 <__intr_save>
c0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101666:	e8 ab fd ff ff       	call   c0101416 <serial_intr>
        kbd_intr();
c010166b:	e8 4c ff ff ff       	call   c01015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101670:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101676:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c010168d:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b3:	89 04 24             	mov    %eax,(%esp)
c01016b6:	e8 71 f7 ff ff       	call   c0100e2c <__intr_restore>
    return c;
c01016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016be:	c9                   	leave  
c01016bf:	c3                   	ret    

c01016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016c0:	55                   	push   %ebp
c01016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016c3:	fb                   	sti    
    sti();
}
c01016c4:	5d                   	pop    %ebp
c01016c5:	c3                   	ret    

c01016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016c6:	55                   	push   %ebp
c01016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016c9:	fa                   	cli    
    cli();
}
c01016ca:	5d                   	pop    %ebp
c01016cb:	c3                   	ret    

c01016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016cc:	55                   	push   %ebp
c01016cd:	89 e5                	mov    %esp,%ebp
c01016cf:	83 ec 14             	sub    $0x14,%esp
c01016d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016dd:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016e3:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016e8:	85 c0                	test   %eax,%eax
c01016ea:	74 36                	je     c0101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f0:	0f b6 c0             	movzbl %al,%eax
c01016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101709:	66 c1 e8 08          	shr    $0x8,%ax
c010170d:	0f b6 c0             	movzbl %al,%eax
c0101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101716:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101721:	ee                   	out    %al,(%dx)
    }
}
c0101722:	c9                   	leave  
c0101723:	c3                   	ret    

c0101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101724:	55                   	push   %ebp
c0101725:	89 e5                	mov    %esp,%ebp
c0101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010172a:	8b 45 08             	mov    0x8(%ebp),%eax
c010172d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101732:	89 c1                	mov    %eax,%ecx
c0101734:	d3 e2                	shl    %cl,%edx
c0101736:	89 d0                	mov    %edx,%eax
c0101738:	f7 d0                	not    %eax
c010173a:	89 c2                	mov    %eax,%edx
c010173c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101743:	21 d0                	and    %edx,%eax
c0101745:	0f b7 c0             	movzwl %ax,%eax
c0101748:	89 04 24             	mov    %eax,(%esp)
c010174b:	e8 7c ff ff ff       	call   c01016cc <pic_setmask>
}
c0101750:	c9                   	leave  
c0101751:	c3                   	ret    

c0101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101752:	55                   	push   %ebp
c0101753:	89 e5                	mov    %esp,%ebp
c0101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101758:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010175f:	00 00 00 
c0101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101774:	ee                   	out    %al,(%dx)
c0101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
c0101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010179a:	ee                   	out    %al,(%dx)
c010179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017ad:	ee                   	out    %al,(%dx)
c01017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017c0:	ee                   	out    %al,(%dx)
c01017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017d3:	ee                   	out    %al,(%dx)
c01017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017e6:	ee                   	out    %al,(%dx)
c01017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f9:	ee                   	out    %al,(%dx)
c01017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010180c:	ee                   	out    %al,(%dx)
c010180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010181f:	ee                   	out    %al,(%dx)
c0101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101832:	ee                   	out    %al,(%dx)
c0101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101845:	ee                   	out    %al,(%dx)
c0101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101858:	ee                   	out    %al,(%dx)
c0101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010186c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101873:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101877:	74 12                	je     c010188b <pic_init+0x139>
        pic_setmask(irq_mask);
c0101879:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101880:	0f b7 c0             	movzwl %ax,%eax
c0101883:	89 04 24             	mov    %eax,(%esp)
c0101886:	e8 41 fe ff ff       	call   c01016cc <pic_setmask>
    }
}
c010188b:	c9                   	leave  
c010188c:	c3                   	ret    

c010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
c0101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010189a:	00 
c010189b:	c7 04 24 e0 62 10 c0 	movl   $0xc01062e0,(%esp)
c01018a2:	e8 a1 ea ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018a7:	c9                   	leave  
c01018a8:	c3                   	ret    

c01018a9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018a9:	55                   	push   %ebp
c01018aa:	89 e5                	mov    %esp,%ebp
c01018ac:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018b6:	e9 c3 00 00 00       	jmp    c010197e <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018be:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018c5:	89 c2                	mov    %eax,%edx
c01018c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ca:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018d1:	c0 
c01018d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d5:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018dc:	c0 08 00 
c01018df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e2:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018e9:	c0 
c01018ea:	83 e2 e0             	and    $0xffffffe0,%edx
c01018ed:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f7:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018fe:	c0 
c01018ff:	83 e2 1f             	and    $0x1f,%edx
c0101902:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101909:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190c:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101913:	c0 
c0101914:	83 e2 f0             	and    $0xfffffff0,%edx
c0101917:	83 ca 0e             	or     $0xe,%edx
c010191a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101921:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101924:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010192b:	c0 
c010192c:	83 e2 ef             	and    $0xffffffef,%edx
c010192f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101936:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101939:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101940:	c0 
c0101941:	83 e2 9f             	and    $0xffffff9f,%edx
c0101944:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010194b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194e:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101955:	c0 
c0101956:	83 ca 80             	or     $0xffffff80,%edx
c0101959:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101960:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101963:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010196a:	c1 e8 10             	shr    $0x10,%eax
c010196d:	89 c2                	mov    %eax,%edx
c010196f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101972:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c0101979:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010197a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010197e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101981:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101986:	0f 86 2f ff ff ff    	jbe    c01018bb <idt_init+0x12>
c010198c:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101993:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101996:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c0101999:	c9                   	leave  
c010199a:	c3                   	ret    

c010199b <trapname>:

static const char *
trapname(int trapno) {
c010199b:	55                   	push   %ebp
c010199c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010199e:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a1:	83 f8 13             	cmp    $0x13,%eax
c01019a4:	77 0c                	ja     c01019b2 <trapname+0x17>
        return excnames[trapno];
c01019a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a9:	8b 04 85 40 66 10 c0 	mov    -0x3fef99c0(,%eax,4),%eax
c01019b0:	eb 18                	jmp    c01019ca <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019b2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019b6:	7e 0d                	jle    c01019c5 <trapname+0x2a>
c01019b8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019bc:	7f 07                	jg     c01019c5 <trapname+0x2a>
        return "Hardware Interrupt";
c01019be:	b8 ea 62 10 c0       	mov    $0xc01062ea,%eax
c01019c3:	eb 05                	jmp    c01019ca <trapname+0x2f>
    }
    return "(unknown trap)";
c01019c5:	b8 fd 62 10 c0       	mov    $0xc01062fd,%eax
}
c01019ca:	5d                   	pop    %ebp
c01019cb:	c3                   	ret    

c01019cc <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019cc:	55                   	push   %ebp
c01019cd:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019d6:	66 83 f8 08          	cmp    $0x8,%ax
c01019da:	0f 94 c0             	sete   %al
c01019dd:	0f b6 c0             	movzbl %al,%eax
}
c01019e0:	5d                   	pop    %ebp
c01019e1:	c3                   	ret    

c01019e2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01019e2:	55                   	push   %ebp
c01019e3:	89 e5                	mov    %esp,%ebp
c01019e5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01019e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019ef:	c7 04 24 3e 63 10 c0 	movl   $0xc010633e,(%esp)
c01019f6:	e8 4d e9 ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c01019fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01019fe:	89 04 24             	mov    %eax,(%esp)
c0101a01:	e8 a1 01 00 00       	call   c0101ba7 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a09:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a0d:	0f b7 c0             	movzwl %ax,%eax
c0101a10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a14:	c7 04 24 4f 63 10 c0 	movl   $0xc010634f,(%esp)
c0101a1b:	e8 28 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a23:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a27:	0f b7 c0             	movzwl %ax,%eax
c0101a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a2e:	c7 04 24 62 63 10 c0 	movl   $0xc0106362,(%esp)
c0101a35:	e8 0e e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a41:	0f b7 c0             	movzwl %ax,%eax
c0101a44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a48:	c7 04 24 75 63 10 c0 	movl   $0xc0106375,(%esp)
c0101a4f:	e8 f4 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a57:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a5b:	0f b7 c0             	movzwl %ax,%eax
c0101a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a62:	c7 04 24 88 63 10 c0 	movl   $0xc0106388,(%esp)
c0101a69:	e8 da e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a71:	8b 40 30             	mov    0x30(%eax),%eax
c0101a74:	89 04 24             	mov    %eax,(%esp)
c0101a77:	e8 1f ff ff ff       	call   c010199b <trapname>
c0101a7c:	8b 55 08             	mov    0x8(%ebp),%edx
c0101a7f:	8b 52 30             	mov    0x30(%edx),%edx
c0101a82:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101a86:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a8a:	c7 04 24 9b 63 10 c0 	movl   $0xc010639b,(%esp)
c0101a91:	e8 b2 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101a96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a99:	8b 40 34             	mov    0x34(%eax),%eax
c0101a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa0:	c7 04 24 ad 63 10 c0 	movl   $0xc01063ad,(%esp)
c0101aa7:	e8 9c e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101aac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aaf:	8b 40 38             	mov    0x38(%eax),%eax
c0101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab6:	c7 04 24 bc 63 10 c0 	movl   $0xc01063bc,(%esp)
c0101abd:	e8 86 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ac9:	0f b7 c0             	movzwl %ax,%eax
c0101acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad0:	c7 04 24 cb 63 10 c0 	movl   $0xc01063cb,(%esp)
c0101ad7:	e8 6c e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101adc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101adf:	8b 40 40             	mov    0x40(%eax),%eax
c0101ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae6:	c7 04 24 de 63 10 c0 	movl   $0xc01063de,(%esp)
c0101aed:	e8 56 e8 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101af9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b00:	eb 3e                	jmp    c0101b40 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b05:	8b 50 40             	mov    0x40(%eax),%edx
c0101b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b0b:	21 d0                	and    %edx,%eax
c0101b0d:	85 c0                	test   %eax,%eax
c0101b0f:	74 28                	je     c0101b39 <print_trapframe+0x157>
c0101b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b14:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b1b:	85 c0                	test   %eax,%eax
c0101b1d:	74 1a                	je     c0101b39 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b22:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b2d:	c7 04 24 ed 63 10 c0 	movl   $0xc01063ed,(%esp)
c0101b34:	e8 0f e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101b3d:	d1 65 f0             	shll   -0x10(%ebp)
c0101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b43:	83 f8 17             	cmp    $0x17,%eax
c0101b46:	76 ba                	jbe    c0101b02 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4b:	8b 40 40             	mov    0x40(%eax),%eax
c0101b4e:	25 00 30 00 00       	and    $0x3000,%eax
c0101b53:	c1 e8 0c             	shr    $0xc,%eax
c0101b56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b5a:	c7 04 24 f1 63 10 c0 	movl   $0xc01063f1,(%esp)
c0101b61:	e8 e2 e7 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b66:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b69:	89 04 24             	mov    %eax,(%esp)
c0101b6c:	e8 5b fe ff ff       	call   c01019cc <trap_in_kernel>
c0101b71:	85 c0                	test   %eax,%eax
c0101b73:	75 30                	jne    c0101ba5 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b78:	8b 40 44             	mov    0x44(%eax),%eax
c0101b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7f:	c7 04 24 fa 63 10 c0 	movl   $0xc01063fa,(%esp)
c0101b86:	e8 bd e7 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101b92:	0f b7 c0             	movzwl %ax,%eax
c0101b95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b99:	c7 04 24 09 64 10 c0 	movl   $0xc0106409,(%esp)
c0101ba0:	e8 a3 e7 ff ff       	call   c0100348 <cprintf>
    }
}
c0101ba5:	c9                   	leave  
c0101ba6:	c3                   	ret    

c0101ba7 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101ba7:	55                   	push   %ebp
c0101ba8:	89 e5                	mov    %esp,%ebp
c0101baa:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101bad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb0:	8b 00                	mov    (%eax),%eax
c0101bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bb6:	c7 04 24 1c 64 10 c0 	movl   $0xc010641c,(%esp)
c0101bbd:	e8 86 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc5:	8b 40 04             	mov    0x4(%eax),%eax
c0101bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bcc:	c7 04 24 2b 64 10 c0 	movl   $0xc010642b,(%esp)
c0101bd3:	e8 70 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bdb:	8b 40 08             	mov    0x8(%eax),%eax
c0101bde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be2:	c7 04 24 3a 64 10 c0 	movl   $0xc010643a,(%esp)
c0101be9:	e8 5a e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101bee:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf1:	8b 40 0c             	mov    0xc(%eax),%eax
c0101bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf8:	c7 04 24 49 64 10 c0 	movl   $0xc0106449,(%esp)
c0101bff:	e8 44 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c07:	8b 40 10             	mov    0x10(%eax),%eax
c0101c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c0e:	c7 04 24 58 64 10 c0 	movl   $0xc0106458,(%esp)
c0101c15:	e8 2e e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1d:	8b 40 14             	mov    0x14(%eax),%eax
c0101c20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c24:	c7 04 24 67 64 10 c0 	movl   $0xc0106467,(%esp)
c0101c2b:	e8 18 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c33:	8b 40 18             	mov    0x18(%eax),%eax
c0101c36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3a:	c7 04 24 76 64 10 c0 	movl   $0xc0106476,(%esp)
c0101c41:	e8 02 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c49:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c50:	c7 04 24 85 64 10 c0 	movl   $0xc0106485,(%esp)
c0101c57:	e8 ec e6 ff ff       	call   c0100348 <cprintf>
}
c0101c5c:	c9                   	leave  
c0101c5d:	c3                   	ret    

c0101c5e <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c5e:	55                   	push   %ebp
c0101c5f:	89 e5                	mov    %esp,%ebp
c0101c61:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c64:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c67:	8b 40 30             	mov    0x30(%eax),%eax
c0101c6a:	83 f8 2f             	cmp    $0x2f,%eax
c0101c6d:	77 21                	ja     c0101c90 <trap_dispatch+0x32>
c0101c6f:	83 f8 2e             	cmp    $0x2e,%eax
c0101c72:	0f 83 04 01 00 00    	jae    c0101d7c <trap_dispatch+0x11e>
c0101c78:	83 f8 21             	cmp    $0x21,%eax
c0101c7b:	0f 84 81 00 00 00    	je     c0101d02 <trap_dispatch+0xa4>
c0101c81:	83 f8 24             	cmp    $0x24,%eax
c0101c84:	74 56                	je     c0101cdc <trap_dispatch+0x7e>
c0101c86:	83 f8 20             	cmp    $0x20,%eax
c0101c89:	74 16                	je     c0101ca1 <trap_dispatch+0x43>
c0101c8b:	e9 b4 00 00 00       	jmp    c0101d44 <trap_dispatch+0xe6>
c0101c90:	83 e8 78             	sub    $0x78,%eax
c0101c93:	83 f8 01             	cmp    $0x1,%eax
c0101c96:	0f 87 a8 00 00 00    	ja     c0101d44 <trap_dispatch+0xe6>
c0101c9c:	e9 87 00 00 00       	jmp    c0101d28 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101ca1:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101ca6:	83 c0 01             	add    $0x1,%eax
c0101ca9:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101cae:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101cb4:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cb9:	89 c8                	mov    %ecx,%eax
c0101cbb:	f7 e2                	mul    %edx
c0101cbd:	89 d0                	mov    %edx,%eax
c0101cbf:	c1 e8 05             	shr    $0x5,%eax
c0101cc2:	6b c0 64             	imul   $0x64,%eax,%eax
c0101cc5:	29 c1                	sub    %eax,%ecx
c0101cc7:	89 c8                	mov    %ecx,%eax
c0101cc9:	85 c0                	test   %eax,%eax
c0101ccb:	75 0a                	jne    c0101cd7 <trap_dispatch+0x79>
            print_ticks();
c0101ccd:	e8 bb fb ff ff       	call   c010188d <print_ticks>
        }
        break;
c0101cd2:	e9 a6 00 00 00       	jmp    c0101d7d <trap_dispatch+0x11f>
c0101cd7:	e9 a1 00 00 00       	jmp    c0101d7d <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101cdc:	e8 70 f9 ff ff       	call   c0101651 <cons_getc>
c0101ce1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101ce4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ce8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101cec:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf4:	c7 04 24 94 64 10 c0 	movl   $0xc0106494,(%esp)
c0101cfb:	e8 48 e6 ff ff       	call   c0100348 <cprintf>
        break;
c0101d00:	eb 7b                	jmp    c0101d7d <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d02:	e8 4a f9 ff ff       	call   c0101651 <cons_getc>
c0101d07:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d0a:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d0e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d12:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d1a:	c7 04 24 a6 64 10 c0 	movl   $0xc01064a6,(%esp)
c0101d21:	e8 22 e6 ff ff       	call   c0100348 <cprintf>
        break;
c0101d26:	eb 55                	jmp    c0101d7d <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d28:	c7 44 24 08 b5 64 10 	movl   $0xc01064b5,0x8(%esp)
c0101d2f:	c0 
c0101d30:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101d37:	00 
c0101d38:	c7 04 24 c5 64 10 c0 	movl   $0xc01064c5,(%esp)
c0101d3f:	e8 8e ef ff ff       	call   c0100cd2 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d44:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d47:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d4b:	0f b7 c0             	movzwl %ax,%eax
c0101d4e:	83 e0 03             	and    $0x3,%eax
c0101d51:	85 c0                	test   %eax,%eax
c0101d53:	75 28                	jne    c0101d7d <trap_dispatch+0x11f>
            print_trapframe(tf);
c0101d55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d58:	89 04 24             	mov    %eax,(%esp)
c0101d5b:	e8 82 fc ff ff       	call   c01019e2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d60:	c7 44 24 08 d6 64 10 	movl   $0xc01064d6,0x8(%esp)
c0101d67:	c0 
c0101d68:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101d6f:	00 
c0101d70:	c7 04 24 c5 64 10 c0 	movl   $0xc01064c5,(%esp)
c0101d77:	e8 56 ef ff ff       	call   c0100cd2 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101d7c:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101d7d:	c9                   	leave  
c0101d7e:	c3                   	ret    

c0101d7f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d7f:	55                   	push   %ebp
c0101d80:	89 e5                	mov    %esp,%ebp
c0101d82:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101d85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d88:	89 04 24             	mov    %eax,(%esp)
c0101d8b:	e8 ce fe ff ff       	call   c0101c5e <trap_dispatch>
}
c0101d90:	c9                   	leave  
c0101d91:	c3                   	ret    

c0101d92 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101d92:	1e                   	push   %ds
    pushl %es
c0101d93:	06                   	push   %es
    pushl %fs
c0101d94:	0f a0                	push   %fs
    pushl %gs
c0101d96:	0f a8                	push   %gs
    pushal
c0101d98:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101d99:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101d9e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101da0:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101da2:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101da3:	e8 d7 ff ff ff       	call   c0101d7f <trap>

    # pop the pushed stack pointer
    popl %esp
c0101da8:	5c                   	pop    %esp

c0101da9 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101da9:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101daa:	0f a9                	pop    %gs
    popl %fs
c0101dac:	0f a1                	pop    %fs
    popl %es
c0101dae:	07                   	pop    %es
    popl %ds
c0101daf:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101db0:	83 c4 08             	add    $0x8,%esp
    iret
c0101db3:	cf                   	iret   

c0101db4 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101db4:	6a 00                	push   $0x0
  pushl $0
c0101db6:	6a 00                	push   $0x0
  jmp __alltraps
c0101db8:	e9 d5 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101dbd <vector1>:
.globl vector1
vector1:
  pushl $0
c0101dbd:	6a 00                	push   $0x0
  pushl $1
c0101dbf:	6a 01                	push   $0x1
  jmp __alltraps
c0101dc1:	e9 cc ff ff ff       	jmp    c0101d92 <__alltraps>

c0101dc6 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101dc6:	6a 00                	push   $0x0
  pushl $2
c0101dc8:	6a 02                	push   $0x2
  jmp __alltraps
c0101dca:	e9 c3 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101dcf <vector3>:
.globl vector3
vector3:
  pushl $0
c0101dcf:	6a 00                	push   $0x0
  pushl $3
c0101dd1:	6a 03                	push   $0x3
  jmp __alltraps
c0101dd3:	e9 ba ff ff ff       	jmp    c0101d92 <__alltraps>

c0101dd8 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dd8:	6a 00                	push   $0x0
  pushl $4
c0101dda:	6a 04                	push   $0x4
  jmp __alltraps
c0101ddc:	e9 b1 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101de1 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101de1:	6a 00                	push   $0x0
  pushl $5
c0101de3:	6a 05                	push   $0x5
  jmp __alltraps
c0101de5:	e9 a8 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101dea <vector6>:
.globl vector6
vector6:
  pushl $0
c0101dea:	6a 00                	push   $0x0
  pushl $6
c0101dec:	6a 06                	push   $0x6
  jmp __alltraps
c0101dee:	e9 9f ff ff ff       	jmp    c0101d92 <__alltraps>

c0101df3 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101df3:	6a 00                	push   $0x0
  pushl $7
c0101df5:	6a 07                	push   $0x7
  jmp __alltraps
c0101df7:	e9 96 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101dfc <vector8>:
.globl vector8
vector8:
  pushl $8
c0101dfc:	6a 08                	push   $0x8
  jmp __alltraps
c0101dfe:	e9 8f ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e03 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e03:	6a 00                	push   $0x0
  pushl $9
c0101e05:	6a 09                	push   $0x9
  jmp __alltraps
c0101e07:	e9 86 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e0c <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e0c:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e0e:	e9 7f ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e13 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e13:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e15:	e9 78 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e1a <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e1a:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e1c:	e9 71 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e21 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e21:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e23:	e9 6a ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e28 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e28:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e2a:	e9 63 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e2f <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e2f:	6a 00                	push   $0x0
  pushl $15
c0101e31:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e33:	e9 5a ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e38 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e38:	6a 00                	push   $0x0
  pushl $16
c0101e3a:	6a 10                	push   $0x10
  jmp __alltraps
c0101e3c:	e9 51 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e41 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e41:	6a 11                	push   $0x11
  jmp __alltraps
c0101e43:	e9 4a ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e48 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e48:	6a 00                	push   $0x0
  pushl $18
c0101e4a:	6a 12                	push   $0x12
  jmp __alltraps
c0101e4c:	e9 41 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e51 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e51:	6a 00                	push   $0x0
  pushl $19
c0101e53:	6a 13                	push   $0x13
  jmp __alltraps
c0101e55:	e9 38 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e5a <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e5a:	6a 00                	push   $0x0
  pushl $20
c0101e5c:	6a 14                	push   $0x14
  jmp __alltraps
c0101e5e:	e9 2f ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e63 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e63:	6a 00                	push   $0x0
  pushl $21
c0101e65:	6a 15                	push   $0x15
  jmp __alltraps
c0101e67:	e9 26 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e6c <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e6c:	6a 00                	push   $0x0
  pushl $22
c0101e6e:	6a 16                	push   $0x16
  jmp __alltraps
c0101e70:	e9 1d ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e75 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e75:	6a 00                	push   $0x0
  pushl $23
c0101e77:	6a 17                	push   $0x17
  jmp __alltraps
c0101e79:	e9 14 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e7e <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e7e:	6a 00                	push   $0x0
  pushl $24
c0101e80:	6a 18                	push   $0x18
  jmp __alltraps
c0101e82:	e9 0b ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e87 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e87:	6a 00                	push   $0x0
  pushl $25
c0101e89:	6a 19                	push   $0x19
  jmp __alltraps
c0101e8b:	e9 02 ff ff ff       	jmp    c0101d92 <__alltraps>

c0101e90 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e90:	6a 00                	push   $0x0
  pushl $26
c0101e92:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e94:	e9 f9 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101e99 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e99:	6a 00                	push   $0x0
  pushl $27
c0101e9b:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e9d:	e9 f0 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ea2 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101ea2:	6a 00                	push   $0x0
  pushl $28
c0101ea4:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ea6:	e9 e7 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101eab <vector29>:
.globl vector29
vector29:
  pushl $0
c0101eab:	6a 00                	push   $0x0
  pushl $29
c0101ead:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101eaf:	e9 de fe ff ff       	jmp    c0101d92 <__alltraps>

c0101eb4 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101eb4:	6a 00                	push   $0x0
  pushl $30
c0101eb6:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101eb8:	e9 d5 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ebd <vector31>:
.globl vector31
vector31:
  pushl $0
c0101ebd:	6a 00                	push   $0x0
  pushl $31
c0101ebf:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ec1:	e9 cc fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ec6 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ec6:	6a 00                	push   $0x0
  pushl $32
c0101ec8:	6a 20                	push   $0x20
  jmp __alltraps
c0101eca:	e9 c3 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ecf <vector33>:
.globl vector33
vector33:
  pushl $0
c0101ecf:	6a 00                	push   $0x0
  pushl $33
c0101ed1:	6a 21                	push   $0x21
  jmp __alltraps
c0101ed3:	e9 ba fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ed8 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101ed8:	6a 00                	push   $0x0
  pushl $34
c0101eda:	6a 22                	push   $0x22
  jmp __alltraps
c0101edc:	e9 b1 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ee1 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101ee1:	6a 00                	push   $0x0
  pushl $35
c0101ee3:	6a 23                	push   $0x23
  jmp __alltraps
c0101ee5:	e9 a8 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101eea <vector36>:
.globl vector36
vector36:
  pushl $0
c0101eea:	6a 00                	push   $0x0
  pushl $36
c0101eec:	6a 24                	push   $0x24
  jmp __alltraps
c0101eee:	e9 9f fe ff ff       	jmp    c0101d92 <__alltraps>

c0101ef3 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101ef3:	6a 00                	push   $0x0
  pushl $37
c0101ef5:	6a 25                	push   $0x25
  jmp __alltraps
c0101ef7:	e9 96 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101efc <vector38>:
.globl vector38
vector38:
  pushl $0
c0101efc:	6a 00                	push   $0x0
  pushl $38
c0101efe:	6a 26                	push   $0x26
  jmp __alltraps
c0101f00:	e9 8d fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f05 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f05:	6a 00                	push   $0x0
  pushl $39
c0101f07:	6a 27                	push   $0x27
  jmp __alltraps
c0101f09:	e9 84 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f0e <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f0e:	6a 00                	push   $0x0
  pushl $40
c0101f10:	6a 28                	push   $0x28
  jmp __alltraps
c0101f12:	e9 7b fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f17 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f17:	6a 00                	push   $0x0
  pushl $41
c0101f19:	6a 29                	push   $0x29
  jmp __alltraps
c0101f1b:	e9 72 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f20 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f20:	6a 00                	push   $0x0
  pushl $42
c0101f22:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f24:	e9 69 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f29 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f29:	6a 00                	push   $0x0
  pushl $43
c0101f2b:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f2d:	e9 60 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f32 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f32:	6a 00                	push   $0x0
  pushl $44
c0101f34:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f36:	e9 57 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f3b <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f3b:	6a 00                	push   $0x0
  pushl $45
c0101f3d:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f3f:	e9 4e fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f44 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f44:	6a 00                	push   $0x0
  pushl $46
c0101f46:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f48:	e9 45 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f4d <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f4d:	6a 00                	push   $0x0
  pushl $47
c0101f4f:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f51:	e9 3c fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f56 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f56:	6a 00                	push   $0x0
  pushl $48
c0101f58:	6a 30                	push   $0x30
  jmp __alltraps
c0101f5a:	e9 33 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f5f <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f5f:	6a 00                	push   $0x0
  pushl $49
c0101f61:	6a 31                	push   $0x31
  jmp __alltraps
c0101f63:	e9 2a fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f68 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f68:	6a 00                	push   $0x0
  pushl $50
c0101f6a:	6a 32                	push   $0x32
  jmp __alltraps
c0101f6c:	e9 21 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f71 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f71:	6a 00                	push   $0x0
  pushl $51
c0101f73:	6a 33                	push   $0x33
  jmp __alltraps
c0101f75:	e9 18 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f7a <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f7a:	6a 00                	push   $0x0
  pushl $52
c0101f7c:	6a 34                	push   $0x34
  jmp __alltraps
c0101f7e:	e9 0f fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f83 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f83:	6a 00                	push   $0x0
  pushl $53
c0101f85:	6a 35                	push   $0x35
  jmp __alltraps
c0101f87:	e9 06 fe ff ff       	jmp    c0101d92 <__alltraps>

c0101f8c <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f8c:	6a 00                	push   $0x0
  pushl $54
c0101f8e:	6a 36                	push   $0x36
  jmp __alltraps
c0101f90:	e9 fd fd ff ff       	jmp    c0101d92 <__alltraps>

c0101f95 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f95:	6a 00                	push   $0x0
  pushl $55
c0101f97:	6a 37                	push   $0x37
  jmp __alltraps
c0101f99:	e9 f4 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101f9e <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f9e:	6a 00                	push   $0x0
  pushl $56
c0101fa0:	6a 38                	push   $0x38
  jmp __alltraps
c0101fa2:	e9 eb fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fa7 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101fa7:	6a 00                	push   $0x0
  pushl $57
c0101fa9:	6a 39                	push   $0x39
  jmp __alltraps
c0101fab:	e9 e2 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fb0 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fb0:	6a 00                	push   $0x0
  pushl $58
c0101fb2:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101fb4:	e9 d9 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fb9 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101fb9:	6a 00                	push   $0x0
  pushl $59
c0101fbb:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fbd:	e9 d0 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fc2 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fc2:	6a 00                	push   $0x0
  pushl $60
c0101fc4:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fc6:	e9 c7 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fcb <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fcb:	6a 00                	push   $0x0
  pushl $61
c0101fcd:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fcf:	e9 be fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fd4 <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fd4:	6a 00                	push   $0x0
  pushl $62
c0101fd6:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fd8:	e9 b5 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fdd <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fdd:	6a 00                	push   $0x0
  pushl $63
c0101fdf:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fe1:	e9 ac fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fe6 <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fe6:	6a 00                	push   $0x0
  pushl $64
c0101fe8:	6a 40                	push   $0x40
  jmp __alltraps
c0101fea:	e9 a3 fd ff ff       	jmp    c0101d92 <__alltraps>

c0101fef <vector65>:
.globl vector65
vector65:
  pushl $0
c0101fef:	6a 00                	push   $0x0
  pushl $65
c0101ff1:	6a 41                	push   $0x41
  jmp __alltraps
c0101ff3:	e9 9a fd ff ff       	jmp    c0101d92 <__alltraps>

c0101ff8 <vector66>:
.globl vector66
vector66:
  pushl $0
c0101ff8:	6a 00                	push   $0x0
  pushl $66
c0101ffa:	6a 42                	push   $0x42
  jmp __alltraps
c0101ffc:	e9 91 fd ff ff       	jmp    c0101d92 <__alltraps>

c0102001 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102001:	6a 00                	push   $0x0
  pushl $67
c0102003:	6a 43                	push   $0x43
  jmp __alltraps
c0102005:	e9 88 fd ff ff       	jmp    c0101d92 <__alltraps>

c010200a <vector68>:
.globl vector68
vector68:
  pushl $0
c010200a:	6a 00                	push   $0x0
  pushl $68
c010200c:	6a 44                	push   $0x44
  jmp __alltraps
c010200e:	e9 7f fd ff ff       	jmp    c0101d92 <__alltraps>

c0102013 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102013:	6a 00                	push   $0x0
  pushl $69
c0102015:	6a 45                	push   $0x45
  jmp __alltraps
c0102017:	e9 76 fd ff ff       	jmp    c0101d92 <__alltraps>

c010201c <vector70>:
.globl vector70
vector70:
  pushl $0
c010201c:	6a 00                	push   $0x0
  pushl $70
c010201e:	6a 46                	push   $0x46
  jmp __alltraps
c0102020:	e9 6d fd ff ff       	jmp    c0101d92 <__alltraps>

c0102025 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102025:	6a 00                	push   $0x0
  pushl $71
c0102027:	6a 47                	push   $0x47
  jmp __alltraps
c0102029:	e9 64 fd ff ff       	jmp    c0101d92 <__alltraps>

c010202e <vector72>:
.globl vector72
vector72:
  pushl $0
c010202e:	6a 00                	push   $0x0
  pushl $72
c0102030:	6a 48                	push   $0x48
  jmp __alltraps
c0102032:	e9 5b fd ff ff       	jmp    c0101d92 <__alltraps>

c0102037 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102037:	6a 00                	push   $0x0
  pushl $73
c0102039:	6a 49                	push   $0x49
  jmp __alltraps
c010203b:	e9 52 fd ff ff       	jmp    c0101d92 <__alltraps>

c0102040 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102040:	6a 00                	push   $0x0
  pushl $74
c0102042:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102044:	e9 49 fd ff ff       	jmp    c0101d92 <__alltraps>

c0102049 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102049:	6a 00                	push   $0x0
  pushl $75
c010204b:	6a 4b                	push   $0x4b
  jmp __alltraps
c010204d:	e9 40 fd ff ff       	jmp    c0101d92 <__alltraps>

c0102052 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102052:	6a 00                	push   $0x0
  pushl $76
c0102054:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102056:	e9 37 fd ff ff       	jmp    c0101d92 <__alltraps>

c010205b <vector77>:
.globl vector77
vector77:
  pushl $0
c010205b:	6a 00                	push   $0x0
  pushl $77
c010205d:	6a 4d                	push   $0x4d
  jmp __alltraps
c010205f:	e9 2e fd ff ff       	jmp    c0101d92 <__alltraps>

c0102064 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102064:	6a 00                	push   $0x0
  pushl $78
c0102066:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102068:	e9 25 fd ff ff       	jmp    c0101d92 <__alltraps>

c010206d <vector79>:
.globl vector79
vector79:
  pushl $0
c010206d:	6a 00                	push   $0x0
  pushl $79
c010206f:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102071:	e9 1c fd ff ff       	jmp    c0101d92 <__alltraps>

c0102076 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102076:	6a 00                	push   $0x0
  pushl $80
c0102078:	6a 50                	push   $0x50
  jmp __alltraps
c010207a:	e9 13 fd ff ff       	jmp    c0101d92 <__alltraps>

c010207f <vector81>:
.globl vector81
vector81:
  pushl $0
c010207f:	6a 00                	push   $0x0
  pushl $81
c0102081:	6a 51                	push   $0x51
  jmp __alltraps
c0102083:	e9 0a fd ff ff       	jmp    c0101d92 <__alltraps>

c0102088 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102088:	6a 00                	push   $0x0
  pushl $82
c010208a:	6a 52                	push   $0x52
  jmp __alltraps
c010208c:	e9 01 fd ff ff       	jmp    c0101d92 <__alltraps>

c0102091 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102091:	6a 00                	push   $0x0
  pushl $83
c0102093:	6a 53                	push   $0x53
  jmp __alltraps
c0102095:	e9 f8 fc ff ff       	jmp    c0101d92 <__alltraps>

c010209a <vector84>:
.globl vector84
vector84:
  pushl $0
c010209a:	6a 00                	push   $0x0
  pushl $84
c010209c:	6a 54                	push   $0x54
  jmp __alltraps
c010209e:	e9 ef fc ff ff       	jmp    c0101d92 <__alltraps>

c01020a3 <vector85>:
.globl vector85
vector85:
  pushl $0
c01020a3:	6a 00                	push   $0x0
  pushl $85
c01020a5:	6a 55                	push   $0x55
  jmp __alltraps
c01020a7:	e9 e6 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020ac <vector86>:
.globl vector86
vector86:
  pushl $0
c01020ac:	6a 00                	push   $0x0
  pushl $86
c01020ae:	6a 56                	push   $0x56
  jmp __alltraps
c01020b0:	e9 dd fc ff ff       	jmp    c0101d92 <__alltraps>

c01020b5 <vector87>:
.globl vector87
vector87:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $87
c01020b7:	6a 57                	push   $0x57
  jmp __alltraps
c01020b9:	e9 d4 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020be <vector88>:
.globl vector88
vector88:
  pushl $0
c01020be:	6a 00                	push   $0x0
  pushl $88
c01020c0:	6a 58                	push   $0x58
  jmp __alltraps
c01020c2:	e9 cb fc ff ff       	jmp    c0101d92 <__alltraps>

c01020c7 <vector89>:
.globl vector89
vector89:
  pushl $0
c01020c7:	6a 00                	push   $0x0
  pushl $89
c01020c9:	6a 59                	push   $0x59
  jmp __alltraps
c01020cb:	e9 c2 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020d0 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020d0:	6a 00                	push   $0x0
  pushl $90
c01020d2:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020d4:	e9 b9 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020d9 <vector91>:
.globl vector91
vector91:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $91
c01020db:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020dd:	e9 b0 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020e2 <vector92>:
.globl vector92
vector92:
  pushl $0
c01020e2:	6a 00                	push   $0x0
  pushl $92
c01020e4:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020e6:	e9 a7 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020eb <vector93>:
.globl vector93
vector93:
  pushl $0
c01020eb:	6a 00                	push   $0x0
  pushl $93
c01020ed:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020ef:	e9 9e fc ff ff       	jmp    c0101d92 <__alltraps>

c01020f4 <vector94>:
.globl vector94
vector94:
  pushl $0
c01020f4:	6a 00                	push   $0x0
  pushl $94
c01020f6:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020f8:	e9 95 fc ff ff       	jmp    c0101d92 <__alltraps>

c01020fd <vector95>:
.globl vector95
vector95:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $95
c01020ff:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102101:	e9 8c fc ff ff       	jmp    c0101d92 <__alltraps>

c0102106 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102106:	6a 00                	push   $0x0
  pushl $96
c0102108:	6a 60                	push   $0x60
  jmp __alltraps
c010210a:	e9 83 fc ff ff       	jmp    c0101d92 <__alltraps>

c010210f <vector97>:
.globl vector97
vector97:
  pushl $0
c010210f:	6a 00                	push   $0x0
  pushl $97
c0102111:	6a 61                	push   $0x61
  jmp __alltraps
c0102113:	e9 7a fc ff ff       	jmp    c0101d92 <__alltraps>

c0102118 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102118:	6a 00                	push   $0x0
  pushl $98
c010211a:	6a 62                	push   $0x62
  jmp __alltraps
c010211c:	e9 71 fc ff ff       	jmp    c0101d92 <__alltraps>

c0102121 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $99
c0102123:	6a 63                	push   $0x63
  jmp __alltraps
c0102125:	e9 68 fc ff ff       	jmp    c0101d92 <__alltraps>

c010212a <vector100>:
.globl vector100
vector100:
  pushl $0
c010212a:	6a 00                	push   $0x0
  pushl $100
c010212c:	6a 64                	push   $0x64
  jmp __alltraps
c010212e:	e9 5f fc ff ff       	jmp    c0101d92 <__alltraps>

c0102133 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102133:	6a 00                	push   $0x0
  pushl $101
c0102135:	6a 65                	push   $0x65
  jmp __alltraps
c0102137:	e9 56 fc ff ff       	jmp    c0101d92 <__alltraps>

c010213c <vector102>:
.globl vector102
vector102:
  pushl $0
c010213c:	6a 00                	push   $0x0
  pushl $102
c010213e:	6a 66                	push   $0x66
  jmp __alltraps
c0102140:	e9 4d fc ff ff       	jmp    c0101d92 <__alltraps>

c0102145 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $103
c0102147:	6a 67                	push   $0x67
  jmp __alltraps
c0102149:	e9 44 fc ff ff       	jmp    c0101d92 <__alltraps>

c010214e <vector104>:
.globl vector104
vector104:
  pushl $0
c010214e:	6a 00                	push   $0x0
  pushl $104
c0102150:	6a 68                	push   $0x68
  jmp __alltraps
c0102152:	e9 3b fc ff ff       	jmp    c0101d92 <__alltraps>

c0102157 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102157:	6a 00                	push   $0x0
  pushl $105
c0102159:	6a 69                	push   $0x69
  jmp __alltraps
c010215b:	e9 32 fc ff ff       	jmp    c0101d92 <__alltraps>

c0102160 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102160:	6a 00                	push   $0x0
  pushl $106
c0102162:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102164:	e9 29 fc ff ff       	jmp    c0101d92 <__alltraps>

c0102169 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $107
c010216b:	6a 6b                	push   $0x6b
  jmp __alltraps
c010216d:	e9 20 fc ff ff       	jmp    c0101d92 <__alltraps>

c0102172 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102172:	6a 00                	push   $0x0
  pushl $108
c0102174:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102176:	e9 17 fc ff ff       	jmp    c0101d92 <__alltraps>

c010217b <vector109>:
.globl vector109
vector109:
  pushl $0
c010217b:	6a 00                	push   $0x0
  pushl $109
c010217d:	6a 6d                	push   $0x6d
  jmp __alltraps
c010217f:	e9 0e fc ff ff       	jmp    c0101d92 <__alltraps>

c0102184 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102184:	6a 00                	push   $0x0
  pushl $110
c0102186:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102188:	e9 05 fc ff ff       	jmp    c0101d92 <__alltraps>

c010218d <vector111>:
.globl vector111
vector111:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $111
c010218f:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102191:	e9 fc fb ff ff       	jmp    c0101d92 <__alltraps>

c0102196 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102196:	6a 00                	push   $0x0
  pushl $112
c0102198:	6a 70                	push   $0x70
  jmp __alltraps
c010219a:	e9 f3 fb ff ff       	jmp    c0101d92 <__alltraps>

c010219f <vector113>:
.globl vector113
vector113:
  pushl $0
c010219f:	6a 00                	push   $0x0
  pushl $113
c01021a1:	6a 71                	push   $0x71
  jmp __alltraps
c01021a3:	e9 ea fb ff ff       	jmp    c0101d92 <__alltraps>

c01021a8 <vector114>:
.globl vector114
vector114:
  pushl $0
c01021a8:	6a 00                	push   $0x0
  pushl $114
c01021aa:	6a 72                	push   $0x72
  jmp __alltraps
c01021ac:	e9 e1 fb ff ff       	jmp    c0101d92 <__alltraps>

c01021b1 <vector115>:
.globl vector115
vector115:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $115
c01021b3:	6a 73                	push   $0x73
  jmp __alltraps
c01021b5:	e9 d8 fb ff ff       	jmp    c0101d92 <__alltraps>

c01021ba <vector116>:
.globl vector116
vector116:
  pushl $0
c01021ba:	6a 00                	push   $0x0
  pushl $116
c01021bc:	6a 74                	push   $0x74
  jmp __alltraps
c01021be:	e9 cf fb ff ff       	jmp    c0101d92 <__alltraps>

c01021c3 <vector117>:
.globl vector117
vector117:
  pushl $0
c01021c3:	6a 00                	push   $0x0
  pushl $117
c01021c5:	6a 75                	push   $0x75
  jmp __alltraps
c01021c7:	e9 c6 fb ff ff       	jmp    c0101d92 <__alltraps>

c01021cc <vector118>:
.globl vector118
vector118:
  pushl $0
c01021cc:	6a 00                	push   $0x0
  pushl $118
c01021ce:	6a 76                	push   $0x76
  jmp __alltraps
c01021d0:	e9 bd fb ff ff       	jmp    c0101d92 <__alltraps>

c01021d5 <vector119>:
.globl vector119
vector119:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $119
c01021d7:	6a 77                	push   $0x77
  jmp __alltraps
c01021d9:	e9 b4 fb ff ff       	jmp    c0101d92 <__alltraps>

c01021de <vector120>:
.globl vector120
vector120:
  pushl $0
c01021de:	6a 00                	push   $0x0
  pushl $120
c01021e0:	6a 78                	push   $0x78
  jmp __alltraps
c01021e2:	e9 ab fb ff ff       	jmp    c0101d92 <__alltraps>

c01021e7 <vector121>:
.globl vector121
vector121:
  pushl $0
c01021e7:	6a 00                	push   $0x0
  pushl $121
c01021e9:	6a 79                	push   $0x79
  jmp __alltraps
c01021eb:	e9 a2 fb ff ff       	jmp    c0101d92 <__alltraps>

c01021f0 <vector122>:
.globl vector122
vector122:
  pushl $0
c01021f0:	6a 00                	push   $0x0
  pushl $122
c01021f2:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021f4:	e9 99 fb ff ff       	jmp    c0101d92 <__alltraps>

c01021f9 <vector123>:
.globl vector123
vector123:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $123
c01021fb:	6a 7b                	push   $0x7b
  jmp __alltraps
c01021fd:	e9 90 fb ff ff       	jmp    c0101d92 <__alltraps>

c0102202 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102202:	6a 00                	push   $0x0
  pushl $124
c0102204:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102206:	e9 87 fb ff ff       	jmp    c0101d92 <__alltraps>

c010220b <vector125>:
.globl vector125
vector125:
  pushl $0
c010220b:	6a 00                	push   $0x0
  pushl $125
c010220d:	6a 7d                	push   $0x7d
  jmp __alltraps
c010220f:	e9 7e fb ff ff       	jmp    c0101d92 <__alltraps>

c0102214 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102214:	6a 00                	push   $0x0
  pushl $126
c0102216:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102218:	e9 75 fb ff ff       	jmp    c0101d92 <__alltraps>

c010221d <vector127>:
.globl vector127
vector127:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $127
c010221f:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102221:	e9 6c fb ff ff       	jmp    c0101d92 <__alltraps>

c0102226 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102226:	6a 00                	push   $0x0
  pushl $128
c0102228:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010222d:	e9 60 fb ff ff       	jmp    c0101d92 <__alltraps>

c0102232 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102232:	6a 00                	push   $0x0
  pushl $129
c0102234:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102239:	e9 54 fb ff ff       	jmp    c0101d92 <__alltraps>

c010223e <vector130>:
.globl vector130
vector130:
  pushl $0
c010223e:	6a 00                	push   $0x0
  pushl $130
c0102240:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102245:	e9 48 fb ff ff       	jmp    c0101d92 <__alltraps>

c010224a <vector131>:
.globl vector131
vector131:
  pushl $0
c010224a:	6a 00                	push   $0x0
  pushl $131
c010224c:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102251:	e9 3c fb ff ff       	jmp    c0101d92 <__alltraps>

c0102256 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102256:	6a 00                	push   $0x0
  pushl $132
c0102258:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010225d:	e9 30 fb ff ff       	jmp    c0101d92 <__alltraps>

c0102262 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102262:	6a 00                	push   $0x0
  pushl $133
c0102264:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102269:	e9 24 fb ff ff       	jmp    c0101d92 <__alltraps>

c010226e <vector134>:
.globl vector134
vector134:
  pushl $0
c010226e:	6a 00                	push   $0x0
  pushl $134
c0102270:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102275:	e9 18 fb ff ff       	jmp    c0101d92 <__alltraps>

c010227a <vector135>:
.globl vector135
vector135:
  pushl $0
c010227a:	6a 00                	push   $0x0
  pushl $135
c010227c:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102281:	e9 0c fb ff ff       	jmp    c0101d92 <__alltraps>

c0102286 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102286:	6a 00                	push   $0x0
  pushl $136
c0102288:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010228d:	e9 00 fb ff ff       	jmp    c0101d92 <__alltraps>

c0102292 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102292:	6a 00                	push   $0x0
  pushl $137
c0102294:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102299:	e9 f4 fa ff ff       	jmp    c0101d92 <__alltraps>

c010229e <vector138>:
.globl vector138
vector138:
  pushl $0
c010229e:	6a 00                	push   $0x0
  pushl $138
c01022a0:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022a5:	e9 e8 fa ff ff       	jmp    c0101d92 <__alltraps>

c01022aa <vector139>:
.globl vector139
vector139:
  pushl $0
c01022aa:	6a 00                	push   $0x0
  pushl $139
c01022ac:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022b1:	e9 dc fa ff ff       	jmp    c0101d92 <__alltraps>

c01022b6 <vector140>:
.globl vector140
vector140:
  pushl $0
c01022b6:	6a 00                	push   $0x0
  pushl $140
c01022b8:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022bd:	e9 d0 fa ff ff       	jmp    c0101d92 <__alltraps>

c01022c2 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022c2:	6a 00                	push   $0x0
  pushl $141
c01022c4:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022c9:	e9 c4 fa ff ff       	jmp    c0101d92 <__alltraps>

c01022ce <vector142>:
.globl vector142
vector142:
  pushl $0
c01022ce:	6a 00                	push   $0x0
  pushl $142
c01022d0:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022d5:	e9 b8 fa ff ff       	jmp    c0101d92 <__alltraps>

c01022da <vector143>:
.globl vector143
vector143:
  pushl $0
c01022da:	6a 00                	push   $0x0
  pushl $143
c01022dc:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022e1:	e9 ac fa ff ff       	jmp    c0101d92 <__alltraps>

c01022e6 <vector144>:
.globl vector144
vector144:
  pushl $0
c01022e6:	6a 00                	push   $0x0
  pushl $144
c01022e8:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022ed:	e9 a0 fa ff ff       	jmp    c0101d92 <__alltraps>

c01022f2 <vector145>:
.globl vector145
vector145:
  pushl $0
c01022f2:	6a 00                	push   $0x0
  pushl $145
c01022f4:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01022f9:	e9 94 fa ff ff       	jmp    c0101d92 <__alltraps>

c01022fe <vector146>:
.globl vector146
vector146:
  pushl $0
c01022fe:	6a 00                	push   $0x0
  pushl $146
c0102300:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102305:	e9 88 fa ff ff       	jmp    c0101d92 <__alltraps>

c010230a <vector147>:
.globl vector147
vector147:
  pushl $0
c010230a:	6a 00                	push   $0x0
  pushl $147
c010230c:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102311:	e9 7c fa ff ff       	jmp    c0101d92 <__alltraps>

c0102316 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102316:	6a 00                	push   $0x0
  pushl $148
c0102318:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010231d:	e9 70 fa ff ff       	jmp    c0101d92 <__alltraps>

c0102322 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102322:	6a 00                	push   $0x0
  pushl $149
c0102324:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102329:	e9 64 fa ff ff       	jmp    c0101d92 <__alltraps>

c010232e <vector150>:
.globl vector150
vector150:
  pushl $0
c010232e:	6a 00                	push   $0x0
  pushl $150
c0102330:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102335:	e9 58 fa ff ff       	jmp    c0101d92 <__alltraps>

c010233a <vector151>:
.globl vector151
vector151:
  pushl $0
c010233a:	6a 00                	push   $0x0
  pushl $151
c010233c:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102341:	e9 4c fa ff ff       	jmp    c0101d92 <__alltraps>

c0102346 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102346:	6a 00                	push   $0x0
  pushl $152
c0102348:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010234d:	e9 40 fa ff ff       	jmp    c0101d92 <__alltraps>

c0102352 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102352:	6a 00                	push   $0x0
  pushl $153
c0102354:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102359:	e9 34 fa ff ff       	jmp    c0101d92 <__alltraps>

c010235e <vector154>:
.globl vector154
vector154:
  pushl $0
c010235e:	6a 00                	push   $0x0
  pushl $154
c0102360:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102365:	e9 28 fa ff ff       	jmp    c0101d92 <__alltraps>

c010236a <vector155>:
.globl vector155
vector155:
  pushl $0
c010236a:	6a 00                	push   $0x0
  pushl $155
c010236c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102371:	e9 1c fa ff ff       	jmp    c0101d92 <__alltraps>

c0102376 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102376:	6a 00                	push   $0x0
  pushl $156
c0102378:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010237d:	e9 10 fa ff ff       	jmp    c0101d92 <__alltraps>

c0102382 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102382:	6a 00                	push   $0x0
  pushl $157
c0102384:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102389:	e9 04 fa ff ff       	jmp    c0101d92 <__alltraps>

c010238e <vector158>:
.globl vector158
vector158:
  pushl $0
c010238e:	6a 00                	push   $0x0
  pushl $158
c0102390:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102395:	e9 f8 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010239a <vector159>:
.globl vector159
vector159:
  pushl $0
c010239a:	6a 00                	push   $0x0
  pushl $159
c010239c:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023a1:	e9 ec f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023a6 <vector160>:
.globl vector160
vector160:
  pushl $0
c01023a6:	6a 00                	push   $0x0
  pushl $160
c01023a8:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023ad:	e9 e0 f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023b2 <vector161>:
.globl vector161
vector161:
  pushl $0
c01023b2:	6a 00                	push   $0x0
  pushl $161
c01023b4:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023b9:	e9 d4 f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023be <vector162>:
.globl vector162
vector162:
  pushl $0
c01023be:	6a 00                	push   $0x0
  pushl $162
c01023c0:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023c5:	e9 c8 f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023ca <vector163>:
.globl vector163
vector163:
  pushl $0
c01023ca:	6a 00                	push   $0x0
  pushl $163
c01023cc:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023d1:	e9 bc f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023d6 <vector164>:
.globl vector164
vector164:
  pushl $0
c01023d6:	6a 00                	push   $0x0
  pushl $164
c01023d8:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023dd:	e9 b0 f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023e2 <vector165>:
.globl vector165
vector165:
  pushl $0
c01023e2:	6a 00                	push   $0x0
  pushl $165
c01023e4:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023e9:	e9 a4 f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023ee <vector166>:
.globl vector166
vector166:
  pushl $0
c01023ee:	6a 00                	push   $0x0
  pushl $166
c01023f0:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023f5:	e9 98 f9 ff ff       	jmp    c0101d92 <__alltraps>

c01023fa <vector167>:
.globl vector167
vector167:
  pushl $0
c01023fa:	6a 00                	push   $0x0
  pushl $167
c01023fc:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102401:	e9 8c f9 ff ff       	jmp    c0101d92 <__alltraps>

c0102406 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102406:	6a 00                	push   $0x0
  pushl $168
c0102408:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010240d:	e9 80 f9 ff ff       	jmp    c0101d92 <__alltraps>

c0102412 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102412:	6a 00                	push   $0x0
  pushl $169
c0102414:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102419:	e9 74 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010241e <vector170>:
.globl vector170
vector170:
  pushl $0
c010241e:	6a 00                	push   $0x0
  pushl $170
c0102420:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102425:	e9 68 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010242a <vector171>:
.globl vector171
vector171:
  pushl $0
c010242a:	6a 00                	push   $0x0
  pushl $171
c010242c:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102431:	e9 5c f9 ff ff       	jmp    c0101d92 <__alltraps>

c0102436 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102436:	6a 00                	push   $0x0
  pushl $172
c0102438:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010243d:	e9 50 f9 ff ff       	jmp    c0101d92 <__alltraps>

c0102442 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102442:	6a 00                	push   $0x0
  pushl $173
c0102444:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102449:	e9 44 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010244e <vector174>:
.globl vector174
vector174:
  pushl $0
c010244e:	6a 00                	push   $0x0
  pushl $174
c0102450:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102455:	e9 38 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010245a <vector175>:
.globl vector175
vector175:
  pushl $0
c010245a:	6a 00                	push   $0x0
  pushl $175
c010245c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102461:	e9 2c f9 ff ff       	jmp    c0101d92 <__alltraps>

c0102466 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102466:	6a 00                	push   $0x0
  pushl $176
c0102468:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010246d:	e9 20 f9 ff ff       	jmp    c0101d92 <__alltraps>

c0102472 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102472:	6a 00                	push   $0x0
  pushl $177
c0102474:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102479:	e9 14 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010247e <vector178>:
.globl vector178
vector178:
  pushl $0
c010247e:	6a 00                	push   $0x0
  pushl $178
c0102480:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102485:	e9 08 f9 ff ff       	jmp    c0101d92 <__alltraps>

c010248a <vector179>:
.globl vector179
vector179:
  pushl $0
c010248a:	6a 00                	push   $0x0
  pushl $179
c010248c:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102491:	e9 fc f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102496 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102496:	6a 00                	push   $0x0
  pushl $180
c0102498:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010249d:	e9 f0 f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024a2 <vector181>:
.globl vector181
vector181:
  pushl $0
c01024a2:	6a 00                	push   $0x0
  pushl $181
c01024a4:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024a9:	e9 e4 f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024ae <vector182>:
.globl vector182
vector182:
  pushl $0
c01024ae:	6a 00                	push   $0x0
  pushl $182
c01024b0:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024b5:	e9 d8 f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024ba <vector183>:
.globl vector183
vector183:
  pushl $0
c01024ba:	6a 00                	push   $0x0
  pushl $183
c01024bc:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024c1:	e9 cc f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024c6 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024c6:	6a 00                	push   $0x0
  pushl $184
c01024c8:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024cd:	e9 c0 f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024d2 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024d2:	6a 00                	push   $0x0
  pushl $185
c01024d4:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024d9:	e9 b4 f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024de <vector186>:
.globl vector186
vector186:
  pushl $0
c01024de:	6a 00                	push   $0x0
  pushl $186
c01024e0:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024e5:	e9 a8 f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024ea <vector187>:
.globl vector187
vector187:
  pushl $0
c01024ea:	6a 00                	push   $0x0
  pushl $187
c01024ec:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024f1:	e9 9c f8 ff ff       	jmp    c0101d92 <__alltraps>

c01024f6 <vector188>:
.globl vector188
vector188:
  pushl $0
c01024f6:	6a 00                	push   $0x0
  pushl $188
c01024f8:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01024fd:	e9 90 f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102502 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102502:	6a 00                	push   $0x0
  pushl $189
c0102504:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102509:	e9 84 f8 ff ff       	jmp    c0101d92 <__alltraps>

c010250e <vector190>:
.globl vector190
vector190:
  pushl $0
c010250e:	6a 00                	push   $0x0
  pushl $190
c0102510:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102515:	e9 78 f8 ff ff       	jmp    c0101d92 <__alltraps>

c010251a <vector191>:
.globl vector191
vector191:
  pushl $0
c010251a:	6a 00                	push   $0x0
  pushl $191
c010251c:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102521:	e9 6c f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102526 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102526:	6a 00                	push   $0x0
  pushl $192
c0102528:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010252d:	e9 60 f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102532 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102532:	6a 00                	push   $0x0
  pushl $193
c0102534:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102539:	e9 54 f8 ff ff       	jmp    c0101d92 <__alltraps>

c010253e <vector194>:
.globl vector194
vector194:
  pushl $0
c010253e:	6a 00                	push   $0x0
  pushl $194
c0102540:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102545:	e9 48 f8 ff ff       	jmp    c0101d92 <__alltraps>

c010254a <vector195>:
.globl vector195
vector195:
  pushl $0
c010254a:	6a 00                	push   $0x0
  pushl $195
c010254c:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102551:	e9 3c f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102556 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102556:	6a 00                	push   $0x0
  pushl $196
c0102558:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010255d:	e9 30 f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102562 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102562:	6a 00                	push   $0x0
  pushl $197
c0102564:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102569:	e9 24 f8 ff ff       	jmp    c0101d92 <__alltraps>

c010256e <vector198>:
.globl vector198
vector198:
  pushl $0
c010256e:	6a 00                	push   $0x0
  pushl $198
c0102570:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102575:	e9 18 f8 ff ff       	jmp    c0101d92 <__alltraps>

c010257a <vector199>:
.globl vector199
vector199:
  pushl $0
c010257a:	6a 00                	push   $0x0
  pushl $199
c010257c:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102581:	e9 0c f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102586 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102586:	6a 00                	push   $0x0
  pushl $200
c0102588:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010258d:	e9 00 f8 ff ff       	jmp    c0101d92 <__alltraps>

c0102592 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102592:	6a 00                	push   $0x0
  pushl $201
c0102594:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102599:	e9 f4 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010259e <vector202>:
.globl vector202
vector202:
  pushl $0
c010259e:	6a 00                	push   $0x0
  pushl $202
c01025a0:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025a5:	e9 e8 f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025aa <vector203>:
.globl vector203
vector203:
  pushl $0
c01025aa:	6a 00                	push   $0x0
  pushl $203
c01025ac:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025b1:	e9 dc f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025b6 <vector204>:
.globl vector204
vector204:
  pushl $0
c01025b6:	6a 00                	push   $0x0
  pushl $204
c01025b8:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025bd:	e9 d0 f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025c2 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025c2:	6a 00                	push   $0x0
  pushl $205
c01025c4:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025c9:	e9 c4 f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025ce <vector206>:
.globl vector206
vector206:
  pushl $0
c01025ce:	6a 00                	push   $0x0
  pushl $206
c01025d0:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025d5:	e9 b8 f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025da <vector207>:
.globl vector207
vector207:
  pushl $0
c01025da:	6a 00                	push   $0x0
  pushl $207
c01025dc:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025e1:	e9 ac f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025e6 <vector208>:
.globl vector208
vector208:
  pushl $0
c01025e6:	6a 00                	push   $0x0
  pushl $208
c01025e8:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025ed:	e9 a0 f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025f2 <vector209>:
.globl vector209
vector209:
  pushl $0
c01025f2:	6a 00                	push   $0x0
  pushl $209
c01025f4:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01025f9:	e9 94 f7 ff ff       	jmp    c0101d92 <__alltraps>

c01025fe <vector210>:
.globl vector210
vector210:
  pushl $0
c01025fe:	6a 00                	push   $0x0
  pushl $210
c0102600:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102605:	e9 88 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010260a <vector211>:
.globl vector211
vector211:
  pushl $0
c010260a:	6a 00                	push   $0x0
  pushl $211
c010260c:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102611:	e9 7c f7 ff ff       	jmp    c0101d92 <__alltraps>

c0102616 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102616:	6a 00                	push   $0x0
  pushl $212
c0102618:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010261d:	e9 70 f7 ff ff       	jmp    c0101d92 <__alltraps>

c0102622 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102622:	6a 00                	push   $0x0
  pushl $213
c0102624:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102629:	e9 64 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010262e <vector214>:
.globl vector214
vector214:
  pushl $0
c010262e:	6a 00                	push   $0x0
  pushl $214
c0102630:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102635:	e9 58 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010263a <vector215>:
.globl vector215
vector215:
  pushl $0
c010263a:	6a 00                	push   $0x0
  pushl $215
c010263c:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102641:	e9 4c f7 ff ff       	jmp    c0101d92 <__alltraps>

c0102646 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102646:	6a 00                	push   $0x0
  pushl $216
c0102648:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010264d:	e9 40 f7 ff ff       	jmp    c0101d92 <__alltraps>

c0102652 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102652:	6a 00                	push   $0x0
  pushl $217
c0102654:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102659:	e9 34 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010265e <vector218>:
.globl vector218
vector218:
  pushl $0
c010265e:	6a 00                	push   $0x0
  pushl $218
c0102660:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102665:	e9 28 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010266a <vector219>:
.globl vector219
vector219:
  pushl $0
c010266a:	6a 00                	push   $0x0
  pushl $219
c010266c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102671:	e9 1c f7 ff ff       	jmp    c0101d92 <__alltraps>

c0102676 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102676:	6a 00                	push   $0x0
  pushl $220
c0102678:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010267d:	e9 10 f7 ff ff       	jmp    c0101d92 <__alltraps>

c0102682 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102682:	6a 00                	push   $0x0
  pushl $221
c0102684:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102689:	e9 04 f7 ff ff       	jmp    c0101d92 <__alltraps>

c010268e <vector222>:
.globl vector222
vector222:
  pushl $0
c010268e:	6a 00                	push   $0x0
  pushl $222
c0102690:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102695:	e9 f8 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010269a <vector223>:
.globl vector223
vector223:
  pushl $0
c010269a:	6a 00                	push   $0x0
  pushl $223
c010269c:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026a1:	e9 ec f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026a6 <vector224>:
.globl vector224
vector224:
  pushl $0
c01026a6:	6a 00                	push   $0x0
  pushl $224
c01026a8:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026ad:	e9 e0 f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026b2 <vector225>:
.globl vector225
vector225:
  pushl $0
c01026b2:	6a 00                	push   $0x0
  pushl $225
c01026b4:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026b9:	e9 d4 f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026be <vector226>:
.globl vector226
vector226:
  pushl $0
c01026be:	6a 00                	push   $0x0
  pushl $226
c01026c0:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026c5:	e9 c8 f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026ca <vector227>:
.globl vector227
vector227:
  pushl $0
c01026ca:	6a 00                	push   $0x0
  pushl $227
c01026cc:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026d1:	e9 bc f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026d6 <vector228>:
.globl vector228
vector228:
  pushl $0
c01026d6:	6a 00                	push   $0x0
  pushl $228
c01026d8:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026dd:	e9 b0 f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026e2 <vector229>:
.globl vector229
vector229:
  pushl $0
c01026e2:	6a 00                	push   $0x0
  pushl $229
c01026e4:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026e9:	e9 a4 f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026ee <vector230>:
.globl vector230
vector230:
  pushl $0
c01026ee:	6a 00                	push   $0x0
  pushl $230
c01026f0:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026f5:	e9 98 f6 ff ff       	jmp    c0101d92 <__alltraps>

c01026fa <vector231>:
.globl vector231
vector231:
  pushl $0
c01026fa:	6a 00                	push   $0x0
  pushl $231
c01026fc:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102701:	e9 8c f6 ff ff       	jmp    c0101d92 <__alltraps>

c0102706 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102706:	6a 00                	push   $0x0
  pushl $232
c0102708:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010270d:	e9 80 f6 ff ff       	jmp    c0101d92 <__alltraps>

c0102712 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102712:	6a 00                	push   $0x0
  pushl $233
c0102714:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102719:	e9 74 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010271e <vector234>:
.globl vector234
vector234:
  pushl $0
c010271e:	6a 00                	push   $0x0
  pushl $234
c0102720:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102725:	e9 68 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010272a <vector235>:
.globl vector235
vector235:
  pushl $0
c010272a:	6a 00                	push   $0x0
  pushl $235
c010272c:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102731:	e9 5c f6 ff ff       	jmp    c0101d92 <__alltraps>

c0102736 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102736:	6a 00                	push   $0x0
  pushl $236
c0102738:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010273d:	e9 50 f6 ff ff       	jmp    c0101d92 <__alltraps>

c0102742 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102742:	6a 00                	push   $0x0
  pushl $237
c0102744:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102749:	e9 44 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010274e <vector238>:
.globl vector238
vector238:
  pushl $0
c010274e:	6a 00                	push   $0x0
  pushl $238
c0102750:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102755:	e9 38 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010275a <vector239>:
.globl vector239
vector239:
  pushl $0
c010275a:	6a 00                	push   $0x0
  pushl $239
c010275c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102761:	e9 2c f6 ff ff       	jmp    c0101d92 <__alltraps>

c0102766 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102766:	6a 00                	push   $0x0
  pushl $240
c0102768:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010276d:	e9 20 f6 ff ff       	jmp    c0101d92 <__alltraps>

c0102772 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102772:	6a 00                	push   $0x0
  pushl $241
c0102774:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102779:	e9 14 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010277e <vector242>:
.globl vector242
vector242:
  pushl $0
c010277e:	6a 00                	push   $0x0
  pushl $242
c0102780:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102785:	e9 08 f6 ff ff       	jmp    c0101d92 <__alltraps>

c010278a <vector243>:
.globl vector243
vector243:
  pushl $0
c010278a:	6a 00                	push   $0x0
  pushl $243
c010278c:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102791:	e9 fc f5 ff ff       	jmp    c0101d92 <__alltraps>

c0102796 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102796:	6a 00                	push   $0x0
  pushl $244
c0102798:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010279d:	e9 f0 f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027a2 <vector245>:
.globl vector245
vector245:
  pushl $0
c01027a2:	6a 00                	push   $0x0
  pushl $245
c01027a4:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027a9:	e9 e4 f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027ae <vector246>:
.globl vector246
vector246:
  pushl $0
c01027ae:	6a 00                	push   $0x0
  pushl $246
c01027b0:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027b5:	e9 d8 f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027ba <vector247>:
.globl vector247
vector247:
  pushl $0
c01027ba:	6a 00                	push   $0x0
  pushl $247
c01027bc:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027c1:	e9 cc f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027c6 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027c6:	6a 00                	push   $0x0
  pushl $248
c01027c8:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027cd:	e9 c0 f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027d2 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027d2:	6a 00                	push   $0x0
  pushl $249
c01027d4:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027d9:	e9 b4 f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027de <vector250>:
.globl vector250
vector250:
  pushl $0
c01027de:	6a 00                	push   $0x0
  pushl $250
c01027e0:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027e5:	e9 a8 f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027ea <vector251>:
.globl vector251
vector251:
  pushl $0
c01027ea:	6a 00                	push   $0x0
  pushl $251
c01027ec:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027f1:	e9 9c f5 ff ff       	jmp    c0101d92 <__alltraps>

c01027f6 <vector252>:
.globl vector252
vector252:
  pushl $0
c01027f6:	6a 00                	push   $0x0
  pushl $252
c01027f8:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01027fd:	e9 90 f5 ff ff       	jmp    c0101d92 <__alltraps>

c0102802 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102802:	6a 00                	push   $0x0
  pushl $253
c0102804:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102809:	e9 84 f5 ff ff       	jmp    c0101d92 <__alltraps>

c010280e <vector254>:
.globl vector254
vector254:
  pushl $0
c010280e:	6a 00                	push   $0x0
  pushl $254
c0102810:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102815:	e9 78 f5 ff ff       	jmp    c0101d92 <__alltraps>

c010281a <vector255>:
.globl vector255
vector255:
  pushl $0
c010281a:	6a 00                	push   $0x0
  pushl $255
c010281c:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102821:	e9 6c f5 ff ff       	jmp    c0101d92 <__alltraps>

c0102826 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102826:	55                   	push   %ebp
c0102827:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102829:	8b 55 08             	mov    0x8(%ebp),%edx
c010282c:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0102831:	29 c2                	sub    %eax,%edx
c0102833:	89 d0                	mov    %edx,%eax
c0102835:	c1 f8 02             	sar    $0x2,%eax
c0102838:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010283e:	5d                   	pop    %ebp
c010283f:	c3                   	ret    

c0102840 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102840:	55                   	push   %ebp
c0102841:	89 e5                	mov    %esp,%ebp
c0102843:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102846:	8b 45 08             	mov    0x8(%ebp),%eax
c0102849:	89 04 24             	mov    %eax,(%esp)
c010284c:	e8 d5 ff ff ff       	call   c0102826 <page2ppn>
c0102851:	c1 e0 0c             	shl    $0xc,%eax
}
c0102854:	c9                   	leave  
c0102855:	c3                   	ret    

c0102856 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102856:	55                   	push   %ebp
c0102857:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102859:	8b 45 08             	mov    0x8(%ebp),%eax
c010285c:	8b 00                	mov    (%eax),%eax
}
c010285e:	5d                   	pop    %ebp
c010285f:	c3                   	ret    

c0102860 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102860:	55                   	push   %ebp
c0102861:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102863:	8b 45 08             	mov    0x8(%ebp),%eax
c0102866:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102869:	89 10                	mov    %edx,(%eax)
}
c010286b:	5d                   	pop    %ebp
c010286c:	c3                   	ret    

c010286d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010286d:	55                   	push   %ebp
c010286e:	89 e5                	mov    %esp,%ebp
c0102870:	83 ec 10             	sub    $0x10,%esp
c0102873:	c7 45 fc 10 af 11 c0 	movl   $0xc011af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010287d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102880:	89 50 04             	mov    %edx,0x4(%eax)
c0102883:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102886:	8b 50 04             	mov    0x4(%eax),%edx
c0102889:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010288c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010288e:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0102895:	00 00 00 
}
c0102898:	c9                   	leave  
c0102899:	c3                   	ret    

c010289a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010289a:	55                   	push   %ebp
c010289b:	89 e5                	mov    %esp,%ebp
c010289d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01028a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01028a4:	75 24                	jne    c01028ca <default_init_memmap+0x30>
c01028a6:	c7 44 24 0c 90 66 10 	movl   $0xc0106690,0xc(%esp)
c01028ad:	c0 
c01028ae:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01028b5:	c0 
c01028b6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01028bd:	00 
c01028be:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01028c5:	e8 08 e4 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c01028ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01028cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01028d0:	eb 7d                	jmp    c010294f <default_init_memmap+0xb5>
        assert(PageReserved(p));//确认本页是否为保留页
c01028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028d5:	83 c0 04             	add    $0x4,%eax
c01028d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01028df:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01028e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01028e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01028e8:	0f a3 10             	bt     %edx,(%eax)
c01028eb:	19 c0                	sbb    %eax,%eax
c01028ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01028f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01028f4:	0f 95 c0             	setne  %al
c01028f7:	0f b6 c0             	movzbl %al,%eax
c01028fa:	85 c0                	test   %eax,%eax
c01028fc:	75 24                	jne    c0102922 <default_init_memmap+0x88>
c01028fe:	c7 44 24 0c c1 66 10 	movl   $0xc01066c1,0xc(%esp)
c0102905:	c0 
c0102906:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010290d:	c0 
c010290e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0102915:	00 
c0102916:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010291d:	e8 b0 e3 ff ff       	call   c0100cd2 <__panic>
        //设置标志位
        p->flags = p->property = 0;
c0102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102925:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010292c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010292f:	8b 50 08             	mov    0x8(%eax),%edx
c0102932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102935:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);//清空引用
c0102938:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010293f:	00 
c0102940:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102943:	89 04 24             	mov    %eax,(%esp)
c0102946:	e8 15 ff ff ff       	call   c0102860 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010294b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010294f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102952:	89 d0                	mov    %edx,%eax
c0102954:	c1 e0 02             	shl    $0x2,%eax
c0102957:	01 d0                	add    %edx,%eax
c0102959:	c1 e0 02             	shl    $0x2,%eax
c010295c:	89 c2                	mov    %eax,%edx
c010295e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102961:	01 d0                	add    %edx,%eax
c0102963:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102966:	0f 85 66 ff ff ff    	jne    c01028d2 <default_init_memmap+0x38>
        //设置标志位
        p->flags = p->property = 0;
        set_page_ref(p, 0);//清空引用
        
    }
    base->property = n; //头一个空闲页 要设置数量
c010296c:	8b 45 08             	mov    0x8(%ebp),%eax
c010296f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102972:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102975:	8b 45 08             	mov    0x8(%ebp),%eax
c0102978:	83 c0 04             	add    $0x4,%eax
c010297b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102982:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102985:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102988:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010298b:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;  //说明连续有n个空闲页，属于空闲链表
c010298e:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102994:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102997:	01 d0                	add    %edx,%eax
c0102999:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    list_add_before(&free_list, &(p->page_link));
c010299e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029a1:	83 c0 0c             	add    $0xc,%eax
c01029a4:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
c01029ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01029ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029b1:	8b 00                	mov    (%eax),%eax
c01029b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01029b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01029b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01029bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01029c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01029c8:	89 10                	mov    %edx,(%eax)
c01029ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029cd:	8b 10                	mov    (%eax),%edx
c01029cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01029d2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01029d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01029d8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01029db:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01029de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01029e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01029e4:	89 10                	mov    %edx,(%eax)
}
c01029e6:	c9                   	leave  
c01029e7:	c3                   	ret    

c01029e8 <default_alloc_pages>:


static struct Page *
default_alloc_pages(size_t n) {
c01029e8:	55                   	push   %ebp
c01029e9:	89 e5                	mov    %esp,%ebp
c01029eb:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01029ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029f2:	75 24                	jne    c0102a18 <default_alloc_pages+0x30>
c01029f4:	c7 44 24 0c 90 66 10 	movl   $0xc0106690,0xc(%esp)
c01029fb:	c0 
c01029fc:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102a03:	c0 
c0102a04:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0102a0b:	00 
c0102a0c:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102a13:	e8 ba e2 ff ff       	call   c0100cd2 <__panic>
    if (n > nr_free) { //如果所有的空闲页的加起来的大小都不够，那直接返回NULL
c0102a18:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102a1d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a20:	73 0a                	jae    c0102a2c <default_alloc_pages+0x44>
        return NULL;
c0102a22:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a27:	e9 49 01 00 00       	jmp    c0102b75 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
c0102a2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
c0102a33:	c7 45 f0 10 af 11 c0 	movl   $0xc011af10,-0x10(%ebp)
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
c0102a3a:	eb 1c                	jmp    c0102a58 <default_alloc_pages+0x70>
        // 此处 le2page 就是将 le 的地址 - page_link 在 Page 的偏移 从而找到 Page 的地址
        struct Page *p = le2page(le, page_link);//将地址转换成页的结构
c0102a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a3f:	83 e8 0c             	sub    $0xc,%eax
c0102a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
c0102a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a48:	8b 40 08             	mov    0x8(%eax),%eax
c0102a4b:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a4e:	72 08                	jb     c0102a58 <default_alloc_pages+0x70>
            page = p;
c0102a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a53:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102a56:	eb 18                	jmp    c0102a70 <default_alloc_pages+0x88>
c0102a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a61:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
c0102a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102a67:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102a6e:	75 cc                	jne    c0102a3c <default_alloc_pages+0x54>
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102a70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102a74:	0f 84 f8 00 00 00    	je     c0102b72 <default_alloc_pages+0x18a>
        if (page->property > n) {
c0102a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a7d:	8b 40 08             	mov    0x8(%eax),%eax
c0102a80:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a83:	0f 86 98 00 00 00    	jbe    c0102b21 <default_alloc_pages+0x139>
            struct Page *p = page + n;
c0102a89:	8b 55 08             	mov    0x8(%ebp),%edx
c0102a8c:	89 d0                	mov    %edx,%eax
c0102a8e:	c1 e0 02             	shl    $0x2,%eax
c0102a91:	01 d0                	add    %edx,%eax
c0102a93:	c1 e0 02             	shl    $0x2,%eax
c0102a96:	89 c2                	mov    %eax,%edx
c0102a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a9b:	01 d0                	add    %edx,%eax
c0102a9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//如果选中的第一个连续的块大于n，只取其中的大小为n的块
c0102aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102aa3:	8b 40 08             	mov    0x8(%eax),%eax
c0102aa6:	2b 45 08             	sub    0x8(%ebp),%eax
c0102aa9:	89 c2                	mov    %eax,%edx
c0102aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102aae:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102ab1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ab4:	83 c0 04             	add    $0x4,%eax
c0102ab7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102abe:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102ac1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102ac4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102ac7:	0f ab 10             	bts    %edx,(%eax)
            // 将多出来的插入到 被分配掉的页块 后面
            list_add(&(page->page_link), &(p->page_link));
c0102aca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102acd:	83 c0 0c             	add    $0xc,%eax
c0102ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102ad3:	83 c2 0c             	add    $0xc,%edx
c0102ad6:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102ad9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102adc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102adf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ae2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102ae5:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102ae8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102aeb:	8b 40 04             	mov    0x4(%eax),%eax
c0102aee:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102af1:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102af4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102af7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0102afa:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102afd:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102b00:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102b03:	89 10                	mov    %edx,(%eax)
c0102b05:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102b08:	8b 10                	mov    (%eax),%edx
c0102b0a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102b0d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b10:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b13:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102b16:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b19:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b1c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102b1f:	89 10                	mov    %edx,(%eax)
        }
        // 最后在空闲页链表中删除掉原来的空闲页
        list_del(&(page->page_link));
c0102b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b24:	83 c0 0c             	add    $0xc,%eax
c0102b27:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102b2a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102b2d:	8b 40 04             	mov    0x4(%eax),%eax
c0102b30:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102b33:	8b 12                	mov    (%edx),%edx
c0102b35:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102b38:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102b3b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102b3e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102b41:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102b44:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102b47:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102b4a:	89 10                	mov    %edx,(%eax)
	
        nr_free -= n;//当前空闲页的数目减n
c0102b4c:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102b51:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b54:	a3 18 af 11 c0       	mov    %eax,0xc011af18
        ClearPageProperty(page);
c0102b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b5c:	83 c0 04             	add    $0x4,%eax
c0102b5f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102b66:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b69:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102b6c:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102b6f:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b75:	c9                   	leave  
c0102b76:	c3                   	ret    

c0102b77 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102b77:	55                   	push   %ebp
c0102b78:	89 e5                	mov    %esp,%ebp
c0102b7a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102b84:	75 24                	jne    c0102baa <default_free_pages+0x33>
c0102b86:	c7 44 24 0c 90 66 10 	movl   $0xc0106690,0xc(%esp)
c0102b8d:	c0 
c0102b8e:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102b95:	c0 
c0102b96:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c0102b9d:	00 
c0102b9e:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102ba5:	e8 28 e1 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c0102baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102bb0:	e9 9d 00 00 00       	jmp    c0102c52 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bb8:	83 c0 04             	add    $0x4,%eax
c0102bbb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102bc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102bcb:	0f a3 10             	bt     %edx,(%eax)
c0102bce:	19 c0                	sbb    %eax,%eax
c0102bd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102bd3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102bd7:	0f 95 c0             	setne  %al
c0102bda:	0f b6 c0             	movzbl %al,%eax
c0102bdd:	85 c0                	test   %eax,%eax
c0102bdf:	75 2c                	jne    c0102c0d <default_free_pages+0x96>
c0102be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102be4:	83 c0 04             	add    $0x4,%eax
c0102be7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102bee:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102bf1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102bf4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102bf7:	0f a3 10             	bt     %edx,(%eax)
c0102bfa:	19 c0                	sbb    %eax,%eax
c0102bfc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102bff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102c03:	0f 95 c0             	setne  %al
c0102c06:	0f b6 c0             	movzbl %al,%eax
c0102c09:	85 c0                	test   %eax,%eax
c0102c0b:	74 24                	je     c0102c31 <default_free_pages+0xba>
c0102c0d:	c7 44 24 0c d4 66 10 	movl   $0xc01066d4,0xc(%esp)
c0102c14:	c0 
c0102c15:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102c1c:	c0 
c0102c1d:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c0102c24:	00 
c0102c25:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102c2c:	e8 a1 e0 ff ff       	call   c0100cd2 <__panic>
        p->flags = 0;//修改标志位
c0102c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c34:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c42:	00 
c0102c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c46:	89 04 24             	mov    %eax,(%esp)
c0102c49:	e8 12 fc ff ff       	call   c0102860 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102c4e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102c52:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c55:	89 d0                	mov    %edx,%eax
c0102c57:	c1 e0 02             	shl    $0x2,%eax
c0102c5a:	01 d0                	add    %edx,%eax
c0102c5c:	c1 e0 02             	shl    $0x2,%eax
c0102c5f:	89 c2                	mov    %eax,%edx
c0102c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c64:	01 d0                	add    %edx,%eax
c0102c66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102c69:	0f 85 46 ff ff ff    	jne    c0102bb5 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;//修改标志位
        set_page_ref(p, 0);
    }
    base->property = n;//设置连续大小为n
c0102c6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c72:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c75:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102c78:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c7b:	83 c0 04             	add    $0x4,%eax
c0102c7e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102c85:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102c88:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102c8b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102c8e:	0f ab 10             	bts    %edx,(%eax)
c0102c91:	c7 45 cc 10 af 11 c0 	movl   $0xc011af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102c98:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102c9b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 合并到合适的页块中
    while (le != &free_list) {
c0102ca1:	e9 08 01 00 00       	jmp    c0102dae <default_free_pages+0x237>
        p = le2page(le, page_link);//获取链表对应的Page
c0102ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ca9:	83 e8 0c             	sub    $0xc,%eax
c0102cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cb2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102cb5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102cb8:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102cbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cc1:	8b 50 08             	mov    0x8(%eax),%edx
c0102cc4:	89 d0                	mov    %edx,%eax
c0102cc6:	c1 e0 02             	shl    $0x2,%eax
c0102cc9:	01 d0                	add    %edx,%eax
c0102ccb:	c1 e0 02             	shl    $0x2,%eax
c0102cce:	89 c2                	mov    %eax,%edx
c0102cd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cd3:	01 d0                	add    %edx,%eax
c0102cd5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102cd8:	75 5a                	jne    c0102d34 <default_free_pages+0x1bd>
            base->property += p->property;
c0102cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cdd:	8b 50 08             	mov    0x8(%eax),%edx
c0102ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ce3:	8b 40 08             	mov    0x8(%eax),%eax
c0102ce6:	01 c2                	add    %eax,%edx
c0102ce8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ceb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cf1:	83 c0 04             	add    $0x4,%eax
c0102cf4:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102cfb:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102cfe:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102d01:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102d04:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d0a:	83 c0 0c             	add    $0xc,%eax
c0102d0d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d10:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d13:	8b 40 04             	mov    0x4(%eax),%eax
c0102d16:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d19:	8b 12                	mov    (%edx),%edx
c0102d1b:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102d1e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102d21:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d24:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d27:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102d2a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102d2d:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102d30:	89 10                	mov    %edx,(%eax)
c0102d32:	eb 7a                	jmp    c0102dae <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d37:	8b 50 08             	mov    0x8(%eax),%edx
c0102d3a:	89 d0                	mov    %edx,%eax
c0102d3c:	c1 e0 02             	shl    $0x2,%eax
c0102d3f:	01 d0                	add    %edx,%eax
c0102d41:	c1 e0 02             	shl    $0x2,%eax
c0102d44:	89 c2                	mov    %eax,%edx
c0102d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d49:	01 d0                	add    %edx,%eax
c0102d4b:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102d4e:	75 5e                	jne    c0102dae <default_free_pages+0x237>
            p->property += base->property;
c0102d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d53:	8b 50 08             	mov    0x8(%eax),%edx
c0102d56:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d59:	8b 40 08             	mov    0x8(%eax),%eax
c0102d5c:	01 c2                	add    %eax,%edx
c0102d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d61:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102d64:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d67:	83 c0 04             	add    $0x4,%eax
c0102d6a:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102d71:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102d74:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102d77:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102d7a:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d80:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d86:	83 c0 0c             	add    $0xc,%eax
c0102d89:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d8c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102d8f:	8b 40 04             	mov    0x4(%eax),%eax
c0102d92:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102d95:	8b 12                	mov    (%edx),%edx
c0102d97:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102d9a:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102d9d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102da0:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102da3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102da6:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102da9:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102dac:	89 10                	mov    %edx,(%eax)
    }
    base->property = n;//设置连续大小为n
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    // 合并到合适的页块中
    while (le != &free_list) {
c0102dae:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102db5:	0f 85 eb fe ff ff    	jne    c0102ca6 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0102dbb:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102dc4:	01 d0                	add    %edx,%eax
c0102dc6:	a3 18 af 11 c0       	mov    %eax,0xc011af18
c0102dcb:	c7 45 9c 10 af 11 c0 	movl   $0xc011af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102dd2:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102dd5:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0102dd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
c0102ddb:	eb 36                	jmp    c0102e13 <default_free_pages+0x29c>
        p = le2page(le, page_link);
c0102ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102de0:	83 e8 0c             	sub    $0xc,%eax
c0102de3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0102de6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102de9:	8b 50 08             	mov    0x8(%eax),%edx
c0102dec:	89 d0                	mov    %edx,%eax
c0102dee:	c1 e0 02             	shl    $0x2,%eax
c0102df1:	01 d0                	add    %edx,%eax
c0102df3:	c1 e0 02             	shl    $0x2,%eax
c0102df6:	89 c2                	mov    %eax,%edx
c0102df8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dfb:	01 d0                	add    %edx,%eax
c0102dfd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e00:	77 02                	ja     c0102e04 <default_free_pages+0x28d>
            break;
c0102e02:	eb 18                	jmp    c0102e1c <default_free_pages+0x2a5>
c0102e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e07:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102e0a:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e0d:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0102e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
c0102e13:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102e1a:	75 c1                	jne    c0102ddd <default_free_pages+0x266>
        if (base + base->property <= p) {
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));//将空闲块插入空闲链表中
c0102e1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e1f:	8d 50 0c             	lea    0xc(%eax),%edx
c0102e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e25:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102e28:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102e2b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102e2e:	8b 00                	mov    (%eax),%eax
c0102e30:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e33:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0102e36:	89 45 88             	mov    %eax,-0x78(%ebp)
c0102e39:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102e3c:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102e3f:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102e42:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102e45:	89 10                	mov    %edx,(%eax)
c0102e47:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102e4a:	8b 10                	mov    (%eax),%edx
c0102e4c:	8b 45 88             	mov    -0x78(%ebp),%eax
c0102e4f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102e52:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e55:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102e58:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102e5b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e5e:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102e61:	89 10                	mov    %edx,(%eax)
}
c0102e63:	c9                   	leave  
c0102e64:	c3                   	ret    

c0102e65 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102e65:	55                   	push   %ebp
c0102e66:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102e68:	a1 18 af 11 c0       	mov    0xc011af18,%eax
}
c0102e6d:	5d                   	pop    %ebp
c0102e6e:	c3                   	ret    

c0102e6f <basic_check>:

static void
basic_check(void) {
c0102e6f:	55                   	push   %ebp
c0102e70:	89 e5                	mov    %esp,%ebp
c0102e72:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102e75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e85:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102e88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e8f:	e8 db 0e 00 00       	call   c0103d6f <alloc_pages>
c0102e94:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102e97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102e9b:	75 24                	jne    c0102ec1 <basic_check+0x52>
c0102e9d:	c7 44 24 0c f9 66 10 	movl   $0xc01066f9,0xc(%esp)
c0102ea4:	c0 
c0102ea5:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102eac:	c0 
c0102ead:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0102eb4:	00 
c0102eb5:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102ebc:	e8 11 de ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102ec1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102ec8:	e8 a2 0e 00 00       	call   c0103d6f <alloc_pages>
c0102ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102ed0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102ed4:	75 24                	jne    c0102efa <basic_check+0x8b>
c0102ed6:	c7 44 24 0c 15 67 10 	movl   $0xc0106715,0xc(%esp)
c0102edd:	c0 
c0102ede:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102ee5:	c0 
c0102ee6:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0102eed:	00 
c0102eee:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102ef5:	e8 d8 dd ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102efa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f01:	e8 69 0e 00 00       	call   c0103d6f <alloc_pages>
c0102f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f0d:	75 24                	jne    c0102f33 <basic_check+0xc4>
c0102f0f:	c7 44 24 0c 31 67 10 	movl   $0xc0106731,0xc(%esp)
c0102f16:	c0 
c0102f17:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102f1e:	c0 
c0102f1f:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102f26:	00 
c0102f27:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102f2e:	e8 9f dd ff ff       	call   c0100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102f33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f36:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102f39:	74 10                	je     c0102f4b <basic_check+0xdc>
c0102f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102f41:	74 08                	je     c0102f4b <basic_check+0xdc>
c0102f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102f49:	75 24                	jne    c0102f6f <basic_check+0x100>
c0102f4b:	c7 44 24 0c 50 67 10 	movl   $0xc0106750,0xc(%esp)
c0102f52:	c0 
c0102f53:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102f5a:	c0 
c0102f5b:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0102f62:	00 
c0102f63:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102f6a:	e8 63 dd ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f72:	89 04 24             	mov    %eax,(%esp)
c0102f75:	e8 dc f8 ff ff       	call   c0102856 <page_ref>
c0102f7a:	85 c0                	test   %eax,%eax
c0102f7c:	75 1e                	jne    c0102f9c <basic_check+0x12d>
c0102f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f81:	89 04 24             	mov    %eax,(%esp)
c0102f84:	e8 cd f8 ff ff       	call   c0102856 <page_ref>
c0102f89:	85 c0                	test   %eax,%eax
c0102f8b:	75 0f                	jne    c0102f9c <basic_check+0x12d>
c0102f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f90:	89 04 24             	mov    %eax,(%esp)
c0102f93:	e8 be f8 ff ff       	call   c0102856 <page_ref>
c0102f98:	85 c0                	test   %eax,%eax
c0102f9a:	74 24                	je     c0102fc0 <basic_check+0x151>
c0102f9c:	c7 44 24 0c 74 67 10 	movl   $0xc0106774,0xc(%esp)
c0102fa3:	c0 
c0102fa4:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102fab:	c0 
c0102fac:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0102fb3:	00 
c0102fb4:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102fbb:	e8 12 dd ff ff       	call   c0100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0102fc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fc3:	89 04 24             	mov    %eax,(%esp)
c0102fc6:	e8 75 f8 ff ff       	call   c0102840 <page2pa>
c0102fcb:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102fd1:	c1 e2 0c             	shl    $0xc,%edx
c0102fd4:	39 d0                	cmp    %edx,%eax
c0102fd6:	72 24                	jb     c0102ffc <basic_check+0x18d>
c0102fd8:	c7 44 24 0c b0 67 10 	movl   $0xc01067b0,0xc(%esp)
c0102fdf:	c0 
c0102fe0:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0102fe7:	c0 
c0102fe8:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0102fef:	00 
c0102ff0:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0102ff7:	e8 d6 dc ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0102ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fff:	89 04 24             	mov    %eax,(%esp)
c0103002:	e8 39 f8 ff ff       	call   c0102840 <page2pa>
c0103007:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010300d:	c1 e2 0c             	shl    $0xc,%edx
c0103010:	39 d0                	cmp    %edx,%eax
c0103012:	72 24                	jb     c0103038 <basic_check+0x1c9>
c0103014:	c7 44 24 0c cd 67 10 	movl   $0xc01067cd,0xc(%esp)
c010301b:	c0 
c010301c:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103023:	c0 
c0103024:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c010302b:	00 
c010302c:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103033:	e8 9a dc ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103038:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010303b:	89 04 24             	mov    %eax,(%esp)
c010303e:	e8 fd f7 ff ff       	call   c0102840 <page2pa>
c0103043:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103049:	c1 e2 0c             	shl    $0xc,%edx
c010304c:	39 d0                	cmp    %edx,%eax
c010304e:	72 24                	jb     c0103074 <basic_check+0x205>
c0103050:	c7 44 24 0c ea 67 10 	movl   $0xc01067ea,0xc(%esp)
c0103057:	c0 
c0103058:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010305f:	c0 
c0103060:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103067:	00 
c0103068:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010306f:	e8 5e dc ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c0103074:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0103079:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c010307f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103082:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103085:	c7 45 e0 10 af 11 c0 	movl   $0xc011af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010308c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010308f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103092:	89 50 04             	mov    %edx,0x4(%eax)
c0103095:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103098:	8b 50 04             	mov    0x4(%eax),%edx
c010309b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010309e:	89 10                	mov    %edx,(%eax)
c01030a0:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01030a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01030aa:	8b 40 04             	mov    0x4(%eax),%eax
c01030ad:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01030b0:	0f 94 c0             	sete   %al
c01030b3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01030b6:	85 c0                	test   %eax,%eax
c01030b8:	75 24                	jne    c01030de <basic_check+0x26f>
c01030ba:	c7 44 24 0c 07 68 10 	movl   $0xc0106807,0xc(%esp)
c01030c1:	c0 
c01030c2:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01030c9:	c0 
c01030ca:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01030d1:	00 
c01030d2:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01030d9:	e8 f4 db ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c01030de:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01030e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01030e6:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01030ed:	00 00 00 

    assert(alloc_page() == NULL);
c01030f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030f7:	e8 73 0c 00 00       	call   c0103d6f <alloc_pages>
c01030fc:	85 c0                	test   %eax,%eax
c01030fe:	74 24                	je     c0103124 <basic_check+0x2b5>
c0103100:	c7 44 24 0c 1e 68 10 	movl   $0xc010681e,0xc(%esp)
c0103107:	c0 
c0103108:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010310f:	c0 
c0103110:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103117:	00 
c0103118:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010311f:	e8 ae db ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c0103124:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010312b:	00 
c010312c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010312f:	89 04 24             	mov    %eax,(%esp)
c0103132:	e8 70 0c 00 00       	call   c0103da7 <free_pages>
    free_page(p1);
c0103137:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010313e:	00 
c010313f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103142:	89 04 24             	mov    %eax,(%esp)
c0103145:	e8 5d 0c 00 00       	call   c0103da7 <free_pages>
    free_page(p2);
c010314a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103151:	00 
c0103152:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103155:	89 04 24             	mov    %eax,(%esp)
c0103158:	e8 4a 0c 00 00       	call   c0103da7 <free_pages>
    assert(nr_free == 3);
c010315d:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103162:	83 f8 03             	cmp    $0x3,%eax
c0103165:	74 24                	je     c010318b <basic_check+0x31c>
c0103167:	c7 44 24 0c 33 68 10 	movl   $0xc0106833,0xc(%esp)
c010316e:	c0 
c010316f:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103176:	c0 
c0103177:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c010317e:	00 
c010317f:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103186:	e8 47 db ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010318b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103192:	e8 d8 0b 00 00       	call   c0103d6f <alloc_pages>
c0103197:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010319a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010319e:	75 24                	jne    c01031c4 <basic_check+0x355>
c01031a0:	c7 44 24 0c f9 66 10 	movl   $0xc01066f9,0xc(%esp)
c01031a7:	c0 
c01031a8:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01031af:	c0 
c01031b0:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01031b7:	00 
c01031b8:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01031bf:	e8 0e db ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01031c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031cb:	e8 9f 0b 00 00       	call   c0103d6f <alloc_pages>
c01031d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01031d7:	75 24                	jne    c01031fd <basic_check+0x38e>
c01031d9:	c7 44 24 0c 15 67 10 	movl   $0xc0106715,0xc(%esp)
c01031e0:	c0 
c01031e1:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01031e8:	c0 
c01031e9:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01031f0:	00 
c01031f1:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01031f8:	e8 d5 da ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01031fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103204:	e8 66 0b 00 00       	call   c0103d6f <alloc_pages>
c0103209:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010320c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103210:	75 24                	jne    c0103236 <basic_check+0x3c7>
c0103212:	c7 44 24 0c 31 67 10 	movl   $0xc0106731,0xc(%esp)
c0103219:	c0 
c010321a:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103221:	c0 
c0103222:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0103229:	00 
c010322a:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103231:	e8 9c da ff ff       	call   c0100cd2 <__panic>

    assert(alloc_page() == NULL);
c0103236:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010323d:	e8 2d 0b 00 00       	call   c0103d6f <alloc_pages>
c0103242:	85 c0                	test   %eax,%eax
c0103244:	74 24                	je     c010326a <basic_check+0x3fb>
c0103246:	c7 44 24 0c 1e 68 10 	movl   $0xc010681e,0xc(%esp)
c010324d:	c0 
c010324e:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103255:	c0 
c0103256:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c010325d:	00 
c010325e:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103265:	e8 68 da ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c010326a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103271:	00 
c0103272:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103275:	89 04 24             	mov    %eax,(%esp)
c0103278:	e8 2a 0b 00 00       	call   c0103da7 <free_pages>
c010327d:	c7 45 d8 10 af 11 c0 	movl   $0xc011af10,-0x28(%ebp)
c0103284:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103287:	8b 40 04             	mov    0x4(%eax),%eax
c010328a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010328d:	0f 94 c0             	sete   %al
c0103290:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103293:	85 c0                	test   %eax,%eax
c0103295:	74 24                	je     c01032bb <basic_check+0x44c>
c0103297:	c7 44 24 0c 40 68 10 	movl   $0xc0106840,0xc(%esp)
c010329e:	c0 
c010329f:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01032a6:	c0 
c01032a7:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01032ae:	00 
c01032af:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01032b6:	e8 17 da ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01032bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032c2:	e8 a8 0a 00 00       	call   c0103d6f <alloc_pages>
c01032c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01032ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01032cd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01032d0:	74 24                	je     c01032f6 <basic_check+0x487>
c01032d2:	c7 44 24 0c 58 68 10 	movl   $0xc0106858,0xc(%esp)
c01032d9:	c0 
c01032da:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01032e1:	c0 
c01032e2:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c01032e9:	00 
c01032ea:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01032f1:	e8 dc d9 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01032f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032fd:	e8 6d 0a 00 00       	call   c0103d6f <alloc_pages>
c0103302:	85 c0                	test   %eax,%eax
c0103304:	74 24                	je     c010332a <basic_check+0x4bb>
c0103306:	c7 44 24 0c 1e 68 10 	movl   $0xc010681e,0xc(%esp)
c010330d:	c0 
c010330e:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103315:	c0 
c0103316:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c010331d:	00 
c010331e:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103325:	e8 a8 d9 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c010332a:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c010332f:	85 c0                	test   %eax,%eax
c0103331:	74 24                	je     c0103357 <basic_check+0x4e8>
c0103333:	c7 44 24 0c 71 68 10 	movl   $0xc0106871,0xc(%esp)
c010333a:	c0 
c010333b:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103342:	c0 
c0103343:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c010334a:	00 
c010334b:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103352:	e8 7b d9 ff ff       	call   c0100cd2 <__panic>
    free_list = free_list_store;
c0103357:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010335a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010335d:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c0103362:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    nr_free = nr_free_store;
c0103368:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010336b:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_page(p);
c0103370:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103377:	00 
c0103378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010337b:	89 04 24             	mov    %eax,(%esp)
c010337e:	e8 24 0a 00 00       	call   c0103da7 <free_pages>
    free_page(p1);
c0103383:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010338a:	00 
c010338b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010338e:	89 04 24             	mov    %eax,(%esp)
c0103391:	e8 11 0a 00 00       	call   c0103da7 <free_pages>
    free_page(p2);
c0103396:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010339d:	00 
c010339e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a1:	89 04 24             	mov    %eax,(%esp)
c01033a4:	e8 fe 09 00 00       	call   c0103da7 <free_pages>
}
c01033a9:	c9                   	leave  
c01033aa:	c3                   	ret    

c01033ab <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01033ab:	55                   	push   %ebp
c01033ac:	89 e5                	mov    %esp,%ebp
c01033ae:	53                   	push   %ebx
c01033af:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c01033b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01033bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01033c3:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01033ca:	eb 6b                	jmp    c0103437 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c01033cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033cf:	83 e8 0c             	sub    $0xc,%eax
c01033d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c01033d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033d8:	83 c0 04             	add    $0x4,%eax
c01033db:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01033e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01033e8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01033eb:	0f a3 10             	bt     %edx,(%eax)
c01033ee:	19 c0                	sbb    %eax,%eax
c01033f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01033f3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01033f7:	0f 95 c0             	setne  %al
c01033fa:	0f b6 c0             	movzbl %al,%eax
c01033fd:	85 c0                	test   %eax,%eax
c01033ff:	75 24                	jne    c0103425 <default_check+0x7a>
c0103401:	c7 44 24 0c 7e 68 10 	movl   $0xc010687e,0xc(%esp)
c0103408:	c0 
c0103409:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103410:	c0 
c0103411:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0103418:	00 
c0103419:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103420:	e8 ad d8 ff ff       	call   c0100cd2 <__panic>
        count ++, total += p->property;
c0103425:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103429:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010342c:	8b 50 08             	mov    0x8(%eax),%edx
c010342f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103432:	01 d0                	add    %edx,%eax
c0103434:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103437:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010343a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010343d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103440:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103443:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103446:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c010344d:	0f 85 79 ff ff ff    	jne    c01033cc <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103453:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103456:	e8 7e 09 00 00       	call   c0103dd9 <nr_free_pages>
c010345b:	39 c3                	cmp    %eax,%ebx
c010345d:	74 24                	je     c0103483 <default_check+0xd8>
c010345f:	c7 44 24 0c 8e 68 10 	movl   $0xc010688e,0xc(%esp)
c0103466:	c0 
c0103467:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010346e:	c0 
c010346f:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0103476:	00 
c0103477:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010347e:	e8 4f d8 ff ff       	call   c0100cd2 <__panic>

    basic_check();
c0103483:	e8 e7 f9 ff ff       	call   c0102e6f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103488:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010348f:	e8 db 08 00 00       	call   c0103d6f <alloc_pages>
c0103494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010349b:	75 24                	jne    c01034c1 <default_check+0x116>
c010349d:	c7 44 24 0c a7 68 10 	movl   $0xc01068a7,0xc(%esp)
c01034a4:	c0 
c01034a5:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01034ac:	c0 
c01034ad:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01034b4:	00 
c01034b5:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01034bc:	e8 11 d8 ff ff       	call   c0100cd2 <__panic>
    assert(!PageProperty(p0));
c01034c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034c4:	83 c0 04             	add    $0x4,%eax
c01034c7:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01034ce:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01034d1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01034d4:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01034d7:	0f a3 10             	bt     %edx,(%eax)
c01034da:	19 c0                	sbb    %eax,%eax
c01034dc:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01034df:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01034e3:	0f 95 c0             	setne  %al
c01034e6:	0f b6 c0             	movzbl %al,%eax
c01034e9:	85 c0                	test   %eax,%eax
c01034eb:	74 24                	je     c0103511 <default_check+0x166>
c01034ed:	c7 44 24 0c b2 68 10 	movl   $0xc01068b2,0xc(%esp)
c01034f4:	c0 
c01034f5:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01034fc:	c0 
c01034fd:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103504:	00 
c0103505:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010350c:	e8 c1 d7 ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c0103511:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0103516:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c010351c:	89 45 80             	mov    %eax,-0x80(%ebp)
c010351f:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103522:	c7 45 b4 10 af 11 c0 	movl   $0xc011af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103529:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010352c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010352f:	89 50 04             	mov    %edx,0x4(%eax)
c0103532:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103535:	8b 50 04             	mov    0x4(%eax),%edx
c0103538:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010353b:	89 10                	mov    %edx,(%eax)
c010353d:	c7 45 b0 10 af 11 c0 	movl   $0xc011af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103544:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103547:	8b 40 04             	mov    0x4(%eax),%eax
c010354a:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c010354d:	0f 94 c0             	sete   %al
c0103550:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103553:	85 c0                	test   %eax,%eax
c0103555:	75 24                	jne    c010357b <default_check+0x1d0>
c0103557:	c7 44 24 0c 07 68 10 	movl   $0xc0106807,0xc(%esp)
c010355e:	c0 
c010355f:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103566:	c0 
c0103567:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010356e:	00 
c010356f:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103576:	e8 57 d7 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c010357b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103582:	e8 e8 07 00 00       	call   c0103d6f <alloc_pages>
c0103587:	85 c0                	test   %eax,%eax
c0103589:	74 24                	je     c01035af <default_check+0x204>
c010358b:	c7 44 24 0c 1e 68 10 	movl   $0xc010681e,0xc(%esp)
c0103592:	c0 
c0103593:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010359a:	c0 
c010359b:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01035a2:	00 
c01035a3:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01035aa:	e8 23 d7 ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c01035af:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01035b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01035b7:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01035be:	00 00 00 

    free_pages(p0 + 2, 3);
c01035c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035c4:	83 c0 28             	add    $0x28,%eax
c01035c7:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01035ce:	00 
c01035cf:	89 04 24             	mov    %eax,(%esp)
c01035d2:	e8 d0 07 00 00       	call   c0103da7 <free_pages>
    assert(alloc_pages(4) == NULL);
c01035d7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01035de:	e8 8c 07 00 00       	call   c0103d6f <alloc_pages>
c01035e3:	85 c0                	test   %eax,%eax
c01035e5:	74 24                	je     c010360b <default_check+0x260>
c01035e7:	c7 44 24 0c c4 68 10 	movl   $0xc01068c4,0xc(%esp)
c01035ee:	c0 
c01035ef:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01035f6:	c0 
c01035f7:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01035fe:	00 
c01035ff:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103606:	e8 c7 d6 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010360b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010360e:	83 c0 28             	add    $0x28,%eax
c0103611:	83 c0 04             	add    $0x4,%eax
c0103614:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010361b:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010361e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103621:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103624:	0f a3 10             	bt     %edx,(%eax)
c0103627:	19 c0                	sbb    %eax,%eax
c0103629:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010362c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103630:	0f 95 c0             	setne  %al
c0103633:	0f b6 c0             	movzbl %al,%eax
c0103636:	85 c0                	test   %eax,%eax
c0103638:	74 0e                	je     c0103648 <default_check+0x29d>
c010363a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010363d:	83 c0 28             	add    $0x28,%eax
c0103640:	8b 40 08             	mov    0x8(%eax),%eax
c0103643:	83 f8 03             	cmp    $0x3,%eax
c0103646:	74 24                	je     c010366c <default_check+0x2c1>
c0103648:	c7 44 24 0c dc 68 10 	movl   $0xc01068dc,0xc(%esp)
c010364f:	c0 
c0103650:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103657:	c0 
c0103658:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c010365f:	00 
c0103660:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103667:	e8 66 d6 ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010366c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103673:	e8 f7 06 00 00       	call   c0103d6f <alloc_pages>
c0103678:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010367b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010367f:	75 24                	jne    c01036a5 <default_check+0x2fa>
c0103681:	c7 44 24 0c 08 69 10 	movl   $0xc0106908,0xc(%esp)
c0103688:	c0 
c0103689:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103690:	c0 
c0103691:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0103698:	00 
c0103699:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01036a0:	e8 2d d6 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01036a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036ac:	e8 be 06 00 00       	call   c0103d6f <alloc_pages>
c01036b1:	85 c0                	test   %eax,%eax
c01036b3:	74 24                	je     c01036d9 <default_check+0x32e>
c01036b5:	c7 44 24 0c 1e 68 10 	movl   $0xc010681e,0xc(%esp)
c01036bc:	c0 
c01036bd:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01036c4:	c0 
c01036c5:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01036cc:	00 
c01036cd:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01036d4:	e8 f9 d5 ff ff       	call   c0100cd2 <__panic>
    assert(p0 + 2 == p1);
c01036d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036dc:	83 c0 28             	add    $0x28,%eax
c01036df:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01036e2:	74 24                	je     c0103708 <default_check+0x35d>
c01036e4:	c7 44 24 0c 26 69 10 	movl   $0xc0106926,0xc(%esp)
c01036eb:	c0 
c01036ec:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01036f3:	c0 
c01036f4:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01036fb:	00 
c01036fc:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103703:	e8 ca d5 ff ff       	call   c0100cd2 <__panic>

    p2 = p0 + 1;
c0103708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010370b:	83 c0 14             	add    $0x14,%eax
c010370e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103711:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103718:	00 
c0103719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010371c:	89 04 24             	mov    %eax,(%esp)
c010371f:	e8 83 06 00 00       	call   c0103da7 <free_pages>
    free_pages(p1, 3);
c0103724:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010372b:	00 
c010372c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010372f:	89 04 24             	mov    %eax,(%esp)
c0103732:	e8 70 06 00 00       	call   c0103da7 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0103737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010373a:	83 c0 04             	add    $0x4,%eax
c010373d:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103744:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103747:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010374a:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010374d:	0f a3 10             	bt     %edx,(%eax)
c0103750:	19 c0                	sbb    %eax,%eax
c0103752:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103755:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103759:	0f 95 c0             	setne  %al
c010375c:	0f b6 c0             	movzbl %al,%eax
c010375f:	85 c0                	test   %eax,%eax
c0103761:	74 0b                	je     c010376e <default_check+0x3c3>
c0103763:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103766:	8b 40 08             	mov    0x8(%eax),%eax
c0103769:	83 f8 01             	cmp    $0x1,%eax
c010376c:	74 24                	je     c0103792 <default_check+0x3e7>
c010376e:	c7 44 24 0c 34 69 10 	movl   $0xc0106934,0xc(%esp)
c0103775:	c0 
c0103776:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010377d:	c0 
c010377e:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0103785:	00 
c0103786:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010378d:	e8 40 d5 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0103792:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103795:	83 c0 04             	add    $0x4,%eax
c0103798:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010379f:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037a2:	8b 45 90             	mov    -0x70(%ebp),%eax
c01037a5:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01037a8:	0f a3 10             	bt     %edx,(%eax)
c01037ab:	19 c0                	sbb    %eax,%eax
c01037ad:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01037b0:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01037b4:	0f 95 c0             	setne  %al
c01037b7:	0f b6 c0             	movzbl %al,%eax
c01037ba:	85 c0                	test   %eax,%eax
c01037bc:	74 0b                	je     c01037c9 <default_check+0x41e>
c01037be:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037c1:	8b 40 08             	mov    0x8(%eax),%eax
c01037c4:	83 f8 03             	cmp    $0x3,%eax
c01037c7:	74 24                	je     c01037ed <default_check+0x442>
c01037c9:	c7 44 24 0c 5c 69 10 	movl   $0xc010695c,0xc(%esp)
c01037d0:	c0 
c01037d1:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01037d8:	c0 
c01037d9:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c01037e0:	00 
c01037e1:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01037e8:	e8 e5 d4 ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01037ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037f4:	e8 76 05 00 00       	call   c0103d6f <alloc_pages>
c01037f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01037fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037ff:	83 e8 14             	sub    $0x14,%eax
c0103802:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103805:	74 24                	je     c010382b <default_check+0x480>
c0103807:	c7 44 24 0c 82 69 10 	movl   $0xc0106982,0xc(%esp)
c010380e:	c0 
c010380f:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103816:	c0 
c0103817:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c010381e:	00 
c010381f:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103826:	e8 a7 d4 ff ff       	call   c0100cd2 <__panic>
    free_page(p0);
c010382b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103832:	00 
c0103833:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103836:	89 04 24             	mov    %eax,(%esp)
c0103839:	e8 69 05 00 00       	call   c0103da7 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010383e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103845:	e8 25 05 00 00       	call   c0103d6f <alloc_pages>
c010384a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010384d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103850:	83 c0 14             	add    $0x14,%eax
c0103853:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103856:	74 24                	je     c010387c <default_check+0x4d1>
c0103858:	c7 44 24 0c a0 69 10 	movl   $0xc01069a0,0xc(%esp)
c010385f:	c0 
c0103860:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103867:	c0 
c0103868:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c010386f:	00 
c0103870:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103877:	e8 56 d4 ff ff       	call   c0100cd2 <__panic>

    free_pages(p0, 2);
c010387c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103883:	00 
c0103884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103887:	89 04 24             	mov    %eax,(%esp)
c010388a:	e8 18 05 00 00       	call   c0103da7 <free_pages>
    free_page(p2);
c010388f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103896:	00 
c0103897:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010389a:	89 04 24             	mov    %eax,(%esp)
c010389d:	e8 05 05 00 00       	call   c0103da7 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01038a2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01038a9:	e8 c1 04 00 00       	call   c0103d6f <alloc_pages>
c01038ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01038b5:	75 24                	jne    c01038db <default_check+0x530>
c01038b7:	c7 44 24 0c c0 69 10 	movl   $0xc01069c0,0xc(%esp)
c01038be:	c0 
c01038bf:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01038c6:	c0 
c01038c7:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c01038ce:	00 
c01038cf:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01038d6:	e8 f7 d3 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01038db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038e2:	e8 88 04 00 00       	call   c0103d6f <alloc_pages>
c01038e7:	85 c0                	test   %eax,%eax
c01038e9:	74 24                	je     c010390f <default_check+0x564>
c01038eb:	c7 44 24 0c 1e 68 10 	movl   $0xc010681e,0xc(%esp)
c01038f2:	c0 
c01038f3:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01038fa:	c0 
c01038fb:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103902:	00 
c0103903:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c010390a:	e8 c3 d3 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c010390f:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103914:	85 c0                	test   %eax,%eax
c0103916:	74 24                	je     c010393c <default_check+0x591>
c0103918:	c7 44 24 0c 71 68 10 	movl   $0xc0106871,0xc(%esp)
c010391f:	c0 
c0103920:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103927:	c0 
c0103928:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c010392f:	00 
c0103930:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103937:	e8 96 d3 ff ff       	call   c0100cd2 <__panic>
    nr_free = nr_free_store;
c010393c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010393f:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_list = free_list_store;
c0103944:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103947:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010394a:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c010394f:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    free_pages(p0, 5);
c0103955:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010395c:	00 
c010395d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103960:	89 04 24             	mov    %eax,(%esp)
c0103963:	e8 3f 04 00 00       	call   c0103da7 <free_pages>

    le = &free_list;
c0103968:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010396f:	eb 5b                	jmp    c01039cc <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
c0103971:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103974:	8b 40 04             	mov    0x4(%eax),%eax
c0103977:	8b 00                	mov    (%eax),%eax
c0103979:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010397c:	75 0d                	jne    c010398b <default_check+0x5e0>
c010397e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103981:	8b 00                	mov    (%eax),%eax
c0103983:	8b 40 04             	mov    0x4(%eax),%eax
c0103986:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103989:	74 24                	je     c01039af <default_check+0x604>
c010398b:	c7 44 24 0c e0 69 10 	movl   $0xc01069e0,0xc(%esp)
c0103992:	c0 
c0103993:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c010399a:	c0 
c010399b:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01039a2:	00 
c01039a3:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c01039aa:	e8 23 d3 ff ff       	call   c0100cd2 <__panic>
        struct Page *p = le2page(le, page_link);
c01039af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039b2:	83 e8 0c             	sub    $0xc,%eax
c01039b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01039b8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01039bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01039bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01039c2:	8b 40 08             	mov    0x8(%eax),%eax
c01039c5:	29 c2                	sub    %eax,%edx
c01039c7:	89 d0                	mov    %edx,%eax
c01039c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039cf:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01039d2:	8b 45 88             	mov    -0x78(%ebp),%eax
c01039d5:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01039d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039db:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c01039e2:	75 8d                	jne    c0103971 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01039e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039e8:	74 24                	je     c0103a0e <default_check+0x663>
c01039ea:	c7 44 24 0c 0d 6a 10 	movl   $0xc0106a0d,0xc(%esp)
c01039f1:	c0 
c01039f2:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c01039f9:	c0 
c01039fa:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0103a01:	00 
c0103a02:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103a09:	e8 c4 d2 ff ff       	call   c0100cd2 <__panic>
    assert(total == 0);
c0103a0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a12:	74 24                	je     c0103a38 <default_check+0x68d>
c0103a14:	c7 44 24 0c 18 6a 10 	movl   $0xc0106a18,0xc(%esp)
c0103a1b:	c0 
c0103a1c:	c7 44 24 08 96 66 10 	movl   $0xc0106696,0x8(%esp)
c0103a23:	c0 
c0103a24:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0103a2b:	00 
c0103a2c:	c7 04 24 ab 66 10 c0 	movl   $0xc01066ab,(%esp)
c0103a33:	e8 9a d2 ff ff       	call   c0100cd2 <__panic>
}
c0103a38:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103a3e:	5b                   	pop    %ebx
c0103a3f:	5d                   	pop    %ebp
c0103a40:	c3                   	ret    

c0103a41 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103a41:	55                   	push   %ebp
c0103a42:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103a44:	8b 55 08             	mov    0x8(%ebp),%edx
c0103a47:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103a4c:	29 c2                	sub    %eax,%edx
c0103a4e:	89 d0                	mov    %edx,%eax
c0103a50:	c1 f8 02             	sar    $0x2,%eax
c0103a53:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103a59:	5d                   	pop    %ebp
c0103a5a:	c3                   	ret    

c0103a5b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103a5b:	55                   	push   %ebp
c0103a5c:	89 e5                	mov    %esp,%ebp
c0103a5e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a64:	89 04 24             	mov    %eax,(%esp)
c0103a67:	e8 d5 ff ff ff       	call   c0103a41 <page2ppn>
c0103a6c:	c1 e0 0c             	shl    $0xc,%eax
}
c0103a6f:	c9                   	leave  
c0103a70:	c3                   	ret    

c0103a71 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103a71:	55                   	push   %ebp
c0103a72:	89 e5                	mov    %esp,%ebp
c0103a74:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103a77:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a7a:	c1 e8 0c             	shr    $0xc,%eax
c0103a7d:	89 c2                	mov    %eax,%edx
c0103a7f:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103a84:	39 c2                	cmp    %eax,%edx
c0103a86:	72 1c                	jb     c0103aa4 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103a88:	c7 44 24 08 54 6a 10 	movl   $0xc0106a54,0x8(%esp)
c0103a8f:	c0 
c0103a90:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103a97:	00 
c0103a98:	c7 04 24 73 6a 10 c0 	movl   $0xc0106a73,(%esp)
c0103a9f:	e8 2e d2 ff ff       	call   c0100cd2 <__panic>
    }
    return &pages[PPN(pa)];
c0103aa4:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aad:	c1 e8 0c             	shr    $0xc,%eax
c0103ab0:	89 c2                	mov    %eax,%edx
c0103ab2:	89 d0                	mov    %edx,%eax
c0103ab4:	c1 e0 02             	shl    $0x2,%eax
c0103ab7:	01 d0                	add    %edx,%eax
c0103ab9:	c1 e0 02             	shl    $0x2,%eax
c0103abc:	01 c8                	add    %ecx,%eax
}
c0103abe:	c9                   	leave  
c0103abf:	c3                   	ret    

c0103ac0 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103ac0:	55                   	push   %ebp
c0103ac1:	89 e5                	mov    %esp,%ebp
c0103ac3:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103ac6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac9:	89 04 24             	mov    %eax,(%esp)
c0103acc:	e8 8a ff ff ff       	call   c0103a5b <page2pa>
c0103ad1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad7:	c1 e8 0c             	shr    $0xc,%eax
c0103ada:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103add:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103ae2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103ae5:	72 23                	jb     c0103b0a <page2kva+0x4a>
c0103ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103aee:	c7 44 24 08 84 6a 10 	movl   $0xc0106a84,0x8(%esp)
c0103af5:	c0 
c0103af6:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103afd:	00 
c0103afe:	c7 04 24 73 6a 10 c0 	movl   $0xc0106a73,(%esp)
c0103b05:	e8 c8 d1 ff ff       	call   c0100cd2 <__panic>
c0103b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b0d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103b12:	c9                   	leave  
c0103b13:	c3                   	ret    

c0103b14 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103b14:	55                   	push   %ebp
c0103b15:	89 e5                	mov    %esp,%ebp
c0103b17:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b1d:	83 e0 01             	and    $0x1,%eax
c0103b20:	85 c0                	test   %eax,%eax
c0103b22:	75 1c                	jne    c0103b40 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103b24:	c7 44 24 08 a8 6a 10 	movl   $0xc0106aa8,0x8(%esp)
c0103b2b:	c0 
c0103b2c:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103b33:	00 
c0103b34:	c7 04 24 73 6a 10 c0 	movl   $0xc0106a73,(%esp)
c0103b3b:	e8 92 d1 ff ff       	call   c0100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b48:	89 04 24             	mov    %eax,(%esp)
c0103b4b:	e8 21 ff ff ff       	call   c0103a71 <pa2page>
}
c0103b50:	c9                   	leave  
c0103b51:	c3                   	ret    

c0103b52 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103b52:	55                   	push   %ebp
c0103b53:	89 e5                	mov    %esp,%ebp
c0103b55:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b60:	89 04 24             	mov    %eax,(%esp)
c0103b63:	e8 09 ff ff ff       	call   c0103a71 <pa2page>
}
c0103b68:	c9                   	leave  
c0103b69:	c3                   	ret    

c0103b6a <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103b6a:	55                   	push   %ebp
c0103b6b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b70:	8b 00                	mov    (%eax),%eax
}
c0103b72:	5d                   	pop    %ebp
c0103b73:	c3                   	ret    

c0103b74 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103b74:	55                   	push   %ebp
c0103b75:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103b7d:	89 10                	mov    %edx,(%eax)
}
c0103b7f:	5d                   	pop    %ebp
c0103b80:	c3                   	ret    

c0103b81 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103b81:	55                   	push   %ebp
c0103b82:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103b84:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b87:	8b 00                	mov    (%eax),%eax
c0103b89:	8d 50 01             	lea    0x1(%eax),%edx
c0103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b8f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b94:	8b 00                	mov    (%eax),%eax
}
c0103b96:	5d                   	pop    %ebp
c0103b97:	c3                   	ret    

c0103b98 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103b98:	55                   	push   %ebp
c0103b99:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b9e:	8b 00                	mov    (%eax),%eax
c0103ba0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba6:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bab:	8b 00                	mov    (%eax),%eax
}
c0103bad:	5d                   	pop    %ebp
c0103bae:	c3                   	ret    

c0103baf <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103baf:	55                   	push   %ebp
c0103bb0:	89 e5                	mov    %esp,%ebp
c0103bb2:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103bb5:	9c                   	pushf  
c0103bb6:	58                   	pop    %eax
c0103bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103bbd:	25 00 02 00 00       	and    $0x200,%eax
c0103bc2:	85 c0                	test   %eax,%eax
c0103bc4:	74 0c                	je     c0103bd2 <__intr_save+0x23>
        intr_disable();
c0103bc6:	e8 fb da ff ff       	call   c01016c6 <intr_disable>
        return 1;
c0103bcb:	b8 01 00 00 00       	mov    $0x1,%eax
c0103bd0:	eb 05                	jmp    c0103bd7 <__intr_save+0x28>
    }
    return 0;
c0103bd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103bd7:	c9                   	leave  
c0103bd8:	c3                   	ret    

c0103bd9 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103bd9:	55                   	push   %ebp
c0103bda:	89 e5                	mov    %esp,%ebp
c0103bdc:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103bdf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103be3:	74 05                	je     c0103bea <__intr_restore+0x11>
        intr_enable();
c0103be5:	e8 d6 da ff ff       	call   c01016c0 <intr_enable>
    }
}
c0103bea:	c9                   	leave  
c0103beb:	c3                   	ret    

c0103bec <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103bec:	55                   	push   %ebp
c0103bed:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103bef:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103bf5:	b8 23 00 00 00       	mov    $0x23,%eax
c0103bfa:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103bfc:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c01:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103c03:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c08:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103c0a:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c0f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103c11:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c16:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103c18:	ea 1f 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103c1f
}
c0103c1f:	5d                   	pop    %ebp
c0103c20:	c3                   	ret    

c0103c21 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103c21:	55                   	push   %ebp
c0103c22:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c27:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103c2c:	5d                   	pop    %ebp
c0103c2d:	c3                   	ret    

c0103c2e <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103c2e:	55                   	push   %ebp
c0103c2f:	89 e5                	mov    %esp,%ebp
c0103c31:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103c34:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103c39:	89 04 24             	mov    %eax,(%esp)
c0103c3c:	e8 e0 ff ff ff       	call   c0103c21 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103c41:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103c48:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103c4a:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103c51:	68 00 
c0103c53:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c58:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103c5e:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c63:	c1 e8 10             	shr    $0x10,%eax
c0103c66:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103c6b:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c72:	83 e0 f0             	and    $0xfffffff0,%eax
c0103c75:	83 c8 09             	or     $0x9,%eax
c0103c78:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c7d:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c84:	83 e0 ef             	and    $0xffffffef,%eax
c0103c87:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c8c:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c93:	83 e0 9f             	and    $0xffffff9f,%eax
c0103c96:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c9b:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103ca2:	83 c8 80             	or     $0xffffff80,%eax
c0103ca5:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103caa:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cb1:	83 e0 f0             	and    $0xfffffff0,%eax
c0103cb4:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cb9:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cc0:	83 e0 ef             	and    $0xffffffef,%eax
c0103cc3:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cc8:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103ccf:	83 e0 df             	and    $0xffffffdf,%eax
c0103cd2:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cd7:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cde:	83 c8 40             	or     $0x40,%eax
c0103ce1:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103ce6:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103ced:	83 e0 7f             	and    $0x7f,%eax
c0103cf0:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cf5:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103cfa:	c1 e8 18             	shr    $0x18,%eax
c0103cfd:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103d02:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103d09:	e8 de fe ff ff       	call   c0103bec <lgdt>
c0103d0e:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103d14:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103d18:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103d1b:	c9                   	leave  
c0103d1c:	c3                   	ret    

c0103d1d <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103d1d:	55                   	push   %ebp
c0103d1e:	89 e5                	mov    %esp,%ebp
c0103d20:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103d23:	c7 05 1c af 11 c0 38 	movl   $0xc0106a38,0xc011af1c
c0103d2a:	6a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103d2d:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d32:	8b 00                	mov    (%eax),%eax
c0103d34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d38:	c7 04 24 d4 6a 10 c0 	movl   $0xc0106ad4,(%esp)
c0103d3f:	e8 04 c6 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0103d44:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d49:	8b 40 04             	mov    0x4(%eax),%eax
c0103d4c:	ff d0                	call   *%eax
}
c0103d4e:	c9                   	leave  
c0103d4f:	c3                   	ret    

c0103d50 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103d50:	55                   	push   %ebp
c0103d51:	89 e5                	mov    %esp,%ebp
c0103d53:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103d56:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d5b:	8b 40 08             	mov    0x8(%eax),%eax
c0103d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103d61:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d65:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d68:	89 14 24             	mov    %edx,(%esp)
c0103d6b:	ff d0                	call   *%eax
}
c0103d6d:	c9                   	leave  
c0103d6e:	c3                   	ret    

c0103d6f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103d6f:	55                   	push   %ebp
c0103d70:	89 e5                	mov    %esp,%ebp
c0103d72:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103d7c:	e8 2e fe ff ff       	call   c0103baf <__intr_save>
c0103d81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103d84:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d89:	8b 40 0c             	mov    0xc(%eax),%eax
c0103d8c:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d8f:	89 14 24             	mov    %edx,(%esp)
c0103d92:	ff d0                	call   *%eax
c0103d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d9a:	89 04 24             	mov    %eax,(%esp)
c0103d9d:	e8 37 fe ff ff       	call   c0103bd9 <__intr_restore>
    return page;
c0103da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103da5:	c9                   	leave  
c0103da6:	c3                   	ret    

c0103da7 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103da7:	55                   	push   %ebp
c0103da8:	89 e5                	mov    %esp,%ebp
c0103daa:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103dad:	e8 fd fd ff ff       	call   c0103baf <__intr_save>
c0103db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103db5:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103dba:	8b 40 10             	mov    0x10(%eax),%eax
c0103dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103dc0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dc4:	8b 55 08             	mov    0x8(%ebp),%edx
c0103dc7:	89 14 24             	mov    %edx,(%esp)
c0103dca:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dcf:	89 04 24             	mov    %eax,(%esp)
c0103dd2:	e8 02 fe ff ff       	call   c0103bd9 <__intr_restore>
}
c0103dd7:	c9                   	leave  
c0103dd8:	c3                   	ret    

c0103dd9 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103dd9:	55                   	push   %ebp
c0103dda:	89 e5                	mov    %esp,%ebp
c0103ddc:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103ddf:	e8 cb fd ff ff       	call   c0103baf <__intr_save>
c0103de4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103de7:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103dec:	8b 40 14             	mov    0x14(%eax),%eax
c0103def:	ff d0                	call   *%eax
c0103df1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103df7:	89 04 24             	mov    %eax,(%esp)
c0103dfa:	e8 da fd ff ff       	call   c0103bd9 <__intr_restore>
    return ret;
c0103dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103e02:	c9                   	leave  
c0103e03:	c3                   	ret    

c0103e04 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103e04:	55                   	push   %ebp
c0103e05:	89 e5                	mov    %esp,%ebp
c0103e07:	57                   	push   %edi
c0103e08:	56                   	push   %esi
c0103e09:	53                   	push   %ebx
c0103e0a:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103e10:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103e17:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103e1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103e25:	c7 04 24 eb 6a 10 c0 	movl   $0xc0106aeb,(%esp)
c0103e2c:	e8 17 c5 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e31:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103e38:	e9 15 01 00 00       	jmp    c0103f52 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103e3d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e40:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e43:	89 d0                	mov    %edx,%eax
c0103e45:	c1 e0 02             	shl    $0x2,%eax
c0103e48:	01 d0                	add    %edx,%eax
c0103e4a:	c1 e0 02             	shl    $0x2,%eax
c0103e4d:	01 c8                	add    %ecx,%eax
c0103e4f:	8b 50 08             	mov    0x8(%eax),%edx
c0103e52:	8b 40 04             	mov    0x4(%eax),%eax
c0103e55:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103e58:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103e5b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e61:	89 d0                	mov    %edx,%eax
c0103e63:	c1 e0 02             	shl    $0x2,%eax
c0103e66:	01 d0                	add    %edx,%eax
c0103e68:	c1 e0 02             	shl    $0x2,%eax
c0103e6b:	01 c8                	add    %ecx,%eax
c0103e6d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103e70:	8b 58 10             	mov    0x10(%eax),%ebx
c0103e73:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103e76:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103e79:	01 c8                	add    %ecx,%eax
c0103e7b:	11 da                	adc    %ebx,%edx
c0103e7d:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103e80:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103e83:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e86:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e89:	89 d0                	mov    %edx,%eax
c0103e8b:	c1 e0 02             	shl    $0x2,%eax
c0103e8e:	01 d0                	add    %edx,%eax
c0103e90:	c1 e0 02             	shl    $0x2,%eax
c0103e93:	01 c8                	add    %ecx,%eax
c0103e95:	83 c0 14             	add    $0x14,%eax
c0103e98:	8b 00                	mov    (%eax),%eax
c0103e9a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103ea0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103ea3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103ea6:	83 c0 ff             	add    $0xffffffff,%eax
c0103ea9:	83 d2 ff             	adc    $0xffffffff,%edx
c0103eac:	89 c6                	mov    %eax,%esi
c0103eae:	89 d7                	mov    %edx,%edi
c0103eb0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103eb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eb6:	89 d0                	mov    %edx,%eax
c0103eb8:	c1 e0 02             	shl    $0x2,%eax
c0103ebb:	01 d0                	add    %edx,%eax
c0103ebd:	c1 e0 02             	shl    $0x2,%eax
c0103ec0:	01 c8                	add    %ecx,%eax
c0103ec2:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103ec5:	8b 58 10             	mov    0x10(%eax),%ebx
c0103ec8:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103ece:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103ed2:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103ed6:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103eda:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103edd:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103ee0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103ee4:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103ee8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103eec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103ef0:	c7 04 24 f8 6a 10 c0 	movl   $0xc0106af8,(%esp)
c0103ef7:	e8 4c c4 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103efc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103eff:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f02:	89 d0                	mov    %edx,%eax
c0103f04:	c1 e0 02             	shl    $0x2,%eax
c0103f07:	01 d0                	add    %edx,%eax
c0103f09:	c1 e0 02             	shl    $0x2,%eax
c0103f0c:	01 c8                	add    %ecx,%eax
c0103f0e:	83 c0 14             	add    $0x14,%eax
c0103f11:	8b 00                	mov    (%eax),%eax
c0103f13:	83 f8 01             	cmp    $0x1,%eax
c0103f16:	75 36                	jne    c0103f4e <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103f18:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f1e:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f21:	77 2b                	ja     c0103f4e <page_init+0x14a>
c0103f23:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f26:	72 05                	jb     c0103f2d <page_init+0x129>
c0103f28:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103f2b:	73 21                	jae    c0103f4e <page_init+0x14a>
c0103f2d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f31:	77 1b                	ja     c0103f4e <page_init+0x14a>
c0103f33:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f37:	72 09                	jb     c0103f42 <page_init+0x13e>
c0103f39:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103f40:	77 0c                	ja     c0103f4e <page_init+0x14a>
                maxpa = end;
c0103f42:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f45:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f48:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103f4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103f4e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103f52:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f55:	8b 00                	mov    (%eax),%eax
c0103f57:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103f5a:	0f 8f dd fe ff ff    	jg     c0103e3d <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103f60:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f64:	72 1d                	jb     c0103f83 <page_init+0x17f>
c0103f66:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f6a:	77 09                	ja     c0103f75 <page_init+0x171>
c0103f6c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103f73:	76 0e                	jbe    c0103f83 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103f75:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103f7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103f83:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f89:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103f8d:	c1 ea 0c             	shr    $0xc,%edx
c0103f90:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103f95:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103f9c:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0103fa1:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103fa4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103fa7:	01 d0                	add    %edx,%eax
c0103fa9:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103fac:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103faf:	ba 00 00 00 00       	mov    $0x0,%edx
c0103fb4:	f7 75 ac             	divl   -0x54(%ebp)
c0103fb7:	89 d0                	mov    %edx,%eax
c0103fb9:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103fbc:	29 c2                	sub    %eax,%edx
c0103fbe:	89 d0                	mov    %edx,%eax
c0103fc0:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    for (i = 0; i < npage; i ++) {
c0103fc5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103fcc:	eb 2f                	jmp    c0103ffd <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103fce:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103fd4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fd7:	89 d0                	mov    %edx,%eax
c0103fd9:	c1 e0 02             	shl    $0x2,%eax
c0103fdc:	01 d0                	add    %edx,%eax
c0103fde:	c1 e0 02             	shl    $0x2,%eax
c0103fe1:	01 c8                	add    %ecx,%eax
c0103fe3:	83 c0 04             	add    $0x4,%eax
c0103fe6:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0103fed:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103ff0:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103ff3:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103ff6:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0103ff9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103ffd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104000:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104005:	39 c2                	cmp    %eax,%edx
c0104007:	72 c5                	jb     c0103fce <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104009:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010400f:	89 d0                	mov    %edx,%eax
c0104011:	c1 e0 02             	shl    $0x2,%eax
c0104014:	01 d0                	add    %edx,%eax
c0104016:	c1 e0 02             	shl    $0x2,%eax
c0104019:	89 c2                	mov    %eax,%edx
c010401b:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104020:	01 d0                	add    %edx,%eax
c0104022:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0104025:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010402c:	77 23                	ja     c0104051 <page_init+0x24d>
c010402e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104031:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104035:	c7 44 24 08 28 6b 10 	movl   $0xc0106b28,0x8(%esp)
c010403c:	c0 
c010403d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0104044:	00 
c0104045:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c010404c:	e8 81 cc ff ff       	call   c0100cd2 <__panic>
c0104051:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104054:	05 00 00 00 40       	add    $0x40000000,%eax
c0104059:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010405c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104063:	e9 74 01 00 00       	jmp    c01041dc <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104068:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010406b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010406e:	89 d0                	mov    %edx,%eax
c0104070:	c1 e0 02             	shl    $0x2,%eax
c0104073:	01 d0                	add    %edx,%eax
c0104075:	c1 e0 02             	shl    $0x2,%eax
c0104078:	01 c8                	add    %ecx,%eax
c010407a:	8b 50 08             	mov    0x8(%eax),%edx
c010407d:	8b 40 04             	mov    0x4(%eax),%eax
c0104080:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104083:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104086:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104089:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010408c:	89 d0                	mov    %edx,%eax
c010408e:	c1 e0 02             	shl    $0x2,%eax
c0104091:	01 d0                	add    %edx,%eax
c0104093:	c1 e0 02             	shl    $0x2,%eax
c0104096:	01 c8                	add    %ecx,%eax
c0104098:	8b 48 0c             	mov    0xc(%eax),%ecx
c010409b:	8b 58 10             	mov    0x10(%eax),%ebx
c010409e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01040a4:	01 c8                	add    %ecx,%eax
c01040a6:	11 da                	adc    %ebx,%edx
c01040a8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01040ab:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01040ae:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040b4:	89 d0                	mov    %edx,%eax
c01040b6:	c1 e0 02             	shl    $0x2,%eax
c01040b9:	01 d0                	add    %edx,%eax
c01040bb:	c1 e0 02             	shl    $0x2,%eax
c01040be:	01 c8                	add    %ecx,%eax
c01040c0:	83 c0 14             	add    $0x14,%eax
c01040c3:	8b 00                	mov    (%eax),%eax
c01040c5:	83 f8 01             	cmp    $0x1,%eax
c01040c8:	0f 85 0a 01 00 00    	jne    c01041d8 <page_init+0x3d4>
            if (begin < freemem) {
c01040ce:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040d1:	ba 00 00 00 00       	mov    $0x0,%edx
c01040d6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01040d9:	72 17                	jb     c01040f2 <page_init+0x2ee>
c01040db:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01040de:	77 05                	ja     c01040e5 <page_init+0x2e1>
c01040e0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01040e3:	76 0d                	jbe    c01040f2 <page_init+0x2ee>
                begin = freemem;
c01040e5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01040eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01040f2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01040f6:	72 1d                	jb     c0104115 <page_init+0x311>
c01040f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01040fc:	77 09                	ja     c0104107 <page_init+0x303>
c01040fe:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104105:	76 0e                	jbe    c0104115 <page_init+0x311>
                end = KMEMSIZE;
c0104107:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010410e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104115:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104118:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010411b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010411e:	0f 87 b4 00 00 00    	ja     c01041d8 <page_init+0x3d4>
c0104124:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104127:	72 09                	jb     c0104132 <page_init+0x32e>
c0104129:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010412c:	0f 83 a6 00 00 00    	jae    c01041d8 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0104132:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104139:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010413c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010413f:	01 d0                	add    %edx,%eax
c0104141:	83 e8 01             	sub    $0x1,%eax
c0104144:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104147:	8b 45 98             	mov    -0x68(%ebp),%eax
c010414a:	ba 00 00 00 00       	mov    $0x0,%edx
c010414f:	f7 75 9c             	divl   -0x64(%ebp)
c0104152:	89 d0                	mov    %edx,%eax
c0104154:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104157:	29 c2                	sub    %eax,%edx
c0104159:	89 d0                	mov    %edx,%eax
c010415b:	ba 00 00 00 00       	mov    $0x0,%edx
c0104160:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104163:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104166:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104169:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010416c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010416f:	ba 00 00 00 00       	mov    $0x0,%edx
c0104174:	89 c7                	mov    %eax,%edi
c0104176:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010417c:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010417f:	89 d0                	mov    %edx,%eax
c0104181:	83 e0 00             	and    $0x0,%eax
c0104184:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104187:	8b 45 80             	mov    -0x80(%ebp),%eax
c010418a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010418d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104190:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104193:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104196:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104199:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010419c:	77 3a                	ja     c01041d8 <page_init+0x3d4>
c010419e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041a1:	72 05                	jb     c01041a8 <page_init+0x3a4>
c01041a3:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01041a6:	73 30                	jae    c01041d8 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01041a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01041ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01041ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01041b1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01041b4:	29 c8                	sub    %ecx,%eax
c01041b6:	19 da                	sbb    %ebx,%edx
c01041b8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01041bc:	c1 ea 0c             	shr    $0xc,%edx
c01041bf:	89 c3                	mov    %eax,%ebx
c01041c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041c4:	89 04 24             	mov    %eax,(%esp)
c01041c7:	e8 a5 f8 ff ff       	call   c0103a71 <pa2page>
c01041cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041d0:	89 04 24             	mov    %eax,(%esp)
c01041d3:	e8 78 fb ff ff       	call   c0103d50 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01041d8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01041dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01041df:	8b 00                	mov    (%eax),%eax
c01041e1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01041e4:	0f 8f 7e fe ff ff    	jg     c0104068 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01041ea:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01041f0:	5b                   	pop    %ebx
c01041f1:	5e                   	pop    %esi
c01041f2:	5f                   	pop    %edi
c01041f3:	5d                   	pop    %ebp
c01041f4:	c3                   	ret    

c01041f5 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01041f5:	55                   	push   %ebp
c01041f6:	89 e5                	mov    %esp,%ebp
c01041f8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01041fb:	8b 45 14             	mov    0x14(%ebp),%eax
c01041fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104201:	31 d0                	xor    %edx,%eax
c0104203:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104208:	85 c0                	test   %eax,%eax
c010420a:	74 24                	je     c0104230 <boot_map_segment+0x3b>
c010420c:	c7 44 24 0c 5a 6b 10 	movl   $0xc0106b5a,0xc(%esp)
c0104213:	c0 
c0104214:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c010421b:	c0 
c010421c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104223:	00 
c0104224:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c010422b:	e8 a2 ca ff ff       	call   c0100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104230:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104237:	8b 45 0c             	mov    0xc(%ebp),%eax
c010423a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010423f:	89 c2                	mov    %eax,%edx
c0104241:	8b 45 10             	mov    0x10(%ebp),%eax
c0104244:	01 c2                	add    %eax,%edx
c0104246:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104249:	01 d0                	add    %edx,%eax
c010424b:	83 e8 01             	sub    $0x1,%eax
c010424e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104251:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104254:	ba 00 00 00 00       	mov    $0x0,%edx
c0104259:	f7 75 f0             	divl   -0x10(%ebp)
c010425c:	89 d0                	mov    %edx,%eax
c010425e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104261:	29 c2                	sub    %eax,%edx
c0104263:	89 d0                	mov    %edx,%eax
c0104265:	c1 e8 0c             	shr    $0xc,%eax
c0104268:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010426b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010426e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104271:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104274:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104279:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010427c:	8b 45 14             	mov    0x14(%ebp),%eax
c010427f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104285:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010428a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010428d:	eb 6b                	jmp    c01042fa <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010428f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104296:	00 
c0104297:	8b 45 0c             	mov    0xc(%ebp),%eax
c010429a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010429e:	8b 45 08             	mov    0x8(%ebp),%eax
c01042a1:	89 04 24             	mov    %eax,(%esp)
c01042a4:	e8 82 01 00 00       	call   c010442b <get_pte>
c01042a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01042ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042b0:	75 24                	jne    c01042d6 <boot_map_segment+0xe1>
c01042b2:	c7 44 24 0c 86 6b 10 	movl   $0xc0106b86,0xc(%esp)
c01042b9:	c0 
c01042ba:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c01042c1:	c0 
c01042c2:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01042c9:	00 
c01042ca:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01042d1:	e8 fc c9 ff ff       	call   c0100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
c01042d6:	8b 45 18             	mov    0x18(%ebp),%eax
c01042d9:	8b 55 14             	mov    0x14(%ebp),%edx
c01042dc:	09 d0                	or     %edx,%eax
c01042de:	83 c8 01             	or     $0x1,%eax
c01042e1:	89 c2                	mov    %eax,%edx
c01042e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042e6:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01042e8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01042ec:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01042f3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01042fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042fe:	75 8f                	jne    c010428f <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104300:	c9                   	leave  
c0104301:	c3                   	ret    

c0104302 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104302:	55                   	push   %ebp
c0104303:	89 e5                	mov    %esp,%ebp
c0104305:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104308:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010430f:	e8 5b fa ff ff       	call   c0103d6f <alloc_pages>
c0104314:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104317:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010431b:	75 1c                	jne    c0104339 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010431d:	c7 44 24 08 93 6b 10 	movl   $0xc0106b93,0x8(%esp)
c0104324:	c0 
c0104325:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010432c:	00 
c010432d:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104334:	e8 99 c9 ff ff       	call   c0100cd2 <__panic>
    }
    return page2kva(p);
c0104339:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010433c:	89 04 24             	mov    %eax,(%esp)
c010433f:	e8 7c f7 ff ff       	call   c0103ac0 <page2kva>
}
c0104344:	c9                   	leave  
c0104345:	c3                   	ret    

c0104346 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104346:	55                   	push   %ebp
c0104347:	89 e5                	mov    %esp,%ebp
c0104349:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010434c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104351:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104354:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010435b:	77 23                	ja     c0104380 <pmm_init+0x3a>
c010435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104360:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104364:	c7 44 24 08 28 6b 10 	movl   $0xc0106b28,0x8(%esp)
c010436b:	c0 
c010436c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104373:	00 
c0104374:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c010437b:	e8 52 c9 ff ff       	call   c0100cd2 <__panic>
c0104380:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104383:	05 00 00 00 40       	add    $0x40000000,%eax
c0104388:	a3 20 af 11 c0       	mov    %eax,0xc011af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010438d:	e8 8b f9 ff ff       	call   c0103d1d <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104392:	e8 6d fa ff ff       	call   c0103e04 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104397:	e8 db 03 00 00       	call   c0104777 <check_alloc_page>

    check_pgdir();
c010439c:	e8 f4 03 00 00       	call   c0104795 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01043a1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043a6:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01043ac:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043b4:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01043bb:	77 23                	ja     c01043e0 <pmm_init+0x9a>
c01043bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043c4:	c7 44 24 08 28 6b 10 	movl   $0xc0106b28,0x8(%esp)
c01043cb:	c0 
c01043cc:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01043d3:	00 
c01043d4:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01043db:	e8 f2 c8 ff ff       	call   c0100cd2 <__panic>
c01043e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e3:	05 00 00 00 40       	add    $0x40000000,%eax
c01043e8:	83 c8 03             	or     $0x3,%eax
c01043eb:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01043ed:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043f2:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01043f9:	00 
c01043fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104401:	00 
c0104402:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104409:	38 
c010440a:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104411:	c0 
c0104412:	89 04 24             	mov    %eax,(%esp)
c0104415:	e8 db fd ff ff       	call   c01041f5 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010441a:	e8 0f f8 ff ff       	call   c0103c2e <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010441f:	e8 0c 0a 00 00       	call   c0104e30 <check_boot_pgdir>

    print_pgdir();
c0104424:	e8 94 0e 00 00       	call   c01052bd <print_pgdir>

}
c0104429:	c9                   	leave  
c010442a:	c3                   	ret    

c010442b <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010442b:	55                   	push   %ebp
c010442c:	89 e5                	mov    %esp,%ebp
c010442e:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
pde_t *pdep = &pgdir[PDX(la)]; // 找到 PDE 这里的 pgdir 可以看做是页目录表的基址
c0104431:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104434:	c1 e8 16             	shr    $0x16,%eax
c0104437:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010443e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104441:	01 d0                	add    %edx,%eax
c0104443:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // 看看 PDE 指向的页表是否存在
c0104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104449:	8b 00                	mov    (%eax),%eax
c010444b:	83 e0 01             	and    $0x1,%eax
c010444e:	85 c0                	test   %eax,%eax
c0104450:	0f 85 af 00 00 00    	jne    c0104505 <get_pte+0xda>
        struct Page* page = alloc_page(); // 不存在就申请一页物理页
c0104456:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010445d:	e8 0d f9 ff ff       	call   c0103d6f <alloc_pages>
c0104462:	89 45 f0             	mov    %eax,-0x10(%ebp)
        
        if (!create || page == NULL) { //不存在且不需要创建，返回NULL
c0104465:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104469:	74 06                	je     c0104471 <get_pte+0x46>
c010446b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010446f:	75 0a                	jne    c010447b <get_pte+0x50>
            return NULL;
c0104471:	b8 00 00 00 00       	mov    $0x0,%eax
c0104476:	e9 e6 00 00 00       	jmp    c0104561 <get_pte+0x136>
        }
        set_page_ref(page, 1); //设置此页被引用一次
c010447b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104482:	00 
c0104483:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104486:	89 04 24             	mov    %eax,(%esp)
c0104489:	e8 e6 f6 ff ff       	call   c0103b74 <set_page_ref>
        uintptr_t pa = page2pa(page);//得到 page 管理的那一页的物理地址
c010448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104491:	89 04 24             	mov    %eax,(%esp)
c0104494:	e8 c2 f5 ff ff       	call   c0103a5b <page2pa>
c0104499:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); 
c010449c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010449f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01044a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044a5:	c1 e8 0c             	shr    $0xc,%eax
c01044a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044ab:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01044b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01044b3:	72 23                	jb     c01044d8 <get_pte+0xad>
c01044b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044bc:	c7 44 24 08 84 6a 10 	movl   $0xc0106a84,0x8(%esp)
c01044c3:	c0 
c01044c4:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
c01044cb:	00 
c01044cc:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01044d3:	e8 fa c7 ff ff       	call   c0100cd2 <__panic>
c01044d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044db:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01044e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01044e7:	00 
c01044e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01044ef:	00 
c01044f0:	89 04 24             	mov    %eax,(%esp)
c01044f3:	e8 e3 18 00 00       	call   c0105ddb <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P; // 设置 PDE 权限
c01044f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044fb:	83 c8 07             	or     $0x7,%eax
c01044fe:	89 c2                	mov    %eax,%edx
c0104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104503:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104508:	8b 00                	mov    (%eax),%eax
c010450a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010450f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104512:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104515:	c1 e8 0c             	shr    $0xc,%eax
c0104518:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010451b:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104520:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104523:	72 23                	jb     c0104548 <get_pte+0x11d>
c0104525:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104528:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010452c:	c7 44 24 08 84 6a 10 	movl   $0xc0106a84,0x8(%esp)
c0104533:	c0 
c0104534:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c010453b:	00 
c010453c:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104543:	e8 8a c7 ff ff       	call   c0100cd2 <__panic>
c0104548:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010454b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104550:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104553:	c1 ea 0c             	shr    $0xc,%edx
c0104556:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c010455c:	c1 e2 02             	shl    $0x2,%edx
c010455f:	01 d0                	add    %edx,%eax
}
c0104561:	c9                   	leave  
c0104562:	c3                   	ret    

c0104563 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0104563:	55                   	push   %ebp
c0104564:	89 e5                	mov    %esp,%ebp
c0104566:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104569:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104570:	00 
c0104571:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104574:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104578:	8b 45 08             	mov    0x8(%ebp),%eax
c010457b:	89 04 24             	mov    %eax,(%esp)
c010457e:	e8 a8 fe ff ff       	call   c010442b <get_pte>
c0104583:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0104586:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010458a:	74 08                	je     c0104594 <get_page+0x31>
        *ptep_store = ptep;
c010458c:	8b 45 10             	mov    0x10(%ebp),%eax
c010458f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104592:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104594:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104598:	74 1b                	je     c01045b5 <get_page+0x52>
c010459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010459d:	8b 00                	mov    (%eax),%eax
c010459f:	83 e0 01             	and    $0x1,%eax
c01045a2:	85 c0                	test   %eax,%eax
c01045a4:	74 0f                	je     c01045b5 <get_page+0x52>
        return pte2page(*ptep);
c01045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045a9:	8b 00                	mov    (%eax),%eax
c01045ab:	89 04 24             	mov    %eax,(%esp)
c01045ae:	e8 61 f5 ff ff       	call   c0103b14 <pte2page>
c01045b3:	eb 05                	jmp    c01045ba <get_page+0x57>
    }
    return NULL;
c01045b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045ba:	c9                   	leave  
c01045bb:	c3                   	ret    

c01045bc <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01045bc:	55                   	push   %ebp
c01045bd:	89 e5                	mov    %esp,%ebp
c01045bf:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
if ((*ptep & PTE_P)) { //判断页表中该表项是否存在
c01045c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01045c5:	8b 00                	mov    (%eax),%eax
c01045c7:	83 e0 01             	and    $0x1,%eax
c01045ca:	85 c0                	test   %eax,%eax
c01045cc:	74 4d                	je     c010461b <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);// 将页表项转换为页数据结构
c01045ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01045d1:	8b 00                	mov    (%eax),%eax
c01045d3:	89 04 24             	mov    %eax,(%esp)
c01045d6:	e8 39 f5 ff ff       	call   c0103b14 <pte2page>
c01045db:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { // 判断是否只被引用了一次，若引用计数减一后为0，则释放该物理页
c01045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e1:	89 04 24             	mov    %eax,(%esp)
c01045e4:	e8 af f5 ff ff       	call   c0103b98 <page_ref_dec>
c01045e9:	85 c0                	test   %eax,%eax
c01045eb:	75 13                	jne    c0104600 <page_remove_pte+0x44>
            free_page(page);
c01045ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01045f4:	00 
c01045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f8:	89 04 24             	mov    %eax,(%esp)
c01045fb:	e8 a7 f7 ff ff       	call   c0103da7 <free_pages>
        }
        *ptep = 0; // //如果被多次引用，则不能释放此页，只用释放二级页表的表项，清空 PTE
c0104600:	8b 45 10             	mov    0x10(%ebp),%eax
c0104603:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la); // 刷新 tlb
c0104609:	8b 45 0c             	mov    0xc(%ebp),%eax
c010460c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104610:	8b 45 08             	mov    0x8(%ebp),%eax
c0104613:	89 04 24             	mov    %eax,(%esp)
c0104616:	e8 ff 00 00 00       	call   c010471a <tlb_invalidate>
    }
}
c010461b:	c9                   	leave  
c010461c:	c3                   	ret    

c010461d <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010461d:	55                   	push   %ebp
c010461e:	89 e5                	mov    %esp,%ebp
c0104620:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104623:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010462a:	00 
c010462b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010462e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104632:	8b 45 08             	mov    0x8(%ebp),%eax
c0104635:	89 04 24             	mov    %eax,(%esp)
c0104638:	e8 ee fd ff ff       	call   c010442b <get_pte>
c010463d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104640:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104644:	74 19                	je     c010465f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104649:	89 44 24 08          	mov    %eax,0x8(%esp)
c010464d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104650:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104654:	8b 45 08             	mov    0x8(%ebp),%eax
c0104657:	89 04 24             	mov    %eax,(%esp)
c010465a:	e8 5d ff ff ff       	call   c01045bc <page_remove_pte>
    }
}
c010465f:	c9                   	leave  
c0104660:	c3                   	ret    

c0104661 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104661:	55                   	push   %ebp
c0104662:	89 e5                	mov    %esp,%ebp
c0104664:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104667:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010466e:	00 
c010466f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104672:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104676:	8b 45 08             	mov    0x8(%ebp),%eax
c0104679:	89 04 24             	mov    %eax,(%esp)
c010467c:	e8 aa fd ff ff       	call   c010442b <get_pte>
c0104681:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104688:	75 0a                	jne    c0104694 <page_insert+0x33>
        return -E_NO_MEM;
c010468a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010468f:	e9 84 00 00 00       	jmp    c0104718 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104694:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104697:	89 04 24             	mov    %eax,(%esp)
c010469a:	e8 e2 f4 ff ff       	call   c0103b81 <page_ref_inc>
    if (*ptep & PTE_P) {
c010469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046a2:	8b 00                	mov    (%eax),%eax
c01046a4:	83 e0 01             	and    $0x1,%eax
c01046a7:	85 c0                	test   %eax,%eax
c01046a9:	74 3e                	je     c01046e9 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ae:	8b 00                	mov    (%eax),%eax
c01046b0:	89 04 24             	mov    %eax,(%esp)
c01046b3:	e8 5c f4 ff ff       	call   c0103b14 <pte2page>
c01046b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01046bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046be:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01046c1:	75 0d                	jne    c01046d0 <page_insert+0x6f>
            page_ref_dec(page);
c01046c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046c6:	89 04 24             	mov    %eax,(%esp)
c01046c9:	e8 ca f4 ff ff       	call   c0103b98 <page_ref_dec>
c01046ce:	eb 19                	jmp    c01046e9 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01046da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046de:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e1:	89 04 24             	mov    %eax,(%esp)
c01046e4:	e8 d3 fe ff ff       	call   c01045bc <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01046e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046ec:	89 04 24             	mov    %eax,(%esp)
c01046ef:	e8 67 f3 ff ff       	call   c0103a5b <page2pa>
c01046f4:	0b 45 14             	or     0x14(%ebp),%eax
c01046f7:	83 c8 01             	or     $0x1,%eax
c01046fa:	89 c2                	mov    %eax,%edx
c01046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ff:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104701:	8b 45 10             	mov    0x10(%ebp),%eax
c0104704:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104708:	8b 45 08             	mov    0x8(%ebp),%eax
c010470b:	89 04 24             	mov    %eax,(%esp)
c010470e:	e8 07 00 00 00       	call   c010471a <tlb_invalidate>
    return 0;
c0104713:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104718:	c9                   	leave  
c0104719:	c3                   	ret    

c010471a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010471a:	55                   	push   %ebp
c010471b:	89 e5                	mov    %esp,%ebp
c010471d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104720:	0f 20 d8             	mov    %cr3,%eax
c0104723:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104726:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0104729:	89 c2                	mov    %eax,%edx
c010472b:	8b 45 08             	mov    0x8(%ebp),%eax
c010472e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104731:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104738:	77 23                	ja     c010475d <tlb_invalidate+0x43>
c010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104741:	c7 44 24 08 28 6b 10 	movl   $0xc0106b28,0x8(%esp)
c0104748:	c0 
c0104749:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c0104750:	00 
c0104751:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104758:	e8 75 c5 ff ff       	call   c0100cd2 <__panic>
c010475d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104760:	05 00 00 00 40       	add    $0x40000000,%eax
c0104765:	39 c2                	cmp    %eax,%edx
c0104767:	75 0c                	jne    c0104775 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104769:	8b 45 0c             	mov    0xc(%ebp),%eax
c010476c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010476f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104772:	0f 01 38             	invlpg (%eax)
    }
}
c0104775:	c9                   	leave  
c0104776:	c3                   	ret    

c0104777 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104777:	55                   	push   %ebp
c0104778:	89 e5                	mov    %esp,%ebp
c010477a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010477d:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104782:	8b 40 18             	mov    0x18(%eax),%eax
c0104785:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104787:	c7 04 24 ac 6b 10 c0 	movl   $0xc0106bac,(%esp)
c010478e:	e8 b5 bb ff ff       	call   c0100348 <cprintf>
}
c0104793:	c9                   	leave  
c0104794:	c3                   	ret    

c0104795 <check_pgdir>:

static void
check_pgdir(void) {
c0104795:	55                   	push   %ebp
c0104796:	89 e5                	mov    %esp,%ebp
c0104798:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010479b:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01047a0:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01047a5:	76 24                	jbe    c01047cb <check_pgdir+0x36>
c01047a7:	c7 44 24 0c cb 6b 10 	movl   $0xc0106bcb,0xc(%esp)
c01047ae:	c0 
c01047af:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c01047b6:	c0 
c01047b7:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c01047be:	00 
c01047bf:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01047c6:	e8 07 c5 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01047cb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01047d0:	85 c0                	test   %eax,%eax
c01047d2:	74 0e                	je     c01047e2 <check_pgdir+0x4d>
c01047d4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01047d9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01047de:	85 c0                	test   %eax,%eax
c01047e0:	74 24                	je     c0104806 <check_pgdir+0x71>
c01047e2:	c7 44 24 0c e8 6b 10 	movl   $0xc0106be8,0xc(%esp)
c01047e9:	c0 
c01047ea:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c01047f1:	c0 
c01047f2:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c01047f9:	00 
c01047fa:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104801:	e8 cc c4 ff ff       	call   c0100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104806:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010480b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104812:	00 
c0104813:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010481a:	00 
c010481b:	89 04 24             	mov    %eax,(%esp)
c010481e:	e8 40 fd ff ff       	call   c0104563 <get_page>
c0104823:	85 c0                	test   %eax,%eax
c0104825:	74 24                	je     c010484b <check_pgdir+0xb6>
c0104827:	c7 44 24 0c 20 6c 10 	movl   $0xc0106c20,0xc(%esp)
c010482e:	c0 
c010482f:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104836:	c0 
c0104837:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c010483e:	00 
c010483f:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104846:	e8 87 c4 ff ff       	call   c0100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010484b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104852:	e8 18 f5 ff ff       	call   c0103d6f <alloc_pages>
c0104857:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010485a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010485f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104866:	00 
c0104867:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010486e:	00 
c010486f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104872:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104876:	89 04 24             	mov    %eax,(%esp)
c0104879:	e8 e3 fd ff ff       	call   c0104661 <page_insert>
c010487e:	85 c0                	test   %eax,%eax
c0104880:	74 24                	je     c01048a6 <check_pgdir+0x111>
c0104882:	c7 44 24 0c 48 6c 10 	movl   $0xc0106c48,0xc(%esp)
c0104889:	c0 
c010488a:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104891:	c0 
c0104892:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0104899:	00 
c010489a:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01048a1:	e8 2c c4 ff ff       	call   c0100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01048a6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048b2:	00 
c01048b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048ba:	00 
c01048bb:	89 04 24             	mov    %eax,(%esp)
c01048be:	e8 68 fb ff ff       	call   c010442b <get_pte>
c01048c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048ca:	75 24                	jne    c01048f0 <check_pgdir+0x15b>
c01048cc:	c7 44 24 0c 74 6c 10 	movl   $0xc0106c74,0xc(%esp)
c01048d3:	c0 
c01048d4:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c01048db:	c0 
c01048dc:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c01048e3:	00 
c01048e4:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01048eb:	e8 e2 c3 ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c01048f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048f3:	8b 00                	mov    (%eax),%eax
c01048f5:	89 04 24             	mov    %eax,(%esp)
c01048f8:	e8 17 f2 ff ff       	call   c0103b14 <pte2page>
c01048fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104900:	74 24                	je     c0104926 <check_pgdir+0x191>
c0104902:	c7 44 24 0c a1 6c 10 	movl   $0xc0106ca1,0xc(%esp)
c0104909:	c0 
c010490a:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104911:	c0 
c0104912:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c0104919:	00 
c010491a:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104921:	e8 ac c3 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 1);
c0104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104929:	89 04 24             	mov    %eax,(%esp)
c010492c:	e8 39 f2 ff ff       	call   c0103b6a <page_ref>
c0104931:	83 f8 01             	cmp    $0x1,%eax
c0104934:	74 24                	je     c010495a <check_pgdir+0x1c5>
c0104936:	c7 44 24 0c b7 6c 10 	movl   $0xc0106cb7,0xc(%esp)
c010493d:	c0 
c010493e:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104945:	c0 
c0104946:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c010494d:	00 
c010494e:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104955:	e8 78 c3 ff ff       	call   c0100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010495a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010495f:	8b 00                	mov    (%eax),%eax
c0104961:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104966:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104969:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010496c:	c1 e8 0c             	shr    $0xc,%eax
c010496f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104972:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104977:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010497a:	72 23                	jb     c010499f <check_pgdir+0x20a>
c010497c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010497f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104983:	c7 44 24 08 84 6a 10 	movl   $0xc0106a84,0x8(%esp)
c010498a:	c0 
c010498b:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c0104992:	00 
c0104993:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c010499a:	e8 33 c3 ff ff       	call   c0100cd2 <__panic>
c010499f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049a2:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01049a7:	83 c0 04             	add    $0x4,%eax
c01049aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01049ad:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01049b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049b9:	00 
c01049ba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01049c1:	00 
c01049c2:	89 04 24             	mov    %eax,(%esp)
c01049c5:	e8 61 fa ff ff       	call   c010442b <get_pte>
c01049ca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049cd:	74 24                	je     c01049f3 <check_pgdir+0x25e>
c01049cf:	c7 44 24 0c cc 6c 10 	movl   $0xc0106ccc,0xc(%esp)
c01049d6:	c0 
c01049d7:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c01049de:	c0 
c01049df:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c01049e6:	00 
c01049e7:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01049ee:	e8 df c2 ff ff       	call   c0100cd2 <__panic>

    p2 = alloc_page();
c01049f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01049fa:	e8 70 f3 ff ff       	call   c0103d6f <alloc_pages>
c01049ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104a02:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104a0e:	00 
c0104a0f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104a16:	00 
c0104a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104a1a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a1e:	89 04 24             	mov    %eax,(%esp)
c0104a21:	e8 3b fc ff ff       	call   c0104661 <page_insert>
c0104a26:	85 c0                	test   %eax,%eax
c0104a28:	74 24                	je     c0104a4e <check_pgdir+0x2b9>
c0104a2a:	c7 44 24 0c f4 6c 10 	movl   $0xc0106cf4,0xc(%esp)
c0104a31:	c0 
c0104a32:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104a39:	c0 
c0104a3a:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0104a41:	00 
c0104a42:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104a49:	e8 84 c2 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104a4e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a5a:	00 
c0104a5b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a62:	00 
c0104a63:	89 04 24             	mov    %eax,(%esp)
c0104a66:	e8 c0 f9 ff ff       	call   c010442b <get_pte>
c0104a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a72:	75 24                	jne    c0104a98 <check_pgdir+0x303>
c0104a74:	c7 44 24 0c 2c 6d 10 	movl   $0xc0106d2c,0xc(%esp)
c0104a7b:	c0 
c0104a7c:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104a83:	c0 
c0104a84:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0104a8b:	00 
c0104a8c:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104a93:	e8 3a c2 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_U);
c0104a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a9b:	8b 00                	mov    (%eax),%eax
c0104a9d:	83 e0 04             	and    $0x4,%eax
c0104aa0:	85 c0                	test   %eax,%eax
c0104aa2:	75 24                	jne    c0104ac8 <check_pgdir+0x333>
c0104aa4:	c7 44 24 0c 5c 6d 10 	movl   $0xc0106d5c,0xc(%esp)
c0104aab:	c0 
c0104aac:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104ab3:	c0 
c0104ab4:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0104abb:	00 
c0104abc:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104ac3:	e8 0a c2 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_W);
c0104ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104acb:	8b 00                	mov    (%eax),%eax
c0104acd:	83 e0 02             	and    $0x2,%eax
c0104ad0:	85 c0                	test   %eax,%eax
c0104ad2:	75 24                	jne    c0104af8 <check_pgdir+0x363>
c0104ad4:	c7 44 24 0c 6a 6d 10 	movl   $0xc0106d6a,0xc(%esp)
c0104adb:	c0 
c0104adc:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104ae3:	c0 
c0104ae4:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0104aeb:	00 
c0104aec:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104af3:	e8 da c1 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104af8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104afd:	8b 00                	mov    (%eax),%eax
c0104aff:	83 e0 04             	and    $0x4,%eax
c0104b02:	85 c0                	test   %eax,%eax
c0104b04:	75 24                	jne    c0104b2a <check_pgdir+0x395>
c0104b06:	c7 44 24 0c 78 6d 10 	movl   $0xc0106d78,0xc(%esp)
c0104b0d:	c0 
c0104b0e:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104b15:	c0 
c0104b16:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0104b1d:	00 
c0104b1e:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104b25:	e8 a8 c1 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 1);
c0104b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b2d:	89 04 24             	mov    %eax,(%esp)
c0104b30:	e8 35 f0 ff ff       	call   c0103b6a <page_ref>
c0104b35:	83 f8 01             	cmp    $0x1,%eax
c0104b38:	74 24                	je     c0104b5e <check_pgdir+0x3c9>
c0104b3a:	c7 44 24 0c 8e 6d 10 	movl   $0xc0106d8e,0xc(%esp)
c0104b41:	c0 
c0104b42:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104b49:	c0 
c0104b4a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0104b51:	00 
c0104b52:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104b59:	e8 74 c1 ff ff       	call   c0100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104b5e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b63:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104b6a:	00 
c0104b6b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104b72:	00 
c0104b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b76:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b7a:	89 04 24             	mov    %eax,(%esp)
c0104b7d:	e8 df fa ff ff       	call   c0104661 <page_insert>
c0104b82:	85 c0                	test   %eax,%eax
c0104b84:	74 24                	je     c0104baa <check_pgdir+0x415>
c0104b86:	c7 44 24 0c a0 6d 10 	movl   $0xc0106da0,0xc(%esp)
c0104b8d:	c0 
c0104b8e:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104b95:	c0 
c0104b96:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0104b9d:	00 
c0104b9e:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104ba5:	e8 28 c1 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 2);
c0104baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bad:	89 04 24             	mov    %eax,(%esp)
c0104bb0:	e8 b5 ef ff ff       	call   c0103b6a <page_ref>
c0104bb5:	83 f8 02             	cmp    $0x2,%eax
c0104bb8:	74 24                	je     c0104bde <check_pgdir+0x449>
c0104bba:	c7 44 24 0c cc 6d 10 	movl   $0xc0106dcc,0xc(%esp)
c0104bc1:	c0 
c0104bc2:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104bc9:	c0 
c0104bca:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0104bd1:	00 
c0104bd2:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104bd9:	e8 f4 c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104bde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104be1:	89 04 24             	mov    %eax,(%esp)
c0104be4:	e8 81 ef ff ff       	call   c0103b6a <page_ref>
c0104be9:	85 c0                	test   %eax,%eax
c0104beb:	74 24                	je     c0104c11 <check_pgdir+0x47c>
c0104bed:	c7 44 24 0c de 6d 10 	movl   $0xc0106dde,0xc(%esp)
c0104bf4:	c0 
c0104bf5:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104bfc:	c0 
c0104bfd:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0104c04:	00 
c0104c05:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104c0c:	e8 c1 c0 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104c11:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c1d:	00 
c0104c1e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c25:	00 
c0104c26:	89 04 24             	mov    %eax,(%esp)
c0104c29:	e8 fd f7 ff ff       	call   c010442b <get_pte>
c0104c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c35:	75 24                	jne    c0104c5b <check_pgdir+0x4c6>
c0104c37:	c7 44 24 0c 2c 6d 10 	movl   $0xc0106d2c,0xc(%esp)
c0104c3e:	c0 
c0104c3f:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104c46:	c0 
c0104c47:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0104c4e:	00 
c0104c4f:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104c56:	e8 77 c0 ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c0104c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c5e:	8b 00                	mov    (%eax),%eax
c0104c60:	89 04 24             	mov    %eax,(%esp)
c0104c63:	e8 ac ee ff ff       	call   c0103b14 <pte2page>
c0104c68:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c6b:	74 24                	je     c0104c91 <check_pgdir+0x4fc>
c0104c6d:	c7 44 24 0c a1 6c 10 	movl   $0xc0106ca1,0xc(%esp)
c0104c74:	c0 
c0104c75:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104c7c:	c0 
c0104c7d:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0104c84:	00 
c0104c85:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104c8c:	e8 41 c0 ff ff       	call   c0100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c94:	8b 00                	mov    (%eax),%eax
c0104c96:	83 e0 04             	and    $0x4,%eax
c0104c99:	85 c0                	test   %eax,%eax
c0104c9b:	74 24                	je     c0104cc1 <check_pgdir+0x52c>
c0104c9d:	c7 44 24 0c f0 6d 10 	movl   $0xc0106df0,0xc(%esp)
c0104ca4:	c0 
c0104ca5:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104cac:	c0 
c0104cad:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0104cb4:	00 
c0104cb5:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104cbc:	e8 11 c0 ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104cc1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104cc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ccd:	00 
c0104cce:	89 04 24             	mov    %eax,(%esp)
c0104cd1:	e8 47 f9 ff ff       	call   c010461d <page_remove>
    assert(page_ref(p1) == 1);
c0104cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cd9:	89 04 24             	mov    %eax,(%esp)
c0104cdc:	e8 89 ee ff ff       	call   c0103b6a <page_ref>
c0104ce1:	83 f8 01             	cmp    $0x1,%eax
c0104ce4:	74 24                	je     c0104d0a <check_pgdir+0x575>
c0104ce6:	c7 44 24 0c b7 6c 10 	movl   $0xc0106cb7,0xc(%esp)
c0104ced:	c0 
c0104cee:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104cf5:	c0 
c0104cf6:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0104cfd:	00 
c0104cfe:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104d05:	e8 c8 bf ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d0d:	89 04 24             	mov    %eax,(%esp)
c0104d10:	e8 55 ee ff ff       	call   c0103b6a <page_ref>
c0104d15:	85 c0                	test   %eax,%eax
c0104d17:	74 24                	je     c0104d3d <check_pgdir+0x5a8>
c0104d19:	c7 44 24 0c de 6d 10 	movl   $0xc0106dde,0xc(%esp)
c0104d20:	c0 
c0104d21:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104d28:	c0 
c0104d29:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104d30:	00 
c0104d31:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104d38:	e8 95 bf ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104d3d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d42:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d49:	00 
c0104d4a:	89 04 24             	mov    %eax,(%esp)
c0104d4d:	e8 cb f8 ff ff       	call   c010461d <page_remove>
    assert(page_ref(p1) == 0);
c0104d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d55:	89 04 24             	mov    %eax,(%esp)
c0104d58:	e8 0d ee ff ff       	call   c0103b6a <page_ref>
c0104d5d:	85 c0                	test   %eax,%eax
c0104d5f:	74 24                	je     c0104d85 <check_pgdir+0x5f0>
c0104d61:	c7 44 24 0c 05 6e 10 	movl   $0xc0106e05,0xc(%esp)
c0104d68:	c0 
c0104d69:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104d70:	c0 
c0104d71:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0104d78:	00 
c0104d79:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104d80:	e8 4d bf ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d88:	89 04 24             	mov    %eax,(%esp)
c0104d8b:	e8 da ed ff ff       	call   c0103b6a <page_ref>
c0104d90:	85 c0                	test   %eax,%eax
c0104d92:	74 24                	je     c0104db8 <check_pgdir+0x623>
c0104d94:	c7 44 24 0c de 6d 10 	movl   $0xc0106dde,0xc(%esp)
c0104d9b:	c0 
c0104d9c:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104da3:	c0 
c0104da4:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104dab:	00 
c0104dac:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104db3:	e8 1a bf ff ff       	call   c0100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104db8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dbd:	8b 00                	mov    (%eax),%eax
c0104dbf:	89 04 24             	mov    %eax,(%esp)
c0104dc2:	e8 8b ed ff ff       	call   c0103b52 <pde2page>
c0104dc7:	89 04 24             	mov    %eax,(%esp)
c0104dca:	e8 9b ed ff ff       	call   c0103b6a <page_ref>
c0104dcf:	83 f8 01             	cmp    $0x1,%eax
c0104dd2:	74 24                	je     c0104df8 <check_pgdir+0x663>
c0104dd4:	c7 44 24 0c 18 6e 10 	movl   $0xc0106e18,0xc(%esp)
c0104ddb:	c0 
c0104ddc:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104de3:	c0 
c0104de4:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104deb:	00 
c0104dec:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104df3:	e8 da be ff ff       	call   c0100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104df8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dfd:	8b 00                	mov    (%eax),%eax
c0104dff:	89 04 24             	mov    %eax,(%esp)
c0104e02:	e8 4b ed ff ff       	call   c0103b52 <pde2page>
c0104e07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e0e:	00 
c0104e0f:	89 04 24             	mov    %eax,(%esp)
c0104e12:	e8 90 ef ff ff       	call   c0103da7 <free_pages>
    boot_pgdir[0] = 0;
c0104e17:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104e22:	c7 04 24 3f 6e 10 c0 	movl   $0xc0106e3f,(%esp)
c0104e29:	e8 1a b5 ff ff       	call   c0100348 <cprintf>
}
c0104e2e:	c9                   	leave  
c0104e2f:	c3                   	ret    

c0104e30 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104e30:	55                   	push   %ebp
c0104e31:	89 e5                	mov    %esp,%ebp
c0104e33:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e3d:	e9 ca 00 00 00       	jmp    c0104f0c <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e45:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e4b:	c1 e8 0c             	shr    $0xc,%eax
c0104e4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e51:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104e56:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104e59:	72 23                	jb     c0104e7e <check_boot_pgdir+0x4e>
c0104e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e62:	c7 44 24 08 84 6a 10 	movl   $0xc0106a84,0x8(%esp)
c0104e69:	c0 
c0104e6a:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104e71:	00 
c0104e72:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104e79:	e8 54 be ff ff       	call   c0100cd2 <__panic>
c0104e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e81:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104e86:	89 c2                	mov    %eax,%edx
c0104e88:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104e94:	00 
c0104e95:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e99:	89 04 24             	mov    %eax,(%esp)
c0104e9c:	e8 8a f5 ff ff       	call   c010442b <get_pte>
c0104ea1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104ea4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104ea8:	75 24                	jne    c0104ece <check_boot_pgdir+0x9e>
c0104eaa:	c7 44 24 0c 5c 6e 10 	movl   $0xc0106e5c,0xc(%esp)
c0104eb1:	c0 
c0104eb2:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104eb9:	c0 
c0104eba:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104ec1:	00 
c0104ec2:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104ec9:	e8 04 be ff ff       	call   c0100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104ece:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ed1:	8b 00                	mov    (%eax),%eax
c0104ed3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104ed8:	89 c2                	mov    %eax,%edx
c0104eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104edd:	39 c2                	cmp    %eax,%edx
c0104edf:	74 24                	je     c0104f05 <check_boot_pgdir+0xd5>
c0104ee1:	c7 44 24 0c 99 6e 10 	movl   $0xc0106e99,0xc(%esp)
c0104ee8:	c0 
c0104ee9:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104ef8:	00 
c0104ef9:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104f00:	e8 cd bd ff ff       	call   c0100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104f05:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104f0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f0f:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104f14:	39 c2                	cmp    %eax,%edx
c0104f16:	0f 82 26 ff ff ff    	jb     c0104e42 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104f1c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f21:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104f26:	8b 00                	mov    (%eax),%eax
c0104f28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f2d:	89 c2                	mov    %eax,%edx
c0104f2f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104f37:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104f3e:	77 23                	ja     c0104f63 <check_boot_pgdir+0x133>
c0104f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f47:	c7 44 24 08 28 6b 10 	movl   $0xc0106b28,0x8(%esp)
c0104f4e:	c0 
c0104f4f:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104f56:	00 
c0104f57:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104f5e:	e8 6f bd ff ff       	call   c0100cd2 <__panic>
c0104f63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f66:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f6b:	39 c2                	cmp    %eax,%edx
c0104f6d:	74 24                	je     c0104f93 <check_boot_pgdir+0x163>
c0104f6f:	c7 44 24 0c b0 6e 10 	movl   $0xc0106eb0,0xc(%esp)
c0104f76:	c0 
c0104f77:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104f7e:	c0 
c0104f7f:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104f86:	00 
c0104f87:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104f8e:	e8 3f bd ff ff       	call   c0100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
c0104f93:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f98:	8b 00                	mov    (%eax),%eax
c0104f9a:	85 c0                	test   %eax,%eax
c0104f9c:	74 24                	je     c0104fc2 <check_boot_pgdir+0x192>
c0104f9e:	c7 44 24 0c e4 6e 10 	movl   $0xc0106ee4,0xc(%esp)
c0104fa5:	c0 
c0104fa6:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0104fad:	c0 
c0104fae:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104fb5:	00 
c0104fb6:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0104fbd:	e8 10 bd ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
c0104fc2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104fc9:	e8 a1 ed ff ff       	call   c0103d6f <alloc_pages>
c0104fce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104fd1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fd6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104fdd:	00 
c0104fde:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104fe5:	00 
c0104fe6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104fe9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fed:	89 04 24             	mov    %eax,(%esp)
c0104ff0:	e8 6c f6 ff ff       	call   c0104661 <page_insert>
c0104ff5:	85 c0                	test   %eax,%eax
c0104ff7:	74 24                	je     c010501d <check_boot_pgdir+0x1ed>
c0104ff9:	c7 44 24 0c f8 6e 10 	movl   $0xc0106ef8,0xc(%esp)
c0105000:	c0 
c0105001:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0105008:	c0 
c0105009:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0105010:	00 
c0105011:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0105018:	e8 b5 bc ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 1);
c010501d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105020:	89 04 24             	mov    %eax,(%esp)
c0105023:	e8 42 eb ff ff       	call   c0103b6a <page_ref>
c0105028:	83 f8 01             	cmp    $0x1,%eax
c010502b:	74 24                	je     c0105051 <check_boot_pgdir+0x221>
c010502d:	c7 44 24 0c 26 6f 10 	movl   $0xc0106f26,0xc(%esp)
c0105034:	c0 
c0105035:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c010503c:	c0 
c010503d:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0105044:	00 
c0105045:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c010504c:	e8 81 bc ff ff       	call   c0100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105051:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105056:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010505d:	00 
c010505e:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105065:	00 
c0105066:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105069:	89 54 24 04          	mov    %edx,0x4(%esp)
c010506d:	89 04 24             	mov    %eax,(%esp)
c0105070:	e8 ec f5 ff ff       	call   c0104661 <page_insert>
c0105075:	85 c0                	test   %eax,%eax
c0105077:	74 24                	je     c010509d <check_boot_pgdir+0x26d>
c0105079:	c7 44 24 0c 38 6f 10 	movl   $0xc0106f38,0xc(%esp)
c0105080:	c0 
c0105081:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0105088:	c0 
c0105089:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0105090:	00 
c0105091:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0105098:	e8 35 bc ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 2);
c010509d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050a0:	89 04 24             	mov    %eax,(%esp)
c01050a3:	e8 c2 ea ff ff       	call   c0103b6a <page_ref>
c01050a8:	83 f8 02             	cmp    $0x2,%eax
c01050ab:	74 24                	je     c01050d1 <check_boot_pgdir+0x2a1>
c01050ad:	c7 44 24 0c 6f 6f 10 	movl   $0xc0106f6f,0xc(%esp)
c01050b4:	c0 
c01050b5:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c01050bc:	c0 
c01050bd:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c01050c4:	00 
c01050c5:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c01050cc:	e8 01 bc ff ff       	call   c0100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
c01050d1:	c7 45 dc 80 6f 10 c0 	movl   $0xc0106f80,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01050d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050df:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01050e6:	e8 19 0a 00 00       	call   c0105b04 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01050eb:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01050f2:	00 
c01050f3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01050fa:	e8 7e 0a 00 00       	call   c0105b7d <strcmp>
c01050ff:	85 c0                	test   %eax,%eax
c0105101:	74 24                	je     c0105127 <check_boot_pgdir+0x2f7>
c0105103:	c7 44 24 0c 98 6f 10 	movl   $0xc0106f98,0xc(%esp)
c010510a:	c0 
c010510b:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0105112:	c0 
c0105113:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c010511a:	00 
c010511b:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0105122:	e8 ab bb ff ff       	call   c0100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105127:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010512a:	89 04 24             	mov    %eax,(%esp)
c010512d:	e8 8e e9 ff ff       	call   c0103ac0 <page2kva>
c0105132:	05 00 01 00 00       	add    $0x100,%eax
c0105137:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010513a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105141:	e8 66 09 00 00       	call   c0105aac <strlen>
c0105146:	85 c0                	test   %eax,%eax
c0105148:	74 24                	je     c010516e <check_boot_pgdir+0x33e>
c010514a:	c7 44 24 0c d0 6f 10 	movl   $0xc0106fd0,0xc(%esp)
c0105151:	c0 
c0105152:	c7 44 24 08 71 6b 10 	movl   $0xc0106b71,0x8(%esp)
c0105159:	c0 
c010515a:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0105161:	00 
c0105162:	c7 04 24 4c 6b 10 c0 	movl   $0xc0106b4c,(%esp)
c0105169:	e8 64 bb ff ff       	call   c0100cd2 <__panic>

    free_page(p);
c010516e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105175:	00 
c0105176:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105179:	89 04 24             	mov    %eax,(%esp)
c010517c:	e8 26 ec ff ff       	call   c0103da7 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105181:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105186:	8b 00                	mov    (%eax),%eax
c0105188:	89 04 24             	mov    %eax,(%esp)
c010518b:	e8 c2 e9 ff ff       	call   c0103b52 <pde2page>
c0105190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105197:	00 
c0105198:	89 04 24             	mov    %eax,(%esp)
c010519b:	e8 07 ec ff ff       	call   c0103da7 <free_pages>
    boot_pgdir[0] = 0;
c01051a0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01051a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01051ab:	c7 04 24 f4 6f 10 c0 	movl   $0xc0106ff4,(%esp)
c01051b2:	e8 91 b1 ff ff       	call   c0100348 <cprintf>
}
c01051b7:	c9                   	leave  
c01051b8:	c3                   	ret    

c01051b9 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01051b9:	55                   	push   %ebp
c01051ba:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01051bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01051bf:	83 e0 04             	and    $0x4,%eax
c01051c2:	85 c0                	test   %eax,%eax
c01051c4:	74 07                	je     c01051cd <perm2str+0x14>
c01051c6:	b8 75 00 00 00       	mov    $0x75,%eax
c01051cb:	eb 05                	jmp    c01051d2 <perm2str+0x19>
c01051cd:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01051d2:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c01051d7:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01051de:	8b 45 08             	mov    0x8(%ebp),%eax
c01051e1:	83 e0 02             	and    $0x2,%eax
c01051e4:	85 c0                	test   %eax,%eax
c01051e6:	74 07                	je     c01051ef <perm2str+0x36>
c01051e8:	b8 77 00 00 00       	mov    $0x77,%eax
c01051ed:	eb 05                	jmp    c01051f4 <perm2str+0x3b>
c01051ef:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01051f4:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c01051f9:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0105200:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0105205:	5d                   	pop    %ebp
c0105206:	c3                   	ret    

c0105207 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105207:	55                   	push   %ebp
c0105208:	89 e5                	mov    %esp,%ebp
c010520a:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010520d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105210:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105213:	72 0a                	jb     c010521f <get_pgtable_items+0x18>
        return 0;
c0105215:	b8 00 00 00 00       	mov    $0x0,%eax
c010521a:	e9 9c 00 00 00       	jmp    c01052bb <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c010521f:	eb 04                	jmp    c0105225 <get_pgtable_items+0x1e>
        start ++;
c0105221:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105225:	8b 45 10             	mov    0x10(%ebp),%eax
c0105228:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010522b:	73 18                	jae    c0105245 <get_pgtable_items+0x3e>
c010522d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105230:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105237:	8b 45 14             	mov    0x14(%ebp),%eax
c010523a:	01 d0                	add    %edx,%eax
c010523c:	8b 00                	mov    (%eax),%eax
c010523e:	83 e0 01             	and    $0x1,%eax
c0105241:	85 c0                	test   %eax,%eax
c0105243:	74 dc                	je     c0105221 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105245:	8b 45 10             	mov    0x10(%ebp),%eax
c0105248:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010524b:	73 69                	jae    c01052b6 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c010524d:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105251:	74 08                	je     c010525b <get_pgtable_items+0x54>
            *left_store = start;
c0105253:	8b 45 18             	mov    0x18(%ebp),%eax
c0105256:	8b 55 10             	mov    0x10(%ebp),%edx
c0105259:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010525b:	8b 45 10             	mov    0x10(%ebp),%eax
c010525e:	8d 50 01             	lea    0x1(%eax),%edx
c0105261:	89 55 10             	mov    %edx,0x10(%ebp)
c0105264:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010526b:	8b 45 14             	mov    0x14(%ebp),%eax
c010526e:	01 d0                	add    %edx,%eax
c0105270:	8b 00                	mov    (%eax),%eax
c0105272:	83 e0 07             	and    $0x7,%eax
c0105275:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105278:	eb 04                	jmp    c010527e <get_pgtable_items+0x77>
            start ++;
c010527a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c010527e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105281:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105284:	73 1d                	jae    c01052a3 <get_pgtable_items+0x9c>
c0105286:	8b 45 10             	mov    0x10(%ebp),%eax
c0105289:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105290:	8b 45 14             	mov    0x14(%ebp),%eax
c0105293:	01 d0                	add    %edx,%eax
c0105295:	8b 00                	mov    (%eax),%eax
c0105297:	83 e0 07             	and    $0x7,%eax
c010529a:	89 c2                	mov    %eax,%edx
c010529c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010529f:	39 c2                	cmp    %eax,%edx
c01052a1:	74 d7                	je     c010527a <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01052a3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01052a7:	74 08                	je     c01052b1 <get_pgtable_items+0xaa>
            *right_store = start;
c01052a9:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01052ac:	8b 55 10             	mov    0x10(%ebp),%edx
c01052af:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01052b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052b4:	eb 05                	jmp    c01052bb <get_pgtable_items+0xb4>
    }
    return 0;
c01052b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052bb:	c9                   	leave  
c01052bc:	c3                   	ret    

c01052bd <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01052bd:	55                   	push   %ebp
c01052be:	89 e5                	mov    %esp,%ebp
c01052c0:	57                   	push   %edi
c01052c1:	56                   	push   %esi
c01052c2:	53                   	push   %ebx
c01052c3:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01052c6:	c7 04 24 14 70 10 c0 	movl   $0xc0107014,(%esp)
c01052cd:	e8 76 b0 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c01052d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01052d9:	e9 fa 00 00 00       	jmp    c01053d8 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01052de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01052e1:	89 04 24             	mov    %eax,(%esp)
c01052e4:	e8 d0 fe ff ff       	call   c01051b9 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01052e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01052ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01052ef:	29 d1                	sub    %edx,%ecx
c01052f1:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01052f3:	89 d6                	mov    %edx,%esi
c01052f5:	c1 e6 16             	shl    $0x16,%esi
c01052f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052fb:	89 d3                	mov    %edx,%ebx
c01052fd:	c1 e3 16             	shl    $0x16,%ebx
c0105300:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105303:	89 d1                	mov    %edx,%ecx
c0105305:	c1 e1 16             	shl    $0x16,%ecx
c0105308:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010530b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010530e:	29 d7                	sub    %edx,%edi
c0105310:	89 fa                	mov    %edi,%edx
c0105312:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105316:	89 74 24 10          	mov    %esi,0x10(%esp)
c010531a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010531e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105322:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105326:	c7 04 24 45 70 10 c0 	movl   $0xc0107045,(%esp)
c010532d:	e8 16 b0 ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105332:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105335:	c1 e0 0a             	shl    $0xa,%eax
c0105338:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010533b:	eb 54                	jmp    c0105391 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010533d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105340:	89 04 24             	mov    %eax,(%esp)
c0105343:	e8 71 fe ff ff       	call   c01051b9 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105348:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010534b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010534e:	29 d1                	sub    %edx,%ecx
c0105350:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105352:	89 d6                	mov    %edx,%esi
c0105354:	c1 e6 0c             	shl    $0xc,%esi
c0105357:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010535a:	89 d3                	mov    %edx,%ebx
c010535c:	c1 e3 0c             	shl    $0xc,%ebx
c010535f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105362:	c1 e2 0c             	shl    $0xc,%edx
c0105365:	89 d1                	mov    %edx,%ecx
c0105367:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010536a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010536d:	29 d7                	sub    %edx,%edi
c010536f:	89 fa                	mov    %edi,%edx
c0105371:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105375:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010537d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105381:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105385:	c7 04 24 64 70 10 c0 	movl   $0xc0107064,(%esp)
c010538c:	e8 b7 af ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105391:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105396:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105399:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010539c:	89 ce                	mov    %ecx,%esi
c010539e:	c1 e6 0a             	shl    $0xa,%esi
c01053a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01053a4:	89 cb                	mov    %ecx,%ebx
c01053a6:	c1 e3 0a             	shl    $0xa,%ebx
c01053a9:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01053ac:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01053b0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01053b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01053b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01053bb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053bf:	89 74 24 04          	mov    %esi,0x4(%esp)
c01053c3:	89 1c 24             	mov    %ebx,(%esp)
c01053c6:	e8 3c fe ff ff       	call   c0105207 <get_pgtable_items>
c01053cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01053ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01053d2:	0f 85 65 ff ff ff    	jne    c010533d <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01053d8:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c01053dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053e0:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c01053e3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01053e7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c01053ea:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01053ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01053f2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053f6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01053fd:	00 
c01053fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105405:	e8 fd fd ff ff       	call   c0105207 <get_pgtable_items>
c010540a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010540d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105411:	0f 85 c7 fe ff ff    	jne    c01052de <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105417:	c7 04 24 88 70 10 c0 	movl   $0xc0107088,(%esp)
c010541e:	e8 25 af ff ff       	call   c0100348 <cprintf>
}
c0105423:	83 c4 4c             	add    $0x4c,%esp
c0105426:	5b                   	pop    %ebx
c0105427:	5e                   	pop    %esi
c0105428:	5f                   	pop    %edi
c0105429:	5d                   	pop    %ebp
c010542a:	c3                   	ret    

c010542b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010542b:	55                   	push   %ebp
c010542c:	89 e5                	mov    %esp,%ebp
c010542e:	83 ec 58             	sub    $0x58,%esp
c0105431:	8b 45 10             	mov    0x10(%ebp),%eax
c0105434:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105437:	8b 45 14             	mov    0x14(%ebp),%eax
c010543a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010543d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105440:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105443:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105446:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105449:	8b 45 18             	mov    0x18(%ebp),%eax
c010544c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010544f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105452:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105455:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105458:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010545b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010545e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105461:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105465:	74 1c                	je     c0105483 <printnum+0x58>
c0105467:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010546a:	ba 00 00 00 00       	mov    $0x0,%edx
c010546f:	f7 75 e4             	divl   -0x1c(%ebp)
c0105472:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105475:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105478:	ba 00 00 00 00       	mov    $0x0,%edx
c010547d:	f7 75 e4             	divl   -0x1c(%ebp)
c0105480:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105483:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105486:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105489:	f7 75 e4             	divl   -0x1c(%ebp)
c010548c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010548f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105492:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105495:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105498:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010549b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010549e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054a1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01054a4:	8b 45 18             	mov    0x18(%ebp),%eax
c01054a7:	ba 00 00 00 00       	mov    $0x0,%edx
c01054ac:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054af:	77 56                	ja     c0105507 <printnum+0xdc>
c01054b1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054b4:	72 05                	jb     c01054bb <printnum+0x90>
c01054b6:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01054b9:	77 4c                	ja     c0105507 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01054bb:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01054be:	8d 50 ff             	lea    -0x1(%eax),%edx
c01054c1:	8b 45 20             	mov    0x20(%ebp),%eax
c01054c4:	89 44 24 18          	mov    %eax,0x18(%esp)
c01054c8:	89 54 24 14          	mov    %edx,0x14(%esp)
c01054cc:	8b 45 18             	mov    0x18(%ebp),%eax
c01054cf:	89 44 24 10          	mov    %eax,0x10(%esp)
c01054d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054d9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01054dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01054e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01054eb:	89 04 24             	mov    %eax,(%esp)
c01054ee:	e8 38 ff ff ff       	call   c010542b <printnum>
c01054f3:	eb 1c                	jmp    c0105511 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01054f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054fc:	8b 45 20             	mov    0x20(%ebp),%eax
c01054ff:	89 04 24             	mov    %eax,(%esp)
c0105502:	8b 45 08             	mov    0x8(%ebp),%eax
c0105505:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105507:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010550b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010550f:	7f e4                	jg     c01054f5 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105511:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105514:	05 3c 71 10 c0       	add    $0xc010713c,%eax
c0105519:	0f b6 00             	movzbl (%eax),%eax
c010551c:	0f be c0             	movsbl %al,%eax
c010551f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105522:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105526:	89 04 24             	mov    %eax,(%esp)
c0105529:	8b 45 08             	mov    0x8(%ebp),%eax
c010552c:	ff d0                	call   *%eax
}
c010552e:	c9                   	leave  
c010552f:	c3                   	ret    

c0105530 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105530:	55                   	push   %ebp
c0105531:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105533:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105537:	7e 14                	jle    c010554d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105539:	8b 45 08             	mov    0x8(%ebp),%eax
c010553c:	8b 00                	mov    (%eax),%eax
c010553e:	8d 48 08             	lea    0x8(%eax),%ecx
c0105541:	8b 55 08             	mov    0x8(%ebp),%edx
c0105544:	89 0a                	mov    %ecx,(%edx)
c0105546:	8b 50 04             	mov    0x4(%eax),%edx
c0105549:	8b 00                	mov    (%eax),%eax
c010554b:	eb 30                	jmp    c010557d <getuint+0x4d>
    }
    else if (lflag) {
c010554d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105551:	74 16                	je     c0105569 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105553:	8b 45 08             	mov    0x8(%ebp),%eax
c0105556:	8b 00                	mov    (%eax),%eax
c0105558:	8d 48 04             	lea    0x4(%eax),%ecx
c010555b:	8b 55 08             	mov    0x8(%ebp),%edx
c010555e:	89 0a                	mov    %ecx,(%edx)
c0105560:	8b 00                	mov    (%eax),%eax
c0105562:	ba 00 00 00 00       	mov    $0x0,%edx
c0105567:	eb 14                	jmp    c010557d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105569:	8b 45 08             	mov    0x8(%ebp),%eax
c010556c:	8b 00                	mov    (%eax),%eax
c010556e:	8d 48 04             	lea    0x4(%eax),%ecx
c0105571:	8b 55 08             	mov    0x8(%ebp),%edx
c0105574:	89 0a                	mov    %ecx,(%edx)
c0105576:	8b 00                	mov    (%eax),%eax
c0105578:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010557d:	5d                   	pop    %ebp
c010557e:	c3                   	ret    

c010557f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010557f:	55                   	push   %ebp
c0105580:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105582:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105586:	7e 14                	jle    c010559c <getint+0x1d>
        return va_arg(*ap, long long);
c0105588:	8b 45 08             	mov    0x8(%ebp),%eax
c010558b:	8b 00                	mov    (%eax),%eax
c010558d:	8d 48 08             	lea    0x8(%eax),%ecx
c0105590:	8b 55 08             	mov    0x8(%ebp),%edx
c0105593:	89 0a                	mov    %ecx,(%edx)
c0105595:	8b 50 04             	mov    0x4(%eax),%edx
c0105598:	8b 00                	mov    (%eax),%eax
c010559a:	eb 28                	jmp    c01055c4 <getint+0x45>
    }
    else if (lflag) {
c010559c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055a0:	74 12                	je     c01055b4 <getint+0x35>
        return va_arg(*ap, long);
c01055a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01055a5:	8b 00                	mov    (%eax),%eax
c01055a7:	8d 48 04             	lea    0x4(%eax),%ecx
c01055aa:	8b 55 08             	mov    0x8(%ebp),%edx
c01055ad:	89 0a                	mov    %ecx,(%edx)
c01055af:	8b 00                	mov    (%eax),%eax
c01055b1:	99                   	cltd   
c01055b2:	eb 10                	jmp    c01055c4 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01055b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b7:	8b 00                	mov    (%eax),%eax
c01055b9:	8d 48 04             	lea    0x4(%eax),%ecx
c01055bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01055bf:	89 0a                	mov    %ecx,(%edx)
c01055c1:	8b 00                	mov    (%eax),%eax
c01055c3:	99                   	cltd   
    }
}
c01055c4:	5d                   	pop    %ebp
c01055c5:	c3                   	ret    

c01055c6 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01055c6:	55                   	push   %ebp
c01055c7:	89 e5                	mov    %esp,%ebp
c01055c9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01055cc:	8d 45 14             	lea    0x14(%ebp),%eax
c01055cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01055d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055d9:	8b 45 10             	mov    0x10(%ebp),%eax
c01055dc:	89 44 24 08          	mov    %eax,0x8(%esp)
c01055e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ea:	89 04 24             	mov    %eax,(%esp)
c01055ed:	e8 02 00 00 00       	call   c01055f4 <vprintfmt>
    va_end(ap);
}
c01055f2:	c9                   	leave  
c01055f3:	c3                   	ret    

c01055f4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01055f4:	55                   	push   %ebp
c01055f5:	89 e5                	mov    %esp,%ebp
c01055f7:	56                   	push   %esi
c01055f8:	53                   	push   %ebx
c01055f9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01055fc:	eb 18                	jmp    c0105616 <vprintfmt+0x22>
            if (ch == '\0') {
c01055fe:	85 db                	test   %ebx,%ebx
c0105600:	75 05                	jne    c0105607 <vprintfmt+0x13>
                return;
c0105602:	e9 d1 03 00 00       	jmp    c01059d8 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105607:	8b 45 0c             	mov    0xc(%ebp),%eax
c010560a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010560e:	89 1c 24             	mov    %ebx,(%esp)
c0105611:	8b 45 08             	mov    0x8(%ebp),%eax
c0105614:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105616:	8b 45 10             	mov    0x10(%ebp),%eax
c0105619:	8d 50 01             	lea    0x1(%eax),%edx
c010561c:	89 55 10             	mov    %edx,0x10(%ebp)
c010561f:	0f b6 00             	movzbl (%eax),%eax
c0105622:	0f b6 d8             	movzbl %al,%ebx
c0105625:	83 fb 25             	cmp    $0x25,%ebx
c0105628:	75 d4                	jne    c01055fe <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010562a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010562e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105638:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010563b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105642:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105645:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105648:	8b 45 10             	mov    0x10(%ebp),%eax
c010564b:	8d 50 01             	lea    0x1(%eax),%edx
c010564e:	89 55 10             	mov    %edx,0x10(%ebp)
c0105651:	0f b6 00             	movzbl (%eax),%eax
c0105654:	0f b6 d8             	movzbl %al,%ebx
c0105657:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010565a:	83 f8 55             	cmp    $0x55,%eax
c010565d:	0f 87 44 03 00 00    	ja     c01059a7 <vprintfmt+0x3b3>
c0105663:	8b 04 85 60 71 10 c0 	mov    -0x3fef8ea0(,%eax,4),%eax
c010566a:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010566c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105670:	eb d6                	jmp    c0105648 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105672:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105676:	eb d0                	jmp    c0105648 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105678:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010567f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105682:	89 d0                	mov    %edx,%eax
c0105684:	c1 e0 02             	shl    $0x2,%eax
c0105687:	01 d0                	add    %edx,%eax
c0105689:	01 c0                	add    %eax,%eax
c010568b:	01 d8                	add    %ebx,%eax
c010568d:	83 e8 30             	sub    $0x30,%eax
c0105690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105693:	8b 45 10             	mov    0x10(%ebp),%eax
c0105696:	0f b6 00             	movzbl (%eax),%eax
c0105699:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010569c:	83 fb 2f             	cmp    $0x2f,%ebx
c010569f:	7e 0b                	jle    c01056ac <vprintfmt+0xb8>
c01056a1:	83 fb 39             	cmp    $0x39,%ebx
c01056a4:	7f 06                	jg     c01056ac <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01056a6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01056aa:	eb d3                	jmp    c010567f <vprintfmt+0x8b>
            goto process_precision;
c01056ac:	eb 33                	jmp    c01056e1 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01056ae:	8b 45 14             	mov    0x14(%ebp),%eax
c01056b1:	8d 50 04             	lea    0x4(%eax),%edx
c01056b4:	89 55 14             	mov    %edx,0x14(%ebp)
c01056b7:	8b 00                	mov    (%eax),%eax
c01056b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01056bc:	eb 23                	jmp    c01056e1 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01056be:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056c2:	79 0c                	jns    c01056d0 <vprintfmt+0xdc>
                width = 0;
c01056c4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01056cb:	e9 78 ff ff ff       	jmp    c0105648 <vprintfmt+0x54>
c01056d0:	e9 73 ff ff ff       	jmp    c0105648 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01056d5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01056dc:	e9 67 ff ff ff       	jmp    c0105648 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01056e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056e5:	79 12                	jns    c01056f9 <vprintfmt+0x105>
                width = precision, precision = -1;
c01056e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056ed:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01056f4:	e9 4f ff ff ff       	jmp    c0105648 <vprintfmt+0x54>
c01056f9:	e9 4a ff ff ff       	jmp    c0105648 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01056fe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105702:	e9 41 ff ff ff       	jmp    c0105648 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105707:	8b 45 14             	mov    0x14(%ebp),%eax
c010570a:	8d 50 04             	lea    0x4(%eax),%edx
c010570d:	89 55 14             	mov    %edx,0x14(%ebp)
c0105710:	8b 00                	mov    (%eax),%eax
c0105712:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105715:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105719:	89 04 24             	mov    %eax,(%esp)
c010571c:	8b 45 08             	mov    0x8(%ebp),%eax
c010571f:	ff d0                	call   *%eax
            break;
c0105721:	e9 ac 02 00 00       	jmp    c01059d2 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105726:	8b 45 14             	mov    0x14(%ebp),%eax
c0105729:	8d 50 04             	lea    0x4(%eax),%edx
c010572c:	89 55 14             	mov    %edx,0x14(%ebp)
c010572f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105731:	85 db                	test   %ebx,%ebx
c0105733:	79 02                	jns    c0105737 <vprintfmt+0x143>
                err = -err;
c0105735:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105737:	83 fb 06             	cmp    $0x6,%ebx
c010573a:	7f 0b                	jg     c0105747 <vprintfmt+0x153>
c010573c:	8b 34 9d 20 71 10 c0 	mov    -0x3fef8ee0(,%ebx,4),%esi
c0105743:	85 f6                	test   %esi,%esi
c0105745:	75 23                	jne    c010576a <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0105747:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010574b:	c7 44 24 08 4d 71 10 	movl   $0xc010714d,0x8(%esp)
c0105752:	c0 
c0105753:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105756:	89 44 24 04          	mov    %eax,0x4(%esp)
c010575a:	8b 45 08             	mov    0x8(%ebp),%eax
c010575d:	89 04 24             	mov    %eax,(%esp)
c0105760:	e8 61 fe ff ff       	call   c01055c6 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105765:	e9 68 02 00 00       	jmp    c01059d2 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010576a:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010576e:	c7 44 24 08 56 71 10 	movl   $0xc0107156,0x8(%esp)
c0105775:	c0 
c0105776:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105779:	89 44 24 04          	mov    %eax,0x4(%esp)
c010577d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105780:	89 04 24             	mov    %eax,(%esp)
c0105783:	e8 3e fe ff ff       	call   c01055c6 <printfmt>
            }
            break;
c0105788:	e9 45 02 00 00       	jmp    c01059d2 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010578d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105790:	8d 50 04             	lea    0x4(%eax),%edx
c0105793:	89 55 14             	mov    %edx,0x14(%ebp)
c0105796:	8b 30                	mov    (%eax),%esi
c0105798:	85 f6                	test   %esi,%esi
c010579a:	75 05                	jne    c01057a1 <vprintfmt+0x1ad>
                p = "(null)";
c010579c:	be 59 71 10 c0       	mov    $0xc0107159,%esi
            }
            if (width > 0 && padc != '-') {
c01057a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057a5:	7e 3e                	jle    c01057e5 <vprintfmt+0x1f1>
c01057a7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01057ab:	74 38                	je     c01057e5 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057ad:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01057b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057b7:	89 34 24             	mov    %esi,(%esp)
c01057ba:	e8 15 03 00 00       	call   c0105ad4 <strnlen>
c01057bf:	29 c3                	sub    %eax,%ebx
c01057c1:	89 d8                	mov    %ebx,%eax
c01057c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057c6:	eb 17                	jmp    c01057df <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01057c8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01057cc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057d3:	89 04 24             	mov    %eax,(%esp)
c01057d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d9:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057db:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01057df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057e3:	7f e3                	jg     c01057c8 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01057e5:	eb 38                	jmp    c010581f <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c01057e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01057eb:	74 1f                	je     c010580c <vprintfmt+0x218>
c01057ed:	83 fb 1f             	cmp    $0x1f,%ebx
c01057f0:	7e 05                	jle    c01057f7 <vprintfmt+0x203>
c01057f2:	83 fb 7e             	cmp    $0x7e,%ebx
c01057f5:	7e 15                	jle    c010580c <vprintfmt+0x218>
                    putch('?', putdat);
c01057f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057fe:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105805:	8b 45 08             	mov    0x8(%ebp),%eax
c0105808:	ff d0                	call   *%eax
c010580a:	eb 0f                	jmp    c010581b <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010580c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010580f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105813:	89 1c 24             	mov    %ebx,(%esp)
c0105816:	8b 45 08             	mov    0x8(%ebp),%eax
c0105819:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010581b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010581f:	89 f0                	mov    %esi,%eax
c0105821:	8d 70 01             	lea    0x1(%eax),%esi
c0105824:	0f b6 00             	movzbl (%eax),%eax
c0105827:	0f be d8             	movsbl %al,%ebx
c010582a:	85 db                	test   %ebx,%ebx
c010582c:	74 10                	je     c010583e <vprintfmt+0x24a>
c010582e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105832:	78 b3                	js     c01057e7 <vprintfmt+0x1f3>
c0105834:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105838:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010583c:	79 a9                	jns    c01057e7 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010583e:	eb 17                	jmp    c0105857 <vprintfmt+0x263>
                putch(' ', putdat);
c0105840:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105843:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105847:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010584e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105851:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105853:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105857:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010585b:	7f e3                	jg     c0105840 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010585d:	e9 70 01 00 00       	jmp    c01059d2 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105862:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105865:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105869:	8d 45 14             	lea    0x14(%ebp),%eax
c010586c:	89 04 24             	mov    %eax,(%esp)
c010586f:	e8 0b fd ff ff       	call   c010557f <getint>
c0105874:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105877:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010587d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105880:	85 d2                	test   %edx,%edx
c0105882:	79 26                	jns    c01058aa <vprintfmt+0x2b6>
                putch('-', putdat);
c0105884:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105887:	89 44 24 04          	mov    %eax,0x4(%esp)
c010588b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105892:	8b 45 08             	mov    0x8(%ebp),%eax
c0105895:	ff d0                	call   *%eax
                num = -(long long)num;
c0105897:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010589a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010589d:	f7 d8                	neg    %eax
c010589f:	83 d2 00             	adc    $0x0,%edx
c01058a2:	f7 da                	neg    %edx
c01058a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01058aa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058b1:	e9 a8 00 00 00       	jmp    c010595e <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01058b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058bd:	8d 45 14             	lea    0x14(%ebp),%eax
c01058c0:	89 04 24             	mov    %eax,(%esp)
c01058c3:	e8 68 fc ff ff       	call   c0105530 <getuint>
c01058c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01058ce:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058d5:	e9 84 00 00 00       	jmp    c010595e <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01058da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e1:	8d 45 14             	lea    0x14(%ebp),%eax
c01058e4:	89 04 24             	mov    %eax,(%esp)
c01058e7:	e8 44 fc ff ff       	call   c0105530 <getuint>
c01058ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01058f2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01058f9:	eb 63                	jmp    c010595e <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c01058fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105902:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105909:	8b 45 08             	mov    0x8(%ebp),%eax
c010590c:	ff d0                	call   *%eax
            putch('x', putdat);
c010590e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105911:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105915:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010591c:	8b 45 08             	mov    0x8(%ebp),%eax
c010591f:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105921:	8b 45 14             	mov    0x14(%ebp),%eax
c0105924:	8d 50 04             	lea    0x4(%eax),%edx
c0105927:	89 55 14             	mov    %edx,0x14(%ebp)
c010592a:	8b 00                	mov    (%eax),%eax
c010592c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010592f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105936:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010593d:	eb 1f                	jmp    c010595e <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010593f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105942:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105946:	8d 45 14             	lea    0x14(%ebp),%eax
c0105949:	89 04 24             	mov    %eax,(%esp)
c010594c:	e8 df fb ff ff       	call   c0105530 <getuint>
c0105951:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105954:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105957:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010595e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105962:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105965:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105969:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010596c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105970:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105974:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105977:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010597a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010597e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105982:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105985:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105989:	8b 45 08             	mov    0x8(%ebp),%eax
c010598c:	89 04 24             	mov    %eax,(%esp)
c010598f:	e8 97 fa ff ff       	call   c010542b <printnum>
            break;
c0105994:	eb 3c                	jmp    c01059d2 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105996:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105999:	89 44 24 04          	mov    %eax,0x4(%esp)
c010599d:	89 1c 24             	mov    %ebx,(%esp)
c01059a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a3:	ff d0                	call   *%eax
            break;
c01059a5:	eb 2b                	jmp    c01059d2 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01059b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b8:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01059ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01059be:	eb 04                	jmp    c01059c4 <vprintfmt+0x3d0>
c01059c0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01059c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01059c7:	83 e8 01             	sub    $0x1,%eax
c01059ca:	0f b6 00             	movzbl (%eax),%eax
c01059cd:	3c 25                	cmp    $0x25,%al
c01059cf:	75 ef                	jne    c01059c0 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c01059d1:	90                   	nop
        }
    }
c01059d2:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01059d3:	e9 3e fc ff ff       	jmp    c0105616 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01059d8:	83 c4 40             	add    $0x40,%esp
c01059db:	5b                   	pop    %ebx
c01059dc:	5e                   	pop    %esi
c01059dd:	5d                   	pop    %ebp
c01059de:	c3                   	ret    

c01059df <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01059df:	55                   	push   %ebp
c01059e0:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01059e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e5:	8b 40 08             	mov    0x8(%eax),%eax
c01059e8:	8d 50 01             	lea    0x1(%eax),%edx
c01059eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ee:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059f4:	8b 10                	mov    (%eax),%edx
c01059f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059f9:	8b 40 04             	mov    0x4(%eax),%eax
c01059fc:	39 c2                	cmp    %eax,%edx
c01059fe:	73 12                	jae    c0105a12 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105a00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a03:	8b 00                	mov    (%eax),%eax
c0105a05:	8d 48 01             	lea    0x1(%eax),%ecx
c0105a08:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a0b:	89 0a                	mov    %ecx,(%edx)
c0105a0d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a10:	88 10                	mov    %dl,(%eax)
    }
}
c0105a12:	5d                   	pop    %ebp
c0105a13:	c3                   	ret    

c0105a14 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105a14:	55                   	push   %ebp
c0105a15:	89 e5                	mov    %esp,%ebp
c0105a17:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105a1a:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a23:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a27:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a38:	89 04 24             	mov    %eax,(%esp)
c0105a3b:	e8 08 00 00 00       	call   c0105a48 <vsnprintf>
c0105a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a46:	c9                   	leave  
c0105a47:	c3                   	ret    

c0105a48 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105a48:	55                   	push   %ebp
c0105a49:	89 e5                	mov    %esp,%ebp
c0105a4b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105a4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a57:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5d:	01 d0                	add    %edx,%eax
c0105a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105a69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a6d:	74 0a                	je     c0105a79 <vsnprintf+0x31>
c0105a6f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a75:	39 c2                	cmp    %eax,%edx
c0105a77:	76 07                	jbe    c0105a80 <vsnprintf+0x38>
        return -E_INVAL;
c0105a79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105a7e:	eb 2a                	jmp    c0105aaa <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105a80:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a87:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105a91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a95:	c7 04 24 df 59 10 c0 	movl   $0xc01059df,(%esp)
c0105a9c:	e8 53 fb ff ff       	call   c01055f4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105aa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105aa4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105aaa:	c9                   	leave  
c0105aab:	c3                   	ret    

c0105aac <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105aac:	55                   	push   %ebp
c0105aad:	89 e5                	mov    %esp,%ebp
c0105aaf:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105ab2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105ab9:	eb 04                	jmp    c0105abf <strlen+0x13>
        cnt ++;
c0105abb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ac2:	8d 50 01             	lea    0x1(%eax),%edx
c0105ac5:	89 55 08             	mov    %edx,0x8(%ebp)
c0105ac8:	0f b6 00             	movzbl (%eax),%eax
c0105acb:	84 c0                	test   %al,%al
c0105acd:	75 ec                	jne    c0105abb <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105acf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105ad2:	c9                   	leave  
c0105ad3:	c3                   	ret    

c0105ad4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105ad4:	55                   	push   %ebp
c0105ad5:	89 e5                	mov    %esp,%ebp
c0105ad7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105ada:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105ae1:	eb 04                	jmp    c0105ae7 <strnlen+0x13>
        cnt ++;
c0105ae3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105ae7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105aea:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105aed:	73 10                	jae    c0105aff <strnlen+0x2b>
c0105aef:	8b 45 08             	mov    0x8(%ebp),%eax
c0105af2:	8d 50 01             	lea    0x1(%eax),%edx
c0105af5:	89 55 08             	mov    %edx,0x8(%ebp)
c0105af8:	0f b6 00             	movzbl (%eax),%eax
c0105afb:	84 c0                	test   %al,%al
c0105afd:	75 e4                	jne    c0105ae3 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105aff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b02:	c9                   	leave  
c0105b03:	c3                   	ret    

c0105b04 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105b04:	55                   	push   %ebp
c0105b05:	89 e5                	mov    %esp,%ebp
c0105b07:	57                   	push   %edi
c0105b08:	56                   	push   %esi
c0105b09:	83 ec 20             	sub    $0x20,%esp
c0105b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105b18:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b1e:	89 d1                	mov    %edx,%ecx
c0105b20:	89 c2                	mov    %eax,%edx
c0105b22:	89 ce                	mov    %ecx,%esi
c0105b24:	89 d7                	mov    %edx,%edi
c0105b26:	ac                   	lods   %ds:(%esi),%al
c0105b27:	aa                   	stos   %al,%es:(%edi)
c0105b28:	84 c0                	test   %al,%al
c0105b2a:	75 fa                	jne    c0105b26 <strcpy+0x22>
c0105b2c:	89 fa                	mov    %edi,%edx
c0105b2e:	89 f1                	mov    %esi,%ecx
c0105b30:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105b33:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105b36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105b3c:	83 c4 20             	add    $0x20,%esp
c0105b3f:	5e                   	pop    %esi
c0105b40:	5f                   	pop    %edi
c0105b41:	5d                   	pop    %ebp
c0105b42:	c3                   	ret    

c0105b43 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105b43:	55                   	push   %ebp
c0105b44:	89 e5                	mov    %esp,%ebp
c0105b46:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105b49:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105b4f:	eb 21                	jmp    c0105b72 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105b51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b54:	0f b6 10             	movzbl (%eax),%edx
c0105b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b5a:	88 10                	mov    %dl,(%eax)
c0105b5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b5f:	0f b6 00             	movzbl (%eax),%eax
c0105b62:	84 c0                	test   %al,%al
c0105b64:	74 04                	je     c0105b6a <strncpy+0x27>
            src ++;
c0105b66:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105b6a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105b6e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105b72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b76:	75 d9                	jne    c0105b51 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105b78:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105b7b:	c9                   	leave  
c0105b7c:	c3                   	ret    

c0105b7d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105b7d:	55                   	push   %ebp
c0105b7e:	89 e5                	mov    %esp,%ebp
c0105b80:	57                   	push   %edi
c0105b81:	56                   	push   %esi
c0105b82:	83 ec 20             	sub    $0x20,%esp
c0105b85:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b97:	89 d1                	mov    %edx,%ecx
c0105b99:	89 c2                	mov    %eax,%edx
c0105b9b:	89 ce                	mov    %ecx,%esi
c0105b9d:	89 d7                	mov    %edx,%edi
c0105b9f:	ac                   	lods   %ds:(%esi),%al
c0105ba0:	ae                   	scas   %es:(%edi),%al
c0105ba1:	75 08                	jne    c0105bab <strcmp+0x2e>
c0105ba3:	84 c0                	test   %al,%al
c0105ba5:	75 f8                	jne    c0105b9f <strcmp+0x22>
c0105ba7:	31 c0                	xor    %eax,%eax
c0105ba9:	eb 04                	jmp    c0105baf <strcmp+0x32>
c0105bab:	19 c0                	sbb    %eax,%eax
c0105bad:	0c 01                	or     $0x1,%al
c0105baf:	89 fa                	mov    %edi,%edx
c0105bb1:	89 f1                	mov    %esi,%ecx
c0105bb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105bb6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105bb9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105bbf:	83 c4 20             	add    $0x20,%esp
c0105bc2:	5e                   	pop    %esi
c0105bc3:	5f                   	pop    %edi
c0105bc4:	5d                   	pop    %ebp
c0105bc5:	c3                   	ret    

c0105bc6 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105bc6:	55                   	push   %ebp
c0105bc7:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105bc9:	eb 0c                	jmp    c0105bd7 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105bcb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105bcf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105bd3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105bd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105bdb:	74 1a                	je     c0105bf7 <strncmp+0x31>
c0105bdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be0:	0f b6 00             	movzbl (%eax),%eax
c0105be3:	84 c0                	test   %al,%al
c0105be5:	74 10                	je     c0105bf7 <strncmp+0x31>
c0105be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bea:	0f b6 10             	movzbl (%eax),%edx
c0105bed:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bf0:	0f b6 00             	movzbl (%eax),%eax
c0105bf3:	38 c2                	cmp    %al,%dl
c0105bf5:	74 d4                	je     c0105bcb <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105bf7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105bfb:	74 18                	je     c0105c15 <strncmp+0x4f>
c0105bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c00:	0f b6 00             	movzbl (%eax),%eax
c0105c03:	0f b6 d0             	movzbl %al,%edx
c0105c06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c09:	0f b6 00             	movzbl (%eax),%eax
c0105c0c:	0f b6 c0             	movzbl %al,%eax
c0105c0f:	29 c2                	sub    %eax,%edx
c0105c11:	89 d0                	mov    %edx,%eax
c0105c13:	eb 05                	jmp    c0105c1a <strncmp+0x54>
c0105c15:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c1a:	5d                   	pop    %ebp
c0105c1b:	c3                   	ret    

c0105c1c <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105c1c:	55                   	push   %ebp
c0105c1d:	89 e5                	mov    %esp,%ebp
c0105c1f:	83 ec 04             	sub    $0x4,%esp
c0105c22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c25:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c28:	eb 14                	jmp    c0105c3e <strchr+0x22>
        if (*s == c) {
c0105c2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2d:	0f b6 00             	movzbl (%eax),%eax
c0105c30:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105c33:	75 05                	jne    c0105c3a <strchr+0x1e>
            return (char *)s;
c0105c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c38:	eb 13                	jmp    c0105c4d <strchr+0x31>
        }
        s ++;
c0105c3a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c41:	0f b6 00             	movzbl (%eax),%eax
c0105c44:	84 c0                	test   %al,%al
c0105c46:	75 e2                	jne    c0105c2a <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105c48:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c4d:	c9                   	leave  
c0105c4e:	c3                   	ret    

c0105c4f <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105c4f:	55                   	push   %ebp
c0105c50:	89 e5                	mov    %esp,%ebp
c0105c52:	83 ec 04             	sub    $0x4,%esp
c0105c55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c58:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c5b:	eb 11                	jmp    c0105c6e <strfind+0x1f>
        if (*s == c) {
c0105c5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c60:	0f b6 00             	movzbl (%eax),%eax
c0105c63:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105c66:	75 02                	jne    c0105c6a <strfind+0x1b>
            break;
c0105c68:	eb 0e                	jmp    c0105c78 <strfind+0x29>
        }
        s ++;
c0105c6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105c6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c71:	0f b6 00             	movzbl (%eax),%eax
c0105c74:	84 c0                	test   %al,%al
c0105c76:	75 e5                	jne    c0105c5d <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105c78:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105c7b:	c9                   	leave  
c0105c7c:	c3                   	ret    

c0105c7d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105c7d:	55                   	push   %ebp
c0105c7e:	89 e5                	mov    %esp,%ebp
c0105c80:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105c83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105c8a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105c91:	eb 04                	jmp    c0105c97 <strtol+0x1a>
        s ++;
c0105c93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105c97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9a:	0f b6 00             	movzbl (%eax),%eax
c0105c9d:	3c 20                	cmp    $0x20,%al
c0105c9f:	74 f2                	je     c0105c93 <strtol+0x16>
c0105ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca4:	0f b6 00             	movzbl (%eax),%eax
c0105ca7:	3c 09                	cmp    $0x9,%al
c0105ca9:	74 e8                	je     c0105c93 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105cab:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cae:	0f b6 00             	movzbl (%eax),%eax
c0105cb1:	3c 2b                	cmp    $0x2b,%al
c0105cb3:	75 06                	jne    c0105cbb <strtol+0x3e>
        s ++;
c0105cb5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105cb9:	eb 15                	jmp    c0105cd0 <strtol+0x53>
    }
    else if (*s == '-') {
c0105cbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cbe:	0f b6 00             	movzbl (%eax),%eax
c0105cc1:	3c 2d                	cmp    $0x2d,%al
c0105cc3:	75 0b                	jne    c0105cd0 <strtol+0x53>
        s ++, neg = 1;
c0105cc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105cc9:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105cd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105cd4:	74 06                	je     c0105cdc <strtol+0x5f>
c0105cd6:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105cda:	75 24                	jne    c0105d00 <strtol+0x83>
c0105cdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cdf:	0f b6 00             	movzbl (%eax),%eax
c0105ce2:	3c 30                	cmp    $0x30,%al
c0105ce4:	75 1a                	jne    c0105d00 <strtol+0x83>
c0105ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce9:	83 c0 01             	add    $0x1,%eax
c0105cec:	0f b6 00             	movzbl (%eax),%eax
c0105cef:	3c 78                	cmp    $0x78,%al
c0105cf1:	75 0d                	jne    c0105d00 <strtol+0x83>
        s += 2, base = 16;
c0105cf3:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105cf7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105cfe:	eb 2a                	jmp    c0105d2a <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105d00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d04:	75 17                	jne    c0105d1d <strtol+0xa0>
c0105d06:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d09:	0f b6 00             	movzbl (%eax),%eax
c0105d0c:	3c 30                	cmp    $0x30,%al
c0105d0e:	75 0d                	jne    c0105d1d <strtol+0xa0>
        s ++, base = 8;
c0105d10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d14:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105d1b:	eb 0d                	jmp    c0105d2a <strtol+0xad>
    }
    else if (base == 0) {
c0105d1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d21:	75 07                	jne    c0105d2a <strtol+0xad>
        base = 10;
c0105d23:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105d2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2d:	0f b6 00             	movzbl (%eax),%eax
c0105d30:	3c 2f                	cmp    $0x2f,%al
c0105d32:	7e 1b                	jle    c0105d4f <strtol+0xd2>
c0105d34:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d37:	0f b6 00             	movzbl (%eax),%eax
c0105d3a:	3c 39                	cmp    $0x39,%al
c0105d3c:	7f 11                	jg     c0105d4f <strtol+0xd2>
            dig = *s - '0';
c0105d3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d41:	0f b6 00             	movzbl (%eax),%eax
c0105d44:	0f be c0             	movsbl %al,%eax
c0105d47:	83 e8 30             	sub    $0x30,%eax
c0105d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d4d:	eb 48                	jmp    c0105d97 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105d4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d52:	0f b6 00             	movzbl (%eax),%eax
c0105d55:	3c 60                	cmp    $0x60,%al
c0105d57:	7e 1b                	jle    c0105d74 <strtol+0xf7>
c0105d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5c:	0f b6 00             	movzbl (%eax),%eax
c0105d5f:	3c 7a                	cmp    $0x7a,%al
c0105d61:	7f 11                	jg     c0105d74 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d66:	0f b6 00             	movzbl (%eax),%eax
c0105d69:	0f be c0             	movsbl %al,%eax
c0105d6c:	83 e8 57             	sub    $0x57,%eax
c0105d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d72:	eb 23                	jmp    c0105d97 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105d74:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d77:	0f b6 00             	movzbl (%eax),%eax
c0105d7a:	3c 40                	cmp    $0x40,%al
c0105d7c:	7e 3d                	jle    c0105dbb <strtol+0x13e>
c0105d7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d81:	0f b6 00             	movzbl (%eax),%eax
c0105d84:	3c 5a                	cmp    $0x5a,%al
c0105d86:	7f 33                	jg     c0105dbb <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105d88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8b:	0f b6 00             	movzbl (%eax),%eax
c0105d8e:	0f be c0             	movsbl %al,%eax
c0105d91:	83 e8 37             	sub    $0x37,%eax
c0105d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d9a:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105d9d:	7c 02                	jl     c0105da1 <strtol+0x124>
            break;
c0105d9f:	eb 1a                	jmp    c0105dbb <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105da1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105da5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105da8:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105dac:	89 c2                	mov    %eax,%edx
c0105dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105db1:	01 d0                	add    %edx,%eax
c0105db3:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105db6:	e9 6f ff ff ff       	jmp    c0105d2a <strtol+0xad>

    if (endptr) {
c0105dbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105dbf:	74 08                	je     c0105dc9 <strtol+0x14c>
        *endptr = (char *) s;
c0105dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc4:	8b 55 08             	mov    0x8(%ebp),%edx
c0105dc7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105dc9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105dcd:	74 07                	je     c0105dd6 <strtol+0x159>
c0105dcf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dd2:	f7 d8                	neg    %eax
c0105dd4:	eb 03                	jmp    c0105dd9 <strtol+0x15c>
c0105dd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105dd9:	c9                   	leave  
c0105dda:	c3                   	ret    

c0105ddb <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105ddb:	55                   	push   %ebp
c0105ddc:	89 e5                	mov    %esp,%ebp
c0105dde:	57                   	push   %edi
c0105ddf:	83 ec 24             	sub    $0x24,%esp
c0105de2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de5:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105de8:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105dec:	8b 55 08             	mov    0x8(%ebp),%edx
c0105def:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105df2:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105df5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105df8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105dfb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105dfe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105e02:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105e05:	89 d7                	mov    %edx,%edi
c0105e07:	f3 aa                	rep stos %al,%es:(%edi)
c0105e09:	89 fa                	mov    %edi,%edx
c0105e0b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105e0e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105e11:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105e14:	83 c4 24             	add    $0x24,%esp
c0105e17:	5f                   	pop    %edi
c0105e18:	5d                   	pop    %ebp
c0105e19:	c3                   	ret    

c0105e1a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105e1a:	55                   	push   %ebp
c0105e1b:	89 e5                	mov    %esp,%ebp
c0105e1d:	57                   	push   %edi
c0105e1e:	56                   	push   %esi
c0105e1f:	53                   	push   %ebx
c0105e20:	83 ec 30             	sub    $0x30,%esp
c0105e23:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e29:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e2f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e32:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e38:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105e3b:	73 42                	jae    c0105e7f <memmove+0x65>
c0105e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e46:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e4c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e52:	c1 e8 02             	shr    $0x2,%eax
c0105e55:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105e57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e5d:	89 d7                	mov    %edx,%edi
c0105e5f:	89 c6                	mov    %eax,%esi
c0105e61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e63:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105e66:	83 e1 03             	and    $0x3,%ecx
c0105e69:	74 02                	je     c0105e6d <memmove+0x53>
c0105e6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e6d:	89 f0                	mov    %esi,%eax
c0105e6f:	89 fa                	mov    %edi,%edx
c0105e71:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105e74:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105e77:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e7d:	eb 36                	jmp    c0105eb5 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105e7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e82:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e85:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e88:	01 c2                	add    %eax,%edx
c0105e8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e8d:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e93:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e99:	89 c1                	mov    %eax,%ecx
c0105e9b:	89 d8                	mov    %ebx,%eax
c0105e9d:	89 d6                	mov    %edx,%esi
c0105e9f:	89 c7                	mov    %eax,%edi
c0105ea1:	fd                   	std    
c0105ea2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105ea4:	fc                   	cld    
c0105ea5:	89 f8                	mov    %edi,%eax
c0105ea7:	89 f2                	mov    %esi,%edx
c0105ea9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105eac:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105eaf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105eb5:	83 c4 30             	add    $0x30,%esp
c0105eb8:	5b                   	pop    %ebx
c0105eb9:	5e                   	pop    %esi
c0105eba:	5f                   	pop    %edi
c0105ebb:	5d                   	pop    %ebp
c0105ebc:	c3                   	ret    

c0105ebd <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105ebd:	55                   	push   %ebp
c0105ebe:	89 e5                	mov    %esp,%ebp
c0105ec0:	57                   	push   %edi
c0105ec1:	56                   	push   %esi
c0105ec2:	83 ec 20             	sub    $0x20,%esp
c0105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ed1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105eda:	c1 e8 02             	shr    $0x2,%eax
c0105edd:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105edf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ee5:	89 d7                	mov    %edx,%edi
c0105ee7:	89 c6                	mov    %eax,%esi
c0105ee9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105eeb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105eee:	83 e1 03             	and    $0x3,%ecx
c0105ef1:	74 02                	je     c0105ef5 <memcpy+0x38>
c0105ef3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105ef5:	89 f0                	mov    %esi,%eax
c0105ef7:	89 fa                	mov    %edi,%edx
c0105ef9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105efc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105eff:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105f05:	83 c4 20             	add    $0x20,%esp
c0105f08:	5e                   	pop    %esi
c0105f09:	5f                   	pop    %edi
c0105f0a:	5d                   	pop    %ebp
c0105f0b:	c3                   	ret    

c0105f0c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105f0c:	55                   	push   %ebp
c0105f0d:	89 e5                	mov    %esp,%ebp
c0105f0f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105f12:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f15:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105f18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f1b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105f1e:	eb 30                	jmp    c0105f50 <memcmp+0x44>
        if (*s1 != *s2) {
c0105f20:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f23:	0f b6 10             	movzbl (%eax),%edx
c0105f26:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f29:	0f b6 00             	movzbl (%eax),%eax
c0105f2c:	38 c2                	cmp    %al,%dl
c0105f2e:	74 18                	je     c0105f48 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f33:	0f b6 00             	movzbl (%eax),%eax
c0105f36:	0f b6 d0             	movzbl %al,%edx
c0105f39:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f3c:	0f b6 00             	movzbl (%eax),%eax
c0105f3f:	0f b6 c0             	movzbl %al,%eax
c0105f42:	29 c2                	sub    %eax,%edx
c0105f44:	89 d0                	mov    %edx,%eax
c0105f46:	eb 1a                	jmp    c0105f62 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105f48:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105f4c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105f50:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f53:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f56:	89 55 10             	mov    %edx,0x10(%ebp)
c0105f59:	85 c0                	test   %eax,%eax
c0105f5b:	75 c3                	jne    c0105f20 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105f5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f62:	c9                   	leave  
c0105f63:	c3                   	ret    
