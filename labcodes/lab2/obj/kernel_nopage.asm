
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 79 5d 00 00       	call   105ddb <memset>

    cons_init();                // init the console
  100062:	e8 82 15 00 00       	call   1015e9 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 5f 10 00 	movl   $0x105f80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 5f 10 00 	movl   $0x105f9c,(%esp)
  10007c:	e8 c7 02 00 00       	call   100348 <cprintf>

    print_kerninfo();
  100081:	e8 f6 07 00 00       	call   10087c <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 b6 42 00 00       	call   104346 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 bd 16 00 00       	call   101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 0f 18 00 00       	call   1018a9 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 00 0d 00 00       	call   100d9f <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 1c 16 00 00       	call   1016c0 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 f8 0b 00 00       	call   100cc0 <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 a1 5f 10 00 	movl   $0x105fa1,(%esp)
  100168:	e8 db 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 5f 10 00 	movl   $0x105faf,(%esp)
  100188:	e8 bb 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 bd 5f 10 00 	movl   $0x105fbd,(%esp)
  1001a8:	e8 9b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 cb 5f 10 00 	movl   $0x105fcb,(%esp)
  1001c8:	e8 7b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 d9 5f 10 00 	movl   $0x105fd9,(%esp)
  1001e8:	e8 5b 01 00 00       	call   100348 <cprintf>
    round ++;
  1001ed:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001ff:	5d                   	pop    %ebp
  100200:	c3                   	ret    

00100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100204:	5d                   	pop    %ebp
  100205:	c3                   	ret    

00100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100206:	55                   	push   %ebp
  100207:	89 e5                	mov    %esp,%ebp
  100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020c:	e8 25 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100211:	c7 04 24 e8 5f 10 00 	movl   $0x105fe8,(%esp)
  100218:	e8 2b 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 08 60 10 00 	movl   $0x106008,(%esp)
  10022e:	e8 15 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_kernel();
  100233:	e8 c9 ff ff ff       	call   100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100238:	e8 f9 fe ff ff       	call   100136 <lab1_print_cur_status>
}
  10023d:	c9                   	leave  
  10023e:	c3                   	ret    

0010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10023f:	55                   	push   %ebp
  100240:	89 e5                	mov    %esp,%ebp
  100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100249:	74 13                	je     10025e <readline+0x1f>
        cprintf("%s", prompt);
  10024b:	8b 45 08             	mov    0x8(%ebp),%eax
  10024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100252:	c7 04 24 27 60 10 00 	movl   $0x106027,(%esp)
  100259:	e8 ea 00 00 00       	call   100348 <cprintf>
    }
    int i = 0, c;
  10025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100265:	e8 66 01 00 00       	call   1003d0 <getchar>
  10026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100271:	79 07                	jns    10027a <readline+0x3b>
            return NULL;
  100273:	b8 00 00 00 00       	mov    $0x0,%eax
  100278:	eb 79                	jmp    1002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10027e:	7e 28                	jle    1002a8 <readline+0x69>
  100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100287:	7f 1f                	jg     1002a8 <readline+0x69>
            cputchar(c);
  100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10028c:	89 04 24             	mov    %eax,(%esp)
  10028f:	e8 da 00 00 00       	call   10036e <cputchar>
            buf[i ++] = c;
  100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100297:	8d 50 01             	lea    0x1(%eax),%edx
  10029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a0:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  1002a6:	eb 46                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002ac:	75 17                	jne    1002c5 <readline+0x86>
  1002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002b2:	7e 11                	jle    1002c5 <readline+0x86>
            cputchar(c);
  1002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b7:	89 04 24             	mov    %eax,(%esp)
  1002ba:	e8 af 00 00 00       	call   10036e <cputchar>
            i --;
  1002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002c3:	eb 29                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002c9:	74 06                	je     1002d1 <readline+0x92>
  1002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002cf:	75 1d                	jne    1002ee <readline+0xaf>
            cputchar(c);
  1002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d4:	89 04 24             	mov    %eax,(%esp)
  1002d7:	e8 92 00 00 00       	call   10036e <cputchar>
            buf[i] = '\0';
  1002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002df:	05 20 a0 11 00       	add    $0x11a020,%eax
  1002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002e7:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1002ec:	eb 05                	jmp    1002f3 <readline+0xb4>
        }
    }
  1002ee:	e9 72 ff ff ff       	jmp    100265 <readline+0x26>
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fe:	89 04 24             	mov    %eax,(%esp)
  100301:	e8 0f 13 00 00       	call   101615 <cons_putc>
    (*cnt) ++;
  100306:	8b 45 0c             	mov    0xc(%ebp),%eax
  100309:	8b 00                	mov    (%eax),%eax
  10030b:	8d 50 01             	lea    0x1(%eax),%edx
  10030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100311:	89 10                	mov    %edx,(%eax)
}
  100313:	c9                   	leave  
  100314:	c3                   	ret    

00100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100315:	55                   	push   %ebp
  100316:	89 e5                	mov    %esp,%ebp
  100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100322:	8b 45 0c             	mov    0xc(%ebp),%eax
  100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100329:	8b 45 08             	mov    0x8(%ebp),%eax
  10032c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100333:	89 44 24 04          	mov    %eax,0x4(%esp)
  100337:	c7 04 24 f5 02 10 00 	movl   $0x1002f5,(%esp)
  10033e:	e8 b1 52 00 00       	call   1055f4 <vprintfmt>
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10034e:	8d 45 0c             	lea    0xc(%ebp),%eax
  100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100357:	89 44 24 04          	mov    %eax,0x4(%esp)
  10035b:	8b 45 08             	mov    0x8(%ebp),%eax
  10035e:	89 04 24             	mov    %eax,(%esp)
  100361:	e8 af ff ff ff       	call   100315 <vcprintf>
  100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10036c:	c9                   	leave  
  10036d:	c3                   	ret    

0010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10036e:	55                   	push   %ebp
  10036f:	89 e5                	mov    %esp,%ebp
  100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100374:	8b 45 08             	mov    0x8(%ebp),%eax
  100377:	89 04 24             	mov    %eax,(%esp)
  10037a:	e8 96 12 00 00       	call   101615 <cons_putc>
}
  10037f:	c9                   	leave  
  100380:	c3                   	ret    

00100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100381:	55                   	push   %ebp
  100382:	89 e5                	mov    %esp,%ebp
  100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10038e:	eb 13                	jmp    1003a3 <cputs+0x22>
        cputch(c, &cnt);
  100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100397:	89 54 24 04          	mov    %edx,0x4(%esp)
  10039b:	89 04 24             	mov    %eax,(%esp)
  10039e:	e8 52 ff ff ff       	call   1002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1003a6:	8d 50 01             	lea    0x1(%eax),%edx
  1003a9:	89 55 08             	mov    %edx,0x8(%ebp)
  1003ac:	0f b6 00             	movzbl (%eax),%eax
  1003af:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003b6:	75 d8                	jne    100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003c6:	e8 2a ff ff ff       	call   1002f5 <cputch>
    return cnt;
  1003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003ce:	c9                   	leave  
  1003cf:	c3                   	ret    

001003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003d0:	55                   	push   %ebp
  1003d1:	89 e5                	mov    %esp,%ebp
  1003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003d6:	e8 76 12 00 00       	call   101651 <cons_getc>
  1003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003e2:	74 f2                	je     1003d6 <getchar+0x6>
        /* do nothing */;
    return c;
  1003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003f2:	8b 00                	mov    (%eax),%eax
  1003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1003fa:	8b 00                	mov    (%eax),%eax
  1003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100406:	e9 d2 00 00 00       	jmp    1004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  10040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100411:	01 d0                	add    %edx,%eax
  100413:	89 c2                	mov    %eax,%edx
  100415:	c1 ea 1f             	shr    $0x1f,%edx
  100418:	01 d0                	add    %edx,%eax
  10041a:	d1 f8                	sar    %eax
  10041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100425:	eb 04                	jmp    10042b <stab_binsearch+0x42>
            m --;
  100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100431:	7c 1f                	jl     100452 <stab_binsearch+0x69>
  100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100436:	89 d0                	mov    %edx,%eax
  100438:	01 c0                	add    %eax,%eax
  10043a:	01 d0                	add    %edx,%eax
  10043c:	c1 e0 02             	shl    $0x2,%eax
  10043f:	89 c2                	mov    %eax,%edx
  100441:	8b 45 08             	mov    0x8(%ebp),%eax
  100444:	01 d0                	add    %edx,%eax
  100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10044a:	0f b6 c0             	movzbl %al,%eax
  10044d:	3b 45 14             	cmp    0x14(%ebp),%eax
  100450:	75 d5                	jne    100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100458:	7d 0b                	jge    100465 <stab_binsearch+0x7c>
            l = true_m + 1;
  10045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10045d:	83 c0 01             	add    $0x1,%eax
  100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100463:	eb 78                	jmp    1004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10046f:	89 d0                	mov    %edx,%eax
  100471:	01 c0                	add    %eax,%eax
  100473:	01 d0                	add    %edx,%eax
  100475:	c1 e0 02             	shl    $0x2,%eax
  100478:	89 c2                	mov    %eax,%edx
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	01 d0                	add    %edx,%eax
  10047f:	8b 40 08             	mov    0x8(%eax),%eax
  100482:	3b 45 18             	cmp    0x18(%ebp),%eax
  100485:	73 13                	jae    10049a <stab_binsearch+0xb1>
            *region_left = m;
  100487:	8b 45 0c             	mov    0xc(%ebp),%eax
  10048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100492:	83 c0 01             	add    $0x1,%eax
  100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100498:	eb 43                	jmp    1004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  10049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049d:	89 d0                	mov    %edx,%eax
  10049f:	01 c0                	add    %eax,%eax
  1004a1:	01 d0                	add    %edx,%eax
  1004a3:	c1 e0 02             	shl    $0x2,%eax
  1004a6:	89 c2                	mov    %eax,%edx
  1004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ab:	01 d0                	add    %edx,%eax
  1004ad:	8b 40 08             	mov    0x8(%eax),%eax
  1004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004b3:	76 16                	jbe    1004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c3:	83 e8 01             	sub    $0x1,%eax
  1004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004c9:	eb 12                	jmp    1004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d1:	89 10                	mov    %edx,(%eax)
            l = m;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004e3:	0f 8e 22 ff ff ff    	jle    10040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004ed:	75 0f                	jne    1004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004f2:	8b 00                	mov    (%eax),%eax
  1004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1004fa:	89 10                	mov    %edx,(%eax)
  1004fc:	eb 3f                	jmp    10053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004fe:	8b 45 10             	mov    0x10(%ebp),%eax
  100501:	8b 00                	mov    (%eax),%eax
  100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100506:	eb 04                	jmp    10050c <stab_binsearch+0x123>
  100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10050f:	8b 00                	mov    (%eax),%eax
  100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100514:	7d 1f                	jge    100535 <stab_binsearch+0x14c>
  100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100519:	89 d0                	mov    %edx,%eax
  10051b:	01 c0                	add    %eax,%eax
  10051d:	01 d0                	add    %edx,%eax
  10051f:	c1 e0 02             	shl    $0x2,%eax
  100522:	89 c2                	mov    %eax,%edx
  100524:	8b 45 08             	mov    0x8(%ebp),%eax
  100527:	01 d0                	add    %edx,%eax
  100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10052d:	0f b6 c0             	movzbl %al,%eax
  100530:	3b 45 14             	cmp    0x14(%ebp),%eax
  100533:	75 d3                	jne    100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100535:	8b 45 0c             	mov    0xc(%ebp),%eax
  100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10053b:	89 10                	mov    %edx,(%eax)
    }
}
  10053d:	c9                   	leave  
  10053e:	c3                   	ret    

0010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10053f:	55                   	push   %ebp
  100540:	89 e5                	mov    %esp,%ebp
  100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100545:	8b 45 0c             	mov    0xc(%ebp),%eax
  100548:	c7 00 2c 60 10 00    	movl   $0x10602c,(%eax)
    info->eip_line = 0;
  10054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	c7 40 08 2c 60 10 00 	movl   $0x10602c,0x8(%eax)
    info->eip_fn_namelen = 9;
  100562:	8b 45 0c             	mov    0xc(%ebp),%eax
  100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10056c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056f:	8b 55 08             	mov    0x8(%ebp),%edx
  100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100575:	8b 45 0c             	mov    0xc(%ebp),%eax
  100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10057f:	c7 45 f4 b8 72 10 00 	movl   $0x1072b8,-0xc(%ebp)
    stab_end = __STAB_END__;
  100586:	c7 45 f0 b4 1e 11 00 	movl   $0x111eb4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec b5 1e 11 00 	movl   $0x111eb5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 dd 48 11 00 	movl   $0x1148dd,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005a1:	76 0d                	jbe    1005b0 <debuginfo_eip+0x71>
  1005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a6:	83 e8 01             	sub    $0x1,%eax
  1005a9:	0f b6 00             	movzbl (%eax),%eax
  1005ac:	84 c0                	test   %al,%al
  1005ae:	74 0a                	je     1005ba <debuginfo_eip+0x7b>
        return -1;
  1005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005b5:	e9 c0 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005c7:	29 c2                	sub    %eax,%edx
  1005c9:	89 d0                	mov    %edx,%eax
  1005cb:	c1 f8 02             	sar    $0x2,%eax
  1005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005d4:	83 e8 01             	sub    $0x1,%eax
  1005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005da:	8b 45 08             	mov    0x8(%ebp),%eax
  1005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005e8:	00 
  1005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005fa:	89 04 24             	mov    %eax,(%esp)
  1005fd:	e8 e7 fd ff ff       	call   1003e9 <stab_binsearch>
    if (lfile == 0)
  100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100605:	85 c0                	test   %eax,%eax
  100607:	75 0a                	jne    100613 <debuginfo_eip+0xd4>
        return -1;
  100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10060e:	e9 67 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10061f:	8b 45 08             	mov    0x8(%ebp),%eax
  100622:	89 44 24 10          	mov    %eax,0x10(%esp)
  100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10062d:	00 
  10062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100631:	89 44 24 08          	mov    %eax,0x8(%esp)
  100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100638:	89 44 24 04          	mov    %eax,0x4(%esp)
  10063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063f:	89 04 24             	mov    %eax,(%esp)
  100642:	e8 a2 fd ff ff       	call   1003e9 <stab_binsearch>

    if (lfun <= rfun) {
  100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10064d:	39 c2                	cmp    %eax,%edx
  10064f:	7f 7c                	jg     1006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100654:	89 c2                	mov    %eax,%edx
  100656:	89 d0                	mov    %edx,%eax
  100658:	01 c0                	add    %eax,%eax
  10065a:	01 d0                	add    %edx,%eax
  10065c:	c1 e0 02             	shl    $0x2,%eax
  10065f:	89 c2                	mov    %eax,%edx
  100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	8b 10                	mov    (%eax),%edx
  100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066e:	29 c1                	sub    %eax,%ecx
  100670:	89 c8                	mov    %ecx,%eax
  100672:	39 c2                	cmp    %eax,%edx
  100674:	73 22                	jae    100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100679:	89 c2                	mov    %eax,%edx
  10067b:	89 d0                	mov    %edx,%eax
  10067d:	01 c0                	add    %eax,%eax
  10067f:	01 d0                	add    %edx,%eax
  100681:	c1 e0 02             	shl    $0x2,%eax
  100684:	89 c2                	mov    %eax,%edx
  100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100689:	01 d0                	add    %edx,%eax
  10068b:	8b 10                	mov    (%eax),%edx
  10068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100690:	01 c2                	add    %eax,%edx
  100692:	8b 45 0c             	mov    0xc(%ebp),%eax
  100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069b:	89 c2                	mov    %eax,%edx
  10069d:	89 d0                	mov    %edx,%eax
  10069f:	01 c0                	add    %eax,%eax
  1006a1:	01 d0                	add    %edx,%eax
  1006a3:	c1 e0 02             	shl    $0x2,%eax
  1006a6:	89 c2                	mov    %eax,%edx
  1006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006ab:	01 d0                	add    %edx,%eax
  1006ad:	8b 50 08             	mov    0x8(%eax),%edx
  1006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	8b 40 10             	mov    0x10(%eax),%eax
  1006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006cb:	eb 15                	jmp    1006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d0:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e5:	8b 40 08             	mov    0x8(%eax),%eax
  1006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006ef:	00 
  1006f0:	89 04 24             	mov    %eax,(%esp)
  1006f3:	e8 57 55 00 00       	call   105c4f <strfind>
  1006f8:	89 c2                	mov    %eax,%edx
  1006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fd:	8b 40 08             	mov    0x8(%eax),%eax
  100700:	29 c2                	sub    %eax,%edx
  100702:	8b 45 0c             	mov    0xc(%ebp),%eax
  100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100708:	8b 45 08             	mov    0x8(%ebp),%eax
  10070b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100716:	00 
  100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100721:	89 44 24 04          	mov    %eax,0x4(%esp)
  100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100728:	89 04 24             	mov    %eax,(%esp)
  10072b:	e8 b9 fc ff ff       	call   1003e9 <stab_binsearch>
    if (lline <= rline) {
  100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100736:	39 c2                	cmp    %eax,%edx
  100738:	7f 24                	jg     10075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  10073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073d:	89 c2                	mov    %eax,%edx
  10073f:	89 d0                	mov    %edx,%eax
  100741:	01 c0                	add    %eax,%eax
  100743:	01 d0                	add    %edx,%eax
  100745:	c1 e0 02             	shl    $0x2,%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074d:	01 d0                	add    %edx,%eax
  10074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100753:	0f b7 d0             	movzwl %ax,%edx
  100756:	8b 45 0c             	mov    0xc(%ebp),%eax
  100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10075c:	eb 13                	jmp    100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100763:	e9 12 01 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10076b:	83 e8 01             	sub    $0x1,%eax
  10076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100777:	39 c2                	cmp    %eax,%edx
  100779:	7c 56                	jl     1007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077e:	89 c2                	mov    %eax,%edx
  100780:	89 d0                	mov    %edx,%eax
  100782:	01 c0                	add    %eax,%eax
  100784:	01 d0                	add    %edx,%eax
  100786:	c1 e0 02             	shl    $0x2,%eax
  100789:	89 c2                	mov    %eax,%edx
  10078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10078e:	01 d0                	add    %edx,%eax
  100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100794:	3c 84                	cmp    $0x84,%al
  100796:	74 39                	je     1007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079b:	89 c2                	mov    %eax,%edx
  10079d:	89 d0                	mov    %edx,%eax
  10079f:	01 c0                	add    %eax,%eax
  1007a1:	01 d0                	add    %edx,%eax
  1007a3:	c1 e0 02             	shl    $0x2,%eax
  1007a6:	89 c2                	mov    %eax,%edx
  1007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ab:	01 d0                	add    %edx,%eax
  1007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b1:	3c 64                	cmp    $0x64,%al
  1007b3:	75 b3                	jne    100768 <debuginfo_eip+0x229>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 40 08             	mov    0x8(%eax),%eax
  1007cd:	85 c0                	test   %eax,%eax
  1007cf:	74 97                	je     100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d7:	39 c2                	cmp    %eax,%edx
  1007d9:	7c 46                	jl     100821 <debuginfo_eip+0x2e2>
  1007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007de:	89 c2                	mov    %eax,%edx
  1007e0:	89 d0                	mov    %edx,%eax
  1007e2:	01 c0                	add    %eax,%eax
  1007e4:	01 d0                	add    %edx,%eax
  1007e6:	c1 e0 02             	shl    $0x2,%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ee:	01 d0                	add    %edx,%eax
  1007f0:	8b 10                	mov    (%eax),%edx
  1007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f8:	29 c1                	sub    %eax,%ecx
  1007fa:	89 c8                	mov    %ecx,%eax
  1007fc:	39 c2                	cmp    %eax,%edx
  1007fe:	73 21                	jae    100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100803:	89 c2                	mov    %eax,%edx
  100805:	89 d0                	mov    %edx,%eax
  100807:	01 c0                	add    %eax,%eax
  100809:	01 d0                	add    %edx,%eax
  10080b:	c1 e0 02             	shl    $0x2,%eax
  10080e:	89 c2                	mov    %eax,%edx
  100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100813:	01 d0                	add    %edx,%eax
  100815:	8b 10                	mov    (%eax),%edx
  100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10081a:	01 c2                	add    %eax,%edx
  10081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100827:	39 c2                	cmp    %eax,%edx
  100829:	7d 4a                	jge    100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  10082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082e:	83 c0 01             	add    $0x1,%eax
  100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100834:	eb 18                	jmp    10084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100836:	8b 45 0c             	mov    0xc(%ebp),%eax
  100839:	8b 40 14             	mov    0x14(%eax),%eax
  10083c:	8d 50 01             	lea    0x1(%eax),%edx
  10083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100848:	83 c0 01             	add    $0x1,%eax
  10084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100854:	39 c2                	cmp    %eax,%edx
  100856:	7d 1d                	jge    100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c a0                	cmp    $0xa0,%al
  100873:	74 c1                	je     100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10087a:	c9                   	leave  
  10087b:	c3                   	ret    

0010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10087c:	55                   	push   %ebp
  10087d:	89 e5                	mov    %esp,%ebp
  10087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100882:	c7 04 24 36 60 10 00 	movl   $0x106036,(%esp)
  100889:	e8 ba fa ff ff       	call   100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100895:	00 
  100896:	c7 04 24 4f 60 10 00 	movl   $0x10604f,(%esp)
  10089d:	e8 a6 fa ff ff       	call   100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a2:	c7 44 24 04 64 5f 10 	movl   $0x105f64,0x4(%esp)
  1008a9:	00 
  1008aa:	c7 04 24 67 60 10 00 	movl   $0x106067,(%esp)
  1008b1:	e8 92 fa ff ff       	call   100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b6:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008bd:	00 
  1008be:	c7 04 24 7f 60 10 00 	movl   $0x10607f,(%esp)
  1008c5:	e8 7e fa ff ff       	call   100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008ca:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  1008d1:	00 
  1008d2:	c7 04 24 97 60 10 00 	movl   $0x106097,(%esp)
  1008d9:	e8 6a fa ff ff       	call   100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008de:	b8 28 af 11 00       	mov    $0x11af28,%eax
  1008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008e9:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008ee:	29 c2                	sub    %eax,%edx
  1008f0:	89 d0                	mov    %edx,%eax
  1008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f8:	85 c0                	test   %eax,%eax
  1008fa:	0f 48 c2             	cmovs  %edx,%eax
  1008fd:	c1 f8 0a             	sar    $0xa,%eax
  100900:	89 44 24 04          	mov    %eax,0x4(%esp)
  100904:	c7 04 24 b0 60 10 00 	movl   $0x1060b0,(%esp)
  10090b:	e8 38 fa ff ff       	call   100348 <cprintf>
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100922:	8b 45 08             	mov    0x8(%ebp),%eax
  100925:	89 04 24             	mov    %eax,(%esp)
  100928:	e8 12 fc ff ff       	call   10053f <debuginfo_eip>
  10092d:	85 c0                	test   %eax,%eax
  10092f:	74 15                	je     100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100931:	8b 45 08             	mov    0x8(%ebp),%eax
  100934:	89 44 24 04          	mov    %eax,0x4(%esp)
  100938:	c7 04 24 da 60 10 00 	movl   $0x1060da,(%esp)
  10093f:	e8 04 fa ff ff       	call   100348 <cprintf>
  100944:	eb 6d                	jmp    1009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10094d:	eb 1c                	jmp    10096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100955:	01 d0                	add    %edx,%eax
  100957:	0f b6 00             	movzbl (%eax),%eax
  10095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100963:	01 ca                	add    %ecx,%edx
  100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100971:	7f dc                	jg     10094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097c:	01 d0                	add    %edx,%eax
  10097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100984:	8b 55 08             	mov    0x8(%ebp),%edx
  100987:	89 d1                	mov    %edx,%ecx
  100989:	29 c1                	sub    %eax,%ecx
  10098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10099f:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a7:	c7 04 24 f6 60 10 00 	movl   $0x1060f6,(%esp)
  1009ae:	e8 95 f9 ff ff       	call   100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009b3:	c9                   	leave  
  1009b4:	c3                   	ret    

001009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b5:	55                   	push   %ebp
  1009b6:	89 e5                	mov    %esp,%ebp
  1009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009bb:	8b 45 04             	mov    0x4(%ebp),%eax
  1009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c4:	c9                   	leave  
  1009c5:	c3                   	ret    

001009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c6:	55                   	push   %ebp
  1009c7:	89 e5                	mov    %esp,%ebp
  1009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cc:	89 e8                	mov    %ebp,%eax
  1009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  1009d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1009d7:	e8 d9 ff ff ff       	call   1009b5 <read_eip>
  1009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  1009df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e6:	e9 88 00 00 00       	jmp    100a73 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  1009eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f9:	c7 04 24 08 61 10 00 	movl   $0x106108,(%esp)
  100a00:	e8 43 f9 ff ff       	call   100348 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
  100a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a08:	83 c0 08             	add    $0x8,%eax
  100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100a0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a15:	eb 25                	jmp    100a3c <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
  100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a24:	01 d0                	add    %edx,%eax
  100a26:	8b 00                	mov    (%eax),%eax
  100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2c:	c7 04 24 24 61 10 00 	movl   $0x106124,(%esp)
  100a33:	e8 10 f9 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
  100a38:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100a3c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a40:	7e d5                	jle    100a17 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
  100a42:	c7 04 24 2c 61 10 00 	movl   $0x10612c,(%esp)
  100a49:	e8 fa f8 ff ff       	call   100348 <cprintf>
        print_debuginfo(eip - 1);
  100a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a51:	83 e8 01             	sub    $0x1,%eax
  100a54:	89 04 24             	mov    %eax,(%esp)
  100a57:	e8 b6 fe ff ff       	call   100912 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5f:	83 c0 04             	add    $0x4,%eax
  100a62:	8b 00                	mov    (%eax),%eax
  100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a6a:	8b 00                	mov    (%eax),%eax
  100a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a6f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a77:	74 0a                	je     100a83 <print_stackframe+0xbd>
  100a79:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a7d:	0f 8e 68 ff ff ff    	jle    1009eb <print_stackframe+0x25>
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }

}
  100a83:	c9                   	leave  
  100a84:	c3                   	ret    

00100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a85:	55                   	push   %ebp
  100a86:	89 e5                	mov    %esp,%ebp
  100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a92:	eb 0c                	jmp    100aa0 <parse+0x1b>
            *buf ++ = '\0';
  100a94:	8b 45 08             	mov    0x8(%ebp),%eax
  100a97:	8d 50 01             	lea    0x1(%eax),%edx
  100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa3:	0f b6 00             	movzbl (%eax),%eax
  100aa6:	84 c0                	test   %al,%al
  100aa8:	74 1d                	je     100ac7 <parse+0x42>
  100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  100aad:	0f b6 00             	movzbl (%eax),%eax
  100ab0:	0f be c0             	movsbl %al,%eax
  100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab7:	c7 04 24 b0 61 10 00 	movl   $0x1061b0,(%esp)
  100abe:	e8 59 51 00 00       	call   105c1c <strchr>
  100ac3:	85 c0                	test   %eax,%eax
  100ac5:	75 cd                	jne    100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  100aca:	0f b6 00             	movzbl (%eax),%eax
  100acd:	84 c0                	test   %al,%al
  100acf:	75 02                	jne    100ad3 <parse+0x4e>
            break;
  100ad1:	eb 67                	jmp    100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad7:	75 14                	jne    100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ae0:	00 
  100ae1:	c7 04 24 b5 61 10 00 	movl   $0x1061b5,(%esp)
  100ae8:	e8 5b f8 ff ff       	call   100348 <cprintf>
        }
        argv[argc ++] = buf;
  100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af0:	8d 50 01             	lea    0x1(%eax),%edx
  100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b00:	01 c2                	add    %eax,%edx
  100b02:	8b 45 08             	mov    0x8(%ebp),%eax
  100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b07:	eb 04                	jmp    100b0d <parse+0x88>
            buf ++;
  100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100b10:	0f b6 00             	movzbl (%eax),%eax
  100b13:	84 c0                	test   %al,%al
  100b15:	74 1d                	je     100b34 <parse+0xaf>
  100b17:	8b 45 08             	mov    0x8(%ebp),%eax
  100b1a:	0f b6 00             	movzbl (%eax),%eax
  100b1d:	0f be c0             	movsbl %al,%eax
  100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b24:	c7 04 24 b0 61 10 00 	movl   $0x1061b0,(%esp)
  100b2b:	e8 ec 50 00 00       	call   105c1c <strchr>
  100b30:	85 c0                	test   %eax,%eax
  100b32:	74 d5                	je     100b09 <parse+0x84>
            buf ++;
        }
    }
  100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b35:	e9 66 ff ff ff       	jmp    100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b3d:	c9                   	leave  
  100b3e:	c3                   	ret    

00100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3f:	55                   	push   %ebp
  100b40:	89 e5                	mov    %esp,%ebp
  100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4f:	89 04 24             	mov    %eax,(%esp)
  100b52:	e8 2e ff ff ff       	call   100a85 <parse>
  100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5e:	75 0a                	jne    100b6a <runcmd+0x2b>
        return 0;
  100b60:	b8 00 00 00 00       	mov    $0x0,%eax
  100b65:	e9 85 00 00 00       	jmp    100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b71:	eb 5c                	jmp    100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b79:	89 d0                	mov    %edx,%eax
  100b7b:	01 c0                	add    %eax,%eax
  100b7d:	01 d0                	add    %edx,%eax
  100b7f:	c1 e0 02             	shl    $0x2,%eax
  100b82:	05 00 70 11 00       	add    $0x117000,%eax
  100b87:	8b 00                	mov    (%eax),%eax
  100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b8d:	89 04 24             	mov    %eax,(%esp)
  100b90:	e8 e8 4f 00 00       	call   105b7d <strcmp>
  100b95:	85 c0                	test   %eax,%eax
  100b97:	75 32                	jne    100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9c:	89 d0                	mov    %edx,%eax
  100b9e:	01 c0                	add    %eax,%eax
  100ba0:	01 d0                	add    %edx,%eax
  100ba2:	c1 e0 02             	shl    $0x2,%eax
  100ba5:	05 00 70 11 00       	add    $0x117000,%eax
  100baa:	8b 40 08             	mov    0x8(%eax),%eax
  100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bbd:	83 c2 04             	add    $0x4,%edx
  100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bc4:	89 0c 24             	mov    %ecx,(%esp)
  100bc7:	ff d0                	call   *%eax
  100bc9:	eb 24                	jmp    100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd2:	83 f8 02             	cmp    $0x2,%eax
  100bd5:	76 9c                	jbe    100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bde:	c7 04 24 d3 61 10 00 	movl   $0x1061d3,(%esp)
  100be5:	e8 5e f7 ff ff       	call   100348 <cprintf>
    return 0;
  100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bef:	c9                   	leave  
  100bf0:	c3                   	ret    

00100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bf1:	55                   	push   %ebp
  100bf2:	89 e5                	mov    %esp,%ebp
  100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bf7:	c7 04 24 ec 61 10 00 	movl   $0x1061ec,(%esp)
  100bfe:	e8 45 f7 ff ff       	call   100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c03:	c7 04 24 14 62 10 00 	movl   $0x106214,(%esp)
  100c0a:	e8 39 f7 ff ff       	call   100348 <cprintf>

    if (tf != NULL) {
  100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c13:	74 0b                	je     100c20 <kmonitor+0x2f>
        print_trapframe(tf);
  100c15:	8b 45 08             	mov    0x8(%ebp),%eax
  100c18:	89 04 24             	mov    %eax,(%esp)
  100c1b:	e8 c2 0d 00 00       	call   1019e2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c20:	c7 04 24 39 62 10 00 	movl   $0x106239,(%esp)
  100c27:	e8 13 f6 ff ff       	call   10023f <readline>
  100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c33:	74 18                	je     100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c35:	8b 45 08             	mov    0x8(%ebp),%eax
  100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c3f:	89 04 24             	mov    %eax,(%esp)
  100c42:	e8 f8 fe ff ff       	call   100b3f <runcmd>
  100c47:	85 c0                	test   %eax,%eax
  100c49:	79 02                	jns    100c4d <kmonitor+0x5c>
                break;
  100c4b:	eb 02                	jmp    100c4f <kmonitor+0x5e>
            }
        }
    }
  100c4d:	eb d1                	jmp    100c20 <kmonitor+0x2f>
}
  100c4f:	c9                   	leave  
  100c50:	c3                   	ret    

00100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c51:	55                   	push   %ebp
  100c52:	89 e5                	mov    %esp,%ebp
  100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c5e:	eb 3f                	jmp    100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c63:	89 d0                	mov    %edx,%eax
  100c65:	01 c0                	add    %eax,%eax
  100c67:	01 d0                	add    %edx,%eax
  100c69:	c1 e0 02             	shl    $0x2,%eax
  100c6c:	05 00 70 11 00       	add    $0x117000,%eax
  100c71:	8b 48 04             	mov    0x4(%eax),%ecx
  100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c77:	89 d0                	mov    %edx,%eax
  100c79:	01 c0                	add    %eax,%eax
  100c7b:	01 d0                	add    %edx,%eax
  100c7d:	c1 e0 02             	shl    $0x2,%eax
  100c80:	05 00 70 11 00       	add    $0x117000,%eax
  100c85:	8b 00                	mov    (%eax),%eax
  100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c8f:	c7 04 24 3d 62 10 00 	movl   $0x10623d,(%esp)
  100c96:	e8 ad f6 ff ff       	call   100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca2:	83 f8 02             	cmp    $0x2,%eax
  100ca5:	76 b9                	jbe    100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cac:	c9                   	leave  
  100cad:	c3                   	ret    

00100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cae:	55                   	push   %ebp
  100caf:	89 e5                	mov    %esp,%ebp
  100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb4:	e8 c3 fb ff ff       	call   10087c <print_kerninfo>
    return 0;
  100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbe:	c9                   	leave  
  100cbf:	c3                   	ret    

00100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cc0:	55                   	push   %ebp
  100cc1:	89 e5                	mov    %esp,%ebp
  100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc6:	e8 fb fc ff ff       	call   1009c6 <print_stackframe>
    return 0;
  100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd0:	c9                   	leave  
  100cd1:	c3                   	ret    

00100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cd2:	55                   	push   %ebp
  100cd3:	89 e5                	mov    %esp,%ebp
  100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd8:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100cdd:	85 c0                	test   %eax,%eax
  100cdf:	74 02                	je     100ce3 <__panic+0x11>
        goto panic_dead;
  100ce1:	eb 59                	jmp    100d3c <__panic+0x6a>
    }
    is_panic = 1;
  100ce3:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ced:	8d 45 14             	lea    0x14(%ebp),%eax
  100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d01:	c7 04 24 46 62 10 00 	movl   $0x106246,(%esp)
  100d08:	e8 3b f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d14:	8b 45 10             	mov    0x10(%ebp),%eax
  100d17:	89 04 24             	mov    %eax,(%esp)
  100d1a:	e8 f6 f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d1f:	c7 04 24 62 62 10 00 	movl   $0x106262,(%esp)
  100d26:	e8 1d f6 ff ff       	call   100348 <cprintf>
    
    cprintf("stack trackback:\n");
  100d2b:	c7 04 24 64 62 10 00 	movl   $0x106264,(%esp)
  100d32:	e8 11 f6 ff ff       	call   100348 <cprintf>
    print_stackframe();
  100d37:	e8 8a fc ff ff       	call   1009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d3c:	e8 85 09 00 00       	call   1016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d48:	e8 a4 fe ff ff       	call   100bf1 <kmonitor>
    }
  100d4d:	eb f2                	jmp    100d41 <__panic+0x6f>

00100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d4f:	55                   	push   %ebp
  100d50:	89 e5                	mov    %esp,%ebp
  100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d55:	8d 45 14             	lea    0x14(%ebp),%eax
  100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d62:	8b 45 08             	mov    0x8(%ebp),%eax
  100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d69:	c7 04 24 76 62 10 00 	movl   $0x106276,(%esp)
  100d70:	e8 d3 f5 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  100d7f:	89 04 24             	mov    %eax,(%esp)
  100d82:	e8 8e f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d87:	c7 04 24 62 62 10 00 	movl   $0x106262,(%esp)
  100d8e:	e8 b5 f5 ff ff       	call   100348 <cprintf>
    va_end(ap);
}
  100d93:	c9                   	leave  
  100d94:	c3                   	ret    

00100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d95:	55                   	push   %ebp
  100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d98:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100d9d:	5d                   	pop    %ebp
  100d9e:	c3                   	ret    

00100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9f:	55                   	push   %ebp
  100da0:	89 e5                	mov    %esp,%ebp
  100da2:	83 ec 28             	sub    $0x28,%esp
  100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100db7:	ee                   	out    %al,(%dx)
  100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dca:	ee                   	out    %al,(%dx)
  100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dde:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100de8:	c7 04 24 94 62 10 00 	movl   $0x106294,(%esp)
  100def:	e8 54 f5 ff ff       	call   100348 <cprintf>
    pic_enable(IRQ_TIMER);
  100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dfb:	e8 24 09 00 00       	call   101724 <pic_enable>
}
  100e00:	c9                   	leave  
  100e01:	c3                   	ret    

00100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e02:	55                   	push   %ebp
  100e03:	89 e5                	mov    %esp,%ebp
  100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e08:	9c                   	pushf  
  100e09:	58                   	pop    %eax
  100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e10:	25 00 02 00 00       	and    $0x200,%eax
  100e15:	85 c0                	test   %eax,%eax
  100e17:	74 0c                	je     100e25 <__intr_save+0x23>
        intr_disable();
  100e19:	e8 a8 08 00 00       	call   1016c6 <intr_disable>
        return 1;
  100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  100e23:	eb 05                	jmp    100e2a <__intr_save+0x28>
    }
    return 0;
  100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e2a:	c9                   	leave  
  100e2b:	c3                   	ret    

00100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e2c:	55                   	push   %ebp
  100e2d:	89 e5                	mov    %esp,%ebp
  100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e36:	74 05                	je     100e3d <__intr_restore+0x11>
        intr_enable();
  100e38:	e8 83 08 00 00       	call   1016c0 <intr_enable>
    }
}
  100e3d:	c9                   	leave  
  100e3e:	c3                   	ret    

00100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e3f:	55                   	push   %ebp
  100e40:	89 e5                	mov    %esp,%ebp
  100e42:	83 ec 10             	sub    $0x10,%esp
  100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e4f:	89 c2                	mov    %eax,%edx
  100e51:	ec                   	in     (%dx),%al
  100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5f:	89 c2                	mov    %eax,%edx
  100e61:	ec                   	in     (%dx),%al
  100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6f:	89 c2                	mov    %eax,%edx
  100e71:	ec                   	in     (%dx),%al
  100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e7f:	89 c2                	mov    %eax,%edx
  100e81:	ec                   	in     (%dx),%al
  100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e85:	c9                   	leave  
  100e86:	c3                   	ret    

00100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e87:	55                   	push   %ebp
  100e88:	89 e5                	mov    %esp,%ebp
  100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 00             	movzwl (%eax),%eax
  100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea9:	0f b7 00             	movzwl (%eax),%eax
  100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100eb0:	74 12                	je     100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eb9:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ec0:	b4 03 
  100ec2:	eb 13                	jmp    100ed7 <cga_init+0x50>
    } else {
        *cp = was;
  100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ece:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ed7:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ede:	0f b7 c0             	movzwl %ax,%eax
  100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ef2:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ef9:	83 c0 01             	add    $0x1,%eax
  100efc:	0f b7 c0             	movzwl %ax,%eax
  100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f07:	89 c2                	mov    %eax,%edx
  100f09:	ec                   	in     (%dx),%al
  100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f11:	0f b6 c0             	movzbl %al,%eax
  100f14:	c1 e0 08             	shl    $0x8,%eax
  100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f1a:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f21:	0f b7 c0             	movzwl %ax,%eax
  100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f35:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f3c:	83 c0 01             	add    $0x1,%eax
  100f3f:	0f b7 c0             	movzwl %ax,%eax
  100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f4a:	89 c2                	mov    %eax,%edx
  100f4c:	ec                   	in     (%dx),%al
  100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f54:	0f b6 c0             	movzbl %al,%eax
  100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f5d:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f65:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f6b:	c9                   	leave  
  100f6c:	c3                   	ret    

00100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f6d:	55                   	push   %ebp
  100f6e:	89 e5                	mov    %esp,%ebp
  100f70:	83 ec 48             	sub    $0x48,%esp
  100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f85:	ee                   	out    %al,(%dx)
  100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f98:	ee                   	out    %al,(%dx)
  100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fab:	ee                   	out    %al,(%dx)
  100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fbe:	ee                   	out    %al,(%dx)
  100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fd1:	ee                   	out    %al,(%dx)
  100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
  100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100ff7:	ee                   	out    %al,(%dx)
  100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  101002:	89 c2                	mov    %eax,%edx
  101004:	ec                   	in     (%dx),%al
  101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10100c:	3c ff                	cmp    $0xff,%al
  10100e:	0f 95 c0             	setne  %al
  101011:	0f b6 c0             	movzbl %al,%eax
  101014:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101023:	89 c2                	mov    %eax,%edx
  101025:	ec                   	in     (%dx),%al
  101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101033:	89 c2                	mov    %eax,%edx
  101035:	ec                   	in     (%dx),%al
  101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101039:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10103e:	85 c0                	test   %eax,%eax
  101040:	74 0c                	je     10104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101049:	e8 d6 06 00 00       	call   101724 <pic_enable>
    }
}
  10104e:	c9                   	leave  
  10104f:	c3                   	ret    

00101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101050:	55                   	push   %ebp
  101051:	89 e5                	mov    %esp,%ebp
  101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10105d:	eb 09                	jmp    101068 <lpt_putc_sub+0x18>
        delay();
  10105f:	e8 db fd ff ff       	call   100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101072:	89 c2                	mov    %eax,%edx
  101074:	ec                   	in     (%dx),%al
  101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10107c:	84 c0                	test   %al,%al
  10107e:	78 09                	js     101089 <lpt_putc_sub+0x39>
  101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101087:	7e d6                	jle    10105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101089:	8b 45 08             	mov    0x8(%ebp),%eax
  10108c:	0f b6 c0             	movzbl %al,%eax
  10108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010a0:	ee                   	out    %al,(%dx)
  1010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010b3:	ee                   	out    %al,(%dx)
  1010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010c7:	c9                   	leave  
  1010c8:	c3                   	ret    

001010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010c9:	55                   	push   %ebp
  1010ca:	89 e5                	mov    %esp,%ebp
  1010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010d3:	74 0d                	je     1010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d8:	89 04 24             	mov    %eax,(%esp)
  1010db:	e8 70 ff ff ff       	call   101050 <lpt_putc_sub>
  1010e0:	eb 24                	jmp    101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e9:	e8 62 ff ff ff       	call   101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010f5:	e8 56 ff ff ff       	call   101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101101:	e8 4a ff ff ff       	call   101050 <lpt_putc_sub>
    }
}
  101106:	c9                   	leave  
  101107:	c3                   	ret    

00101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101108:	55                   	push   %ebp
  101109:	89 e5                	mov    %esp,%ebp
  10110b:	53                   	push   %ebx
  10110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10110f:	8b 45 08             	mov    0x8(%ebp),%eax
  101112:	b0 00                	mov    $0x0,%al
  101114:	85 c0                	test   %eax,%eax
  101116:	75 07                	jne    10111f <cga_putc+0x17>
        c |= 0x0700;
  101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10111f:	8b 45 08             	mov    0x8(%ebp),%eax
  101122:	0f b6 c0             	movzbl %al,%eax
  101125:	83 f8 0a             	cmp    $0xa,%eax
  101128:	74 4c                	je     101176 <cga_putc+0x6e>
  10112a:	83 f8 0d             	cmp    $0xd,%eax
  10112d:	74 57                	je     101186 <cga_putc+0x7e>
  10112f:	83 f8 08             	cmp    $0x8,%eax
  101132:	0f 85 88 00 00 00    	jne    1011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101138:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10113f:	66 85 c0             	test   %ax,%ax
  101142:	74 30                	je     101174 <cga_putc+0x6c>
            crt_pos --;
  101144:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10114b:	83 e8 01             	sub    $0x1,%eax
  10114e:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101154:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101159:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  101160:	0f b7 d2             	movzwl %dx,%edx
  101163:	01 d2                	add    %edx,%edx
  101165:	01 c2                	add    %eax,%edx
  101167:	8b 45 08             	mov    0x8(%ebp),%eax
  10116a:	b0 00                	mov    $0x0,%al
  10116c:	83 c8 20             	or     $0x20,%eax
  10116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101172:	eb 72                	jmp    1011e6 <cga_putc+0xde>
  101174:	eb 70                	jmp    1011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101176:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10117d:	83 c0 50             	add    $0x50,%eax
  101180:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101186:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  10118d:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101194:	0f b7 c1             	movzwl %cx,%eax
  101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10119d:	c1 e8 10             	shr    $0x10,%eax
  1011a0:	89 c2                	mov    %eax,%edx
  1011a2:	66 c1 ea 06          	shr    $0x6,%dx
  1011a6:	89 d0                	mov    %edx,%eax
  1011a8:	c1 e0 02             	shl    $0x2,%eax
  1011ab:	01 d0                	add    %edx,%eax
  1011ad:	c1 e0 04             	shl    $0x4,%eax
  1011b0:	29 c1                	sub    %eax,%ecx
  1011b2:	89 ca                	mov    %ecx,%edx
  1011b4:	89 d8                	mov    %ebx,%eax
  1011b6:	29 d0                	sub    %edx,%eax
  1011b8:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011be:	eb 26                	jmp    1011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011c0:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011c6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011cd:	8d 50 01             	lea    0x1(%eax),%edx
  1011d0:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011d7:	0f b7 c0             	movzwl %ax,%eax
  1011da:	01 c0                	add    %eax,%eax
  1011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011df:	8b 45 08             	mov    0x8(%ebp),%eax
  1011e2:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011f1:	76 5b                	jbe    10124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f3:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011fe:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120a:	00 
  10120b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120f:	89 04 24             	mov    %eax,(%esp)
  101212:	e8 03 4c 00 00       	call   105e1a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121e:	eb 15                	jmp    101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  101220:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101228:	01 d2                	add    %edx,%edx
  10122a:	01 d0                	add    %edx,%eax
  10122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123c:	7e e2                	jle    101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10123e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101245:	83 e8 50             	sub    $0x50,%eax
  101248:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124e:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101255:	0f b7 c0             	movzwl %ax,%eax
  101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101269:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101270:	66 c1 e8 08          	shr    $0x8,%ax
  101274:	0f b6 c0             	movzbl %al,%eax
  101277:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10127e:	83 c2 01             	add    $0x1,%edx
  101281:	0f b7 d2             	movzwl %dx,%edx
  101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101288:	88 45 ed             	mov    %al,-0x13(%ebp)
  10128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101294:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10129b:	0f b7 c0             	movzwl %ax,%eax
  10129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012af:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012b6:	0f b6 c0             	movzbl %al,%eax
  1012b9:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012c0:	83 c2 01             	add    $0x1,%edx
  1012c3:	0f b7 d2             	movzwl %dx,%edx
  1012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012d5:	ee                   	out    %al,(%dx)
}
  1012d6:	83 c4 34             	add    $0x34,%esp
  1012d9:	5b                   	pop    %ebx
  1012da:	5d                   	pop    %ebp
  1012db:	c3                   	ret    

001012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012dc:	55                   	push   %ebp
  1012dd:	89 e5                	mov    %esp,%ebp
  1012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e9:	eb 09                	jmp    1012f4 <serial_putc_sub+0x18>
        delay();
  1012eb:	e8 4f fb ff ff       	call   100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fe:	89 c2                	mov    %eax,%edx
  101300:	ec                   	in     (%dx),%al
  101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101308:	0f b6 c0             	movzbl %al,%eax
  10130b:	83 e0 20             	and    $0x20,%eax
  10130e:	85 c0                	test   %eax,%eax
  101310:	75 09                	jne    10131b <serial_putc_sub+0x3f>
  101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101319:	7e d0                	jle    1012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  10131b:	8b 45 08             	mov    0x8(%ebp),%eax
  10131e:	0f b6 c0             	movzbl %al,%eax
  101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101332:	ee                   	out    %al,(%dx)
}
  101333:	c9                   	leave  
  101334:	c3                   	ret    

00101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101335:	55                   	push   %ebp
  101336:	89 e5                	mov    %esp,%ebp
  101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133f:	74 0d                	je     10134e <serial_putc+0x19>
        serial_putc_sub(c);
  101341:	8b 45 08             	mov    0x8(%ebp),%eax
  101344:	89 04 24             	mov    %eax,(%esp)
  101347:	e8 90 ff ff ff       	call   1012dc <serial_putc_sub>
  10134c:	eb 24                	jmp    101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  10134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101355:	e8 82 ff ff ff       	call   1012dc <serial_putc_sub>
        serial_putc_sub(' ');
  10135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101361:	e8 76 ff ff ff       	call   1012dc <serial_putc_sub>
        serial_putc_sub('\b');
  101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136d:	e8 6a ff ff ff       	call   1012dc <serial_putc_sub>
    }
}
  101372:	c9                   	leave  
  101373:	c3                   	ret    

00101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101374:	55                   	push   %ebp
  101375:	89 e5                	mov    %esp,%ebp
  101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10137a:	eb 33                	jmp    1013af <cons_intr+0x3b>
        if (c != 0) {
  10137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101380:	74 2d                	je     1013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101382:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101387:	8d 50 01             	lea    0x1(%eax),%edx
  10138a:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101393:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101399:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10139e:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a3:	75 0a                	jne    1013af <cons_intr+0x3b>
                cons.wpos = 0;
  1013a5:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013af:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b2:	ff d0                	call   *%eax
  1013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013bb:	75 bf                	jne    10137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013bd:	c9                   	leave  
  1013be:	c3                   	ret    

001013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013bf:	55                   	push   %ebp
  1013c0:	89 e5                	mov    %esp,%ebp
  1013c2:	83 ec 10             	sub    $0x10,%esp
  1013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cf:	89 c2                	mov    %eax,%edx
  1013d1:	ec                   	in     (%dx),%al
  1013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d9:	0f b6 c0             	movzbl %al,%eax
  1013dc:	83 e0 01             	and    $0x1,%eax
  1013df:	85 c0                	test   %eax,%eax
  1013e1:	75 07                	jne    1013ea <serial_proc_data+0x2b>
        return -1;
  1013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e8:	eb 2a                	jmp    101414 <serial_proc_data+0x55>
  1013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013f4:	89 c2                	mov    %eax,%edx
  1013f6:	ec                   	in     (%dx),%al
  1013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013fe:	0f b6 c0             	movzbl %al,%eax
  101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101408:	75 07                	jne    101411 <serial_proc_data+0x52>
        c = '\b';
  10140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101414:	c9                   	leave  
  101415:	c3                   	ret    

00101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101416:	55                   	push   %ebp
  101417:	89 e5                	mov    %esp,%ebp
  101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10141c:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101421:	85 c0                	test   %eax,%eax
  101423:	74 0c                	je     101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101425:	c7 04 24 bf 13 10 00 	movl   $0x1013bf,(%esp)
  10142c:	e8 43 ff ff ff       	call   101374 <cons_intr>
    }
}
  101431:	c9                   	leave  
  101432:	c3                   	ret    

00101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101433:	55                   	push   %ebp
  101434:	89 e5                	mov    %esp,%ebp
  101436:	83 ec 38             	sub    $0x38,%esp
  101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101443:	89 c2                	mov    %eax,%edx
  101445:	ec                   	in     (%dx),%al
  101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10144d:	0f b6 c0             	movzbl %al,%eax
  101450:	83 e0 01             	and    $0x1,%eax
  101453:	85 c0                	test   %eax,%eax
  101455:	75 0a                	jne    101461 <kbd_proc_data+0x2e>
        return -1;
  101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10145c:	e9 59 01 00 00       	jmp    1015ba <kbd_proc_data+0x187>
  101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10146b:	89 c2                	mov    %eax,%edx
  10146d:	ec                   	in     (%dx),%al
  10146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10147c:	75 17                	jne    101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10147e:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101483:	83 c8 40             	or     $0x40,%eax
  101486:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  10148b:	b8 00 00 00 00       	mov    $0x0,%eax
  101490:	e9 25 01 00 00       	jmp    1015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101499:	84 c0                	test   %al,%al
  10149b:	79 47                	jns    1014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014a2:	83 e0 40             	and    $0x40,%eax
  1014a5:	85 c0                	test   %eax,%eax
  1014a7:	75 09                	jne    1014b2 <kbd_proc_data+0x7f>
  1014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ad:	83 e0 7f             	and    $0x7f,%eax
  1014b0:	eb 04                	jmp    1014b6 <kbd_proc_data+0x83>
  1014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bd:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014c4:	83 c8 40             	or     $0x40,%eax
  1014c7:	0f b6 c0             	movzbl %al,%eax
  1014ca:	f7 d0                	not    %eax
  1014cc:	89 c2                	mov    %eax,%edx
  1014ce:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d3:	21 d0                	and    %edx,%eax
  1014d5:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014da:	b8 00 00 00 00       	mov    $0x0,%eax
  1014df:	e9 d6 00 00 00       	jmp    1015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014e4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014e9:	83 e0 40             	and    $0x40,%eax
  1014ec:	85 c0                	test   %eax,%eax
  1014ee:	74 11                	je     101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f9:	83 e0 bf             	and    $0xffffffbf,%eax
  1014fc:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101505:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  10150c:	0f b6 d0             	movzbl %al,%edx
  10150f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101514:	09 d0                	or     %edx,%eax
  101516:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  10151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151f:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101526:	0f b6 d0             	movzbl %al,%edx
  101529:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152e:	31 d0                	xor    %edx,%eax
  101530:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101535:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10153a:	83 e0 03             	and    $0x3,%eax
  10153d:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101548:	01 d0                	add    %edx,%eax
  10154a:	0f b6 00             	movzbl (%eax),%eax
  10154d:	0f b6 c0             	movzbl %al,%eax
  101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101553:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101558:	83 e0 08             	and    $0x8,%eax
  10155b:	85 c0                	test   %eax,%eax
  10155d:	74 22                	je     101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101563:	7e 0c                	jle    101571 <kbd_proc_data+0x13e>
  101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101569:	7f 06                	jg     101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10156f:	eb 10                	jmp    101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101575:	7e 0a                	jle    101581 <kbd_proc_data+0x14e>
  101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10157b:	7f 04                	jg     101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101581:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101586:	f7 d0                	not    %eax
  101588:	83 e0 06             	and    $0x6,%eax
  10158b:	85 c0                	test   %eax,%eax
  10158d:	75 28                	jne    1015b7 <kbd_proc_data+0x184>
  10158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101596:	75 1f                	jne    1015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101598:	c7 04 24 af 62 10 00 	movl   $0x1062af,(%esp)
  10159f:	e8 a4 ed ff ff       	call   100348 <cprintf>
  1015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015ba:	c9                   	leave  
  1015bb:	c3                   	ret    

001015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015bc:	55                   	push   %ebp
  1015bd:	89 e5                	mov    %esp,%ebp
  1015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015c2:	c7 04 24 33 14 10 00 	movl   $0x101433,(%esp)
  1015c9:	e8 a6 fd ff ff       	call   101374 <cons_intr>
}
  1015ce:	c9                   	leave  
  1015cf:	c3                   	ret    

001015d0 <kbd_init>:

static void
kbd_init(void) {
  1015d0:	55                   	push   %ebp
  1015d1:	89 e5                	mov    %esp,%ebp
  1015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015d6:	e8 e1 ff ff ff       	call   1015bc <kbd_intr>
    pic_enable(IRQ_KBD);
  1015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015e2:	e8 3d 01 00 00       	call   101724 <pic_enable>
}
  1015e7:	c9                   	leave  
  1015e8:	c3                   	ret    

001015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e9:	55                   	push   %ebp
  1015ea:	89 e5                	mov    %esp,%ebp
  1015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ef:	e8 93 f8 ff ff       	call   100e87 <cga_init>
    serial_init();
  1015f4:	e8 74 f9 ff ff       	call   100f6d <serial_init>
    kbd_init();
  1015f9:	e8 d2 ff ff ff       	call   1015d0 <kbd_init>
    if (!serial_exists) {
  1015fe:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101603:	85 c0                	test   %eax,%eax
  101605:	75 0c                	jne    101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101607:	c7 04 24 bb 62 10 00 	movl   $0x1062bb,(%esp)
  10160e:	e8 35 ed ff ff       	call   100348 <cprintf>
    }
}
  101613:	c9                   	leave  
  101614:	c3                   	ret    

00101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101615:	55                   	push   %ebp
  101616:	89 e5                	mov    %esp,%ebp
  101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10161b:	e8 e2 f7 ff ff       	call   100e02 <__intr_save>
  101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101623:	8b 45 08             	mov    0x8(%ebp),%eax
  101626:	89 04 24             	mov    %eax,(%esp)
  101629:	e8 9b fa ff ff       	call   1010c9 <lpt_putc>
        cga_putc(c);
  10162e:	8b 45 08             	mov    0x8(%ebp),%eax
  101631:	89 04 24             	mov    %eax,(%esp)
  101634:	e8 cf fa ff ff       	call   101108 <cga_putc>
        serial_putc(c);
  101639:	8b 45 08             	mov    0x8(%ebp),%eax
  10163c:	89 04 24             	mov    %eax,(%esp)
  10163f:	e8 f1 fc ff ff       	call   101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101647:	89 04 24             	mov    %eax,(%esp)
  10164a:	e8 dd f7 ff ff       	call   100e2c <__intr_restore>
}
  10164f:	c9                   	leave  
  101650:	c3                   	ret    

00101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101651:	55                   	push   %ebp
  101652:	89 e5                	mov    %esp,%ebp
  101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10165e:	e8 9f f7 ff ff       	call   100e02 <__intr_save>
  101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101666:	e8 ab fd ff ff       	call   101416 <serial_intr>
        kbd_intr();
  10166b:	e8 4c ff ff ff       	call   1015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101670:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101676:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10167b:	39 c2                	cmp    %eax,%edx
  10167d:	74 31                	je     1016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167f:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101684:	8d 50 01             	lea    0x1(%eax),%edx
  101687:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  10168d:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101694:	0f b6 c0             	movzbl %al,%eax
  101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10169a:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169f:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a4:	75 0a                	jne    1016b0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016a6:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016b3:	89 04 24             	mov    %eax,(%esp)
  1016b6:	e8 71 f7 ff ff       	call   100e2c <__intr_restore>
    return c;
  1016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016be:	c9                   	leave  
  1016bf:	c3                   	ret    

001016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016c0:	55                   	push   %ebp
  1016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016c3:	fb                   	sti    
    sti();
}
  1016c4:	5d                   	pop    %ebp
  1016c5:	c3                   	ret    

001016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016c6:	55                   	push   %ebp
  1016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016c9:	fa                   	cli    
    cli();
}
  1016ca:	5d                   	pop    %ebp
  1016cb:	c3                   	ret    

001016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016cc:	55                   	push   %ebp
  1016cd:	89 e5                	mov    %esp,%ebp
  1016cf:	83 ec 14             	sub    $0x14,%esp
  1016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016dd:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016e3:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016e8:	85 c0                	test   %eax,%eax
  1016ea:	74 36                	je     101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f0:	0f b6 c0             	movzbl %al,%eax
  1016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101709:	66 c1 e8 08          	shr    $0x8,%ax
  10170d:	0f b6 c0             	movzbl %al,%eax
  101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101716:	88 45 f9             	mov    %al,-0x7(%ebp)
  101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101721:	ee                   	out    %al,(%dx)
    }
}
  101722:	c9                   	leave  
  101723:	c3                   	ret    

00101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101724:	55                   	push   %ebp
  101725:	89 e5                	mov    %esp,%ebp
  101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10172a:	8b 45 08             	mov    0x8(%ebp),%eax
  10172d:	ba 01 00 00 00       	mov    $0x1,%edx
  101732:	89 c1                	mov    %eax,%ecx
  101734:	d3 e2                	shl    %cl,%edx
  101736:	89 d0                	mov    %edx,%eax
  101738:	f7 d0                	not    %eax
  10173a:	89 c2                	mov    %eax,%edx
  10173c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101743:	21 d0                	and    %edx,%eax
  101745:	0f b7 c0             	movzwl %ax,%eax
  101748:	89 04 24             	mov    %eax,(%esp)
  10174b:	e8 7c ff ff ff       	call   1016cc <pic_setmask>
}
  101750:	c9                   	leave  
  101751:	c3                   	ret    

00101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101752:	55                   	push   %ebp
  101753:	89 e5                	mov    %esp,%ebp
  101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101758:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10175f:	00 00 00 
  101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101774:	ee                   	out    %al,(%dx)
  101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101787:	ee                   	out    %al,(%dx)
  101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10179a:	ee                   	out    %al,(%dx)
  10179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017ad:	ee                   	out    %al,(%dx)
  1017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017c0:	ee                   	out    %al,(%dx)
  1017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017d3:	ee                   	out    %al,(%dx)
  1017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017e6:	ee                   	out    %al,(%dx)
  1017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f9:	ee                   	out    %al,(%dx)
  1017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10180c:	ee                   	out    %al,(%dx)
  10180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10181f:	ee                   	out    %al,(%dx)
  101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101832:	ee                   	out    %al,(%dx)
  101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  10183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101845:	ee                   	out    %al,(%dx)
  101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101858:	ee                   	out    %al,(%dx)
  101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10186c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101873:	66 83 f8 ff          	cmp    $0xffff,%ax
  101877:	74 12                	je     10188b <pic_init+0x139>
        pic_setmask(irq_mask);
  101879:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101880:	0f b7 c0             	movzwl %ax,%eax
  101883:	89 04 24             	mov    %eax,(%esp)
  101886:	e8 41 fe ff ff       	call   1016cc <pic_setmask>
    }
}
  10188b:	c9                   	leave  
  10188c:	c3                   	ret    

0010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10188d:	55                   	push   %ebp
  10188e:	89 e5                	mov    %esp,%ebp
  101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10189a:	00 
  10189b:	c7 04 24 e0 62 10 00 	movl   $0x1062e0,(%esp)
  1018a2:	e8 a1 ea ff ff       	call   100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018a7:	c9                   	leave  
  1018a8:	c3                   	ret    

001018a9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018a9:	55                   	push   %ebp
  1018aa:	89 e5                	mov    %esp,%ebp
  1018ac:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018b6:	e9 c3 00 00 00       	jmp    10197e <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018be:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018c5:	89 c2                	mov    %eax,%edx
  1018c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ca:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018d1:	00 
  1018d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d5:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018dc:	00 08 00 
  1018df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e2:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018e9:	00 
  1018ea:	83 e2 e0             	and    $0xffffffe0,%edx
  1018ed:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f7:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018fe:	00 
  1018ff:	83 e2 1f             	and    $0x1f,%edx
  101902:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101909:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190c:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101913:	00 
  101914:	83 e2 f0             	and    $0xfffffff0,%edx
  101917:	83 ca 0e             	or     $0xe,%edx
  10191a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101921:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101924:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10192b:	00 
  10192c:	83 e2 ef             	and    $0xffffffef,%edx
  10192f:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101936:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101939:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101940:	00 
  101941:	83 e2 9f             	and    $0xffffff9f,%edx
  101944:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10194b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194e:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101955:	00 
  101956:	83 ca 80             	or     $0xffffff80,%edx
  101959:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101960:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101963:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  10196a:	c1 e8 10             	shr    $0x10,%eax
  10196d:	89 c2                	mov    %eax,%edx
  10196f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101972:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  101979:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10197a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10197e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101981:	3d ff 00 00 00       	cmp    $0xff,%eax
  101986:	0f 86 2f ff ff ff    	jbe    1018bb <idt_init+0x12>
  10198c:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101993:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101996:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
  101999:	c9                   	leave  
  10199a:	c3                   	ret    

0010199b <trapname>:

static const char *
trapname(int trapno) {
  10199b:	55                   	push   %ebp
  10199c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  10199e:	8b 45 08             	mov    0x8(%ebp),%eax
  1019a1:	83 f8 13             	cmp    $0x13,%eax
  1019a4:	77 0c                	ja     1019b2 <trapname+0x17>
        return excnames[trapno];
  1019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1019a9:	8b 04 85 40 66 10 00 	mov    0x106640(,%eax,4),%eax
  1019b0:	eb 18                	jmp    1019ca <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019b2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019b6:	7e 0d                	jle    1019c5 <trapname+0x2a>
  1019b8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019bc:	7f 07                	jg     1019c5 <trapname+0x2a>
        return "Hardware Interrupt";
  1019be:	b8 ea 62 10 00       	mov    $0x1062ea,%eax
  1019c3:	eb 05                	jmp    1019ca <trapname+0x2f>
    }
    return "(unknown trap)";
  1019c5:	b8 fd 62 10 00       	mov    $0x1062fd,%eax
}
  1019ca:	5d                   	pop    %ebp
  1019cb:	c3                   	ret    

001019cc <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019cc:	55                   	push   %ebp
  1019cd:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1019d2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019d6:	66 83 f8 08          	cmp    $0x8,%ax
  1019da:	0f 94 c0             	sete   %al
  1019dd:	0f b6 c0             	movzbl %al,%eax
}
  1019e0:	5d                   	pop    %ebp
  1019e1:	c3                   	ret    

001019e2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019e2:	55                   	push   %ebp
  1019e3:	89 e5                	mov    %esp,%ebp
  1019e5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019ef:	c7 04 24 3e 63 10 00 	movl   $0x10633e,(%esp)
  1019f6:	e8 4d e9 ff ff       	call   100348 <cprintf>
    print_regs(&tf->tf_regs);
  1019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1019fe:	89 04 24             	mov    %eax,(%esp)
  101a01:	e8 a1 01 00 00       	call   101ba7 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a06:	8b 45 08             	mov    0x8(%ebp),%eax
  101a09:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a0d:	0f b7 c0             	movzwl %ax,%eax
  101a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a14:	c7 04 24 4f 63 10 00 	movl   $0x10634f,(%esp)
  101a1b:	e8 28 e9 ff ff       	call   100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a20:	8b 45 08             	mov    0x8(%ebp),%eax
  101a23:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a27:	0f b7 c0             	movzwl %ax,%eax
  101a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a2e:	c7 04 24 62 63 10 00 	movl   $0x106362,(%esp)
  101a35:	e8 0e e9 ff ff       	call   100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a41:	0f b7 c0             	movzwl %ax,%eax
  101a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a48:	c7 04 24 75 63 10 00 	movl   $0x106375,(%esp)
  101a4f:	e8 f4 e8 ff ff       	call   100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a54:	8b 45 08             	mov    0x8(%ebp),%eax
  101a57:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a5b:	0f b7 c0             	movzwl %ax,%eax
  101a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a62:	c7 04 24 88 63 10 00 	movl   $0x106388,(%esp)
  101a69:	e8 da e8 ff ff       	call   100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a71:	8b 40 30             	mov    0x30(%eax),%eax
  101a74:	89 04 24             	mov    %eax,(%esp)
  101a77:	e8 1f ff ff ff       	call   10199b <trapname>
  101a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  101a7f:	8b 52 30             	mov    0x30(%edx),%edx
  101a82:	89 44 24 08          	mov    %eax,0x8(%esp)
  101a86:	89 54 24 04          	mov    %edx,0x4(%esp)
  101a8a:	c7 04 24 9b 63 10 00 	movl   $0x10639b,(%esp)
  101a91:	e8 b2 e8 ff ff       	call   100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a96:	8b 45 08             	mov    0x8(%ebp),%eax
  101a99:	8b 40 34             	mov    0x34(%eax),%eax
  101a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa0:	c7 04 24 ad 63 10 00 	movl   $0x1063ad,(%esp)
  101aa7:	e8 9c e8 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101aac:	8b 45 08             	mov    0x8(%ebp),%eax
  101aaf:	8b 40 38             	mov    0x38(%eax),%eax
  101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab6:	c7 04 24 bc 63 10 00 	movl   $0x1063bc,(%esp)
  101abd:	e8 86 e8 ff ff       	call   100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ac9:	0f b7 c0             	movzwl %ax,%eax
  101acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad0:	c7 04 24 cb 63 10 00 	movl   $0x1063cb,(%esp)
  101ad7:	e8 6c e8 ff ff       	call   100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101adc:	8b 45 08             	mov    0x8(%ebp),%eax
  101adf:	8b 40 40             	mov    0x40(%eax),%eax
  101ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae6:	c7 04 24 de 63 10 00 	movl   $0x1063de,(%esp)
  101aed:	e8 56 e8 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101af9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b00:	eb 3e                	jmp    101b40 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b02:	8b 45 08             	mov    0x8(%ebp),%eax
  101b05:	8b 50 40             	mov    0x40(%eax),%edx
  101b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b0b:	21 d0                	and    %edx,%eax
  101b0d:	85 c0                	test   %eax,%eax
  101b0f:	74 28                	je     101b39 <print_trapframe+0x157>
  101b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b14:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b1b:	85 c0                	test   %eax,%eax
  101b1d:	74 1a                	je     101b39 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b22:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b2d:	c7 04 24 ed 63 10 00 	movl   $0x1063ed,(%esp)
  101b34:	e8 0f e8 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b3d:	d1 65 f0             	shll   -0x10(%ebp)
  101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b43:	83 f8 17             	cmp    $0x17,%eax
  101b46:	76 ba                	jbe    101b02 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b48:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4b:	8b 40 40             	mov    0x40(%eax),%eax
  101b4e:	25 00 30 00 00       	and    $0x3000,%eax
  101b53:	c1 e8 0c             	shr    $0xc,%eax
  101b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5a:	c7 04 24 f1 63 10 00 	movl   $0x1063f1,(%esp)
  101b61:	e8 e2 e7 ff ff       	call   100348 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b66:	8b 45 08             	mov    0x8(%ebp),%eax
  101b69:	89 04 24             	mov    %eax,(%esp)
  101b6c:	e8 5b fe ff ff       	call   1019cc <trap_in_kernel>
  101b71:	85 c0                	test   %eax,%eax
  101b73:	75 30                	jne    101ba5 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b75:	8b 45 08             	mov    0x8(%ebp),%eax
  101b78:	8b 40 44             	mov    0x44(%eax),%eax
  101b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7f:	c7 04 24 fa 63 10 00 	movl   $0x1063fa,(%esp)
  101b86:	e8 bd e7 ff ff       	call   100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b92:	0f b7 c0             	movzwl %ax,%eax
  101b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b99:	c7 04 24 09 64 10 00 	movl   $0x106409,(%esp)
  101ba0:	e8 a3 e7 ff ff       	call   100348 <cprintf>
    }
}
  101ba5:	c9                   	leave  
  101ba6:	c3                   	ret    

00101ba7 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101ba7:	55                   	push   %ebp
  101ba8:	89 e5                	mov    %esp,%ebp
  101baa:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bad:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb0:	8b 00                	mov    (%eax),%eax
  101bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb6:	c7 04 24 1c 64 10 00 	movl   $0x10641c,(%esp)
  101bbd:	e8 86 e7 ff ff       	call   100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc5:	8b 40 04             	mov    0x4(%eax),%eax
  101bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bcc:	c7 04 24 2b 64 10 00 	movl   $0x10642b,(%esp)
  101bd3:	e8 70 e7 ff ff       	call   100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdb:	8b 40 08             	mov    0x8(%eax),%eax
  101bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be2:	c7 04 24 3a 64 10 00 	movl   $0x10643a,(%esp)
  101be9:	e8 5a e7 ff ff       	call   100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bee:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf1:	8b 40 0c             	mov    0xc(%eax),%eax
  101bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf8:	c7 04 24 49 64 10 00 	movl   $0x106449,(%esp)
  101bff:	e8 44 e7 ff ff       	call   100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c04:	8b 45 08             	mov    0x8(%ebp),%eax
  101c07:	8b 40 10             	mov    0x10(%eax),%eax
  101c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0e:	c7 04 24 58 64 10 00 	movl   $0x106458,(%esp)
  101c15:	e8 2e e7 ff ff       	call   100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1d:	8b 40 14             	mov    0x14(%eax),%eax
  101c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c24:	c7 04 24 67 64 10 00 	movl   $0x106467,(%esp)
  101c2b:	e8 18 e7 ff ff       	call   100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c30:	8b 45 08             	mov    0x8(%ebp),%eax
  101c33:	8b 40 18             	mov    0x18(%eax),%eax
  101c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3a:	c7 04 24 76 64 10 00 	movl   $0x106476,(%esp)
  101c41:	e8 02 e7 ff ff       	call   100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c46:	8b 45 08             	mov    0x8(%ebp),%eax
  101c49:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c50:	c7 04 24 85 64 10 00 	movl   $0x106485,(%esp)
  101c57:	e8 ec e6 ff ff       	call   100348 <cprintf>
}
  101c5c:	c9                   	leave  
  101c5d:	c3                   	ret    

00101c5e <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c5e:	55                   	push   %ebp
  101c5f:	89 e5                	mov    %esp,%ebp
  101c61:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c64:	8b 45 08             	mov    0x8(%ebp),%eax
  101c67:	8b 40 30             	mov    0x30(%eax),%eax
  101c6a:	83 f8 2f             	cmp    $0x2f,%eax
  101c6d:	77 21                	ja     101c90 <trap_dispatch+0x32>
  101c6f:	83 f8 2e             	cmp    $0x2e,%eax
  101c72:	0f 83 04 01 00 00    	jae    101d7c <trap_dispatch+0x11e>
  101c78:	83 f8 21             	cmp    $0x21,%eax
  101c7b:	0f 84 81 00 00 00    	je     101d02 <trap_dispatch+0xa4>
  101c81:	83 f8 24             	cmp    $0x24,%eax
  101c84:	74 56                	je     101cdc <trap_dispatch+0x7e>
  101c86:	83 f8 20             	cmp    $0x20,%eax
  101c89:	74 16                	je     101ca1 <trap_dispatch+0x43>
  101c8b:	e9 b4 00 00 00       	jmp    101d44 <trap_dispatch+0xe6>
  101c90:	83 e8 78             	sub    $0x78,%eax
  101c93:	83 f8 01             	cmp    $0x1,%eax
  101c96:	0f 87 a8 00 00 00    	ja     101d44 <trap_dispatch+0xe6>
  101c9c:	e9 87 00 00 00       	jmp    101d28 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101ca1:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101ca6:	83 c0 01             	add    $0x1,%eax
  101ca9:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if (ticks % TICK_NUM == 0) {
  101cae:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101cb4:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cb9:	89 c8                	mov    %ecx,%eax
  101cbb:	f7 e2                	mul    %edx
  101cbd:	89 d0                	mov    %edx,%eax
  101cbf:	c1 e8 05             	shr    $0x5,%eax
  101cc2:	6b c0 64             	imul   $0x64,%eax,%eax
  101cc5:	29 c1                	sub    %eax,%ecx
  101cc7:	89 c8                	mov    %ecx,%eax
  101cc9:	85 c0                	test   %eax,%eax
  101ccb:	75 0a                	jne    101cd7 <trap_dispatch+0x79>
            print_ticks();
  101ccd:	e8 bb fb ff ff       	call   10188d <print_ticks>
        }
        break;
  101cd2:	e9 a6 00 00 00       	jmp    101d7d <trap_dispatch+0x11f>
  101cd7:	e9 a1 00 00 00       	jmp    101d7d <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cdc:	e8 70 f9 ff ff       	call   101651 <cons_getc>
  101ce1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101ce4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ce8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cec:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf4:	c7 04 24 94 64 10 00 	movl   $0x106494,(%esp)
  101cfb:	e8 48 e6 ff ff       	call   100348 <cprintf>
        break;
  101d00:	eb 7b                	jmp    101d7d <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d02:	e8 4a f9 ff ff       	call   101651 <cons_getc>
  101d07:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d0a:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d0e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d12:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d16:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d1a:	c7 04 24 a6 64 10 00 	movl   $0x1064a6,(%esp)
  101d21:	e8 22 e6 ff ff       	call   100348 <cprintf>
        break;
  101d26:	eb 55                	jmp    101d7d <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d28:	c7 44 24 08 b5 64 10 	movl   $0x1064b5,0x8(%esp)
  101d2f:	00 
  101d30:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101d37:	00 
  101d38:	c7 04 24 c5 64 10 00 	movl   $0x1064c5,(%esp)
  101d3f:	e8 8e ef ff ff       	call   100cd2 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d44:	8b 45 08             	mov    0x8(%ebp),%eax
  101d47:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d4b:	0f b7 c0             	movzwl %ax,%eax
  101d4e:	83 e0 03             	and    $0x3,%eax
  101d51:	85 c0                	test   %eax,%eax
  101d53:	75 28                	jne    101d7d <trap_dispatch+0x11f>
            print_trapframe(tf);
  101d55:	8b 45 08             	mov    0x8(%ebp),%eax
  101d58:	89 04 24             	mov    %eax,(%esp)
  101d5b:	e8 82 fc ff ff       	call   1019e2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d60:	c7 44 24 08 d6 64 10 	movl   $0x1064d6,0x8(%esp)
  101d67:	00 
  101d68:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  101d6f:	00 
  101d70:	c7 04 24 c5 64 10 00 	movl   $0x1064c5,(%esp)
  101d77:	e8 56 ef ff ff       	call   100cd2 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101d7c:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101d7d:	c9                   	leave  
  101d7e:	c3                   	ret    

00101d7f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d7f:	55                   	push   %ebp
  101d80:	89 e5                	mov    %esp,%ebp
  101d82:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d85:	8b 45 08             	mov    0x8(%ebp),%eax
  101d88:	89 04 24             	mov    %eax,(%esp)
  101d8b:	e8 ce fe ff ff       	call   101c5e <trap_dispatch>
}
  101d90:	c9                   	leave  
  101d91:	c3                   	ret    

00101d92 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101d92:	1e                   	push   %ds
    pushl %es
  101d93:	06                   	push   %es
    pushl %fs
  101d94:	0f a0                	push   %fs
    pushl %gs
  101d96:	0f a8                	push   %gs
    pushal
  101d98:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101d99:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101d9e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101da0:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101da2:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101da3:	e8 d7 ff ff ff       	call   101d7f <trap>

    # pop the pushed stack pointer
    popl %esp
  101da8:	5c                   	pop    %esp

00101da9 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101da9:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101daa:	0f a9                	pop    %gs
    popl %fs
  101dac:	0f a1                	pop    %fs
    popl %es
  101dae:	07                   	pop    %es
    popl %ds
  101daf:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101db0:	83 c4 08             	add    $0x8,%esp
    iret
  101db3:	cf                   	iret   

00101db4 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101db4:	6a 00                	push   $0x0
  pushl $0
  101db6:	6a 00                	push   $0x0
  jmp __alltraps
  101db8:	e9 d5 ff ff ff       	jmp    101d92 <__alltraps>

00101dbd <vector1>:
.globl vector1
vector1:
  pushl $0
  101dbd:	6a 00                	push   $0x0
  pushl $1
  101dbf:	6a 01                	push   $0x1
  jmp __alltraps
  101dc1:	e9 cc ff ff ff       	jmp    101d92 <__alltraps>

00101dc6 <vector2>:
.globl vector2
vector2:
  pushl $0
  101dc6:	6a 00                	push   $0x0
  pushl $2
  101dc8:	6a 02                	push   $0x2
  jmp __alltraps
  101dca:	e9 c3 ff ff ff       	jmp    101d92 <__alltraps>

00101dcf <vector3>:
.globl vector3
vector3:
  pushl $0
  101dcf:	6a 00                	push   $0x0
  pushl $3
  101dd1:	6a 03                	push   $0x3
  jmp __alltraps
  101dd3:	e9 ba ff ff ff       	jmp    101d92 <__alltraps>

00101dd8 <vector4>:
.globl vector4
vector4:
  pushl $0
  101dd8:	6a 00                	push   $0x0
  pushl $4
  101dda:	6a 04                	push   $0x4
  jmp __alltraps
  101ddc:	e9 b1 ff ff ff       	jmp    101d92 <__alltraps>

00101de1 <vector5>:
.globl vector5
vector5:
  pushl $0
  101de1:	6a 00                	push   $0x0
  pushl $5
  101de3:	6a 05                	push   $0x5
  jmp __alltraps
  101de5:	e9 a8 ff ff ff       	jmp    101d92 <__alltraps>

00101dea <vector6>:
.globl vector6
vector6:
  pushl $0
  101dea:	6a 00                	push   $0x0
  pushl $6
  101dec:	6a 06                	push   $0x6
  jmp __alltraps
  101dee:	e9 9f ff ff ff       	jmp    101d92 <__alltraps>

00101df3 <vector7>:
.globl vector7
vector7:
  pushl $0
  101df3:	6a 00                	push   $0x0
  pushl $7
  101df5:	6a 07                	push   $0x7
  jmp __alltraps
  101df7:	e9 96 ff ff ff       	jmp    101d92 <__alltraps>

00101dfc <vector8>:
.globl vector8
vector8:
  pushl $8
  101dfc:	6a 08                	push   $0x8
  jmp __alltraps
  101dfe:	e9 8f ff ff ff       	jmp    101d92 <__alltraps>

00101e03 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e03:	6a 00                	push   $0x0
  pushl $9
  101e05:	6a 09                	push   $0x9
  jmp __alltraps
  101e07:	e9 86 ff ff ff       	jmp    101d92 <__alltraps>

00101e0c <vector10>:
.globl vector10
vector10:
  pushl $10
  101e0c:	6a 0a                	push   $0xa
  jmp __alltraps
  101e0e:	e9 7f ff ff ff       	jmp    101d92 <__alltraps>

00101e13 <vector11>:
.globl vector11
vector11:
  pushl $11
  101e13:	6a 0b                	push   $0xb
  jmp __alltraps
  101e15:	e9 78 ff ff ff       	jmp    101d92 <__alltraps>

00101e1a <vector12>:
.globl vector12
vector12:
  pushl $12
  101e1a:	6a 0c                	push   $0xc
  jmp __alltraps
  101e1c:	e9 71 ff ff ff       	jmp    101d92 <__alltraps>

00101e21 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e21:	6a 0d                	push   $0xd
  jmp __alltraps
  101e23:	e9 6a ff ff ff       	jmp    101d92 <__alltraps>

00101e28 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e28:	6a 0e                	push   $0xe
  jmp __alltraps
  101e2a:	e9 63 ff ff ff       	jmp    101d92 <__alltraps>

00101e2f <vector15>:
.globl vector15
vector15:
  pushl $0
  101e2f:	6a 00                	push   $0x0
  pushl $15
  101e31:	6a 0f                	push   $0xf
  jmp __alltraps
  101e33:	e9 5a ff ff ff       	jmp    101d92 <__alltraps>

00101e38 <vector16>:
.globl vector16
vector16:
  pushl $0
  101e38:	6a 00                	push   $0x0
  pushl $16
  101e3a:	6a 10                	push   $0x10
  jmp __alltraps
  101e3c:	e9 51 ff ff ff       	jmp    101d92 <__alltraps>

00101e41 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e41:	6a 11                	push   $0x11
  jmp __alltraps
  101e43:	e9 4a ff ff ff       	jmp    101d92 <__alltraps>

00101e48 <vector18>:
.globl vector18
vector18:
  pushl $0
  101e48:	6a 00                	push   $0x0
  pushl $18
  101e4a:	6a 12                	push   $0x12
  jmp __alltraps
  101e4c:	e9 41 ff ff ff       	jmp    101d92 <__alltraps>

00101e51 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e51:	6a 00                	push   $0x0
  pushl $19
  101e53:	6a 13                	push   $0x13
  jmp __alltraps
  101e55:	e9 38 ff ff ff       	jmp    101d92 <__alltraps>

00101e5a <vector20>:
.globl vector20
vector20:
  pushl $0
  101e5a:	6a 00                	push   $0x0
  pushl $20
  101e5c:	6a 14                	push   $0x14
  jmp __alltraps
  101e5e:	e9 2f ff ff ff       	jmp    101d92 <__alltraps>

00101e63 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e63:	6a 00                	push   $0x0
  pushl $21
  101e65:	6a 15                	push   $0x15
  jmp __alltraps
  101e67:	e9 26 ff ff ff       	jmp    101d92 <__alltraps>

00101e6c <vector22>:
.globl vector22
vector22:
  pushl $0
  101e6c:	6a 00                	push   $0x0
  pushl $22
  101e6e:	6a 16                	push   $0x16
  jmp __alltraps
  101e70:	e9 1d ff ff ff       	jmp    101d92 <__alltraps>

00101e75 <vector23>:
.globl vector23
vector23:
  pushl $0
  101e75:	6a 00                	push   $0x0
  pushl $23
  101e77:	6a 17                	push   $0x17
  jmp __alltraps
  101e79:	e9 14 ff ff ff       	jmp    101d92 <__alltraps>

00101e7e <vector24>:
.globl vector24
vector24:
  pushl $0
  101e7e:	6a 00                	push   $0x0
  pushl $24
  101e80:	6a 18                	push   $0x18
  jmp __alltraps
  101e82:	e9 0b ff ff ff       	jmp    101d92 <__alltraps>

00101e87 <vector25>:
.globl vector25
vector25:
  pushl $0
  101e87:	6a 00                	push   $0x0
  pushl $25
  101e89:	6a 19                	push   $0x19
  jmp __alltraps
  101e8b:	e9 02 ff ff ff       	jmp    101d92 <__alltraps>

00101e90 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e90:	6a 00                	push   $0x0
  pushl $26
  101e92:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e94:	e9 f9 fe ff ff       	jmp    101d92 <__alltraps>

00101e99 <vector27>:
.globl vector27
vector27:
  pushl $0
  101e99:	6a 00                	push   $0x0
  pushl $27
  101e9b:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e9d:	e9 f0 fe ff ff       	jmp    101d92 <__alltraps>

00101ea2 <vector28>:
.globl vector28
vector28:
  pushl $0
  101ea2:	6a 00                	push   $0x0
  pushl $28
  101ea4:	6a 1c                	push   $0x1c
  jmp __alltraps
  101ea6:	e9 e7 fe ff ff       	jmp    101d92 <__alltraps>

00101eab <vector29>:
.globl vector29
vector29:
  pushl $0
  101eab:	6a 00                	push   $0x0
  pushl $29
  101ead:	6a 1d                	push   $0x1d
  jmp __alltraps
  101eaf:	e9 de fe ff ff       	jmp    101d92 <__alltraps>

00101eb4 <vector30>:
.globl vector30
vector30:
  pushl $0
  101eb4:	6a 00                	push   $0x0
  pushl $30
  101eb6:	6a 1e                	push   $0x1e
  jmp __alltraps
  101eb8:	e9 d5 fe ff ff       	jmp    101d92 <__alltraps>

00101ebd <vector31>:
.globl vector31
vector31:
  pushl $0
  101ebd:	6a 00                	push   $0x0
  pushl $31
  101ebf:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ec1:	e9 cc fe ff ff       	jmp    101d92 <__alltraps>

00101ec6 <vector32>:
.globl vector32
vector32:
  pushl $0
  101ec6:	6a 00                	push   $0x0
  pushl $32
  101ec8:	6a 20                	push   $0x20
  jmp __alltraps
  101eca:	e9 c3 fe ff ff       	jmp    101d92 <__alltraps>

00101ecf <vector33>:
.globl vector33
vector33:
  pushl $0
  101ecf:	6a 00                	push   $0x0
  pushl $33
  101ed1:	6a 21                	push   $0x21
  jmp __alltraps
  101ed3:	e9 ba fe ff ff       	jmp    101d92 <__alltraps>

00101ed8 <vector34>:
.globl vector34
vector34:
  pushl $0
  101ed8:	6a 00                	push   $0x0
  pushl $34
  101eda:	6a 22                	push   $0x22
  jmp __alltraps
  101edc:	e9 b1 fe ff ff       	jmp    101d92 <__alltraps>

00101ee1 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ee1:	6a 00                	push   $0x0
  pushl $35
  101ee3:	6a 23                	push   $0x23
  jmp __alltraps
  101ee5:	e9 a8 fe ff ff       	jmp    101d92 <__alltraps>

00101eea <vector36>:
.globl vector36
vector36:
  pushl $0
  101eea:	6a 00                	push   $0x0
  pushl $36
  101eec:	6a 24                	push   $0x24
  jmp __alltraps
  101eee:	e9 9f fe ff ff       	jmp    101d92 <__alltraps>

00101ef3 <vector37>:
.globl vector37
vector37:
  pushl $0
  101ef3:	6a 00                	push   $0x0
  pushl $37
  101ef5:	6a 25                	push   $0x25
  jmp __alltraps
  101ef7:	e9 96 fe ff ff       	jmp    101d92 <__alltraps>

00101efc <vector38>:
.globl vector38
vector38:
  pushl $0
  101efc:	6a 00                	push   $0x0
  pushl $38
  101efe:	6a 26                	push   $0x26
  jmp __alltraps
  101f00:	e9 8d fe ff ff       	jmp    101d92 <__alltraps>

00101f05 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f05:	6a 00                	push   $0x0
  pushl $39
  101f07:	6a 27                	push   $0x27
  jmp __alltraps
  101f09:	e9 84 fe ff ff       	jmp    101d92 <__alltraps>

00101f0e <vector40>:
.globl vector40
vector40:
  pushl $0
  101f0e:	6a 00                	push   $0x0
  pushl $40
  101f10:	6a 28                	push   $0x28
  jmp __alltraps
  101f12:	e9 7b fe ff ff       	jmp    101d92 <__alltraps>

00101f17 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f17:	6a 00                	push   $0x0
  pushl $41
  101f19:	6a 29                	push   $0x29
  jmp __alltraps
  101f1b:	e9 72 fe ff ff       	jmp    101d92 <__alltraps>

00101f20 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f20:	6a 00                	push   $0x0
  pushl $42
  101f22:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f24:	e9 69 fe ff ff       	jmp    101d92 <__alltraps>

00101f29 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f29:	6a 00                	push   $0x0
  pushl $43
  101f2b:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f2d:	e9 60 fe ff ff       	jmp    101d92 <__alltraps>

00101f32 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f32:	6a 00                	push   $0x0
  pushl $44
  101f34:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f36:	e9 57 fe ff ff       	jmp    101d92 <__alltraps>

00101f3b <vector45>:
.globl vector45
vector45:
  pushl $0
  101f3b:	6a 00                	push   $0x0
  pushl $45
  101f3d:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f3f:	e9 4e fe ff ff       	jmp    101d92 <__alltraps>

00101f44 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f44:	6a 00                	push   $0x0
  pushl $46
  101f46:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f48:	e9 45 fe ff ff       	jmp    101d92 <__alltraps>

00101f4d <vector47>:
.globl vector47
vector47:
  pushl $0
  101f4d:	6a 00                	push   $0x0
  pushl $47
  101f4f:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f51:	e9 3c fe ff ff       	jmp    101d92 <__alltraps>

00101f56 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f56:	6a 00                	push   $0x0
  pushl $48
  101f58:	6a 30                	push   $0x30
  jmp __alltraps
  101f5a:	e9 33 fe ff ff       	jmp    101d92 <__alltraps>

00101f5f <vector49>:
.globl vector49
vector49:
  pushl $0
  101f5f:	6a 00                	push   $0x0
  pushl $49
  101f61:	6a 31                	push   $0x31
  jmp __alltraps
  101f63:	e9 2a fe ff ff       	jmp    101d92 <__alltraps>

00101f68 <vector50>:
.globl vector50
vector50:
  pushl $0
  101f68:	6a 00                	push   $0x0
  pushl $50
  101f6a:	6a 32                	push   $0x32
  jmp __alltraps
  101f6c:	e9 21 fe ff ff       	jmp    101d92 <__alltraps>

00101f71 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f71:	6a 00                	push   $0x0
  pushl $51
  101f73:	6a 33                	push   $0x33
  jmp __alltraps
  101f75:	e9 18 fe ff ff       	jmp    101d92 <__alltraps>

00101f7a <vector52>:
.globl vector52
vector52:
  pushl $0
  101f7a:	6a 00                	push   $0x0
  pushl $52
  101f7c:	6a 34                	push   $0x34
  jmp __alltraps
  101f7e:	e9 0f fe ff ff       	jmp    101d92 <__alltraps>

00101f83 <vector53>:
.globl vector53
vector53:
  pushl $0
  101f83:	6a 00                	push   $0x0
  pushl $53
  101f85:	6a 35                	push   $0x35
  jmp __alltraps
  101f87:	e9 06 fe ff ff       	jmp    101d92 <__alltraps>

00101f8c <vector54>:
.globl vector54
vector54:
  pushl $0
  101f8c:	6a 00                	push   $0x0
  pushl $54
  101f8e:	6a 36                	push   $0x36
  jmp __alltraps
  101f90:	e9 fd fd ff ff       	jmp    101d92 <__alltraps>

00101f95 <vector55>:
.globl vector55
vector55:
  pushl $0
  101f95:	6a 00                	push   $0x0
  pushl $55
  101f97:	6a 37                	push   $0x37
  jmp __alltraps
  101f99:	e9 f4 fd ff ff       	jmp    101d92 <__alltraps>

00101f9e <vector56>:
.globl vector56
vector56:
  pushl $0
  101f9e:	6a 00                	push   $0x0
  pushl $56
  101fa0:	6a 38                	push   $0x38
  jmp __alltraps
  101fa2:	e9 eb fd ff ff       	jmp    101d92 <__alltraps>

00101fa7 <vector57>:
.globl vector57
vector57:
  pushl $0
  101fa7:	6a 00                	push   $0x0
  pushl $57
  101fa9:	6a 39                	push   $0x39
  jmp __alltraps
  101fab:	e9 e2 fd ff ff       	jmp    101d92 <__alltraps>

00101fb0 <vector58>:
.globl vector58
vector58:
  pushl $0
  101fb0:	6a 00                	push   $0x0
  pushl $58
  101fb2:	6a 3a                	push   $0x3a
  jmp __alltraps
  101fb4:	e9 d9 fd ff ff       	jmp    101d92 <__alltraps>

00101fb9 <vector59>:
.globl vector59
vector59:
  pushl $0
  101fb9:	6a 00                	push   $0x0
  pushl $59
  101fbb:	6a 3b                	push   $0x3b
  jmp __alltraps
  101fbd:	e9 d0 fd ff ff       	jmp    101d92 <__alltraps>

00101fc2 <vector60>:
.globl vector60
vector60:
  pushl $0
  101fc2:	6a 00                	push   $0x0
  pushl $60
  101fc4:	6a 3c                	push   $0x3c
  jmp __alltraps
  101fc6:	e9 c7 fd ff ff       	jmp    101d92 <__alltraps>

00101fcb <vector61>:
.globl vector61
vector61:
  pushl $0
  101fcb:	6a 00                	push   $0x0
  pushl $61
  101fcd:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fcf:	e9 be fd ff ff       	jmp    101d92 <__alltraps>

00101fd4 <vector62>:
.globl vector62
vector62:
  pushl $0
  101fd4:	6a 00                	push   $0x0
  pushl $62
  101fd6:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fd8:	e9 b5 fd ff ff       	jmp    101d92 <__alltraps>

00101fdd <vector63>:
.globl vector63
vector63:
  pushl $0
  101fdd:	6a 00                	push   $0x0
  pushl $63
  101fdf:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fe1:	e9 ac fd ff ff       	jmp    101d92 <__alltraps>

00101fe6 <vector64>:
.globl vector64
vector64:
  pushl $0
  101fe6:	6a 00                	push   $0x0
  pushl $64
  101fe8:	6a 40                	push   $0x40
  jmp __alltraps
  101fea:	e9 a3 fd ff ff       	jmp    101d92 <__alltraps>

00101fef <vector65>:
.globl vector65
vector65:
  pushl $0
  101fef:	6a 00                	push   $0x0
  pushl $65
  101ff1:	6a 41                	push   $0x41
  jmp __alltraps
  101ff3:	e9 9a fd ff ff       	jmp    101d92 <__alltraps>

00101ff8 <vector66>:
.globl vector66
vector66:
  pushl $0
  101ff8:	6a 00                	push   $0x0
  pushl $66
  101ffa:	6a 42                	push   $0x42
  jmp __alltraps
  101ffc:	e9 91 fd ff ff       	jmp    101d92 <__alltraps>

00102001 <vector67>:
.globl vector67
vector67:
  pushl $0
  102001:	6a 00                	push   $0x0
  pushl $67
  102003:	6a 43                	push   $0x43
  jmp __alltraps
  102005:	e9 88 fd ff ff       	jmp    101d92 <__alltraps>

0010200a <vector68>:
.globl vector68
vector68:
  pushl $0
  10200a:	6a 00                	push   $0x0
  pushl $68
  10200c:	6a 44                	push   $0x44
  jmp __alltraps
  10200e:	e9 7f fd ff ff       	jmp    101d92 <__alltraps>

00102013 <vector69>:
.globl vector69
vector69:
  pushl $0
  102013:	6a 00                	push   $0x0
  pushl $69
  102015:	6a 45                	push   $0x45
  jmp __alltraps
  102017:	e9 76 fd ff ff       	jmp    101d92 <__alltraps>

0010201c <vector70>:
.globl vector70
vector70:
  pushl $0
  10201c:	6a 00                	push   $0x0
  pushl $70
  10201e:	6a 46                	push   $0x46
  jmp __alltraps
  102020:	e9 6d fd ff ff       	jmp    101d92 <__alltraps>

00102025 <vector71>:
.globl vector71
vector71:
  pushl $0
  102025:	6a 00                	push   $0x0
  pushl $71
  102027:	6a 47                	push   $0x47
  jmp __alltraps
  102029:	e9 64 fd ff ff       	jmp    101d92 <__alltraps>

0010202e <vector72>:
.globl vector72
vector72:
  pushl $0
  10202e:	6a 00                	push   $0x0
  pushl $72
  102030:	6a 48                	push   $0x48
  jmp __alltraps
  102032:	e9 5b fd ff ff       	jmp    101d92 <__alltraps>

00102037 <vector73>:
.globl vector73
vector73:
  pushl $0
  102037:	6a 00                	push   $0x0
  pushl $73
  102039:	6a 49                	push   $0x49
  jmp __alltraps
  10203b:	e9 52 fd ff ff       	jmp    101d92 <__alltraps>

00102040 <vector74>:
.globl vector74
vector74:
  pushl $0
  102040:	6a 00                	push   $0x0
  pushl $74
  102042:	6a 4a                	push   $0x4a
  jmp __alltraps
  102044:	e9 49 fd ff ff       	jmp    101d92 <__alltraps>

00102049 <vector75>:
.globl vector75
vector75:
  pushl $0
  102049:	6a 00                	push   $0x0
  pushl $75
  10204b:	6a 4b                	push   $0x4b
  jmp __alltraps
  10204d:	e9 40 fd ff ff       	jmp    101d92 <__alltraps>

00102052 <vector76>:
.globl vector76
vector76:
  pushl $0
  102052:	6a 00                	push   $0x0
  pushl $76
  102054:	6a 4c                	push   $0x4c
  jmp __alltraps
  102056:	e9 37 fd ff ff       	jmp    101d92 <__alltraps>

0010205b <vector77>:
.globl vector77
vector77:
  pushl $0
  10205b:	6a 00                	push   $0x0
  pushl $77
  10205d:	6a 4d                	push   $0x4d
  jmp __alltraps
  10205f:	e9 2e fd ff ff       	jmp    101d92 <__alltraps>

00102064 <vector78>:
.globl vector78
vector78:
  pushl $0
  102064:	6a 00                	push   $0x0
  pushl $78
  102066:	6a 4e                	push   $0x4e
  jmp __alltraps
  102068:	e9 25 fd ff ff       	jmp    101d92 <__alltraps>

0010206d <vector79>:
.globl vector79
vector79:
  pushl $0
  10206d:	6a 00                	push   $0x0
  pushl $79
  10206f:	6a 4f                	push   $0x4f
  jmp __alltraps
  102071:	e9 1c fd ff ff       	jmp    101d92 <__alltraps>

00102076 <vector80>:
.globl vector80
vector80:
  pushl $0
  102076:	6a 00                	push   $0x0
  pushl $80
  102078:	6a 50                	push   $0x50
  jmp __alltraps
  10207a:	e9 13 fd ff ff       	jmp    101d92 <__alltraps>

0010207f <vector81>:
.globl vector81
vector81:
  pushl $0
  10207f:	6a 00                	push   $0x0
  pushl $81
  102081:	6a 51                	push   $0x51
  jmp __alltraps
  102083:	e9 0a fd ff ff       	jmp    101d92 <__alltraps>

00102088 <vector82>:
.globl vector82
vector82:
  pushl $0
  102088:	6a 00                	push   $0x0
  pushl $82
  10208a:	6a 52                	push   $0x52
  jmp __alltraps
  10208c:	e9 01 fd ff ff       	jmp    101d92 <__alltraps>

00102091 <vector83>:
.globl vector83
vector83:
  pushl $0
  102091:	6a 00                	push   $0x0
  pushl $83
  102093:	6a 53                	push   $0x53
  jmp __alltraps
  102095:	e9 f8 fc ff ff       	jmp    101d92 <__alltraps>

0010209a <vector84>:
.globl vector84
vector84:
  pushl $0
  10209a:	6a 00                	push   $0x0
  pushl $84
  10209c:	6a 54                	push   $0x54
  jmp __alltraps
  10209e:	e9 ef fc ff ff       	jmp    101d92 <__alltraps>

001020a3 <vector85>:
.globl vector85
vector85:
  pushl $0
  1020a3:	6a 00                	push   $0x0
  pushl $85
  1020a5:	6a 55                	push   $0x55
  jmp __alltraps
  1020a7:	e9 e6 fc ff ff       	jmp    101d92 <__alltraps>

001020ac <vector86>:
.globl vector86
vector86:
  pushl $0
  1020ac:	6a 00                	push   $0x0
  pushl $86
  1020ae:	6a 56                	push   $0x56
  jmp __alltraps
  1020b0:	e9 dd fc ff ff       	jmp    101d92 <__alltraps>

001020b5 <vector87>:
.globl vector87
vector87:
  pushl $0
  1020b5:	6a 00                	push   $0x0
  pushl $87
  1020b7:	6a 57                	push   $0x57
  jmp __alltraps
  1020b9:	e9 d4 fc ff ff       	jmp    101d92 <__alltraps>

001020be <vector88>:
.globl vector88
vector88:
  pushl $0
  1020be:	6a 00                	push   $0x0
  pushl $88
  1020c0:	6a 58                	push   $0x58
  jmp __alltraps
  1020c2:	e9 cb fc ff ff       	jmp    101d92 <__alltraps>

001020c7 <vector89>:
.globl vector89
vector89:
  pushl $0
  1020c7:	6a 00                	push   $0x0
  pushl $89
  1020c9:	6a 59                	push   $0x59
  jmp __alltraps
  1020cb:	e9 c2 fc ff ff       	jmp    101d92 <__alltraps>

001020d0 <vector90>:
.globl vector90
vector90:
  pushl $0
  1020d0:	6a 00                	push   $0x0
  pushl $90
  1020d2:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020d4:	e9 b9 fc ff ff       	jmp    101d92 <__alltraps>

001020d9 <vector91>:
.globl vector91
vector91:
  pushl $0
  1020d9:	6a 00                	push   $0x0
  pushl $91
  1020db:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020dd:	e9 b0 fc ff ff       	jmp    101d92 <__alltraps>

001020e2 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020e2:	6a 00                	push   $0x0
  pushl $92
  1020e4:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020e6:	e9 a7 fc ff ff       	jmp    101d92 <__alltraps>

001020eb <vector93>:
.globl vector93
vector93:
  pushl $0
  1020eb:	6a 00                	push   $0x0
  pushl $93
  1020ed:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020ef:	e9 9e fc ff ff       	jmp    101d92 <__alltraps>

001020f4 <vector94>:
.globl vector94
vector94:
  pushl $0
  1020f4:	6a 00                	push   $0x0
  pushl $94
  1020f6:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020f8:	e9 95 fc ff ff       	jmp    101d92 <__alltraps>

001020fd <vector95>:
.globl vector95
vector95:
  pushl $0
  1020fd:	6a 00                	push   $0x0
  pushl $95
  1020ff:	6a 5f                	push   $0x5f
  jmp __alltraps
  102101:	e9 8c fc ff ff       	jmp    101d92 <__alltraps>

00102106 <vector96>:
.globl vector96
vector96:
  pushl $0
  102106:	6a 00                	push   $0x0
  pushl $96
  102108:	6a 60                	push   $0x60
  jmp __alltraps
  10210a:	e9 83 fc ff ff       	jmp    101d92 <__alltraps>

0010210f <vector97>:
.globl vector97
vector97:
  pushl $0
  10210f:	6a 00                	push   $0x0
  pushl $97
  102111:	6a 61                	push   $0x61
  jmp __alltraps
  102113:	e9 7a fc ff ff       	jmp    101d92 <__alltraps>

00102118 <vector98>:
.globl vector98
vector98:
  pushl $0
  102118:	6a 00                	push   $0x0
  pushl $98
  10211a:	6a 62                	push   $0x62
  jmp __alltraps
  10211c:	e9 71 fc ff ff       	jmp    101d92 <__alltraps>

00102121 <vector99>:
.globl vector99
vector99:
  pushl $0
  102121:	6a 00                	push   $0x0
  pushl $99
  102123:	6a 63                	push   $0x63
  jmp __alltraps
  102125:	e9 68 fc ff ff       	jmp    101d92 <__alltraps>

0010212a <vector100>:
.globl vector100
vector100:
  pushl $0
  10212a:	6a 00                	push   $0x0
  pushl $100
  10212c:	6a 64                	push   $0x64
  jmp __alltraps
  10212e:	e9 5f fc ff ff       	jmp    101d92 <__alltraps>

00102133 <vector101>:
.globl vector101
vector101:
  pushl $0
  102133:	6a 00                	push   $0x0
  pushl $101
  102135:	6a 65                	push   $0x65
  jmp __alltraps
  102137:	e9 56 fc ff ff       	jmp    101d92 <__alltraps>

0010213c <vector102>:
.globl vector102
vector102:
  pushl $0
  10213c:	6a 00                	push   $0x0
  pushl $102
  10213e:	6a 66                	push   $0x66
  jmp __alltraps
  102140:	e9 4d fc ff ff       	jmp    101d92 <__alltraps>

00102145 <vector103>:
.globl vector103
vector103:
  pushl $0
  102145:	6a 00                	push   $0x0
  pushl $103
  102147:	6a 67                	push   $0x67
  jmp __alltraps
  102149:	e9 44 fc ff ff       	jmp    101d92 <__alltraps>

0010214e <vector104>:
.globl vector104
vector104:
  pushl $0
  10214e:	6a 00                	push   $0x0
  pushl $104
  102150:	6a 68                	push   $0x68
  jmp __alltraps
  102152:	e9 3b fc ff ff       	jmp    101d92 <__alltraps>

00102157 <vector105>:
.globl vector105
vector105:
  pushl $0
  102157:	6a 00                	push   $0x0
  pushl $105
  102159:	6a 69                	push   $0x69
  jmp __alltraps
  10215b:	e9 32 fc ff ff       	jmp    101d92 <__alltraps>

00102160 <vector106>:
.globl vector106
vector106:
  pushl $0
  102160:	6a 00                	push   $0x0
  pushl $106
  102162:	6a 6a                	push   $0x6a
  jmp __alltraps
  102164:	e9 29 fc ff ff       	jmp    101d92 <__alltraps>

00102169 <vector107>:
.globl vector107
vector107:
  pushl $0
  102169:	6a 00                	push   $0x0
  pushl $107
  10216b:	6a 6b                	push   $0x6b
  jmp __alltraps
  10216d:	e9 20 fc ff ff       	jmp    101d92 <__alltraps>

00102172 <vector108>:
.globl vector108
vector108:
  pushl $0
  102172:	6a 00                	push   $0x0
  pushl $108
  102174:	6a 6c                	push   $0x6c
  jmp __alltraps
  102176:	e9 17 fc ff ff       	jmp    101d92 <__alltraps>

0010217b <vector109>:
.globl vector109
vector109:
  pushl $0
  10217b:	6a 00                	push   $0x0
  pushl $109
  10217d:	6a 6d                	push   $0x6d
  jmp __alltraps
  10217f:	e9 0e fc ff ff       	jmp    101d92 <__alltraps>

00102184 <vector110>:
.globl vector110
vector110:
  pushl $0
  102184:	6a 00                	push   $0x0
  pushl $110
  102186:	6a 6e                	push   $0x6e
  jmp __alltraps
  102188:	e9 05 fc ff ff       	jmp    101d92 <__alltraps>

0010218d <vector111>:
.globl vector111
vector111:
  pushl $0
  10218d:	6a 00                	push   $0x0
  pushl $111
  10218f:	6a 6f                	push   $0x6f
  jmp __alltraps
  102191:	e9 fc fb ff ff       	jmp    101d92 <__alltraps>

00102196 <vector112>:
.globl vector112
vector112:
  pushl $0
  102196:	6a 00                	push   $0x0
  pushl $112
  102198:	6a 70                	push   $0x70
  jmp __alltraps
  10219a:	e9 f3 fb ff ff       	jmp    101d92 <__alltraps>

0010219f <vector113>:
.globl vector113
vector113:
  pushl $0
  10219f:	6a 00                	push   $0x0
  pushl $113
  1021a1:	6a 71                	push   $0x71
  jmp __alltraps
  1021a3:	e9 ea fb ff ff       	jmp    101d92 <__alltraps>

001021a8 <vector114>:
.globl vector114
vector114:
  pushl $0
  1021a8:	6a 00                	push   $0x0
  pushl $114
  1021aa:	6a 72                	push   $0x72
  jmp __alltraps
  1021ac:	e9 e1 fb ff ff       	jmp    101d92 <__alltraps>

001021b1 <vector115>:
.globl vector115
vector115:
  pushl $0
  1021b1:	6a 00                	push   $0x0
  pushl $115
  1021b3:	6a 73                	push   $0x73
  jmp __alltraps
  1021b5:	e9 d8 fb ff ff       	jmp    101d92 <__alltraps>

001021ba <vector116>:
.globl vector116
vector116:
  pushl $0
  1021ba:	6a 00                	push   $0x0
  pushl $116
  1021bc:	6a 74                	push   $0x74
  jmp __alltraps
  1021be:	e9 cf fb ff ff       	jmp    101d92 <__alltraps>

001021c3 <vector117>:
.globl vector117
vector117:
  pushl $0
  1021c3:	6a 00                	push   $0x0
  pushl $117
  1021c5:	6a 75                	push   $0x75
  jmp __alltraps
  1021c7:	e9 c6 fb ff ff       	jmp    101d92 <__alltraps>

001021cc <vector118>:
.globl vector118
vector118:
  pushl $0
  1021cc:	6a 00                	push   $0x0
  pushl $118
  1021ce:	6a 76                	push   $0x76
  jmp __alltraps
  1021d0:	e9 bd fb ff ff       	jmp    101d92 <__alltraps>

001021d5 <vector119>:
.globl vector119
vector119:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $119
  1021d7:	6a 77                	push   $0x77
  jmp __alltraps
  1021d9:	e9 b4 fb ff ff       	jmp    101d92 <__alltraps>

001021de <vector120>:
.globl vector120
vector120:
  pushl $0
  1021de:	6a 00                	push   $0x0
  pushl $120
  1021e0:	6a 78                	push   $0x78
  jmp __alltraps
  1021e2:	e9 ab fb ff ff       	jmp    101d92 <__alltraps>

001021e7 <vector121>:
.globl vector121
vector121:
  pushl $0
  1021e7:	6a 00                	push   $0x0
  pushl $121
  1021e9:	6a 79                	push   $0x79
  jmp __alltraps
  1021eb:	e9 a2 fb ff ff       	jmp    101d92 <__alltraps>

001021f0 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021f0:	6a 00                	push   $0x0
  pushl $122
  1021f2:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021f4:	e9 99 fb ff ff       	jmp    101d92 <__alltraps>

001021f9 <vector123>:
.globl vector123
vector123:
  pushl $0
  1021f9:	6a 00                	push   $0x0
  pushl $123
  1021fb:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021fd:	e9 90 fb ff ff       	jmp    101d92 <__alltraps>

00102202 <vector124>:
.globl vector124
vector124:
  pushl $0
  102202:	6a 00                	push   $0x0
  pushl $124
  102204:	6a 7c                	push   $0x7c
  jmp __alltraps
  102206:	e9 87 fb ff ff       	jmp    101d92 <__alltraps>

0010220b <vector125>:
.globl vector125
vector125:
  pushl $0
  10220b:	6a 00                	push   $0x0
  pushl $125
  10220d:	6a 7d                	push   $0x7d
  jmp __alltraps
  10220f:	e9 7e fb ff ff       	jmp    101d92 <__alltraps>

00102214 <vector126>:
.globl vector126
vector126:
  pushl $0
  102214:	6a 00                	push   $0x0
  pushl $126
  102216:	6a 7e                	push   $0x7e
  jmp __alltraps
  102218:	e9 75 fb ff ff       	jmp    101d92 <__alltraps>

0010221d <vector127>:
.globl vector127
vector127:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $127
  10221f:	6a 7f                	push   $0x7f
  jmp __alltraps
  102221:	e9 6c fb ff ff       	jmp    101d92 <__alltraps>

00102226 <vector128>:
.globl vector128
vector128:
  pushl $0
  102226:	6a 00                	push   $0x0
  pushl $128
  102228:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10222d:	e9 60 fb ff ff       	jmp    101d92 <__alltraps>

00102232 <vector129>:
.globl vector129
vector129:
  pushl $0
  102232:	6a 00                	push   $0x0
  pushl $129
  102234:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102239:	e9 54 fb ff ff       	jmp    101d92 <__alltraps>

0010223e <vector130>:
.globl vector130
vector130:
  pushl $0
  10223e:	6a 00                	push   $0x0
  pushl $130
  102240:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102245:	e9 48 fb ff ff       	jmp    101d92 <__alltraps>

0010224a <vector131>:
.globl vector131
vector131:
  pushl $0
  10224a:	6a 00                	push   $0x0
  pushl $131
  10224c:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102251:	e9 3c fb ff ff       	jmp    101d92 <__alltraps>

00102256 <vector132>:
.globl vector132
vector132:
  pushl $0
  102256:	6a 00                	push   $0x0
  pushl $132
  102258:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10225d:	e9 30 fb ff ff       	jmp    101d92 <__alltraps>

00102262 <vector133>:
.globl vector133
vector133:
  pushl $0
  102262:	6a 00                	push   $0x0
  pushl $133
  102264:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102269:	e9 24 fb ff ff       	jmp    101d92 <__alltraps>

0010226e <vector134>:
.globl vector134
vector134:
  pushl $0
  10226e:	6a 00                	push   $0x0
  pushl $134
  102270:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102275:	e9 18 fb ff ff       	jmp    101d92 <__alltraps>

0010227a <vector135>:
.globl vector135
vector135:
  pushl $0
  10227a:	6a 00                	push   $0x0
  pushl $135
  10227c:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102281:	e9 0c fb ff ff       	jmp    101d92 <__alltraps>

00102286 <vector136>:
.globl vector136
vector136:
  pushl $0
  102286:	6a 00                	push   $0x0
  pushl $136
  102288:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10228d:	e9 00 fb ff ff       	jmp    101d92 <__alltraps>

00102292 <vector137>:
.globl vector137
vector137:
  pushl $0
  102292:	6a 00                	push   $0x0
  pushl $137
  102294:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102299:	e9 f4 fa ff ff       	jmp    101d92 <__alltraps>

0010229e <vector138>:
.globl vector138
vector138:
  pushl $0
  10229e:	6a 00                	push   $0x0
  pushl $138
  1022a0:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022a5:	e9 e8 fa ff ff       	jmp    101d92 <__alltraps>

001022aa <vector139>:
.globl vector139
vector139:
  pushl $0
  1022aa:	6a 00                	push   $0x0
  pushl $139
  1022ac:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1022b1:	e9 dc fa ff ff       	jmp    101d92 <__alltraps>

001022b6 <vector140>:
.globl vector140
vector140:
  pushl $0
  1022b6:	6a 00                	push   $0x0
  pushl $140
  1022b8:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022bd:	e9 d0 fa ff ff       	jmp    101d92 <__alltraps>

001022c2 <vector141>:
.globl vector141
vector141:
  pushl $0
  1022c2:	6a 00                	push   $0x0
  pushl $141
  1022c4:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022c9:	e9 c4 fa ff ff       	jmp    101d92 <__alltraps>

001022ce <vector142>:
.globl vector142
vector142:
  pushl $0
  1022ce:	6a 00                	push   $0x0
  pushl $142
  1022d0:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022d5:	e9 b8 fa ff ff       	jmp    101d92 <__alltraps>

001022da <vector143>:
.globl vector143
vector143:
  pushl $0
  1022da:	6a 00                	push   $0x0
  pushl $143
  1022dc:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022e1:	e9 ac fa ff ff       	jmp    101d92 <__alltraps>

001022e6 <vector144>:
.globl vector144
vector144:
  pushl $0
  1022e6:	6a 00                	push   $0x0
  pushl $144
  1022e8:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022ed:	e9 a0 fa ff ff       	jmp    101d92 <__alltraps>

001022f2 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022f2:	6a 00                	push   $0x0
  pushl $145
  1022f4:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022f9:	e9 94 fa ff ff       	jmp    101d92 <__alltraps>

001022fe <vector146>:
.globl vector146
vector146:
  pushl $0
  1022fe:	6a 00                	push   $0x0
  pushl $146
  102300:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102305:	e9 88 fa ff ff       	jmp    101d92 <__alltraps>

0010230a <vector147>:
.globl vector147
vector147:
  pushl $0
  10230a:	6a 00                	push   $0x0
  pushl $147
  10230c:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102311:	e9 7c fa ff ff       	jmp    101d92 <__alltraps>

00102316 <vector148>:
.globl vector148
vector148:
  pushl $0
  102316:	6a 00                	push   $0x0
  pushl $148
  102318:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10231d:	e9 70 fa ff ff       	jmp    101d92 <__alltraps>

00102322 <vector149>:
.globl vector149
vector149:
  pushl $0
  102322:	6a 00                	push   $0x0
  pushl $149
  102324:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102329:	e9 64 fa ff ff       	jmp    101d92 <__alltraps>

0010232e <vector150>:
.globl vector150
vector150:
  pushl $0
  10232e:	6a 00                	push   $0x0
  pushl $150
  102330:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102335:	e9 58 fa ff ff       	jmp    101d92 <__alltraps>

0010233a <vector151>:
.globl vector151
vector151:
  pushl $0
  10233a:	6a 00                	push   $0x0
  pushl $151
  10233c:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102341:	e9 4c fa ff ff       	jmp    101d92 <__alltraps>

00102346 <vector152>:
.globl vector152
vector152:
  pushl $0
  102346:	6a 00                	push   $0x0
  pushl $152
  102348:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10234d:	e9 40 fa ff ff       	jmp    101d92 <__alltraps>

00102352 <vector153>:
.globl vector153
vector153:
  pushl $0
  102352:	6a 00                	push   $0x0
  pushl $153
  102354:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102359:	e9 34 fa ff ff       	jmp    101d92 <__alltraps>

0010235e <vector154>:
.globl vector154
vector154:
  pushl $0
  10235e:	6a 00                	push   $0x0
  pushl $154
  102360:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102365:	e9 28 fa ff ff       	jmp    101d92 <__alltraps>

0010236a <vector155>:
.globl vector155
vector155:
  pushl $0
  10236a:	6a 00                	push   $0x0
  pushl $155
  10236c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102371:	e9 1c fa ff ff       	jmp    101d92 <__alltraps>

00102376 <vector156>:
.globl vector156
vector156:
  pushl $0
  102376:	6a 00                	push   $0x0
  pushl $156
  102378:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10237d:	e9 10 fa ff ff       	jmp    101d92 <__alltraps>

00102382 <vector157>:
.globl vector157
vector157:
  pushl $0
  102382:	6a 00                	push   $0x0
  pushl $157
  102384:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102389:	e9 04 fa ff ff       	jmp    101d92 <__alltraps>

0010238e <vector158>:
.globl vector158
vector158:
  pushl $0
  10238e:	6a 00                	push   $0x0
  pushl $158
  102390:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102395:	e9 f8 f9 ff ff       	jmp    101d92 <__alltraps>

0010239a <vector159>:
.globl vector159
vector159:
  pushl $0
  10239a:	6a 00                	push   $0x0
  pushl $159
  10239c:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1023a1:	e9 ec f9 ff ff       	jmp    101d92 <__alltraps>

001023a6 <vector160>:
.globl vector160
vector160:
  pushl $0
  1023a6:	6a 00                	push   $0x0
  pushl $160
  1023a8:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1023ad:	e9 e0 f9 ff ff       	jmp    101d92 <__alltraps>

001023b2 <vector161>:
.globl vector161
vector161:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $161
  1023b4:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1023b9:	e9 d4 f9 ff ff       	jmp    101d92 <__alltraps>

001023be <vector162>:
.globl vector162
vector162:
  pushl $0
  1023be:	6a 00                	push   $0x0
  pushl $162
  1023c0:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023c5:	e9 c8 f9 ff ff       	jmp    101d92 <__alltraps>

001023ca <vector163>:
.globl vector163
vector163:
  pushl $0
  1023ca:	6a 00                	push   $0x0
  pushl $163
  1023cc:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023d1:	e9 bc f9 ff ff       	jmp    101d92 <__alltraps>

001023d6 <vector164>:
.globl vector164
vector164:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $164
  1023d8:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023dd:	e9 b0 f9 ff ff       	jmp    101d92 <__alltraps>

001023e2 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023e2:	6a 00                	push   $0x0
  pushl $165
  1023e4:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023e9:	e9 a4 f9 ff ff       	jmp    101d92 <__alltraps>

001023ee <vector166>:
.globl vector166
vector166:
  pushl $0
  1023ee:	6a 00                	push   $0x0
  pushl $166
  1023f0:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023f5:	e9 98 f9 ff ff       	jmp    101d92 <__alltraps>

001023fa <vector167>:
.globl vector167
vector167:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $167
  1023fc:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102401:	e9 8c f9 ff ff       	jmp    101d92 <__alltraps>

00102406 <vector168>:
.globl vector168
vector168:
  pushl $0
  102406:	6a 00                	push   $0x0
  pushl $168
  102408:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10240d:	e9 80 f9 ff ff       	jmp    101d92 <__alltraps>

00102412 <vector169>:
.globl vector169
vector169:
  pushl $0
  102412:	6a 00                	push   $0x0
  pushl $169
  102414:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102419:	e9 74 f9 ff ff       	jmp    101d92 <__alltraps>

0010241e <vector170>:
.globl vector170
vector170:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $170
  102420:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102425:	e9 68 f9 ff ff       	jmp    101d92 <__alltraps>

0010242a <vector171>:
.globl vector171
vector171:
  pushl $0
  10242a:	6a 00                	push   $0x0
  pushl $171
  10242c:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102431:	e9 5c f9 ff ff       	jmp    101d92 <__alltraps>

00102436 <vector172>:
.globl vector172
vector172:
  pushl $0
  102436:	6a 00                	push   $0x0
  pushl $172
  102438:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10243d:	e9 50 f9 ff ff       	jmp    101d92 <__alltraps>

00102442 <vector173>:
.globl vector173
vector173:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $173
  102444:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102449:	e9 44 f9 ff ff       	jmp    101d92 <__alltraps>

0010244e <vector174>:
.globl vector174
vector174:
  pushl $0
  10244e:	6a 00                	push   $0x0
  pushl $174
  102450:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102455:	e9 38 f9 ff ff       	jmp    101d92 <__alltraps>

0010245a <vector175>:
.globl vector175
vector175:
  pushl $0
  10245a:	6a 00                	push   $0x0
  pushl $175
  10245c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102461:	e9 2c f9 ff ff       	jmp    101d92 <__alltraps>

00102466 <vector176>:
.globl vector176
vector176:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $176
  102468:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10246d:	e9 20 f9 ff ff       	jmp    101d92 <__alltraps>

00102472 <vector177>:
.globl vector177
vector177:
  pushl $0
  102472:	6a 00                	push   $0x0
  pushl $177
  102474:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102479:	e9 14 f9 ff ff       	jmp    101d92 <__alltraps>

0010247e <vector178>:
.globl vector178
vector178:
  pushl $0
  10247e:	6a 00                	push   $0x0
  pushl $178
  102480:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102485:	e9 08 f9 ff ff       	jmp    101d92 <__alltraps>

0010248a <vector179>:
.globl vector179
vector179:
  pushl $0
  10248a:	6a 00                	push   $0x0
  pushl $179
  10248c:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102491:	e9 fc f8 ff ff       	jmp    101d92 <__alltraps>

00102496 <vector180>:
.globl vector180
vector180:
  pushl $0
  102496:	6a 00                	push   $0x0
  pushl $180
  102498:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10249d:	e9 f0 f8 ff ff       	jmp    101d92 <__alltraps>

001024a2 <vector181>:
.globl vector181
vector181:
  pushl $0
  1024a2:	6a 00                	push   $0x0
  pushl $181
  1024a4:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024a9:	e9 e4 f8 ff ff       	jmp    101d92 <__alltraps>

001024ae <vector182>:
.globl vector182
vector182:
  pushl $0
  1024ae:	6a 00                	push   $0x0
  pushl $182
  1024b0:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1024b5:	e9 d8 f8 ff ff       	jmp    101d92 <__alltraps>

001024ba <vector183>:
.globl vector183
vector183:
  pushl $0
  1024ba:	6a 00                	push   $0x0
  pushl $183
  1024bc:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024c1:	e9 cc f8 ff ff       	jmp    101d92 <__alltraps>

001024c6 <vector184>:
.globl vector184
vector184:
  pushl $0
  1024c6:	6a 00                	push   $0x0
  pushl $184
  1024c8:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024cd:	e9 c0 f8 ff ff       	jmp    101d92 <__alltraps>

001024d2 <vector185>:
.globl vector185
vector185:
  pushl $0
  1024d2:	6a 00                	push   $0x0
  pushl $185
  1024d4:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024d9:	e9 b4 f8 ff ff       	jmp    101d92 <__alltraps>

001024de <vector186>:
.globl vector186
vector186:
  pushl $0
  1024de:	6a 00                	push   $0x0
  pushl $186
  1024e0:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024e5:	e9 a8 f8 ff ff       	jmp    101d92 <__alltraps>

001024ea <vector187>:
.globl vector187
vector187:
  pushl $0
  1024ea:	6a 00                	push   $0x0
  pushl $187
  1024ec:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024f1:	e9 9c f8 ff ff       	jmp    101d92 <__alltraps>

001024f6 <vector188>:
.globl vector188
vector188:
  pushl $0
  1024f6:	6a 00                	push   $0x0
  pushl $188
  1024f8:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024fd:	e9 90 f8 ff ff       	jmp    101d92 <__alltraps>

00102502 <vector189>:
.globl vector189
vector189:
  pushl $0
  102502:	6a 00                	push   $0x0
  pushl $189
  102504:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102509:	e9 84 f8 ff ff       	jmp    101d92 <__alltraps>

0010250e <vector190>:
.globl vector190
vector190:
  pushl $0
  10250e:	6a 00                	push   $0x0
  pushl $190
  102510:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102515:	e9 78 f8 ff ff       	jmp    101d92 <__alltraps>

0010251a <vector191>:
.globl vector191
vector191:
  pushl $0
  10251a:	6a 00                	push   $0x0
  pushl $191
  10251c:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102521:	e9 6c f8 ff ff       	jmp    101d92 <__alltraps>

00102526 <vector192>:
.globl vector192
vector192:
  pushl $0
  102526:	6a 00                	push   $0x0
  pushl $192
  102528:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10252d:	e9 60 f8 ff ff       	jmp    101d92 <__alltraps>

00102532 <vector193>:
.globl vector193
vector193:
  pushl $0
  102532:	6a 00                	push   $0x0
  pushl $193
  102534:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102539:	e9 54 f8 ff ff       	jmp    101d92 <__alltraps>

0010253e <vector194>:
.globl vector194
vector194:
  pushl $0
  10253e:	6a 00                	push   $0x0
  pushl $194
  102540:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102545:	e9 48 f8 ff ff       	jmp    101d92 <__alltraps>

0010254a <vector195>:
.globl vector195
vector195:
  pushl $0
  10254a:	6a 00                	push   $0x0
  pushl $195
  10254c:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102551:	e9 3c f8 ff ff       	jmp    101d92 <__alltraps>

00102556 <vector196>:
.globl vector196
vector196:
  pushl $0
  102556:	6a 00                	push   $0x0
  pushl $196
  102558:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10255d:	e9 30 f8 ff ff       	jmp    101d92 <__alltraps>

00102562 <vector197>:
.globl vector197
vector197:
  pushl $0
  102562:	6a 00                	push   $0x0
  pushl $197
  102564:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102569:	e9 24 f8 ff ff       	jmp    101d92 <__alltraps>

0010256e <vector198>:
.globl vector198
vector198:
  pushl $0
  10256e:	6a 00                	push   $0x0
  pushl $198
  102570:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102575:	e9 18 f8 ff ff       	jmp    101d92 <__alltraps>

0010257a <vector199>:
.globl vector199
vector199:
  pushl $0
  10257a:	6a 00                	push   $0x0
  pushl $199
  10257c:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102581:	e9 0c f8 ff ff       	jmp    101d92 <__alltraps>

00102586 <vector200>:
.globl vector200
vector200:
  pushl $0
  102586:	6a 00                	push   $0x0
  pushl $200
  102588:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10258d:	e9 00 f8 ff ff       	jmp    101d92 <__alltraps>

00102592 <vector201>:
.globl vector201
vector201:
  pushl $0
  102592:	6a 00                	push   $0x0
  pushl $201
  102594:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102599:	e9 f4 f7 ff ff       	jmp    101d92 <__alltraps>

0010259e <vector202>:
.globl vector202
vector202:
  pushl $0
  10259e:	6a 00                	push   $0x0
  pushl $202
  1025a0:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025a5:	e9 e8 f7 ff ff       	jmp    101d92 <__alltraps>

001025aa <vector203>:
.globl vector203
vector203:
  pushl $0
  1025aa:	6a 00                	push   $0x0
  pushl $203
  1025ac:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1025b1:	e9 dc f7 ff ff       	jmp    101d92 <__alltraps>

001025b6 <vector204>:
.globl vector204
vector204:
  pushl $0
  1025b6:	6a 00                	push   $0x0
  pushl $204
  1025b8:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025bd:	e9 d0 f7 ff ff       	jmp    101d92 <__alltraps>

001025c2 <vector205>:
.globl vector205
vector205:
  pushl $0
  1025c2:	6a 00                	push   $0x0
  pushl $205
  1025c4:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025c9:	e9 c4 f7 ff ff       	jmp    101d92 <__alltraps>

001025ce <vector206>:
.globl vector206
vector206:
  pushl $0
  1025ce:	6a 00                	push   $0x0
  pushl $206
  1025d0:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025d5:	e9 b8 f7 ff ff       	jmp    101d92 <__alltraps>

001025da <vector207>:
.globl vector207
vector207:
  pushl $0
  1025da:	6a 00                	push   $0x0
  pushl $207
  1025dc:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025e1:	e9 ac f7 ff ff       	jmp    101d92 <__alltraps>

001025e6 <vector208>:
.globl vector208
vector208:
  pushl $0
  1025e6:	6a 00                	push   $0x0
  pushl $208
  1025e8:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025ed:	e9 a0 f7 ff ff       	jmp    101d92 <__alltraps>

001025f2 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025f2:	6a 00                	push   $0x0
  pushl $209
  1025f4:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025f9:	e9 94 f7 ff ff       	jmp    101d92 <__alltraps>

001025fe <vector210>:
.globl vector210
vector210:
  pushl $0
  1025fe:	6a 00                	push   $0x0
  pushl $210
  102600:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102605:	e9 88 f7 ff ff       	jmp    101d92 <__alltraps>

0010260a <vector211>:
.globl vector211
vector211:
  pushl $0
  10260a:	6a 00                	push   $0x0
  pushl $211
  10260c:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102611:	e9 7c f7 ff ff       	jmp    101d92 <__alltraps>

00102616 <vector212>:
.globl vector212
vector212:
  pushl $0
  102616:	6a 00                	push   $0x0
  pushl $212
  102618:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10261d:	e9 70 f7 ff ff       	jmp    101d92 <__alltraps>

00102622 <vector213>:
.globl vector213
vector213:
  pushl $0
  102622:	6a 00                	push   $0x0
  pushl $213
  102624:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102629:	e9 64 f7 ff ff       	jmp    101d92 <__alltraps>

0010262e <vector214>:
.globl vector214
vector214:
  pushl $0
  10262e:	6a 00                	push   $0x0
  pushl $214
  102630:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102635:	e9 58 f7 ff ff       	jmp    101d92 <__alltraps>

0010263a <vector215>:
.globl vector215
vector215:
  pushl $0
  10263a:	6a 00                	push   $0x0
  pushl $215
  10263c:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102641:	e9 4c f7 ff ff       	jmp    101d92 <__alltraps>

00102646 <vector216>:
.globl vector216
vector216:
  pushl $0
  102646:	6a 00                	push   $0x0
  pushl $216
  102648:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10264d:	e9 40 f7 ff ff       	jmp    101d92 <__alltraps>

00102652 <vector217>:
.globl vector217
vector217:
  pushl $0
  102652:	6a 00                	push   $0x0
  pushl $217
  102654:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102659:	e9 34 f7 ff ff       	jmp    101d92 <__alltraps>

0010265e <vector218>:
.globl vector218
vector218:
  pushl $0
  10265e:	6a 00                	push   $0x0
  pushl $218
  102660:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102665:	e9 28 f7 ff ff       	jmp    101d92 <__alltraps>

0010266a <vector219>:
.globl vector219
vector219:
  pushl $0
  10266a:	6a 00                	push   $0x0
  pushl $219
  10266c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102671:	e9 1c f7 ff ff       	jmp    101d92 <__alltraps>

00102676 <vector220>:
.globl vector220
vector220:
  pushl $0
  102676:	6a 00                	push   $0x0
  pushl $220
  102678:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10267d:	e9 10 f7 ff ff       	jmp    101d92 <__alltraps>

00102682 <vector221>:
.globl vector221
vector221:
  pushl $0
  102682:	6a 00                	push   $0x0
  pushl $221
  102684:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102689:	e9 04 f7 ff ff       	jmp    101d92 <__alltraps>

0010268e <vector222>:
.globl vector222
vector222:
  pushl $0
  10268e:	6a 00                	push   $0x0
  pushl $222
  102690:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102695:	e9 f8 f6 ff ff       	jmp    101d92 <__alltraps>

0010269a <vector223>:
.globl vector223
vector223:
  pushl $0
  10269a:	6a 00                	push   $0x0
  pushl $223
  10269c:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1026a1:	e9 ec f6 ff ff       	jmp    101d92 <__alltraps>

001026a6 <vector224>:
.globl vector224
vector224:
  pushl $0
  1026a6:	6a 00                	push   $0x0
  pushl $224
  1026a8:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1026ad:	e9 e0 f6 ff ff       	jmp    101d92 <__alltraps>

001026b2 <vector225>:
.globl vector225
vector225:
  pushl $0
  1026b2:	6a 00                	push   $0x0
  pushl $225
  1026b4:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1026b9:	e9 d4 f6 ff ff       	jmp    101d92 <__alltraps>

001026be <vector226>:
.globl vector226
vector226:
  pushl $0
  1026be:	6a 00                	push   $0x0
  pushl $226
  1026c0:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026c5:	e9 c8 f6 ff ff       	jmp    101d92 <__alltraps>

001026ca <vector227>:
.globl vector227
vector227:
  pushl $0
  1026ca:	6a 00                	push   $0x0
  pushl $227
  1026cc:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026d1:	e9 bc f6 ff ff       	jmp    101d92 <__alltraps>

001026d6 <vector228>:
.globl vector228
vector228:
  pushl $0
  1026d6:	6a 00                	push   $0x0
  pushl $228
  1026d8:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026dd:	e9 b0 f6 ff ff       	jmp    101d92 <__alltraps>

001026e2 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026e2:	6a 00                	push   $0x0
  pushl $229
  1026e4:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026e9:	e9 a4 f6 ff ff       	jmp    101d92 <__alltraps>

001026ee <vector230>:
.globl vector230
vector230:
  pushl $0
  1026ee:	6a 00                	push   $0x0
  pushl $230
  1026f0:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026f5:	e9 98 f6 ff ff       	jmp    101d92 <__alltraps>

001026fa <vector231>:
.globl vector231
vector231:
  pushl $0
  1026fa:	6a 00                	push   $0x0
  pushl $231
  1026fc:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102701:	e9 8c f6 ff ff       	jmp    101d92 <__alltraps>

00102706 <vector232>:
.globl vector232
vector232:
  pushl $0
  102706:	6a 00                	push   $0x0
  pushl $232
  102708:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10270d:	e9 80 f6 ff ff       	jmp    101d92 <__alltraps>

00102712 <vector233>:
.globl vector233
vector233:
  pushl $0
  102712:	6a 00                	push   $0x0
  pushl $233
  102714:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102719:	e9 74 f6 ff ff       	jmp    101d92 <__alltraps>

0010271e <vector234>:
.globl vector234
vector234:
  pushl $0
  10271e:	6a 00                	push   $0x0
  pushl $234
  102720:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102725:	e9 68 f6 ff ff       	jmp    101d92 <__alltraps>

0010272a <vector235>:
.globl vector235
vector235:
  pushl $0
  10272a:	6a 00                	push   $0x0
  pushl $235
  10272c:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102731:	e9 5c f6 ff ff       	jmp    101d92 <__alltraps>

00102736 <vector236>:
.globl vector236
vector236:
  pushl $0
  102736:	6a 00                	push   $0x0
  pushl $236
  102738:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10273d:	e9 50 f6 ff ff       	jmp    101d92 <__alltraps>

00102742 <vector237>:
.globl vector237
vector237:
  pushl $0
  102742:	6a 00                	push   $0x0
  pushl $237
  102744:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102749:	e9 44 f6 ff ff       	jmp    101d92 <__alltraps>

0010274e <vector238>:
.globl vector238
vector238:
  pushl $0
  10274e:	6a 00                	push   $0x0
  pushl $238
  102750:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102755:	e9 38 f6 ff ff       	jmp    101d92 <__alltraps>

0010275a <vector239>:
.globl vector239
vector239:
  pushl $0
  10275a:	6a 00                	push   $0x0
  pushl $239
  10275c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102761:	e9 2c f6 ff ff       	jmp    101d92 <__alltraps>

00102766 <vector240>:
.globl vector240
vector240:
  pushl $0
  102766:	6a 00                	push   $0x0
  pushl $240
  102768:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10276d:	e9 20 f6 ff ff       	jmp    101d92 <__alltraps>

00102772 <vector241>:
.globl vector241
vector241:
  pushl $0
  102772:	6a 00                	push   $0x0
  pushl $241
  102774:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102779:	e9 14 f6 ff ff       	jmp    101d92 <__alltraps>

0010277e <vector242>:
.globl vector242
vector242:
  pushl $0
  10277e:	6a 00                	push   $0x0
  pushl $242
  102780:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102785:	e9 08 f6 ff ff       	jmp    101d92 <__alltraps>

0010278a <vector243>:
.globl vector243
vector243:
  pushl $0
  10278a:	6a 00                	push   $0x0
  pushl $243
  10278c:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102791:	e9 fc f5 ff ff       	jmp    101d92 <__alltraps>

00102796 <vector244>:
.globl vector244
vector244:
  pushl $0
  102796:	6a 00                	push   $0x0
  pushl $244
  102798:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10279d:	e9 f0 f5 ff ff       	jmp    101d92 <__alltraps>

001027a2 <vector245>:
.globl vector245
vector245:
  pushl $0
  1027a2:	6a 00                	push   $0x0
  pushl $245
  1027a4:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027a9:	e9 e4 f5 ff ff       	jmp    101d92 <__alltraps>

001027ae <vector246>:
.globl vector246
vector246:
  pushl $0
  1027ae:	6a 00                	push   $0x0
  pushl $246
  1027b0:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1027b5:	e9 d8 f5 ff ff       	jmp    101d92 <__alltraps>

001027ba <vector247>:
.globl vector247
vector247:
  pushl $0
  1027ba:	6a 00                	push   $0x0
  pushl $247
  1027bc:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027c1:	e9 cc f5 ff ff       	jmp    101d92 <__alltraps>

001027c6 <vector248>:
.globl vector248
vector248:
  pushl $0
  1027c6:	6a 00                	push   $0x0
  pushl $248
  1027c8:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027cd:	e9 c0 f5 ff ff       	jmp    101d92 <__alltraps>

001027d2 <vector249>:
.globl vector249
vector249:
  pushl $0
  1027d2:	6a 00                	push   $0x0
  pushl $249
  1027d4:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027d9:	e9 b4 f5 ff ff       	jmp    101d92 <__alltraps>

001027de <vector250>:
.globl vector250
vector250:
  pushl $0
  1027de:	6a 00                	push   $0x0
  pushl $250
  1027e0:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027e5:	e9 a8 f5 ff ff       	jmp    101d92 <__alltraps>

001027ea <vector251>:
.globl vector251
vector251:
  pushl $0
  1027ea:	6a 00                	push   $0x0
  pushl $251
  1027ec:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027f1:	e9 9c f5 ff ff       	jmp    101d92 <__alltraps>

001027f6 <vector252>:
.globl vector252
vector252:
  pushl $0
  1027f6:	6a 00                	push   $0x0
  pushl $252
  1027f8:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027fd:	e9 90 f5 ff ff       	jmp    101d92 <__alltraps>

00102802 <vector253>:
.globl vector253
vector253:
  pushl $0
  102802:	6a 00                	push   $0x0
  pushl $253
  102804:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102809:	e9 84 f5 ff ff       	jmp    101d92 <__alltraps>

0010280e <vector254>:
.globl vector254
vector254:
  pushl $0
  10280e:	6a 00                	push   $0x0
  pushl $254
  102810:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102815:	e9 78 f5 ff ff       	jmp    101d92 <__alltraps>

0010281a <vector255>:
.globl vector255
vector255:
  pushl $0
  10281a:	6a 00                	push   $0x0
  pushl $255
  10281c:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102821:	e9 6c f5 ff ff       	jmp    101d92 <__alltraps>

00102826 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102826:	55                   	push   %ebp
  102827:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102829:	8b 55 08             	mov    0x8(%ebp),%edx
  10282c:	a1 24 af 11 00       	mov    0x11af24,%eax
  102831:	29 c2                	sub    %eax,%edx
  102833:	89 d0                	mov    %edx,%eax
  102835:	c1 f8 02             	sar    $0x2,%eax
  102838:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10283e:	5d                   	pop    %ebp
  10283f:	c3                   	ret    

00102840 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102840:	55                   	push   %ebp
  102841:	89 e5                	mov    %esp,%ebp
  102843:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102846:	8b 45 08             	mov    0x8(%ebp),%eax
  102849:	89 04 24             	mov    %eax,(%esp)
  10284c:	e8 d5 ff ff ff       	call   102826 <page2ppn>
  102851:	c1 e0 0c             	shl    $0xc,%eax
}
  102854:	c9                   	leave  
  102855:	c3                   	ret    

00102856 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102856:	55                   	push   %ebp
  102857:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102859:	8b 45 08             	mov    0x8(%ebp),%eax
  10285c:	8b 00                	mov    (%eax),%eax
}
  10285e:	5d                   	pop    %ebp
  10285f:	c3                   	ret    

00102860 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102860:	55                   	push   %ebp
  102861:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102863:	8b 45 08             	mov    0x8(%ebp),%eax
  102866:	8b 55 0c             	mov    0xc(%ebp),%edx
  102869:	89 10                	mov    %edx,(%eax)
}
  10286b:	5d                   	pop    %ebp
  10286c:	c3                   	ret    

0010286d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10286d:	55                   	push   %ebp
  10286e:	89 e5                	mov    %esp,%ebp
  102870:	83 ec 10             	sub    $0x10,%esp
  102873:	c7 45 fc 10 af 11 00 	movl   $0x11af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10287d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102880:	89 50 04             	mov    %edx,0x4(%eax)
  102883:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102886:	8b 50 04             	mov    0x4(%eax),%edx
  102889:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10288c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10288e:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  102895:	00 00 00 
}
  102898:	c9                   	leave  
  102899:	c3                   	ret    

0010289a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10289a:	55                   	push   %ebp
  10289b:	89 e5                	mov    %esp,%ebp
  10289d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1028a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1028a4:	75 24                	jne    1028ca <default_init_memmap+0x30>
  1028a6:	c7 44 24 0c 90 66 10 	movl   $0x106690,0xc(%esp)
  1028ad:	00 
  1028ae:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1028b5:	00 
  1028b6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1028bd:	00 
  1028be:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1028c5:	e8 08 e4 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  1028ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1028cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1028d0:	eb 7d                	jmp    10294f <default_init_memmap+0xb5>
        assert(PageReserved(p));//确认本页是否为保留页
  1028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028d5:	83 c0 04             	add    $0x4,%eax
  1028d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1028df:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1028e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1028e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1028e8:	0f a3 10             	bt     %edx,(%eax)
  1028eb:	19 c0                	sbb    %eax,%eax
  1028ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1028f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1028f4:	0f 95 c0             	setne  %al
  1028f7:	0f b6 c0             	movzbl %al,%eax
  1028fa:	85 c0                	test   %eax,%eax
  1028fc:	75 24                	jne    102922 <default_init_memmap+0x88>
  1028fe:	c7 44 24 0c c1 66 10 	movl   $0x1066c1,0xc(%esp)
  102905:	00 
  102906:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10290d:	00 
  10290e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102915:	00 
  102916:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10291d:	e8 b0 e3 ff ff       	call   100cd2 <__panic>
        //设置标志位
        p->flags = p->property = 0;
  102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102925:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10292c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10292f:	8b 50 08             	mov    0x8(%eax),%edx
  102932:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102935:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);//清空引用
  102938:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10293f:	00 
  102940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102943:	89 04 24             	mov    %eax,(%esp)
  102946:	e8 15 ff ff ff       	call   102860 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  10294b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10294f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102952:	89 d0                	mov    %edx,%eax
  102954:	c1 e0 02             	shl    $0x2,%eax
  102957:	01 d0                	add    %edx,%eax
  102959:	c1 e0 02             	shl    $0x2,%eax
  10295c:	89 c2                	mov    %eax,%edx
  10295e:	8b 45 08             	mov    0x8(%ebp),%eax
  102961:	01 d0                	add    %edx,%eax
  102963:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102966:	0f 85 66 ff ff ff    	jne    1028d2 <default_init_memmap+0x38>
        //设置标志位
        p->flags = p->property = 0;
        set_page_ref(p, 0);//清空引用
        
    }
    base->property = n; //头一个空闲页 要设置数量
  10296c:	8b 45 08             	mov    0x8(%ebp),%eax
  10296f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102972:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102975:	8b 45 08             	mov    0x8(%ebp),%eax
  102978:	83 c0 04             	add    $0x4,%eax
  10297b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102982:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102985:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102988:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10298b:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;  //说明连续有n个空闲页，属于空闲链表
  10298e:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102994:	8b 45 0c             	mov    0xc(%ebp),%eax
  102997:	01 d0                	add    %edx,%eax
  102999:	a3 18 af 11 00       	mov    %eax,0x11af18
    list_add_before(&free_list, &(p->page_link));
  10299e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029a1:	83 c0 0c             	add    $0xc,%eax
  1029a4:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
  1029ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1029ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1029b1:	8b 00                	mov    (%eax),%eax
  1029b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1029b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1029b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1029bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1029bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1029c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1029c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1029c8:	89 10                	mov    %edx,(%eax)
  1029ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1029cd:	8b 10                	mov    (%eax),%edx
  1029cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1029d2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1029d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1029d8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1029db:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1029de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1029e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1029e4:	89 10                	mov    %edx,(%eax)
}
  1029e6:	c9                   	leave  
  1029e7:	c3                   	ret    

001029e8 <default_alloc_pages>:


static struct Page *
default_alloc_pages(size_t n) {
  1029e8:	55                   	push   %ebp
  1029e9:	89 e5                	mov    %esp,%ebp
  1029eb:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1029ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029f2:	75 24                	jne    102a18 <default_alloc_pages+0x30>
  1029f4:	c7 44 24 0c 90 66 10 	movl   $0x106690,0xc(%esp)
  1029fb:	00 
  1029fc:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102a03:	00 
  102a04:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  102a0b:	00 
  102a0c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102a13:	e8 ba e2 ff ff       	call   100cd2 <__panic>
    if (n > nr_free) { //如果所有的空闲页的加起来的大小都不够，那直接返回NULL
  102a18:	a1 18 af 11 00       	mov    0x11af18,%eax
  102a1d:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a20:	73 0a                	jae    102a2c <default_alloc_pages+0x44>
        return NULL;
  102a22:	b8 00 00 00 00       	mov    $0x0,%eax
  102a27:	e9 49 01 00 00       	jmp    102b75 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
  102a2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
  102a33:	c7 45 f0 10 af 11 00 	movl   $0x11af10,-0x10(%ebp)
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
  102a3a:	eb 1c                	jmp    102a58 <default_alloc_pages+0x70>
        // 此处 le2page 就是将 le 的地址 - page_link 在 Page 的偏移 从而找到 Page 的地址
        struct Page *p = le2page(le, page_link);//将地址转换成页的结构
  102a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a3f:	83 e8 0c             	sub    $0xc,%eax
  102a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
  102a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a48:	8b 40 08             	mov    0x8(%eax),%eax
  102a4b:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a4e:	72 08                	jb     102a58 <default_alloc_pages+0x70>
            page = p;
  102a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a53:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102a56:	eb 18                	jmp    102a70 <default_alloc_pages+0x88>
  102a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102a61:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
  102a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a67:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102a6e:	75 cc                	jne    102a3c <default_alloc_pages+0x54>
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102a70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102a74:	0f 84 f8 00 00 00    	je     102b72 <default_alloc_pages+0x18a>
        if (page->property > n) {
  102a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a7d:	8b 40 08             	mov    0x8(%eax),%eax
  102a80:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a83:	0f 86 98 00 00 00    	jbe    102b21 <default_alloc_pages+0x139>
            struct Page *p = page + n;
  102a89:	8b 55 08             	mov    0x8(%ebp),%edx
  102a8c:	89 d0                	mov    %edx,%eax
  102a8e:	c1 e0 02             	shl    $0x2,%eax
  102a91:	01 d0                	add    %edx,%eax
  102a93:	c1 e0 02             	shl    $0x2,%eax
  102a96:	89 c2                	mov    %eax,%edx
  102a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a9b:	01 d0                	add    %edx,%eax
  102a9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//如果选中的第一个连续的块大于n，只取其中的大小为n的块
  102aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aa3:	8b 40 08             	mov    0x8(%eax),%eax
  102aa6:	2b 45 08             	sub    0x8(%ebp),%eax
  102aa9:	89 c2                	mov    %eax,%edx
  102aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102aae:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102ab1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ab4:	83 c0 04             	add    $0x4,%eax
  102ab7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102abe:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102ac1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ac4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102ac7:	0f ab 10             	bts    %edx,(%eax)
            // 将多出来的插入到 被分配掉的页块 后面
            list_add(&(page->page_link), &(p->page_link));
  102aca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102acd:	83 c0 0c             	add    $0xc,%eax
  102ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ad3:	83 c2 0c             	add    $0xc,%edx
  102ad6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102ad9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  102adc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102adf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ae2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102ae5:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102ae8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102aeb:	8b 40 04             	mov    0x4(%eax),%eax
  102aee:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102af1:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102af4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102af7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  102afa:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102afd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b00:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b03:	89 10                	mov    %edx,(%eax)
  102b05:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b08:	8b 10                	mov    (%eax),%edx
  102b0a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b0d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b10:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b13:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102b16:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b19:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b1c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102b1f:	89 10                	mov    %edx,(%eax)
        }
        // 最后在空闲页链表中删除掉原来的空闲页
        list_del(&(page->page_link));
  102b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b24:	83 c0 0c             	add    $0xc,%eax
  102b27:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102b2a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102b2d:	8b 40 04             	mov    0x4(%eax),%eax
  102b30:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102b33:	8b 12                	mov    (%edx),%edx
  102b35:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102b38:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102b3b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102b3e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102b41:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102b44:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102b47:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102b4a:	89 10                	mov    %edx,(%eax)
	
        nr_free -= n;//当前空闲页的数目减n
  102b4c:	a1 18 af 11 00       	mov    0x11af18,%eax
  102b51:	2b 45 08             	sub    0x8(%ebp),%eax
  102b54:	a3 18 af 11 00       	mov    %eax,0x11af18
        ClearPageProperty(page);
  102b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b5c:	83 c0 04             	add    $0x4,%eax
  102b5f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102b66:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b69:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102b6c:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102b6f:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102b75:	c9                   	leave  
  102b76:	c3                   	ret    

00102b77 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102b77:	55                   	push   %ebp
  102b78:	89 e5                	mov    %esp,%ebp
  102b7a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b84:	75 24                	jne    102baa <default_free_pages+0x33>
  102b86:	c7 44 24 0c 90 66 10 	movl   $0x106690,0xc(%esp)
  102b8d:	00 
  102b8e:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102b95:	00 
  102b96:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  102b9d:	00 
  102b9e:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102ba5:	e8 28 e1 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  102baa:	8b 45 08             	mov    0x8(%ebp),%eax
  102bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102bb0:	e9 9d 00 00 00       	jmp    102c52 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bb8:	83 c0 04             	add    $0x4,%eax
  102bbb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102bc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102bcb:	0f a3 10             	bt     %edx,(%eax)
  102bce:	19 c0                	sbb    %eax,%eax
  102bd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102bd3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102bd7:	0f 95 c0             	setne  %al
  102bda:	0f b6 c0             	movzbl %al,%eax
  102bdd:	85 c0                	test   %eax,%eax
  102bdf:	75 2c                	jne    102c0d <default_free_pages+0x96>
  102be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102be4:	83 c0 04             	add    $0x4,%eax
  102be7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102bee:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102bf1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102bf4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102bf7:	0f a3 10             	bt     %edx,(%eax)
  102bfa:	19 c0                	sbb    %eax,%eax
  102bfc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102bff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102c03:	0f 95 c0             	setne  %al
  102c06:	0f b6 c0             	movzbl %al,%eax
  102c09:	85 c0                	test   %eax,%eax
  102c0b:	74 24                	je     102c31 <default_free_pages+0xba>
  102c0d:	c7 44 24 0c d4 66 10 	movl   $0x1066d4,0xc(%esp)
  102c14:	00 
  102c15:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102c1c:	00 
  102c1d:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  102c24:	00 
  102c25:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102c2c:	e8 a1 e0 ff ff       	call   100cd2 <__panic>
        p->flags = 0;//修改标志位
  102c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c34:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102c42:	00 
  102c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c46:	89 04 24             	mov    %eax,(%esp)
  102c49:	e8 12 fc ff ff       	call   102860 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102c4e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102c52:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c55:	89 d0                	mov    %edx,%eax
  102c57:	c1 e0 02             	shl    $0x2,%eax
  102c5a:	01 d0                	add    %edx,%eax
  102c5c:	c1 e0 02             	shl    $0x2,%eax
  102c5f:	89 c2                	mov    %eax,%edx
  102c61:	8b 45 08             	mov    0x8(%ebp),%eax
  102c64:	01 d0                	add    %edx,%eax
  102c66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102c69:	0f 85 46 ff ff ff    	jne    102bb5 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;//修改标志位
        set_page_ref(p, 0);
    }
    base->property = n;//设置连续大小为n
  102c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c75:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102c78:	8b 45 08             	mov    0x8(%ebp),%eax
  102c7b:	83 c0 04             	add    $0x4,%eax
  102c7e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102c85:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c88:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102c8b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102c8e:	0f ab 10             	bts    %edx,(%eax)
  102c91:	c7 45 cc 10 af 11 00 	movl   $0x11af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102c98:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102c9b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 合并到合适的页块中
    while (le != &free_list) {
  102ca1:	e9 08 01 00 00       	jmp    102dae <default_free_pages+0x237>
        p = le2page(le, page_link);//获取链表对应的Page
  102ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ca9:	83 e8 0c             	sub    $0xc,%eax
  102cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cb2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102cb5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102cb8:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102cbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc1:	8b 50 08             	mov    0x8(%eax),%edx
  102cc4:	89 d0                	mov    %edx,%eax
  102cc6:	c1 e0 02             	shl    $0x2,%eax
  102cc9:	01 d0                	add    %edx,%eax
  102ccb:	c1 e0 02             	shl    $0x2,%eax
  102cce:	89 c2                	mov    %eax,%edx
  102cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd3:	01 d0                	add    %edx,%eax
  102cd5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102cd8:	75 5a                	jne    102d34 <default_free_pages+0x1bd>
            base->property += p->property;
  102cda:	8b 45 08             	mov    0x8(%ebp),%eax
  102cdd:	8b 50 08             	mov    0x8(%eax),%edx
  102ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ce3:	8b 40 08             	mov    0x8(%eax),%eax
  102ce6:	01 c2                	add    %eax,%edx
  102ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  102ceb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cf1:	83 c0 04             	add    $0x4,%eax
  102cf4:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102cfb:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102cfe:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d01:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d04:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d0a:	83 c0 0c             	add    $0xc,%eax
  102d0d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d10:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d13:	8b 40 04             	mov    0x4(%eax),%eax
  102d16:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d19:	8b 12                	mov    (%edx),%edx
  102d1b:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102d1e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102d21:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d24:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d27:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102d2a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102d2d:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102d30:	89 10                	mov    %edx,(%eax)
  102d32:	eb 7a                	jmp    102dae <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d37:	8b 50 08             	mov    0x8(%eax),%edx
  102d3a:	89 d0                	mov    %edx,%eax
  102d3c:	c1 e0 02             	shl    $0x2,%eax
  102d3f:	01 d0                	add    %edx,%eax
  102d41:	c1 e0 02             	shl    $0x2,%eax
  102d44:	89 c2                	mov    %eax,%edx
  102d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d49:	01 d0                	add    %edx,%eax
  102d4b:	3b 45 08             	cmp    0x8(%ebp),%eax
  102d4e:	75 5e                	jne    102dae <default_free_pages+0x237>
            p->property += base->property;
  102d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d53:	8b 50 08             	mov    0x8(%eax),%edx
  102d56:	8b 45 08             	mov    0x8(%ebp),%eax
  102d59:	8b 40 08             	mov    0x8(%eax),%eax
  102d5c:	01 c2                	add    %eax,%edx
  102d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d61:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102d64:	8b 45 08             	mov    0x8(%ebp),%eax
  102d67:	83 c0 04             	add    $0x4,%eax
  102d6a:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102d71:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102d74:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102d77:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102d7a:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d80:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d86:	83 c0 0c             	add    $0xc,%eax
  102d89:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d8c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102d8f:	8b 40 04             	mov    0x4(%eax),%eax
  102d92:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102d95:	8b 12                	mov    (%edx),%edx
  102d97:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102d9a:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102d9d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102da0:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102da3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102da6:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102da9:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102dac:	89 10                	mov    %edx,(%eax)
    }
    base->property = n;//设置连续大小为n
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    // 合并到合适的页块中
    while (le != &free_list) {
  102dae:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102db5:	0f 85 eb fe ff ff    	jne    102ca6 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102dbb:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc4:	01 d0                	add    %edx,%eax
  102dc6:	a3 18 af 11 00       	mov    %eax,0x11af18
  102dcb:	c7 45 9c 10 af 11 00 	movl   $0x11af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102dd2:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102dd5:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  102dd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
  102ddb:	eb 36                	jmp    102e13 <default_free_pages+0x29c>
        p = le2page(le, page_link);
  102ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102de0:	83 e8 0c             	sub    $0xc,%eax
  102de3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  102de6:	8b 45 08             	mov    0x8(%ebp),%eax
  102de9:	8b 50 08             	mov    0x8(%eax),%edx
  102dec:	89 d0                	mov    %edx,%eax
  102dee:	c1 e0 02             	shl    $0x2,%eax
  102df1:	01 d0                	add    %edx,%eax
  102df3:	c1 e0 02             	shl    $0x2,%eax
  102df6:	89 c2                	mov    %eax,%edx
  102df8:	8b 45 08             	mov    0x8(%ebp),%eax
  102dfb:	01 d0                	add    %edx,%eax
  102dfd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e00:	77 02                	ja     102e04 <default_free_pages+0x28d>
            break;
  102e02:	eb 18                	jmp    102e1c <default_free_pages+0x2a5>
  102e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e07:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e0a:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e0d:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
  102e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
  102e13:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102e1a:	75 c1                	jne    102ddd <default_free_pages+0x266>
        if (base + base->property <= p) {
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));//将空闲块插入空闲链表中
  102e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e1f:	8d 50 0c             	lea    0xc(%eax),%edx
  102e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e25:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102e28:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102e2b:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102e2e:	8b 00                	mov    (%eax),%eax
  102e30:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e33:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102e36:	89 45 88             	mov    %eax,-0x78(%ebp)
  102e39:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102e3c:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102e3f:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102e42:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102e45:	89 10                	mov    %edx,(%eax)
  102e47:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102e4a:	8b 10                	mov    (%eax),%edx
  102e4c:	8b 45 88             	mov    -0x78(%ebp),%eax
  102e4f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102e52:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e55:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102e58:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102e5b:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e5e:	8b 55 88             	mov    -0x78(%ebp),%edx
  102e61:	89 10                	mov    %edx,(%eax)
}
  102e63:	c9                   	leave  
  102e64:	c3                   	ret    

00102e65 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102e65:	55                   	push   %ebp
  102e66:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102e68:	a1 18 af 11 00       	mov    0x11af18,%eax
}
  102e6d:	5d                   	pop    %ebp
  102e6e:	c3                   	ret    

00102e6f <basic_check>:

static void
basic_check(void) {
  102e6f:	55                   	push   %ebp
  102e70:	89 e5                	mov    %esp,%ebp
  102e72:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102e75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e85:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102e88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102e8f:	e8 db 0e 00 00       	call   103d6f <alloc_pages>
  102e94:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102e9b:	75 24                	jne    102ec1 <basic_check+0x52>
  102e9d:	c7 44 24 0c f9 66 10 	movl   $0x1066f9,0xc(%esp)
  102ea4:	00 
  102ea5:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102eac:	00 
  102ead:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  102eb4:	00 
  102eb5:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102ebc:	e8 11 de ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102ec1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102ec8:	e8 a2 0e 00 00       	call   103d6f <alloc_pages>
  102ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ed0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102ed4:	75 24                	jne    102efa <basic_check+0x8b>
  102ed6:	c7 44 24 0c 15 67 10 	movl   $0x106715,0xc(%esp)
  102edd:	00 
  102ede:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102ee5:	00 
  102ee6:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  102eed:	00 
  102eee:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102ef5:	e8 d8 dd ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102efa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f01:	e8 69 0e 00 00       	call   103d6f <alloc_pages>
  102f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102f0d:	75 24                	jne    102f33 <basic_check+0xc4>
  102f0f:	c7 44 24 0c 31 67 10 	movl   $0x106731,0xc(%esp)
  102f16:	00 
  102f17:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102f1e:	00 
  102f1f:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  102f26:	00 
  102f27:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102f2e:	e8 9f dd ff ff       	call   100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102f33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f36:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102f39:	74 10                	je     102f4b <basic_check+0xdc>
  102f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f41:	74 08                	je     102f4b <basic_check+0xdc>
  102f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f49:	75 24                	jne    102f6f <basic_check+0x100>
  102f4b:	c7 44 24 0c 50 67 10 	movl   $0x106750,0xc(%esp)
  102f52:	00 
  102f53:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102f5a:	00 
  102f5b:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  102f62:	00 
  102f63:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102f6a:	e8 63 dd ff ff       	call   100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f72:	89 04 24             	mov    %eax,(%esp)
  102f75:	e8 dc f8 ff ff       	call   102856 <page_ref>
  102f7a:	85 c0                	test   %eax,%eax
  102f7c:	75 1e                	jne    102f9c <basic_check+0x12d>
  102f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f81:	89 04 24             	mov    %eax,(%esp)
  102f84:	e8 cd f8 ff ff       	call   102856 <page_ref>
  102f89:	85 c0                	test   %eax,%eax
  102f8b:	75 0f                	jne    102f9c <basic_check+0x12d>
  102f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f90:	89 04 24             	mov    %eax,(%esp)
  102f93:	e8 be f8 ff ff       	call   102856 <page_ref>
  102f98:	85 c0                	test   %eax,%eax
  102f9a:	74 24                	je     102fc0 <basic_check+0x151>
  102f9c:	c7 44 24 0c 74 67 10 	movl   $0x106774,0xc(%esp)
  102fa3:	00 
  102fa4:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102fab:	00 
  102fac:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  102fb3:	00 
  102fb4:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102fbb:	e8 12 dd ff ff       	call   100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  102fc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fc3:	89 04 24             	mov    %eax,(%esp)
  102fc6:	e8 75 f8 ff ff       	call   102840 <page2pa>
  102fcb:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102fd1:	c1 e2 0c             	shl    $0xc,%edx
  102fd4:	39 d0                	cmp    %edx,%eax
  102fd6:	72 24                	jb     102ffc <basic_check+0x18d>
  102fd8:	c7 44 24 0c b0 67 10 	movl   $0x1067b0,0xc(%esp)
  102fdf:	00 
  102fe0:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102fe7:	00 
  102fe8:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  102fef:	00 
  102ff0:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102ff7:	e8 d6 dc ff ff       	call   100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  102ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fff:	89 04 24             	mov    %eax,(%esp)
  103002:	e8 39 f8 ff ff       	call   102840 <page2pa>
  103007:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10300d:	c1 e2 0c             	shl    $0xc,%edx
  103010:	39 d0                	cmp    %edx,%eax
  103012:	72 24                	jb     103038 <basic_check+0x1c9>
  103014:	c7 44 24 0c cd 67 10 	movl   $0x1067cd,0xc(%esp)
  10301b:	00 
  10301c:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103023:	00 
  103024:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  10302b:	00 
  10302c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103033:	e8 9a dc ff ff       	call   100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10303b:	89 04 24             	mov    %eax,(%esp)
  10303e:	e8 fd f7 ff ff       	call   102840 <page2pa>
  103043:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103049:	c1 e2 0c             	shl    $0xc,%edx
  10304c:	39 d0                	cmp    %edx,%eax
  10304e:	72 24                	jb     103074 <basic_check+0x205>
  103050:	c7 44 24 0c ea 67 10 	movl   $0x1067ea,0xc(%esp)
  103057:	00 
  103058:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10305f:	00 
  103060:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  103067:	00 
  103068:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10306f:	e8 5e dc ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  103074:	a1 10 af 11 00       	mov    0x11af10,%eax
  103079:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  10307f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103082:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103085:	c7 45 e0 10 af 11 00 	movl   $0x11af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10308c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10308f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103092:	89 50 04             	mov    %edx,0x4(%eax)
  103095:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103098:	8b 50 04             	mov    0x4(%eax),%edx
  10309b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10309e:	89 10                	mov    %edx,(%eax)
  1030a0:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1030a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1030aa:	8b 40 04             	mov    0x4(%eax),%eax
  1030ad:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1030b0:	0f 94 c0             	sete   %al
  1030b3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1030b6:	85 c0                	test   %eax,%eax
  1030b8:	75 24                	jne    1030de <basic_check+0x26f>
  1030ba:	c7 44 24 0c 07 68 10 	movl   $0x106807,0xc(%esp)
  1030c1:	00 
  1030c2:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1030c9:	00 
  1030ca:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  1030d1:	00 
  1030d2:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1030d9:	e8 f4 db ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  1030de:	a1 18 af 11 00       	mov    0x11af18,%eax
  1030e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1030e6:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1030ed:	00 00 00 

    assert(alloc_page() == NULL);
  1030f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030f7:	e8 73 0c 00 00       	call   103d6f <alloc_pages>
  1030fc:	85 c0                	test   %eax,%eax
  1030fe:	74 24                	je     103124 <basic_check+0x2b5>
  103100:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  103107:	00 
  103108:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10310f:	00 
  103110:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  103117:	00 
  103118:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10311f:	e8 ae db ff ff       	call   100cd2 <__panic>

    free_page(p0);
  103124:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10312b:	00 
  10312c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10312f:	89 04 24             	mov    %eax,(%esp)
  103132:	e8 70 0c 00 00       	call   103da7 <free_pages>
    free_page(p1);
  103137:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10313e:	00 
  10313f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103142:	89 04 24             	mov    %eax,(%esp)
  103145:	e8 5d 0c 00 00       	call   103da7 <free_pages>
    free_page(p2);
  10314a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103151:	00 
  103152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103155:	89 04 24             	mov    %eax,(%esp)
  103158:	e8 4a 0c 00 00       	call   103da7 <free_pages>
    assert(nr_free == 3);
  10315d:	a1 18 af 11 00       	mov    0x11af18,%eax
  103162:	83 f8 03             	cmp    $0x3,%eax
  103165:	74 24                	je     10318b <basic_check+0x31c>
  103167:	c7 44 24 0c 33 68 10 	movl   $0x106833,0xc(%esp)
  10316e:	00 
  10316f:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103176:	00 
  103177:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  10317e:	00 
  10317f:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103186:	e8 47 db ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
  10318b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103192:	e8 d8 0b 00 00       	call   103d6f <alloc_pages>
  103197:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10319a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10319e:	75 24                	jne    1031c4 <basic_check+0x355>
  1031a0:	c7 44 24 0c f9 66 10 	movl   $0x1066f9,0xc(%esp)
  1031a7:	00 
  1031a8:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1031af:	00 
  1031b0:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  1031b7:	00 
  1031b8:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1031bf:	e8 0e db ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1031c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031cb:	e8 9f 0b 00 00       	call   103d6f <alloc_pages>
  1031d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1031d7:	75 24                	jne    1031fd <basic_check+0x38e>
  1031d9:	c7 44 24 0c 15 67 10 	movl   $0x106715,0xc(%esp)
  1031e0:	00 
  1031e1:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1031e8:	00 
  1031e9:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  1031f0:	00 
  1031f1:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1031f8:	e8 d5 da ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1031fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103204:	e8 66 0b 00 00       	call   103d6f <alloc_pages>
  103209:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10320c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103210:	75 24                	jne    103236 <basic_check+0x3c7>
  103212:	c7 44 24 0c 31 67 10 	movl   $0x106731,0xc(%esp)
  103219:	00 
  10321a:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103221:	00 
  103222:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  103229:	00 
  10322a:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103231:	e8 9c da ff ff       	call   100cd2 <__panic>

    assert(alloc_page() == NULL);
  103236:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10323d:	e8 2d 0b 00 00       	call   103d6f <alloc_pages>
  103242:	85 c0                	test   %eax,%eax
  103244:	74 24                	je     10326a <basic_check+0x3fb>
  103246:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  10324d:	00 
  10324e:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103255:	00 
  103256:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  10325d:	00 
  10325e:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103265:	e8 68 da ff ff       	call   100cd2 <__panic>

    free_page(p0);
  10326a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103271:	00 
  103272:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103275:	89 04 24             	mov    %eax,(%esp)
  103278:	e8 2a 0b 00 00       	call   103da7 <free_pages>
  10327d:	c7 45 d8 10 af 11 00 	movl   $0x11af10,-0x28(%ebp)
  103284:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103287:	8b 40 04             	mov    0x4(%eax),%eax
  10328a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10328d:	0f 94 c0             	sete   %al
  103290:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103293:	85 c0                	test   %eax,%eax
  103295:	74 24                	je     1032bb <basic_check+0x44c>
  103297:	c7 44 24 0c 40 68 10 	movl   $0x106840,0xc(%esp)
  10329e:	00 
  10329f:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1032a6:	00 
  1032a7:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  1032ae:	00 
  1032af:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1032b6:	e8 17 da ff ff       	call   100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1032bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032c2:	e8 a8 0a 00 00       	call   103d6f <alloc_pages>
  1032c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032cd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1032d0:	74 24                	je     1032f6 <basic_check+0x487>
  1032d2:	c7 44 24 0c 58 68 10 	movl   $0x106858,0xc(%esp)
  1032d9:	00 
  1032da:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1032e1:	00 
  1032e2:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  1032e9:	00 
  1032ea:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1032f1:	e8 dc d9 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1032f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032fd:	e8 6d 0a 00 00       	call   103d6f <alloc_pages>
  103302:	85 c0                	test   %eax,%eax
  103304:	74 24                	je     10332a <basic_check+0x4bb>
  103306:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  10330d:	00 
  10330e:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103315:	00 
  103316:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  10331d:	00 
  10331e:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103325:	e8 a8 d9 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  10332a:	a1 18 af 11 00       	mov    0x11af18,%eax
  10332f:	85 c0                	test   %eax,%eax
  103331:	74 24                	je     103357 <basic_check+0x4e8>
  103333:	c7 44 24 0c 71 68 10 	movl   $0x106871,0xc(%esp)
  10333a:	00 
  10333b:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103342:	00 
  103343:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  10334a:	00 
  10334b:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103352:	e8 7b d9 ff ff       	call   100cd2 <__panic>
    free_list = free_list_store;
  103357:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10335a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10335d:	a3 10 af 11 00       	mov    %eax,0x11af10
  103362:	89 15 14 af 11 00    	mov    %edx,0x11af14
    nr_free = nr_free_store;
  103368:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10336b:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_page(p);
  103370:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103377:	00 
  103378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10337b:	89 04 24             	mov    %eax,(%esp)
  10337e:	e8 24 0a 00 00       	call   103da7 <free_pages>
    free_page(p1);
  103383:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10338a:	00 
  10338b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10338e:	89 04 24             	mov    %eax,(%esp)
  103391:	e8 11 0a 00 00       	call   103da7 <free_pages>
    free_page(p2);
  103396:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10339d:	00 
  10339e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033a1:	89 04 24             	mov    %eax,(%esp)
  1033a4:	e8 fe 09 00 00       	call   103da7 <free_pages>
}
  1033a9:	c9                   	leave  
  1033aa:	c3                   	ret    

001033ab <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1033ab:	55                   	push   %ebp
  1033ac:	89 e5                	mov    %esp,%ebp
  1033ae:	53                   	push   %ebx
  1033af:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  1033b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1033bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1033c3:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1033ca:	eb 6b                	jmp    103437 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  1033cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033cf:	83 e8 0c             	sub    $0xc,%eax
  1033d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  1033d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033d8:	83 c0 04             	add    $0x4,%eax
  1033db:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1033e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1033e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1033e8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1033eb:	0f a3 10             	bt     %edx,(%eax)
  1033ee:	19 c0                	sbb    %eax,%eax
  1033f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1033f3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1033f7:	0f 95 c0             	setne  %al
  1033fa:	0f b6 c0             	movzbl %al,%eax
  1033fd:	85 c0                	test   %eax,%eax
  1033ff:	75 24                	jne    103425 <default_check+0x7a>
  103401:	c7 44 24 0c 7e 68 10 	movl   $0x10687e,0xc(%esp)
  103408:	00 
  103409:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103410:	00 
  103411:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  103418:	00 
  103419:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103420:	e8 ad d8 ff ff       	call   100cd2 <__panic>
        count ++, total += p->property;
  103425:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  103429:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10342c:	8b 50 08             	mov    0x8(%eax),%edx
  10342f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103432:	01 d0                	add    %edx,%eax
  103434:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103437:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10343a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10343d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103440:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103443:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103446:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  10344d:	0f 85 79 ff ff ff    	jne    1033cc <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  103453:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  103456:	e8 7e 09 00 00       	call   103dd9 <nr_free_pages>
  10345b:	39 c3                	cmp    %eax,%ebx
  10345d:	74 24                	je     103483 <default_check+0xd8>
  10345f:	c7 44 24 0c 8e 68 10 	movl   $0x10688e,0xc(%esp)
  103466:	00 
  103467:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10346e:	00 
  10346f:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  103476:	00 
  103477:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10347e:	e8 4f d8 ff ff       	call   100cd2 <__panic>

    basic_check();
  103483:	e8 e7 f9 ff ff       	call   102e6f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103488:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10348f:	e8 db 08 00 00       	call   103d6f <alloc_pages>
  103494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  103497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10349b:	75 24                	jne    1034c1 <default_check+0x116>
  10349d:	c7 44 24 0c a7 68 10 	movl   $0x1068a7,0xc(%esp)
  1034a4:	00 
  1034a5:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1034ac:	00 
  1034ad:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  1034b4:	00 
  1034b5:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1034bc:	e8 11 d8 ff ff       	call   100cd2 <__panic>
    assert(!PageProperty(p0));
  1034c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034c4:	83 c0 04             	add    $0x4,%eax
  1034c7:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1034ce:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1034d1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1034d4:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1034d7:	0f a3 10             	bt     %edx,(%eax)
  1034da:	19 c0                	sbb    %eax,%eax
  1034dc:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1034df:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1034e3:	0f 95 c0             	setne  %al
  1034e6:	0f b6 c0             	movzbl %al,%eax
  1034e9:	85 c0                	test   %eax,%eax
  1034eb:	74 24                	je     103511 <default_check+0x166>
  1034ed:	c7 44 24 0c b2 68 10 	movl   $0x1068b2,0xc(%esp)
  1034f4:	00 
  1034f5:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1034fc:	00 
  1034fd:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  103504:	00 
  103505:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10350c:	e8 c1 d7 ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  103511:	a1 10 af 11 00       	mov    0x11af10,%eax
  103516:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  10351c:	89 45 80             	mov    %eax,-0x80(%ebp)
  10351f:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103522:	c7 45 b4 10 af 11 00 	movl   $0x11af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103529:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10352c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10352f:	89 50 04             	mov    %edx,0x4(%eax)
  103532:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103535:	8b 50 04             	mov    0x4(%eax),%edx
  103538:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10353b:	89 10                	mov    %edx,(%eax)
  10353d:	c7 45 b0 10 af 11 00 	movl   $0x11af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103544:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103547:	8b 40 04             	mov    0x4(%eax),%eax
  10354a:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  10354d:	0f 94 c0             	sete   %al
  103550:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103553:	85 c0                	test   %eax,%eax
  103555:	75 24                	jne    10357b <default_check+0x1d0>
  103557:	c7 44 24 0c 07 68 10 	movl   $0x106807,0xc(%esp)
  10355e:	00 
  10355f:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103566:	00 
  103567:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  10356e:	00 
  10356f:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103576:	e8 57 d7 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  10357b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103582:	e8 e8 07 00 00       	call   103d6f <alloc_pages>
  103587:	85 c0                	test   %eax,%eax
  103589:	74 24                	je     1035af <default_check+0x204>
  10358b:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  103592:	00 
  103593:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10359a:	00 
  10359b:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1035a2:	00 
  1035a3:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1035aa:	e8 23 d7 ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  1035af:	a1 18 af 11 00       	mov    0x11af18,%eax
  1035b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  1035b7:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1035be:	00 00 00 

    free_pages(p0 + 2, 3);
  1035c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1035c4:	83 c0 28             	add    $0x28,%eax
  1035c7:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1035ce:	00 
  1035cf:	89 04 24             	mov    %eax,(%esp)
  1035d2:	e8 d0 07 00 00       	call   103da7 <free_pages>
    assert(alloc_pages(4) == NULL);
  1035d7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1035de:	e8 8c 07 00 00       	call   103d6f <alloc_pages>
  1035e3:	85 c0                	test   %eax,%eax
  1035e5:	74 24                	je     10360b <default_check+0x260>
  1035e7:	c7 44 24 0c c4 68 10 	movl   $0x1068c4,0xc(%esp)
  1035ee:	00 
  1035ef:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1035f6:	00 
  1035f7:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1035fe:	00 
  1035ff:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103606:	e8 c7 d6 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10360b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10360e:	83 c0 28             	add    $0x28,%eax
  103611:	83 c0 04             	add    $0x4,%eax
  103614:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10361b:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10361e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103621:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103624:	0f a3 10             	bt     %edx,(%eax)
  103627:	19 c0                	sbb    %eax,%eax
  103629:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10362c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  103630:	0f 95 c0             	setne  %al
  103633:	0f b6 c0             	movzbl %al,%eax
  103636:	85 c0                	test   %eax,%eax
  103638:	74 0e                	je     103648 <default_check+0x29d>
  10363a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10363d:	83 c0 28             	add    $0x28,%eax
  103640:	8b 40 08             	mov    0x8(%eax),%eax
  103643:	83 f8 03             	cmp    $0x3,%eax
  103646:	74 24                	je     10366c <default_check+0x2c1>
  103648:	c7 44 24 0c dc 68 10 	movl   $0x1068dc,0xc(%esp)
  10364f:	00 
  103650:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103657:	00 
  103658:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  10365f:	00 
  103660:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103667:	e8 66 d6 ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10366c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103673:	e8 f7 06 00 00       	call   103d6f <alloc_pages>
  103678:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10367b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10367f:	75 24                	jne    1036a5 <default_check+0x2fa>
  103681:	c7 44 24 0c 08 69 10 	movl   $0x106908,0xc(%esp)
  103688:	00 
  103689:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103690:	00 
  103691:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  103698:	00 
  103699:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1036a0:	e8 2d d6 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1036a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036ac:	e8 be 06 00 00       	call   103d6f <alloc_pages>
  1036b1:	85 c0                	test   %eax,%eax
  1036b3:	74 24                	je     1036d9 <default_check+0x32e>
  1036b5:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  1036bc:	00 
  1036bd:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1036c4:	00 
  1036c5:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  1036cc:	00 
  1036cd:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1036d4:	e8 f9 d5 ff ff       	call   100cd2 <__panic>
    assert(p0 + 2 == p1);
  1036d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036dc:	83 c0 28             	add    $0x28,%eax
  1036df:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1036e2:	74 24                	je     103708 <default_check+0x35d>
  1036e4:	c7 44 24 0c 26 69 10 	movl   $0x106926,0xc(%esp)
  1036eb:	00 
  1036ec:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1036f3:	00 
  1036f4:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  1036fb:	00 
  1036fc:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103703:	e8 ca d5 ff ff       	call   100cd2 <__panic>

    p2 = p0 + 1;
  103708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10370b:	83 c0 14             	add    $0x14,%eax
  10370e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  103711:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103718:	00 
  103719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10371c:	89 04 24             	mov    %eax,(%esp)
  10371f:	e8 83 06 00 00       	call   103da7 <free_pages>
    free_pages(p1, 3);
  103724:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10372b:	00 
  10372c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10372f:	89 04 24             	mov    %eax,(%esp)
  103732:	e8 70 06 00 00       	call   103da7 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  103737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10373a:	83 c0 04             	add    $0x4,%eax
  10373d:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103744:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103747:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10374a:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10374d:	0f a3 10             	bt     %edx,(%eax)
  103750:	19 c0                	sbb    %eax,%eax
  103752:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103755:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103759:	0f 95 c0             	setne  %al
  10375c:	0f b6 c0             	movzbl %al,%eax
  10375f:	85 c0                	test   %eax,%eax
  103761:	74 0b                	je     10376e <default_check+0x3c3>
  103763:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103766:	8b 40 08             	mov    0x8(%eax),%eax
  103769:	83 f8 01             	cmp    $0x1,%eax
  10376c:	74 24                	je     103792 <default_check+0x3e7>
  10376e:	c7 44 24 0c 34 69 10 	movl   $0x106934,0xc(%esp)
  103775:	00 
  103776:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10377d:	00 
  10377e:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  103785:	00 
  103786:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10378d:	e8 40 d5 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103792:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103795:	83 c0 04             	add    $0x4,%eax
  103798:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10379f:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037a2:	8b 45 90             	mov    -0x70(%ebp),%eax
  1037a5:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1037a8:	0f a3 10             	bt     %edx,(%eax)
  1037ab:	19 c0                	sbb    %eax,%eax
  1037ad:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1037b0:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1037b4:	0f 95 c0             	setne  %al
  1037b7:	0f b6 c0             	movzbl %al,%eax
  1037ba:	85 c0                	test   %eax,%eax
  1037bc:	74 0b                	je     1037c9 <default_check+0x41e>
  1037be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037c1:	8b 40 08             	mov    0x8(%eax),%eax
  1037c4:	83 f8 03             	cmp    $0x3,%eax
  1037c7:	74 24                	je     1037ed <default_check+0x442>
  1037c9:	c7 44 24 0c 5c 69 10 	movl   $0x10695c,0xc(%esp)
  1037d0:	00 
  1037d1:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1037d8:	00 
  1037d9:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  1037e0:	00 
  1037e1:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1037e8:	e8 e5 d4 ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1037ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037f4:	e8 76 05 00 00       	call   103d6f <alloc_pages>
  1037f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1037fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1037ff:	83 e8 14             	sub    $0x14,%eax
  103802:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103805:	74 24                	je     10382b <default_check+0x480>
  103807:	c7 44 24 0c 82 69 10 	movl   $0x106982,0xc(%esp)
  10380e:	00 
  10380f:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103816:	00 
  103817:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  10381e:	00 
  10381f:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103826:	e8 a7 d4 ff ff       	call   100cd2 <__panic>
    free_page(p0);
  10382b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103832:	00 
  103833:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103836:	89 04 24             	mov    %eax,(%esp)
  103839:	e8 69 05 00 00       	call   103da7 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10383e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103845:	e8 25 05 00 00       	call   103d6f <alloc_pages>
  10384a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10384d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103850:	83 c0 14             	add    $0x14,%eax
  103853:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103856:	74 24                	je     10387c <default_check+0x4d1>
  103858:	c7 44 24 0c a0 69 10 	movl   $0x1069a0,0xc(%esp)
  10385f:	00 
  103860:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103867:	00 
  103868:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  10386f:	00 
  103870:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103877:	e8 56 d4 ff ff       	call   100cd2 <__panic>

    free_pages(p0, 2);
  10387c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103883:	00 
  103884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103887:	89 04 24             	mov    %eax,(%esp)
  10388a:	e8 18 05 00 00       	call   103da7 <free_pages>
    free_page(p2);
  10388f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103896:	00 
  103897:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10389a:	89 04 24             	mov    %eax,(%esp)
  10389d:	e8 05 05 00 00       	call   103da7 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1038a2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1038a9:	e8 c1 04 00 00       	call   103d6f <alloc_pages>
  1038ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1038b5:	75 24                	jne    1038db <default_check+0x530>
  1038b7:	c7 44 24 0c c0 69 10 	movl   $0x1069c0,0xc(%esp)
  1038be:	00 
  1038bf:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1038c6:	00 
  1038c7:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  1038ce:	00 
  1038cf:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1038d6:	e8 f7 d3 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1038db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038e2:	e8 88 04 00 00       	call   103d6f <alloc_pages>
  1038e7:	85 c0                	test   %eax,%eax
  1038e9:	74 24                	je     10390f <default_check+0x564>
  1038eb:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  1038f2:	00 
  1038f3:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1038fa:	00 
  1038fb:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  103902:	00 
  103903:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10390a:	e8 c3 d3 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  10390f:	a1 18 af 11 00       	mov    0x11af18,%eax
  103914:	85 c0                	test   %eax,%eax
  103916:	74 24                	je     10393c <default_check+0x591>
  103918:	c7 44 24 0c 71 68 10 	movl   $0x106871,0xc(%esp)
  10391f:	00 
  103920:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103927:	00 
  103928:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  10392f:	00 
  103930:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103937:	e8 96 d3 ff ff       	call   100cd2 <__panic>
    nr_free = nr_free_store;
  10393c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10393f:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_list = free_list_store;
  103944:	8b 45 80             	mov    -0x80(%ebp),%eax
  103947:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10394a:	a3 10 af 11 00       	mov    %eax,0x11af10
  10394f:	89 15 14 af 11 00    	mov    %edx,0x11af14
    free_pages(p0, 5);
  103955:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10395c:	00 
  10395d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103960:	89 04 24             	mov    %eax,(%esp)
  103963:	e8 3f 04 00 00       	call   103da7 <free_pages>

    le = &free_list;
  103968:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10396f:	eb 5b                	jmp    1039cc <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  103971:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103974:	8b 40 04             	mov    0x4(%eax),%eax
  103977:	8b 00                	mov    (%eax),%eax
  103979:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10397c:	75 0d                	jne    10398b <default_check+0x5e0>
  10397e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103981:	8b 00                	mov    (%eax),%eax
  103983:	8b 40 04             	mov    0x4(%eax),%eax
  103986:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103989:	74 24                	je     1039af <default_check+0x604>
  10398b:	c7 44 24 0c e0 69 10 	movl   $0x1069e0,0xc(%esp)
  103992:	00 
  103993:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10399a:	00 
  10399b:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  1039a2:	00 
  1039a3:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1039aa:	e8 23 d3 ff ff       	call   100cd2 <__panic>
        struct Page *p = le2page(le, page_link);
  1039af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039b2:	83 e8 0c             	sub    $0xc,%eax
  1039b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1039b8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1039bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1039bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1039c2:	8b 40 08             	mov    0x8(%eax),%eax
  1039c5:	29 c2                	sub    %eax,%edx
  1039c7:	89 d0                	mov    %edx,%eax
  1039c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1039cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039cf:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1039d2:	8b 45 88             	mov    -0x78(%ebp),%eax
  1039d5:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1039d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1039db:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  1039e2:	75 8d                	jne    103971 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  1039e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1039e8:	74 24                	je     103a0e <default_check+0x663>
  1039ea:	c7 44 24 0c 0d 6a 10 	movl   $0x106a0d,0xc(%esp)
  1039f1:	00 
  1039f2:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1039f9:	00 
  1039fa:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  103a01:	00 
  103a02:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103a09:	e8 c4 d2 ff ff       	call   100cd2 <__panic>
    assert(total == 0);
  103a0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a12:	74 24                	je     103a38 <default_check+0x68d>
  103a14:	c7 44 24 0c 18 6a 10 	movl   $0x106a18,0xc(%esp)
  103a1b:	00 
  103a1c:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103a23:	00 
  103a24:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  103a2b:	00 
  103a2c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103a33:	e8 9a d2 ff ff       	call   100cd2 <__panic>
}
  103a38:	81 c4 94 00 00 00    	add    $0x94,%esp
  103a3e:	5b                   	pop    %ebx
  103a3f:	5d                   	pop    %ebp
  103a40:	c3                   	ret    

00103a41 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103a41:	55                   	push   %ebp
  103a42:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103a44:	8b 55 08             	mov    0x8(%ebp),%edx
  103a47:	a1 24 af 11 00       	mov    0x11af24,%eax
  103a4c:	29 c2                	sub    %eax,%edx
  103a4e:	89 d0                	mov    %edx,%eax
  103a50:	c1 f8 02             	sar    $0x2,%eax
  103a53:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103a59:	5d                   	pop    %ebp
  103a5a:	c3                   	ret    

00103a5b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103a5b:	55                   	push   %ebp
  103a5c:	89 e5                	mov    %esp,%ebp
  103a5e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103a61:	8b 45 08             	mov    0x8(%ebp),%eax
  103a64:	89 04 24             	mov    %eax,(%esp)
  103a67:	e8 d5 ff ff ff       	call   103a41 <page2ppn>
  103a6c:	c1 e0 0c             	shl    $0xc,%eax
}
  103a6f:	c9                   	leave  
  103a70:	c3                   	ret    

00103a71 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103a71:	55                   	push   %ebp
  103a72:	89 e5                	mov    %esp,%ebp
  103a74:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103a77:	8b 45 08             	mov    0x8(%ebp),%eax
  103a7a:	c1 e8 0c             	shr    $0xc,%eax
  103a7d:	89 c2                	mov    %eax,%edx
  103a7f:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103a84:	39 c2                	cmp    %eax,%edx
  103a86:	72 1c                	jb     103aa4 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103a88:	c7 44 24 08 54 6a 10 	movl   $0x106a54,0x8(%esp)
  103a8f:	00 
  103a90:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103a97:	00 
  103a98:	c7 04 24 73 6a 10 00 	movl   $0x106a73,(%esp)
  103a9f:	e8 2e d2 ff ff       	call   100cd2 <__panic>
    }
    return &pages[PPN(pa)];
  103aa4:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  103aad:	c1 e8 0c             	shr    $0xc,%eax
  103ab0:	89 c2                	mov    %eax,%edx
  103ab2:	89 d0                	mov    %edx,%eax
  103ab4:	c1 e0 02             	shl    $0x2,%eax
  103ab7:	01 d0                	add    %edx,%eax
  103ab9:	c1 e0 02             	shl    $0x2,%eax
  103abc:	01 c8                	add    %ecx,%eax
}
  103abe:	c9                   	leave  
  103abf:	c3                   	ret    

00103ac0 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103ac0:	55                   	push   %ebp
  103ac1:	89 e5                	mov    %esp,%ebp
  103ac3:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  103ac9:	89 04 24             	mov    %eax,(%esp)
  103acc:	e8 8a ff ff ff       	call   103a5b <page2pa>
  103ad1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ad7:	c1 e8 0c             	shr    $0xc,%eax
  103ada:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103add:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103ae2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103ae5:	72 23                	jb     103b0a <page2kva+0x4a>
  103ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103aea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103aee:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  103af5:	00 
  103af6:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103afd:	00 
  103afe:	c7 04 24 73 6a 10 00 	movl   $0x106a73,(%esp)
  103b05:	e8 c8 d1 ff ff       	call   100cd2 <__panic>
  103b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b0d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103b12:	c9                   	leave  
  103b13:	c3                   	ret    

00103b14 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103b14:	55                   	push   %ebp
  103b15:	89 e5                	mov    %esp,%ebp
  103b17:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  103b1d:	83 e0 01             	and    $0x1,%eax
  103b20:	85 c0                	test   %eax,%eax
  103b22:	75 1c                	jne    103b40 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103b24:	c7 44 24 08 a8 6a 10 	movl   $0x106aa8,0x8(%esp)
  103b2b:	00 
  103b2c:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103b33:	00 
  103b34:	c7 04 24 73 6a 10 00 	movl   $0x106a73,(%esp)
  103b3b:	e8 92 d1 ff ff       	call   100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103b40:	8b 45 08             	mov    0x8(%ebp),%eax
  103b43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b48:	89 04 24             	mov    %eax,(%esp)
  103b4b:	e8 21 ff ff ff       	call   103a71 <pa2page>
}
  103b50:	c9                   	leave  
  103b51:	c3                   	ret    

00103b52 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103b52:	55                   	push   %ebp
  103b53:	89 e5                	mov    %esp,%ebp
  103b55:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103b58:	8b 45 08             	mov    0x8(%ebp),%eax
  103b5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b60:	89 04 24             	mov    %eax,(%esp)
  103b63:	e8 09 ff ff ff       	call   103a71 <pa2page>
}
  103b68:	c9                   	leave  
  103b69:	c3                   	ret    

00103b6a <page_ref>:

static inline int
page_ref(struct Page *page) {
  103b6a:	55                   	push   %ebp
  103b6b:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  103b70:	8b 00                	mov    (%eax),%eax
}
  103b72:	5d                   	pop    %ebp
  103b73:	c3                   	ret    

00103b74 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103b74:	55                   	push   %ebp
  103b75:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103b77:	8b 45 08             	mov    0x8(%ebp),%eax
  103b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  103b7d:	89 10                	mov    %edx,(%eax)
}
  103b7f:	5d                   	pop    %ebp
  103b80:	c3                   	ret    

00103b81 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103b81:	55                   	push   %ebp
  103b82:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103b84:	8b 45 08             	mov    0x8(%ebp),%eax
  103b87:	8b 00                	mov    (%eax),%eax
  103b89:	8d 50 01             	lea    0x1(%eax),%edx
  103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  103b8f:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b91:	8b 45 08             	mov    0x8(%ebp),%eax
  103b94:	8b 00                	mov    (%eax),%eax
}
  103b96:	5d                   	pop    %ebp
  103b97:	c3                   	ret    

00103b98 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103b98:	55                   	push   %ebp
  103b99:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  103b9e:	8b 00                	mov    (%eax),%eax
  103ba0:	8d 50 ff             	lea    -0x1(%eax),%edx
  103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba6:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  103bab:	8b 00                	mov    (%eax),%eax
}
  103bad:	5d                   	pop    %ebp
  103bae:	c3                   	ret    

00103baf <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103baf:	55                   	push   %ebp
  103bb0:	89 e5                	mov    %esp,%ebp
  103bb2:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103bb5:	9c                   	pushf  
  103bb6:	58                   	pop    %eax
  103bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103bbd:	25 00 02 00 00       	and    $0x200,%eax
  103bc2:	85 c0                	test   %eax,%eax
  103bc4:	74 0c                	je     103bd2 <__intr_save+0x23>
        intr_disable();
  103bc6:	e8 fb da ff ff       	call   1016c6 <intr_disable>
        return 1;
  103bcb:	b8 01 00 00 00       	mov    $0x1,%eax
  103bd0:	eb 05                	jmp    103bd7 <__intr_save+0x28>
    }
    return 0;
  103bd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103bd7:	c9                   	leave  
  103bd8:	c3                   	ret    

00103bd9 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103bd9:	55                   	push   %ebp
  103bda:	89 e5                	mov    %esp,%ebp
  103bdc:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103bdf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103be3:	74 05                	je     103bea <__intr_restore+0x11>
        intr_enable();
  103be5:	e8 d6 da ff ff       	call   1016c0 <intr_enable>
    }
}
  103bea:	c9                   	leave  
  103beb:	c3                   	ret    

00103bec <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103bec:	55                   	push   %ebp
  103bed:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103bef:	8b 45 08             	mov    0x8(%ebp),%eax
  103bf2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103bf5:	b8 23 00 00 00       	mov    $0x23,%eax
  103bfa:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103bfc:	b8 23 00 00 00       	mov    $0x23,%eax
  103c01:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103c03:	b8 10 00 00 00       	mov    $0x10,%eax
  103c08:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103c0a:	b8 10 00 00 00       	mov    $0x10,%eax
  103c0f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103c11:	b8 10 00 00 00       	mov    $0x10,%eax
  103c16:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103c18:	ea 1f 3c 10 00 08 00 	ljmp   $0x8,$0x103c1f
}
  103c1f:	5d                   	pop    %ebp
  103c20:	c3                   	ret    

00103c21 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103c21:	55                   	push   %ebp
  103c22:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103c24:	8b 45 08             	mov    0x8(%ebp),%eax
  103c27:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103c2c:	5d                   	pop    %ebp
  103c2d:	c3                   	ret    

00103c2e <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103c2e:	55                   	push   %ebp
  103c2f:	89 e5                	mov    %esp,%ebp
  103c31:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103c34:	b8 00 70 11 00       	mov    $0x117000,%eax
  103c39:	89 04 24             	mov    %eax,(%esp)
  103c3c:	e8 e0 ff ff ff       	call   103c21 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103c41:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103c48:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103c4a:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103c51:	68 00 
  103c53:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c58:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103c5e:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c63:	c1 e8 10             	shr    $0x10,%eax
  103c66:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103c6b:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c72:	83 e0 f0             	and    $0xfffffff0,%eax
  103c75:	83 c8 09             	or     $0x9,%eax
  103c78:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c7d:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c84:	83 e0 ef             	and    $0xffffffef,%eax
  103c87:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c8c:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c93:	83 e0 9f             	and    $0xffffff9f,%eax
  103c96:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c9b:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103ca2:	83 c8 80             	or     $0xffffff80,%eax
  103ca5:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103caa:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cb1:	83 e0 f0             	and    $0xfffffff0,%eax
  103cb4:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cb9:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cc0:	83 e0 ef             	and    $0xffffffef,%eax
  103cc3:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cc8:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ccf:	83 e0 df             	and    $0xffffffdf,%eax
  103cd2:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cd7:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cde:	83 c8 40             	or     $0x40,%eax
  103ce1:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ce6:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ced:	83 e0 7f             	and    $0x7f,%eax
  103cf0:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cf5:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103cfa:	c1 e8 18             	shr    $0x18,%eax
  103cfd:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103d02:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103d09:	e8 de fe ff ff       	call   103bec <lgdt>
  103d0e:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103d14:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103d18:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103d1b:	c9                   	leave  
  103d1c:	c3                   	ret    

00103d1d <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103d1d:	55                   	push   %ebp
  103d1e:	89 e5                	mov    %esp,%ebp
  103d20:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103d23:	c7 05 1c af 11 00 38 	movl   $0x106a38,0x11af1c
  103d2a:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103d2d:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d32:	8b 00                	mov    (%eax),%eax
  103d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d38:	c7 04 24 d4 6a 10 00 	movl   $0x106ad4,(%esp)
  103d3f:	e8 04 c6 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  103d44:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d49:	8b 40 04             	mov    0x4(%eax),%eax
  103d4c:	ff d0                	call   *%eax
}
  103d4e:	c9                   	leave  
  103d4f:	c3                   	ret    

00103d50 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103d50:	55                   	push   %ebp
  103d51:	89 e5                	mov    %esp,%ebp
  103d53:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103d56:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d5b:	8b 40 08             	mov    0x8(%eax),%eax
  103d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d61:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d65:	8b 55 08             	mov    0x8(%ebp),%edx
  103d68:	89 14 24             	mov    %edx,(%esp)
  103d6b:	ff d0                	call   *%eax
}
  103d6d:	c9                   	leave  
  103d6e:	c3                   	ret    

00103d6f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103d6f:	55                   	push   %ebp
  103d70:	89 e5                	mov    %esp,%ebp
  103d72:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103d7c:	e8 2e fe ff ff       	call   103baf <__intr_save>
  103d81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103d84:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d89:	8b 40 0c             	mov    0xc(%eax),%eax
  103d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  103d8f:	89 14 24             	mov    %edx,(%esp)
  103d92:	ff d0                	call   *%eax
  103d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d9a:	89 04 24             	mov    %eax,(%esp)
  103d9d:	e8 37 fe ff ff       	call   103bd9 <__intr_restore>
    return page;
  103da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103da5:	c9                   	leave  
  103da6:	c3                   	ret    

00103da7 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103da7:	55                   	push   %ebp
  103da8:	89 e5                	mov    %esp,%ebp
  103daa:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103dad:	e8 fd fd ff ff       	call   103baf <__intr_save>
  103db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103db5:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103dba:	8b 40 10             	mov    0x10(%eax),%eax
  103dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  103dc0:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  103dc7:	89 14 24             	mov    %edx,(%esp)
  103dca:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103dcf:	89 04 24             	mov    %eax,(%esp)
  103dd2:	e8 02 fe ff ff       	call   103bd9 <__intr_restore>
}
  103dd7:	c9                   	leave  
  103dd8:	c3                   	ret    

00103dd9 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103dd9:	55                   	push   %ebp
  103dda:	89 e5                	mov    %esp,%ebp
  103ddc:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103ddf:	e8 cb fd ff ff       	call   103baf <__intr_save>
  103de4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103de7:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103dec:	8b 40 14             	mov    0x14(%eax),%eax
  103def:	ff d0                	call   *%eax
  103df1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103df7:	89 04 24             	mov    %eax,(%esp)
  103dfa:	e8 da fd ff ff       	call   103bd9 <__intr_restore>
    return ret;
  103dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103e02:	c9                   	leave  
  103e03:	c3                   	ret    

00103e04 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103e04:	55                   	push   %ebp
  103e05:	89 e5                	mov    %esp,%ebp
  103e07:	57                   	push   %edi
  103e08:	56                   	push   %esi
  103e09:	53                   	push   %ebx
  103e0a:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103e10:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103e17:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103e1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103e25:	c7 04 24 eb 6a 10 00 	movl   $0x106aeb,(%esp)
  103e2c:	e8 17 c5 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103e31:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103e38:	e9 15 01 00 00       	jmp    103f52 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103e3d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e40:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e43:	89 d0                	mov    %edx,%eax
  103e45:	c1 e0 02             	shl    $0x2,%eax
  103e48:	01 d0                	add    %edx,%eax
  103e4a:	c1 e0 02             	shl    $0x2,%eax
  103e4d:	01 c8                	add    %ecx,%eax
  103e4f:	8b 50 08             	mov    0x8(%eax),%edx
  103e52:	8b 40 04             	mov    0x4(%eax),%eax
  103e55:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103e58:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103e5b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e61:	89 d0                	mov    %edx,%eax
  103e63:	c1 e0 02             	shl    $0x2,%eax
  103e66:	01 d0                	add    %edx,%eax
  103e68:	c1 e0 02             	shl    $0x2,%eax
  103e6b:	01 c8                	add    %ecx,%eax
  103e6d:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e70:	8b 58 10             	mov    0x10(%eax),%ebx
  103e73:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103e76:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103e79:	01 c8                	add    %ecx,%eax
  103e7b:	11 da                	adc    %ebx,%edx
  103e7d:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103e80:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103e83:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e86:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e89:	89 d0                	mov    %edx,%eax
  103e8b:	c1 e0 02             	shl    $0x2,%eax
  103e8e:	01 d0                	add    %edx,%eax
  103e90:	c1 e0 02             	shl    $0x2,%eax
  103e93:	01 c8                	add    %ecx,%eax
  103e95:	83 c0 14             	add    $0x14,%eax
  103e98:	8b 00                	mov    (%eax),%eax
  103e9a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103ea0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103ea3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103ea6:	83 c0 ff             	add    $0xffffffff,%eax
  103ea9:	83 d2 ff             	adc    $0xffffffff,%edx
  103eac:	89 c6                	mov    %eax,%esi
  103eae:	89 d7                	mov    %edx,%edi
  103eb0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103eb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103eb6:	89 d0                	mov    %edx,%eax
  103eb8:	c1 e0 02             	shl    $0x2,%eax
  103ebb:	01 d0                	add    %edx,%eax
  103ebd:	c1 e0 02             	shl    $0x2,%eax
  103ec0:	01 c8                	add    %ecx,%eax
  103ec2:	8b 48 0c             	mov    0xc(%eax),%ecx
  103ec5:	8b 58 10             	mov    0x10(%eax),%ebx
  103ec8:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103ece:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103ed2:	89 74 24 14          	mov    %esi,0x14(%esp)
  103ed6:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103eda:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103edd:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103ee0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103ee4:	89 54 24 10          	mov    %edx,0x10(%esp)
  103ee8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103eec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103ef0:	c7 04 24 f8 6a 10 00 	movl   $0x106af8,(%esp)
  103ef7:	e8 4c c4 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103efc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103eff:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f02:	89 d0                	mov    %edx,%eax
  103f04:	c1 e0 02             	shl    $0x2,%eax
  103f07:	01 d0                	add    %edx,%eax
  103f09:	c1 e0 02             	shl    $0x2,%eax
  103f0c:	01 c8                	add    %ecx,%eax
  103f0e:	83 c0 14             	add    $0x14,%eax
  103f11:	8b 00                	mov    (%eax),%eax
  103f13:	83 f8 01             	cmp    $0x1,%eax
  103f16:	75 36                	jne    103f4e <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103f18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f1e:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f21:	77 2b                	ja     103f4e <page_init+0x14a>
  103f23:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f26:	72 05                	jb     103f2d <page_init+0x129>
  103f28:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103f2b:	73 21                	jae    103f4e <page_init+0x14a>
  103f2d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f31:	77 1b                	ja     103f4e <page_init+0x14a>
  103f33:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f37:	72 09                	jb     103f42 <page_init+0x13e>
  103f39:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103f40:	77 0c                	ja     103f4e <page_init+0x14a>
                maxpa = end;
  103f42:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f45:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f48:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103f4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103f4e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103f52:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103f55:	8b 00                	mov    (%eax),%eax
  103f57:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103f5a:	0f 8f dd fe ff ff    	jg     103e3d <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103f60:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f64:	72 1d                	jb     103f83 <page_init+0x17f>
  103f66:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f6a:	77 09                	ja     103f75 <page_init+0x171>
  103f6c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103f73:	76 0e                	jbe    103f83 <page_init+0x17f>
        maxpa = KMEMSIZE;
  103f75:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103f7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103f83:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f89:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103f8d:	c1 ea 0c             	shr    $0xc,%edx
  103f90:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103f95:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103f9c:	b8 28 af 11 00       	mov    $0x11af28,%eax
  103fa1:	8d 50 ff             	lea    -0x1(%eax),%edx
  103fa4:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103fa7:	01 d0                	add    %edx,%eax
  103fa9:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103fac:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103faf:	ba 00 00 00 00       	mov    $0x0,%edx
  103fb4:	f7 75 ac             	divl   -0x54(%ebp)
  103fb7:	89 d0                	mov    %edx,%eax
  103fb9:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103fbc:	29 c2                	sub    %eax,%edx
  103fbe:	89 d0                	mov    %edx,%eax
  103fc0:	a3 24 af 11 00       	mov    %eax,0x11af24

    for (i = 0; i < npage; i ++) {
  103fc5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fcc:	eb 2f                	jmp    103ffd <page_init+0x1f9>
        SetPageReserved(pages + i);
  103fce:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103fd4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fd7:	89 d0                	mov    %edx,%eax
  103fd9:	c1 e0 02             	shl    $0x2,%eax
  103fdc:	01 d0                	add    %edx,%eax
  103fde:	c1 e0 02             	shl    $0x2,%eax
  103fe1:	01 c8                	add    %ecx,%eax
  103fe3:	83 c0 04             	add    $0x4,%eax
  103fe6:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  103fed:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103ff0:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103ff3:	8b 55 90             	mov    -0x70(%ebp),%edx
  103ff6:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  103ff9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103ffd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104000:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104005:	39 c2                	cmp    %eax,%edx
  104007:	72 c5                	jb     103fce <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104009:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10400f:	89 d0                	mov    %edx,%eax
  104011:	c1 e0 02             	shl    $0x2,%eax
  104014:	01 d0                	add    %edx,%eax
  104016:	c1 e0 02             	shl    $0x2,%eax
  104019:	89 c2                	mov    %eax,%edx
  10401b:	a1 24 af 11 00       	mov    0x11af24,%eax
  104020:	01 d0                	add    %edx,%eax
  104022:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  104025:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  10402c:	77 23                	ja     104051 <page_init+0x24d>
  10402e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104031:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104035:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  10403c:	00 
  10403d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  104044:	00 
  104045:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10404c:	e8 81 cc ff ff       	call   100cd2 <__panic>
  104051:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104054:	05 00 00 00 40       	add    $0x40000000,%eax
  104059:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  10405c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104063:	e9 74 01 00 00       	jmp    1041dc <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104068:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10406b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10406e:	89 d0                	mov    %edx,%eax
  104070:	c1 e0 02             	shl    $0x2,%eax
  104073:	01 d0                	add    %edx,%eax
  104075:	c1 e0 02             	shl    $0x2,%eax
  104078:	01 c8                	add    %ecx,%eax
  10407a:	8b 50 08             	mov    0x8(%eax),%edx
  10407d:	8b 40 04             	mov    0x4(%eax),%eax
  104080:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104083:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104086:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104089:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10408c:	89 d0                	mov    %edx,%eax
  10408e:	c1 e0 02             	shl    $0x2,%eax
  104091:	01 d0                	add    %edx,%eax
  104093:	c1 e0 02             	shl    $0x2,%eax
  104096:	01 c8                	add    %ecx,%eax
  104098:	8b 48 0c             	mov    0xc(%eax),%ecx
  10409b:	8b 58 10             	mov    0x10(%eax),%ebx
  10409e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1040a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1040a4:	01 c8                	add    %ecx,%eax
  1040a6:	11 da                	adc    %ebx,%edx
  1040a8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1040ab:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1040ae:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040b4:	89 d0                	mov    %edx,%eax
  1040b6:	c1 e0 02             	shl    $0x2,%eax
  1040b9:	01 d0                	add    %edx,%eax
  1040bb:	c1 e0 02             	shl    $0x2,%eax
  1040be:	01 c8                	add    %ecx,%eax
  1040c0:	83 c0 14             	add    $0x14,%eax
  1040c3:	8b 00                	mov    (%eax),%eax
  1040c5:	83 f8 01             	cmp    $0x1,%eax
  1040c8:	0f 85 0a 01 00 00    	jne    1041d8 <page_init+0x3d4>
            if (begin < freemem) {
  1040ce:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040d1:	ba 00 00 00 00       	mov    $0x0,%edx
  1040d6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040d9:	72 17                	jb     1040f2 <page_init+0x2ee>
  1040db:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040de:	77 05                	ja     1040e5 <page_init+0x2e1>
  1040e0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1040e3:	76 0d                	jbe    1040f2 <page_init+0x2ee>
                begin = freemem;
  1040e5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1040f2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1040f6:	72 1d                	jb     104115 <page_init+0x311>
  1040f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1040fc:	77 09                	ja     104107 <page_init+0x303>
  1040fe:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  104105:	76 0e                	jbe    104115 <page_init+0x311>
                end = KMEMSIZE;
  104107:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  10410e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104115:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104118:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10411b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10411e:	0f 87 b4 00 00 00    	ja     1041d8 <page_init+0x3d4>
  104124:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104127:	72 09                	jb     104132 <page_init+0x32e>
  104129:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10412c:	0f 83 a6 00 00 00    	jae    1041d8 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  104132:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104139:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10413c:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10413f:	01 d0                	add    %edx,%eax
  104141:	83 e8 01             	sub    $0x1,%eax
  104144:	89 45 98             	mov    %eax,-0x68(%ebp)
  104147:	8b 45 98             	mov    -0x68(%ebp),%eax
  10414a:	ba 00 00 00 00       	mov    $0x0,%edx
  10414f:	f7 75 9c             	divl   -0x64(%ebp)
  104152:	89 d0                	mov    %edx,%eax
  104154:	8b 55 98             	mov    -0x68(%ebp),%edx
  104157:	29 c2                	sub    %eax,%edx
  104159:	89 d0                	mov    %edx,%eax
  10415b:	ba 00 00 00 00       	mov    $0x0,%edx
  104160:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104163:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104166:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104169:	89 45 94             	mov    %eax,-0x6c(%ebp)
  10416c:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10416f:	ba 00 00 00 00       	mov    $0x0,%edx
  104174:	89 c7                	mov    %eax,%edi
  104176:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  10417c:	89 7d 80             	mov    %edi,-0x80(%ebp)
  10417f:	89 d0                	mov    %edx,%eax
  104181:	83 e0 00             	and    $0x0,%eax
  104184:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104187:	8b 45 80             	mov    -0x80(%ebp),%eax
  10418a:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10418d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104190:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104193:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104196:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104199:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10419c:	77 3a                	ja     1041d8 <page_init+0x3d4>
  10419e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041a1:	72 05                	jb     1041a8 <page_init+0x3a4>
  1041a3:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1041a6:	73 30                	jae    1041d8 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1041a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  1041ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  1041ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1041b1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1041b4:	29 c8                	sub    %ecx,%eax
  1041b6:	19 da                	sbb    %ebx,%edx
  1041b8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1041bc:	c1 ea 0c             	shr    $0xc,%edx
  1041bf:	89 c3                	mov    %eax,%ebx
  1041c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041c4:	89 04 24             	mov    %eax,(%esp)
  1041c7:	e8 a5 f8 ff ff       	call   103a71 <pa2page>
  1041cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041d0:	89 04 24             	mov    %eax,(%esp)
  1041d3:	e8 78 fb ff ff       	call   103d50 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  1041d8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1041dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1041df:	8b 00                	mov    (%eax),%eax
  1041e1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1041e4:	0f 8f 7e fe ff ff    	jg     104068 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  1041ea:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1041f0:	5b                   	pop    %ebx
  1041f1:	5e                   	pop    %esi
  1041f2:	5f                   	pop    %edi
  1041f3:	5d                   	pop    %ebp
  1041f4:	c3                   	ret    

001041f5 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1041f5:	55                   	push   %ebp
  1041f6:	89 e5                	mov    %esp,%ebp
  1041f8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1041fb:	8b 45 14             	mov    0x14(%ebp),%eax
  1041fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  104201:	31 d0                	xor    %edx,%eax
  104203:	25 ff 0f 00 00       	and    $0xfff,%eax
  104208:	85 c0                	test   %eax,%eax
  10420a:	74 24                	je     104230 <boot_map_segment+0x3b>
  10420c:	c7 44 24 0c 5a 6b 10 	movl   $0x106b5a,0xc(%esp)
  104213:	00 
  104214:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  10421b:	00 
  10421c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104223:	00 
  104224:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10422b:	e8 a2 ca ff ff       	call   100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104230:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104237:	8b 45 0c             	mov    0xc(%ebp),%eax
  10423a:	25 ff 0f 00 00       	and    $0xfff,%eax
  10423f:	89 c2                	mov    %eax,%edx
  104241:	8b 45 10             	mov    0x10(%ebp),%eax
  104244:	01 c2                	add    %eax,%edx
  104246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104249:	01 d0                	add    %edx,%eax
  10424b:	83 e8 01             	sub    $0x1,%eax
  10424e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104251:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104254:	ba 00 00 00 00       	mov    $0x0,%edx
  104259:	f7 75 f0             	divl   -0x10(%ebp)
  10425c:	89 d0                	mov    %edx,%eax
  10425e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104261:	29 c2                	sub    %eax,%edx
  104263:	89 d0                	mov    %edx,%eax
  104265:	c1 e8 0c             	shr    $0xc,%eax
  104268:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10426b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10426e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104271:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104274:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104279:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  10427c:	8b 45 14             	mov    0x14(%ebp),%eax
  10427f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104285:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10428a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10428d:	eb 6b                	jmp    1042fa <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10428f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104296:	00 
  104297:	8b 45 0c             	mov    0xc(%ebp),%eax
  10429a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10429e:	8b 45 08             	mov    0x8(%ebp),%eax
  1042a1:	89 04 24             	mov    %eax,(%esp)
  1042a4:	e8 82 01 00 00       	call   10442b <get_pte>
  1042a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1042ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1042b0:	75 24                	jne    1042d6 <boot_map_segment+0xe1>
  1042b2:	c7 44 24 0c 86 6b 10 	movl   $0x106b86,0xc(%esp)
  1042b9:	00 
  1042ba:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1042c1:	00 
  1042c2:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1042c9:	00 
  1042ca:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1042d1:	e8 fc c9 ff ff       	call   100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
  1042d6:	8b 45 18             	mov    0x18(%ebp),%eax
  1042d9:	8b 55 14             	mov    0x14(%ebp),%edx
  1042dc:	09 d0                	or     %edx,%eax
  1042de:	83 c8 01             	or     $0x1,%eax
  1042e1:	89 c2                	mov    %eax,%edx
  1042e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1042e6:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1042e8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1042ec:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1042f3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1042fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1042fe:	75 8f                	jne    10428f <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  104300:	c9                   	leave  
  104301:	c3                   	ret    

00104302 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104302:	55                   	push   %ebp
  104303:	89 e5                	mov    %esp,%ebp
  104305:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  104308:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10430f:	e8 5b fa ff ff       	call   103d6f <alloc_pages>
  104314:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104317:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10431b:	75 1c                	jne    104339 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10431d:	c7 44 24 08 93 6b 10 	movl   $0x106b93,0x8(%esp)
  104324:	00 
  104325:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10432c:	00 
  10432d:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104334:	e8 99 c9 ff ff       	call   100cd2 <__panic>
    }
    return page2kva(p);
  104339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10433c:	89 04 24             	mov    %eax,(%esp)
  10433f:	e8 7c f7 ff ff       	call   103ac0 <page2kva>
}
  104344:	c9                   	leave  
  104345:	c3                   	ret    

00104346 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104346:	55                   	push   %ebp
  104347:	89 e5                	mov    %esp,%ebp
  104349:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10434c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104351:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104354:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10435b:	77 23                	ja     104380 <pmm_init+0x3a>
  10435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104360:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104364:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  10436b:	00 
  10436c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104373:	00 
  104374:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10437b:	e8 52 c9 ff ff       	call   100cd2 <__panic>
  104380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104383:	05 00 00 00 40       	add    $0x40000000,%eax
  104388:	a3 20 af 11 00       	mov    %eax,0x11af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10438d:	e8 8b f9 ff ff       	call   103d1d <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104392:	e8 6d fa ff ff       	call   103e04 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104397:	e8 db 03 00 00       	call   104777 <check_alloc_page>

    check_pgdir();
  10439c:	e8 f4 03 00 00       	call   104795 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1043a1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043a6:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1043ac:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1043b4:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1043bb:	77 23                	ja     1043e0 <pmm_init+0x9a>
  1043bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043c4:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  1043cb:	00 
  1043cc:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1043d3:	00 
  1043d4:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1043db:	e8 f2 c8 ff ff       	call   100cd2 <__panic>
  1043e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043e3:	05 00 00 00 40       	add    $0x40000000,%eax
  1043e8:	83 c8 03             	or     $0x3,%eax
  1043eb:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1043ed:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043f2:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1043f9:	00 
  1043fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104401:	00 
  104402:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104409:	38 
  10440a:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  104411:	c0 
  104412:	89 04 24             	mov    %eax,(%esp)
  104415:	e8 db fd ff ff       	call   1041f5 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  10441a:	e8 0f f8 ff ff       	call   103c2e <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10441f:	e8 0c 0a 00 00       	call   104e30 <check_boot_pgdir>

    print_pgdir();
  104424:	e8 94 0e 00 00       	call   1052bd <print_pgdir>

}
  104429:	c9                   	leave  
  10442a:	c3                   	ret    

0010442b <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10442b:	55                   	push   %ebp
  10442c:	89 e5                	mov    %esp,%ebp
  10442e:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
pde_t *pdep = &pgdir[PDX(la)]; // 找到 PDE 这里的 pgdir 可以看做是页目录表的基址
  104431:	8b 45 0c             	mov    0xc(%ebp),%eax
  104434:	c1 e8 16             	shr    $0x16,%eax
  104437:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10443e:	8b 45 08             	mov    0x8(%ebp),%eax
  104441:	01 d0                	add    %edx,%eax
  104443:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // 看看 PDE 指向的页表是否存在
  104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104449:	8b 00                	mov    (%eax),%eax
  10444b:	83 e0 01             	and    $0x1,%eax
  10444e:	85 c0                	test   %eax,%eax
  104450:	0f 85 af 00 00 00    	jne    104505 <get_pte+0xda>
        struct Page* page = alloc_page(); // 不存在就申请一页物理页
  104456:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10445d:	e8 0d f9 ff ff       	call   103d6f <alloc_pages>
  104462:	89 45 f0             	mov    %eax,-0x10(%ebp)
        
        if (!create || page == NULL) { //不存在且不需要创建，返回NULL
  104465:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104469:	74 06                	je     104471 <get_pte+0x46>
  10446b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10446f:	75 0a                	jne    10447b <get_pte+0x50>
            return NULL;
  104471:	b8 00 00 00 00       	mov    $0x0,%eax
  104476:	e9 e6 00 00 00       	jmp    104561 <get_pte+0x136>
        }
        set_page_ref(page, 1); //设置此页被引用一次
  10447b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104482:	00 
  104483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104486:	89 04 24             	mov    %eax,(%esp)
  104489:	e8 e6 f6 ff ff       	call   103b74 <set_page_ref>
        uintptr_t pa = page2pa(page);//得到 page 管理的那一页的物理地址
  10448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104491:	89 04 24             	mov    %eax,(%esp)
  104494:	e8 c2 f5 ff ff       	call   103a5b <page2pa>
  104499:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); 
  10449c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10449f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1044a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044a5:	c1 e8 0c             	shr    $0xc,%eax
  1044a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1044ab:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1044b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1044b3:	72 23                	jb     1044d8 <get_pte+0xad>
  1044b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1044bc:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  1044c3:	00 
  1044c4:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
  1044cb:	00 
  1044cc:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1044d3:	e8 fa c7 ff ff       	call   100cd2 <__panic>
  1044d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044db:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1044e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1044e7:	00 
  1044e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1044ef:	00 
  1044f0:	89 04 24             	mov    %eax,(%esp)
  1044f3:	e8 e3 18 00 00       	call   105ddb <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P; // 设置 PDE 权限
  1044f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044fb:	83 c8 07             	or     $0x7,%eax
  1044fe:	89 c2                	mov    %eax,%edx
  104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104503:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104508:	8b 00                	mov    (%eax),%eax
  10450a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10450f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104512:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104515:	c1 e8 0c             	shr    $0xc,%eax
  104518:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10451b:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104520:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104523:	72 23                	jb     104548 <get_pte+0x11d>
  104525:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104528:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10452c:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  104533:	00 
  104534:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
  10453b:	00 
  10453c:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104543:	e8 8a c7 ff ff       	call   100cd2 <__panic>
  104548:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10454b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104550:	8b 55 0c             	mov    0xc(%ebp),%edx
  104553:	c1 ea 0c             	shr    $0xc,%edx
  104556:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  10455c:	c1 e2 02             	shl    $0x2,%edx
  10455f:	01 d0                	add    %edx,%eax
}
  104561:	c9                   	leave  
  104562:	c3                   	ret    

00104563 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  104563:	55                   	push   %ebp
  104564:	89 e5                	mov    %esp,%ebp
  104566:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104569:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104570:	00 
  104571:	8b 45 0c             	mov    0xc(%ebp),%eax
  104574:	89 44 24 04          	mov    %eax,0x4(%esp)
  104578:	8b 45 08             	mov    0x8(%ebp),%eax
  10457b:	89 04 24             	mov    %eax,(%esp)
  10457e:	e8 a8 fe ff ff       	call   10442b <get_pte>
  104583:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  104586:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10458a:	74 08                	je     104594 <get_page+0x31>
        *ptep_store = ptep;
  10458c:	8b 45 10             	mov    0x10(%ebp),%eax
  10458f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104592:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104594:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104598:	74 1b                	je     1045b5 <get_page+0x52>
  10459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10459d:	8b 00                	mov    (%eax),%eax
  10459f:	83 e0 01             	and    $0x1,%eax
  1045a2:	85 c0                	test   %eax,%eax
  1045a4:	74 0f                	je     1045b5 <get_page+0x52>
        return pte2page(*ptep);
  1045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045a9:	8b 00                	mov    (%eax),%eax
  1045ab:	89 04 24             	mov    %eax,(%esp)
  1045ae:	e8 61 f5 ff ff       	call   103b14 <pte2page>
  1045b3:	eb 05                	jmp    1045ba <get_page+0x57>
    }
    return NULL;
  1045b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1045ba:	c9                   	leave  
  1045bb:	c3                   	ret    

001045bc <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1045bc:	55                   	push   %ebp
  1045bd:	89 e5                	mov    %esp,%ebp
  1045bf:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
if ((*ptep & PTE_P)) { //判断页表中该表项是否存在
  1045c2:	8b 45 10             	mov    0x10(%ebp),%eax
  1045c5:	8b 00                	mov    (%eax),%eax
  1045c7:	83 e0 01             	and    $0x1,%eax
  1045ca:	85 c0                	test   %eax,%eax
  1045cc:	74 4d                	je     10461b <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);// 将页表项转换为页数据结构
  1045ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1045d1:	8b 00                	mov    (%eax),%eax
  1045d3:	89 04 24             	mov    %eax,(%esp)
  1045d6:	e8 39 f5 ff ff       	call   103b14 <pte2page>
  1045db:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { // 判断是否只被引用了一次，若引用计数减一后为0，则释放该物理页
  1045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045e1:	89 04 24             	mov    %eax,(%esp)
  1045e4:	e8 af f5 ff ff       	call   103b98 <page_ref_dec>
  1045e9:	85 c0                	test   %eax,%eax
  1045eb:	75 13                	jne    104600 <page_remove_pte+0x44>
            free_page(page);
  1045ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1045f4:	00 
  1045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045f8:	89 04 24             	mov    %eax,(%esp)
  1045fb:	e8 a7 f7 ff ff       	call   103da7 <free_pages>
        }
        *ptep = 0; // //如果被多次引用，则不能释放此页，只用释放二级页表的表项，清空 PTE
  104600:	8b 45 10             	mov    0x10(%ebp),%eax
  104603:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la); // 刷新 tlb
  104609:	8b 45 0c             	mov    0xc(%ebp),%eax
  10460c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104610:	8b 45 08             	mov    0x8(%ebp),%eax
  104613:	89 04 24             	mov    %eax,(%esp)
  104616:	e8 ff 00 00 00       	call   10471a <tlb_invalidate>
    }
}
  10461b:	c9                   	leave  
  10461c:	c3                   	ret    

0010461d <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10461d:	55                   	push   %ebp
  10461e:	89 e5                	mov    %esp,%ebp
  104620:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104623:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10462a:	00 
  10462b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10462e:	89 44 24 04          	mov    %eax,0x4(%esp)
  104632:	8b 45 08             	mov    0x8(%ebp),%eax
  104635:	89 04 24             	mov    %eax,(%esp)
  104638:	e8 ee fd ff ff       	call   10442b <get_pte>
  10463d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104640:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104644:	74 19                	je     10465f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104649:	89 44 24 08          	mov    %eax,0x8(%esp)
  10464d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104650:	89 44 24 04          	mov    %eax,0x4(%esp)
  104654:	8b 45 08             	mov    0x8(%ebp),%eax
  104657:	89 04 24             	mov    %eax,(%esp)
  10465a:	e8 5d ff ff ff       	call   1045bc <page_remove_pte>
    }
}
  10465f:	c9                   	leave  
  104660:	c3                   	ret    

00104661 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104661:	55                   	push   %ebp
  104662:	89 e5                	mov    %esp,%ebp
  104664:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  104667:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10466e:	00 
  10466f:	8b 45 10             	mov    0x10(%ebp),%eax
  104672:	89 44 24 04          	mov    %eax,0x4(%esp)
  104676:	8b 45 08             	mov    0x8(%ebp),%eax
  104679:	89 04 24             	mov    %eax,(%esp)
  10467c:	e8 aa fd ff ff       	call   10442b <get_pte>
  104681:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104688:	75 0a                	jne    104694 <page_insert+0x33>
        return -E_NO_MEM;
  10468a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10468f:	e9 84 00 00 00       	jmp    104718 <page_insert+0xb7>
    }
    page_ref_inc(page);
  104694:	8b 45 0c             	mov    0xc(%ebp),%eax
  104697:	89 04 24             	mov    %eax,(%esp)
  10469a:	e8 e2 f4 ff ff       	call   103b81 <page_ref_inc>
    if (*ptep & PTE_P) {
  10469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046a2:	8b 00                	mov    (%eax),%eax
  1046a4:	83 e0 01             	and    $0x1,%eax
  1046a7:	85 c0                	test   %eax,%eax
  1046a9:	74 3e                	je     1046e9 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ae:	8b 00                	mov    (%eax),%eax
  1046b0:	89 04 24             	mov    %eax,(%esp)
  1046b3:	e8 5c f4 ff ff       	call   103b14 <pte2page>
  1046b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1046bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046be:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1046c1:	75 0d                	jne    1046d0 <page_insert+0x6f>
            page_ref_dec(page);
  1046c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046c6:	89 04 24             	mov    %eax,(%esp)
  1046c9:	e8 ca f4 ff ff       	call   103b98 <page_ref_dec>
  1046ce:	eb 19                	jmp    1046e9 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046d7:	8b 45 10             	mov    0x10(%ebp),%eax
  1046da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046de:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e1:	89 04 24             	mov    %eax,(%esp)
  1046e4:	e8 d3 fe ff ff       	call   1045bc <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1046e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046ec:	89 04 24             	mov    %eax,(%esp)
  1046ef:	e8 67 f3 ff ff       	call   103a5b <page2pa>
  1046f4:	0b 45 14             	or     0x14(%ebp),%eax
  1046f7:	83 c8 01             	or     $0x1,%eax
  1046fa:	89 c2                	mov    %eax,%edx
  1046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ff:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  104701:	8b 45 10             	mov    0x10(%ebp),%eax
  104704:	89 44 24 04          	mov    %eax,0x4(%esp)
  104708:	8b 45 08             	mov    0x8(%ebp),%eax
  10470b:	89 04 24             	mov    %eax,(%esp)
  10470e:	e8 07 00 00 00       	call   10471a <tlb_invalidate>
    return 0;
  104713:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104718:	c9                   	leave  
  104719:	c3                   	ret    

0010471a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10471a:	55                   	push   %ebp
  10471b:	89 e5                	mov    %esp,%ebp
  10471d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104720:	0f 20 d8             	mov    %cr3,%eax
  104723:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  104726:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  104729:	89 c2                	mov    %eax,%edx
  10472b:	8b 45 08             	mov    0x8(%ebp),%eax
  10472e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104731:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104738:	77 23                	ja     10475d <tlb_invalidate+0x43>
  10473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10473d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104741:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  104748:	00 
  104749:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  104750:	00 
  104751:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104758:	e8 75 c5 ff ff       	call   100cd2 <__panic>
  10475d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104760:	05 00 00 00 40       	add    $0x40000000,%eax
  104765:	39 c2                	cmp    %eax,%edx
  104767:	75 0c                	jne    104775 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  104769:	8b 45 0c             	mov    0xc(%ebp),%eax
  10476c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  10476f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104772:	0f 01 38             	invlpg (%eax)
    }
}
  104775:	c9                   	leave  
  104776:	c3                   	ret    

00104777 <check_alloc_page>:

static void
check_alloc_page(void) {
  104777:	55                   	push   %ebp
  104778:	89 e5                	mov    %esp,%ebp
  10477a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10477d:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104782:	8b 40 18             	mov    0x18(%eax),%eax
  104785:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104787:	c7 04 24 ac 6b 10 00 	movl   $0x106bac,(%esp)
  10478e:	e8 b5 bb ff ff       	call   100348 <cprintf>
}
  104793:	c9                   	leave  
  104794:	c3                   	ret    

00104795 <check_pgdir>:

static void
check_pgdir(void) {
  104795:	55                   	push   %ebp
  104796:	89 e5                	mov    %esp,%ebp
  104798:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10479b:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1047a0:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1047a5:	76 24                	jbe    1047cb <check_pgdir+0x36>
  1047a7:	c7 44 24 0c cb 6b 10 	movl   $0x106bcb,0xc(%esp)
  1047ae:	00 
  1047af:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1047b6:	00 
  1047b7:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  1047be:	00 
  1047bf:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1047c6:	e8 07 c5 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1047cb:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047d0:	85 c0                	test   %eax,%eax
  1047d2:	74 0e                	je     1047e2 <check_pgdir+0x4d>
  1047d4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047d9:	25 ff 0f 00 00       	and    $0xfff,%eax
  1047de:	85 c0                	test   %eax,%eax
  1047e0:	74 24                	je     104806 <check_pgdir+0x71>
  1047e2:	c7 44 24 0c e8 6b 10 	movl   $0x106be8,0xc(%esp)
  1047e9:	00 
  1047ea:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1047f1:	00 
  1047f2:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  1047f9:	00 
  1047fa:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104801:	e8 cc c4 ff ff       	call   100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104806:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10480b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104812:	00 
  104813:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10481a:	00 
  10481b:	89 04 24             	mov    %eax,(%esp)
  10481e:	e8 40 fd ff ff       	call   104563 <get_page>
  104823:	85 c0                	test   %eax,%eax
  104825:	74 24                	je     10484b <check_pgdir+0xb6>
  104827:	c7 44 24 0c 20 6c 10 	movl   $0x106c20,0xc(%esp)
  10482e:	00 
  10482f:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104836:	00 
  104837:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  10483e:	00 
  10483f:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104846:	e8 87 c4 ff ff       	call   100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10484b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104852:	e8 18 f5 ff ff       	call   103d6f <alloc_pages>
  104857:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10485a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10485f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104866:	00 
  104867:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10486e:	00 
  10486f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104872:	89 54 24 04          	mov    %edx,0x4(%esp)
  104876:	89 04 24             	mov    %eax,(%esp)
  104879:	e8 e3 fd ff ff       	call   104661 <page_insert>
  10487e:	85 c0                	test   %eax,%eax
  104880:	74 24                	je     1048a6 <check_pgdir+0x111>
  104882:	c7 44 24 0c 48 6c 10 	movl   $0x106c48,0xc(%esp)
  104889:	00 
  10488a:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104891:	00 
  104892:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  104899:	00 
  10489a:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1048a1:	e8 2c c4 ff ff       	call   100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1048a6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1048ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048b2:	00 
  1048b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048ba:	00 
  1048bb:	89 04 24             	mov    %eax,(%esp)
  1048be:	e8 68 fb ff ff       	call   10442b <get_pte>
  1048c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048ca:	75 24                	jne    1048f0 <check_pgdir+0x15b>
  1048cc:	c7 44 24 0c 74 6c 10 	movl   $0x106c74,0xc(%esp)
  1048d3:	00 
  1048d4:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1048db:	00 
  1048dc:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  1048e3:	00 
  1048e4:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1048eb:	e8 e2 c3 ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  1048f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048f3:	8b 00                	mov    (%eax),%eax
  1048f5:	89 04 24             	mov    %eax,(%esp)
  1048f8:	e8 17 f2 ff ff       	call   103b14 <pte2page>
  1048fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104900:	74 24                	je     104926 <check_pgdir+0x191>
  104902:	c7 44 24 0c a1 6c 10 	movl   $0x106ca1,0xc(%esp)
  104909:	00 
  10490a:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104911:	00 
  104912:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  104919:	00 
  10491a:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104921:	e8 ac c3 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 1);
  104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104929:	89 04 24             	mov    %eax,(%esp)
  10492c:	e8 39 f2 ff ff       	call   103b6a <page_ref>
  104931:	83 f8 01             	cmp    $0x1,%eax
  104934:	74 24                	je     10495a <check_pgdir+0x1c5>
  104936:	c7 44 24 0c b7 6c 10 	movl   $0x106cb7,0xc(%esp)
  10493d:	00 
  10493e:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104945:	00 
  104946:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  10494d:	00 
  10494e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104955:	e8 78 c3 ff ff       	call   100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10495a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10495f:	8b 00                	mov    (%eax),%eax
  104961:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104966:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104969:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10496c:	c1 e8 0c             	shr    $0xc,%eax
  10496f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104972:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104977:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10497a:	72 23                	jb     10499f <check_pgdir+0x20a>
  10497c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10497f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104983:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  10498a:	00 
  10498b:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  104992:	00 
  104993:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10499a:	e8 33 c3 ff ff       	call   100cd2 <__panic>
  10499f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049a2:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1049a7:	83 c0 04             	add    $0x4,%eax
  1049aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1049ad:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049b9:	00 
  1049ba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1049c1:	00 
  1049c2:	89 04 24             	mov    %eax,(%esp)
  1049c5:	e8 61 fa ff ff       	call   10442b <get_pte>
  1049ca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1049cd:	74 24                	je     1049f3 <check_pgdir+0x25e>
  1049cf:	c7 44 24 0c cc 6c 10 	movl   $0x106ccc,0xc(%esp)
  1049d6:	00 
  1049d7:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1049de:	00 
  1049df:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  1049e6:	00 
  1049e7:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1049ee:	e8 df c2 ff ff       	call   100cd2 <__panic>

    p2 = alloc_page();
  1049f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1049fa:	e8 70 f3 ff ff       	call   103d6f <alloc_pages>
  1049ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104a02:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104a0e:	00 
  104a0f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104a16:	00 
  104a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104a1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a1e:	89 04 24             	mov    %eax,(%esp)
  104a21:	e8 3b fc ff ff       	call   104661 <page_insert>
  104a26:	85 c0                	test   %eax,%eax
  104a28:	74 24                	je     104a4e <check_pgdir+0x2b9>
  104a2a:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  104a31:	00 
  104a32:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104a39:	00 
  104a3a:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  104a41:	00 
  104a42:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104a49:	e8 84 c2 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104a4e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a5a:	00 
  104a5b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a62:	00 
  104a63:	89 04 24             	mov    %eax,(%esp)
  104a66:	e8 c0 f9 ff ff       	call   10442b <get_pte>
  104a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a72:	75 24                	jne    104a98 <check_pgdir+0x303>
  104a74:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  104a7b:	00 
  104a7c:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104a83:	00 
  104a84:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  104a8b:	00 
  104a8c:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104a93:	e8 3a c2 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_U);
  104a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a9b:	8b 00                	mov    (%eax),%eax
  104a9d:	83 e0 04             	and    $0x4,%eax
  104aa0:	85 c0                	test   %eax,%eax
  104aa2:	75 24                	jne    104ac8 <check_pgdir+0x333>
  104aa4:	c7 44 24 0c 5c 6d 10 	movl   $0x106d5c,0xc(%esp)
  104aab:	00 
  104aac:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104ab3:	00 
  104ab4:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  104abb:	00 
  104abc:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104ac3:	e8 0a c2 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_W);
  104ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104acb:	8b 00                	mov    (%eax),%eax
  104acd:	83 e0 02             	and    $0x2,%eax
  104ad0:	85 c0                	test   %eax,%eax
  104ad2:	75 24                	jne    104af8 <check_pgdir+0x363>
  104ad4:	c7 44 24 0c 6a 6d 10 	movl   $0x106d6a,0xc(%esp)
  104adb:	00 
  104adc:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104ae3:	00 
  104ae4:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  104aeb:	00 
  104aec:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104af3:	e8 da c1 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104af8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104afd:	8b 00                	mov    (%eax),%eax
  104aff:	83 e0 04             	and    $0x4,%eax
  104b02:	85 c0                	test   %eax,%eax
  104b04:	75 24                	jne    104b2a <check_pgdir+0x395>
  104b06:	c7 44 24 0c 78 6d 10 	movl   $0x106d78,0xc(%esp)
  104b0d:	00 
  104b0e:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104b15:	00 
  104b16:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  104b1d:	00 
  104b1e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104b25:	e8 a8 c1 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 1);
  104b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b2d:	89 04 24             	mov    %eax,(%esp)
  104b30:	e8 35 f0 ff ff       	call   103b6a <page_ref>
  104b35:	83 f8 01             	cmp    $0x1,%eax
  104b38:	74 24                	je     104b5e <check_pgdir+0x3c9>
  104b3a:	c7 44 24 0c 8e 6d 10 	movl   $0x106d8e,0xc(%esp)
  104b41:	00 
  104b42:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104b49:	00 
  104b4a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  104b51:	00 
  104b52:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104b59:	e8 74 c1 ff ff       	call   100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104b5e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b63:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104b6a:	00 
  104b6b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104b72:	00 
  104b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b76:	89 54 24 04          	mov    %edx,0x4(%esp)
  104b7a:	89 04 24             	mov    %eax,(%esp)
  104b7d:	e8 df fa ff ff       	call   104661 <page_insert>
  104b82:	85 c0                	test   %eax,%eax
  104b84:	74 24                	je     104baa <check_pgdir+0x415>
  104b86:	c7 44 24 0c a0 6d 10 	movl   $0x106da0,0xc(%esp)
  104b8d:	00 
  104b8e:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104b95:	00 
  104b96:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  104b9d:	00 
  104b9e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104ba5:	e8 28 c1 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 2);
  104baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bad:	89 04 24             	mov    %eax,(%esp)
  104bb0:	e8 b5 ef ff ff       	call   103b6a <page_ref>
  104bb5:	83 f8 02             	cmp    $0x2,%eax
  104bb8:	74 24                	je     104bde <check_pgdir+0x449>
  104bba:	c7 44 24 0c cc 6d 10 	movl   $0x106dcc,0xc(%esp)
  104bc1:	00 
  104bc2:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104bc9:	00 
  104bca:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  104bd1:	00 
  104bd2:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104bd9:	e8 f4 c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104bde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104be1:	89 04 24             	mov    %eax,(%esp)
  104be4:	e8 81 ef ff ff       	call   103b6a <page_ref>
  104be9:	85 c0                	test   %eax,%eax
  104beb:	74 24                	je     104c11 <check_pgdir+0x47c>
  104bed:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104bf4:	00 
  104bf5:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104bfc:	00 
  104bfd:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  104c04:	00 
  104c05:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104c0c:	e8 c1 c0 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c11:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c1d:	00 
  104c1e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c25:	00 
  104c26:	89 04 24             	mov    %eax,(%esp)
  104c29:	e8 fd f7 ff ff       	call   10442b <get_pte>
  104c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c35:	75 24                	jne    104c5b <check_pgdir+0x4c6>
  104c37:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  104c3e:	00 
  104c3f:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104c46:	00 
  104c47:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  104c4e:	00 
  104c4f:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104c56:	e8 77 c0 ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  104c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c5e:	8b 00                	mov    (%eax),%eax
  104c60:	89 04 24             	mov    %eax,(%esp)
  104c63:	e8 ac ee ff ff       	call   103b14 <pte2page>
  104c68:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104c6b:	74 24                	je     104c91 <check_pgdir+0x4fc>
  104c6d:	c7 44 24 0c a1 6c 10 	movl   $0x106ca1,0xc(%esp)
  104c74:	00 
  104c75:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104c7c:	00 
  104c7d:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  104c84:	00 
  104c85:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104c8c:	e8 41 c0 ff ff       	call   100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
  104c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c94:	8b 00                	mov    (%eax),%eax
  104c96:	83 e0 04             	and    $0x4,%eax
  104c99:	85 c0                	test   %eax,%eax
  104c9b:	74 24                	je     104cc1 <check_pgdir+0x52c>
  104c9d:	c7 44 24 0c f0 6d 10 	movl   $0x106df0,0xc(%esp)
  104ca4:	00 
  104ca5:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104cac:	00 
  104cad:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104cb4:	00 
  104cb5:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104cbc:	e8 11 c0 ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
  104cc1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104cc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104ccd:	00 
  104cce:	89 04 24             	mov    %eax,(%esp)
  104cd1:	e8 47 f9 ff ff       	call   10461d <page_remove>
    assert(page_ref(p1) == 1);
  104cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cd9:	89 04 24             	mov    %eax,(%esp)
  104cdc:	e8 89 ee ff ff       	call   103b6a <page_ref>
  104ce1:	83 f8 01             	cmp    $0x1,%eax
  104ce4:	74 24                	je     104d0a <check_pgdir+0x575>
  104ce6:	c7 44 24 0c b7 6c 10 	movl   $0x106cb7,0xc(%esp)
  104ced:	00 
  104cee:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104cf5:	00 
  104cf6:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  104cfd:	00 
  104cfe:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104d05:	e8 c8 bf ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d0d:	89 04 24             	mov    %eax,(%esp)
  104d10:	e8 55 ee ff ff       	call   103b6a <page_ref>
  104d15:	85 c0                	test   %eax,%eax
  104d17:	74 24                	je     104d3d <check_pgdir+0x5a8>
  104d19:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104d20:	00 
  104d21:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104d28:	00 
  104d29:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104d30:	00 
  104d31:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104d38:	e8 95 bf ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104d3d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d42:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d49:	00 
  104d4a:	89 04 24             	mov    %eax,(%esp)
  104d4d:	e8 cb f8 ff ff       	call   10461d <page_remove>
    assert(page_ref(p1) == 0);
  104d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d55:	89 04 24             	mov    %eax,(%esp)
  104d58:	e8 0d ee ff ff       	call   103b6a <page_ref>
  104d5d:	85 c0                	test   %eax,%eax
  104d5f:	74 24                	je     104d85 <check_pgdir+0x5f0>
  104d61:	c7 44 24 0c 05 6e 10 	movl   $0x106e05,0xc(%esp)
  104d68:	00 
  104d69:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104d70:	00 
  104d71:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  104d78:	00 
  104d79:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104d80:	e8 4d bf ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d88:	89 04 24             	mov    %eax,(%esp)
  104d8b:	e8 da ed ff ff       	call   103b6a <page_ref>
  104d90:	85 c0                	test   %eax,%eax
  104d92:	74 24                	je     104db8 <check_pgdir+0x623>
  104d94:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104d9b:	00 
  104d9c:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104da3:	00 
  104da4:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104dab:	00 
  104dac:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104db3:	e8 1a bf ff ff       	call   100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104db8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104dbd:	8b 00                	mov    (%eax),%eax
  104dbf:	89 04 24             	mov    %eax,(%esp)
  104dc2:	e8 8b ed ff ff       	call   103b52 <pde2page>
  104dc7:	89 04 24             	mov    %eax,(%esp)
  104dca:	e8 9b ed ff ff       	call   103b6a <page_ref>
  104dcf:	83 f8 01             	cmp    $0x1,%eax
  104dd2:	74 24                	je     104df8 <check_pgdir+0x663>
  104dd4:	c7 44 24 0c 18 6e 10 	movl   $0x106e18,0xc(%esp)
  104ddb:	00 
  104ddc:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104de3:	00 
  104de4:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104deb:	00 
  104dec:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104df3:	e8 da be ff ff       	call   100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104df8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104dfd:	8b 00                	mov    (%eax),%eax
  104dff:	89 04 24             	mov    %eax,(%esp)
  104e02:	e8 4b ed ff ff       	call   103b52 <pde2page>
  104e07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e0e:	00 
  104e0f:	89 04 24             	mov    %eax,(%esp)
  104e12:	e8 90 ef ff ff       	call   103da7 <free_pages>
    boot_pgdir[0] = 0;
  104e17:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104e22:	c7 04 24 3f 6e 10 00 	movl   $0x106e3f,(%esp)
  104e29:	e8 1a b5 ff ff       	call   100348 <cprintf>
}
  104e2e:	c9                   	leave  
  104e2f:	c3                   	ret    

00104e30 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104e30:	55                   	push   %ebp
  104e31:	89 e5                	mov    %esp,%ebp
  104e33:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e3d:	e9 ca 00 00 00       	jmp    104f0c <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e4b:	c1 e8 0c             	shr    $0xc,%eax
  104e4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e51:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104e56:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104e59:	72 23                	jb     104e7e <check_boot_pgdir+0x4e>
  104e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104e62:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  104e69:	00 
  104e6a:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104e71:	00 
  104e72:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104e79:	e8 54 be ff ff       	call   100cd2 <__panic>
  104e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e81:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104e86:	89 c2                	mov    %eax,%edx
  104e88:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104e94:	00 
  104e95:	89 54 24 04          	mov    %edx,0x4(%esp)
  104e99:	89 04 24             	mov    %eax,(%esp)
  104e9c:	e8 8a f5 ff ff       	call   10442b <get_pte>
  104ea1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104ea4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104ea8:	75 24                	jne    104ece <check_boot_pgdir+0x9e>
  104eaa:	c7 44 24 0c 5c 6e 10 	movl   $0x106e5c,0xc(%esp)
  104eb1:	00 
  104eb2:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104eb9:	00 
  104eba:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104ec1:	00 
  104ec2:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104ec9:	e8 04 be ff ff       	call   100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104ece:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ed1:	8b 00                	mov    (%eax),%eax
  104ed3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104ed8:	89 c2                	mov    %eax,%edx
  104eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104edd:	39 c2                	cmp    %eax,%edx
  104edf:	74 24                	je     104f05 <check_boot_pgdir+0xd5>
  104ee1:	c7 44 24 0c 99 6e 10 	movl   $0x106e99,0xc(%esp)
  104ee8:	00 
  104ee9:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104ef0:	00 
  104ef1:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104ef8:	00 
  104ef9:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104f00:	e8 cd bd ff ff       	call   100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104f05:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104f0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104f0f:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104f14:	39 c2                	cmp    %eax,%edx
  104f16:	0f 82 26 ff ff ff    	jb     104e42 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104f1c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f21:	05 ac 0f 00 00       	add    $0xfac,%eax
  104f26:	8b 00                	mov    (%eax),%eax
  104f28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f2d:	89 c2                	mov    %eax,%edx
  104f2f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104f37:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104f3e:	77 23                	ja     104f63 <check_boot_pgdir+0x133>
  104f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104f47:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  104f4e:	00 
  104f4f:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104f56:	00 
  104f57:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104f5e:	e8 6f bd ff ff       	call   100cd2 <__panic>
  104f63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f66:	05 00 00 00 40       	add    $0x40000000,%eax
  104f6b:	39 c2                	cmp    %eax,%edx
  104f6d:	74 24                	je     104f93 <check_boot_pgdir+0x163>
  104f6f:	c7 44 24 0c b0 6e 10 	movl   $0x106eb0,0xc(%esp)
  104f76:	00 
  104f77:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104f7e:	00 
  104f7f:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104f86:	00 
  104f87:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104f8e:	e8 3f bd ff ff       	call   100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
  104f93:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f98:	8b 00                	mov    (%eax),%eax
  104f9a:	85 c0                	test   %eax,%eax
  104f9c:	74 24                	je     104fc2 <check_boot_pgdir+0x192>
  104f9e:	c7 44 24 0c e4 6e 10 	movl   $0x106ee4,0xc(%esp)
  104fa5:	00 
  104fa6:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104fad:	00 
  104fae:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104fb5:	00 
  104fb6:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104fbd:	e8 10 bd ff ff       	call   100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
  104fc2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104fc9:	e8 a1 ed ff ff       	call   103d6f <alloc_pages>
  104fce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104fd1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fd6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104fdd:	00 
  104fde:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  104fe5:	00 
  104fe6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104fe9:	89 54 24 04          	mov    %edx,0x4(%esp)
  104fed:	89 04 24             	mov    %eax,(%esp)
  104ff0:	e8 6c f6 ff ff       	call   104661 <page_insert>
  104ff5:	85 c0                	test   %eax,%eax
  104ff7:	74 24                	je     10501d <check_boot_pgdir+0x1ed>
  104ff9:	c7 44 24 0c f8 6e 10 	movl   $0x106ef8,0xc(%esp)
  105000:	00 
  105001:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105008:	00 
  105009:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  105010:	00 
  105011:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105018:	e8 b5 bc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 1);
  10501d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105020:	89 04 24             	mov    %eax,(%esp)
  105023:	e8 42 eb ff ff       	call   103b6a <page_ref>
  105028:	83 f8 01             	cmp    $0x1,%eax
  10502b:	74 24                	je     105051 <check_boot_pgdir+0x221>
  10502d:	c7 44 24 0c 26 6f 10 	movl   $0x106f26,0xc(%esp)
  105034:	00 
  105035:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  10503c:	00 
  10503d:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  105044:	00 
  105045:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10504c:	e8 81 bc ff ff       	call   100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105051:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105056:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10505d:	00 
  10505e:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  105065:	00 
  105066:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105069:	89 54 24 04          	mov    %edx,0x4(%esp)
  10506d:	89 04 24             	mov    %eax,(%esp)
  105070:	e8 ec f5 ff ff       	call   104661 <page_insert>
  105075:	85 c0                	test   %eax,%eax
  105077:	74 24                	je     10509d <check_boot_pgdir+0x26d>
  105079:	c7 44 24 0c 38 6f 10 	movl   $0x106f38,0xc(%esp)
  105080:	00 
  105081:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105088:	00 
  105089:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  105090:	00 
  105091:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105098:	e8 35 bc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 2);
  10509d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050a0:	89 04 24             	mov    %eax,(%esp)
  1050a3:	e8 c2 ea ff ff       	call   103b6a <page_ref>
  1050a8:	83 f8 02             	cmp    $0x2,%eax
  1050ab:	74 24                	je     1050d1 <check_boot_pgdir+0x2a1>
  1050ad:	c7 44 24 0c 6f 6f 10 	movl   $0x106f6f,0xc(%esp)
  1050b4:	00 
  1050b5:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1050bc:	00 
  1050bd:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  1050c4:	00 
  1050c5:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1050cc:	e8 01 bc ff ff       	call   100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
  1050d1:	c7 45 dc 80 6f 10 00 	movl   $0x106f80,-0x24(%ebp)
    strcpy((void *)0x100, str);
  1050d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1050db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050df:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1050e6:	e8 19 0a 00 00       	call   105b04 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1050eb:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1050f2:	00 
  1050f3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1050fa:	e8 7e 0a 00 00       	call   105b7d <strcmp>
  1050ff:	85 c0                	test   %eax,%eax
  105101:	74 24                	je     105127 <check_boot_pgdir+0x2f7>
  105103:	c7 44 24 0c 98 6f 10 	movl   $0x106f98,0xc(%esp)
  10510a:	00 
  10510b:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105112:	00 
  105113:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  10511a:	00 
  10511b:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105122:	e8 ab bb ff ff       	call   100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105127:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10512a:	89 04 24             	mov    %eax,(%esp)
  10512d:	e8 8e e9 ff ff       	call   103ac0 <page2kva>
  105132:	05 00 01 00 00       	add    $0x100,%eax
  105137:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  10513a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105141:	e8 66 09 00 00       	call   105aac <strlen>
  105146:	85 c0                	test   %eax,%eax
  105148:	74 24                	je     10516e <check_boot_pgdir+0x33e>
  10514a:	c7 44 24 0c d0 6f 10 	movl   $0x106fd0,0xc(%esp)
  105151:	00 
  105152:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105159:	00 
  10515a:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  105161:	00 
  105162:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105169:	e8 64 bb ff ff       	call   100cd2 <__panic>

    free_page(p);
  10516e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105175:	00 
  105176:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105179:	89 04 24             	mov    %eax,(%esp)
  10517c:	e8 26 ec ff ff       	call   103da7 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105181:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105186:	8b 00                	mov    (%eax),%eax
  105188:	89 04 24             	mov    %eax,(%esp)
  10518b:	e8 c2 e9 ff ff       	call   103b52 <pde2page>
  105190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105197:	00 
  105198:	89 04 24             	mov    %eax,(%esp)
  10519b:	e8 07 ec ff ff       	call   103da7 <free_pages>
    boot_pgdir[0] = 0;
  1051a0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1051a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  1051ab:	c7 04 24 f4 6f 10 00 	movl   $0x106ff4,(%esp)
  1051b2:	e8 91 b1 ff ff       	call   100348 <cprintf>
}
  1051b7:	c9                   	leave  
  1051b8:	c3                   	ret    

001051b9 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1051b9:	55                   	push   %ebp
  1051ba:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1051bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1051bf:	83 e0 04             	and    $0x4,%eax
  1051c2:	85 c0                	test   %eax,%eax
  1051c4:	74 07                	je     1051cd <perm2str+0x14>
  1051c6:	b8 75 00 00 00       	mov    $0x75,%eax
  1051cb:	eb 05                	jmp    1051d2 <perm2str+0x19>
  1051cd:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1051d2:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  1051d7:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1051de:	8b 45 08             	mov    0x8(%ebp),%eax
  1051e1:	83 e0 02             	and    $0x2,%eax
  1051e4:	85 c0                	test   %eax,%eax
  1051e6:	74 07                	je     1051ef <perm2str+0x36>
  1051e8:	b8 77 00 00 00       	mov    $0x77,%eax
  1051ed:	eb 05                	jmp    1051f4 <perm2str+0x3b>
  1051ef:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1051f4:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  1051f9:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  105200:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  105205:	5d                   	pop    %ebp
  105206:	c3                   	ret    

00105207 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105207:	55                   	push   %ebp
  105208:	89 e5                	mov    %esp,%ebp
  10520a:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10520d:	8b 45 10             	mov    0x10(%ebp),%eax
  105210:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105213:	72 0a                	jb     10521f <get_pgtable_items+0x18>
        return 0;
  105215:	b8 00 00 00 00       	mov    $0x0,%eax
  10521a:	e9 9c 00 00 00       	jmp    1052bb <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  10521f:	eb 04                	jmp    105225 <get_pgtable_items+0x1e>
        start ++;
  105221:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  105225:	8b 45 10             	mov    0x10(%ebp),%eax
  105228:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10522b:	73 18                	jae    105245 <get_pgtable_items+0x3e>
  10522d:	8b 45 10             	mov    0x10(%ebp),%eax
  105230:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105237:	8b 45 14             	mov    0x14(%ebp),%eax
  10523a:	01 d0                	add    %edx,%eax
  10523c:	8b 00                	mov    (%eax),%eax
  10523e:	83 e0 01             	and    $0x1,%eax
  105241:	85 c0                	test   %eax,%eax
  105243:	74 dc                	je     105221 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  105245:	8b 45 10             	mov    0x10(%ebp),%eax
  105248:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10524b:	73 69                	jae    1052b6 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  10524d:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105251:	74 08                	je     10525b <get_pgtable_items+0x54>
            *left_store = start;
  105253:	8b 45 18             	mov    0x18(%ebp),%eax
  105256:	8b 55 10             	mov    0x10(%ebp),%edx
  105259:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  10525b:	8b 45 10             	mov    0x10(%ebp),%eax
  10525e:	8d 50 01             	lea    0x1(%eax),%edx
  105261:	89 55 10             	mov    %edx,0x10(%ebp)
  105264:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10526b:	8b 45 14             	mov    0x14(%ebp),%eax
  10526e:	01 d0                	add    %edx,%eax
  105270:	8b 00                	mov    (%eax),%eax
  105272:	83 e0 07             	and    $0x7,%eax
  105275:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105278:	eb 04                	jmp    10527e <get_pgtable_items+0x77>
            start ++;
  10527a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  10527e:	8b 45 10             	mov    0x10(%ebp),%eax
  105281:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105284:	73 1d                	jae    1052a3 <get_pgtable_items+0x9c>
  105286:	8b 45 10             	mov    0x10(%ebp),%eax
  105289:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105290:	8b 45 14             	mov    0x14(%ebp),%eax
  105293:	01 d0                	add    %edx,%eax
  105295:	8b 00                	mov    (%eax),%eax
  105297:	83 e0 07             	and    $0x7,%eax
  10529a:	89 c2                	mov    %eax,%edx
  10529c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10529f:	39 c2                	cmp    %eax,%edx
  1052a1:	74 d7                	je     10527a <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  1052a3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1052a7:	74 08                	je     1052b1 <get_pgtable_items+0xaa>
            *right_store = start;
  1052a9:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1052ac:	8b 55 10             	mov    0x10(%ebp),%edx
  1052af:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1052b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052b4:	eb 05                	jmp    1052bb <get_pgtable_items+0xb4>
    }
    return 0;
  1052b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1052bb:	c9                   	leave  
  1052bc:	c3                   	ret    

001052bd <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1052bd:	55                   	push   %ebp
  1052be:	89 e5                	mov    %esp,%ebp
  1052c0:	57                   	push   %edi
  1052c1:	56                   	push   %esi
  1052c2:	53                   	push   %ebx
  1052c3:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1052c6:	c7 04 24 14 70 10 00 	movl   $0x107014,(%esp)
  1052cd:	e8 76 b0 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  1052d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1052d9:	e9 fa 00 00 00       	jmp    1053d8 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1052de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1052e1:	89 04 24             	mov    %eax,(%esp)
  1052e4:	e8 d0 fe ff ff       	call   1051b9 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1052e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1052ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1052ef:	29 d1                	sub    %edx,%ecx
  1052f1:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1052f3:	89 d6                	mov    %edx,%esi
  1052f5:	c1 e6 16             	shl    $0x16,%esi
  1052f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1052fb:	89 d3                	mov    %edx,%ebx
  1052fd:	c1 e3 16             	shl    $0x16,%ebx
  105300:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105303:	89 d1                	mov    %edx,%ecx
  105305:	c1 e1 16             	shl    $0x16,%ecx
  105308:	8b 7d dc             	mov    -0x24(%ebp),%edi
  10530b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10530e:	29 d7                	sub    %edx,%edi
  105310:	89 fa                	mov    %edi,%edx
  105312:	89 44 24 14          	mov    %eax,0x14(%esp)
  105316:	89 74 24 10          	mov    %esi,0x10(%esp)
  10531a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10531e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105322:	89 54 24 04          	mov    %edx,0x4(%esp)
  105326:	c7 04 24 45 70 10 00 	movl   $0x107045,(%esp)
  10532d:	e8 16 b0 ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  105332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105335:	c1 e0 0a             	shl    $0xa,%eax
  105338:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10533b:	eb 54                	jmp    105391 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10533d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105340:	89 04 24             	mov    %eax,(%esp)
  105343:	e8 71 fe ff ff       	call   1051b9 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  105348:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10534b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10534e:	29 d1                	sub    %edx,%ecx
  105350:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105352:	89 d6                	mov    %edx,%esi
  105354:	c1 e6 0c             	shl    $0xc,%esi
  105357:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10535a:	89 d3                	mov    %edx,%ebx
  10535c:	c1 e3 0c             	shl    $0xc,%ebx
  10535f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105362:	c1 e2 0c             	shl    $0xc,%edx
  105365:	89 d1                	mov    %edx,%ecx
  105367:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10536a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10536d:	29 d7                	sub    %edx,%edi
  10536f:	89 fa                	mov    %edi,%edx
  105371:	89 44 24 14          	mov    %eax,0x14(%esp)
  105375:	89 74 24 10          	mov    %esi,0x10(%esp)
  105379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10537d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105381:	89 54 24 04          	mov    %edx,0x4(%esp)
  105385:	c7 04 24 64 70 10 00 	movl   $0x107064,(%esp)
  10538c:	e8 b7 af ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105391:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  105396:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105399:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10539c:	89 ce                	mov    %ecx,%esi
  10539e:	c1 e6 0a             	shl    $0xa,%esi
  1053a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1053a4:	89 cb                	mov    %ecx,%ebx
  1053a6:	c1 e3 0a             	shl    $0xa,%ebx
  1053a9:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1053ac:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1053b0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1053b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1053b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1053bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  1053c3:	89 1c 24             	mov    %ebx,(%esp)
  1053c6:	e8 3c fe ff ff       	call   105207 <get_pgtable_items>
  1053cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1053ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1053d2:	0f 85 65 ff ff ff    	jne    10533d <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1053d8:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  1053dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053e0:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  1053e3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1053e7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  1053ea:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1053ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1053f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053f6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1053fd:	00 
  1053fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105405:	e8 fd fd ff ff       	call   105207 <get_pgtable_items>
  10540a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10540d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105411:	0f 85 c7 fe ff ff    	jne    1052de <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105417:	c7 04 24 88 70 10 00 	movl   $0x107088,(%esp)
  10541e:	e8 25 af ff ff       	call   100348 <cprintf>
}
  105423:	83 c4 4c             	add    $0x4c,%esp
  105426:	5b                   	pop    %ebx
  105427:	5e                   	pop    %esi
  105428:	5f                   	pop    %edi
  105429:	5d                   	pop    %ebp
  10542a:	c3                   	ret    

0010542b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10542b:	55                   	push   %ebp
  10542c:	89 e5                	mov    %esp,%ebp
  10542e:	83 ec 58             	sub    $0x58,%esp
  105431:	8b 45 10             	mov    0x10(%ebp),%eax
  105434:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105437:	8b 45 14             	mov    0x14(%ebp),%eax
  10543a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10543d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105440:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105443:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105446:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105449:	8b 45 18             	mov    0x18(%ebp),%eax
  10544c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10544f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105452:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105458:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10545b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10545e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105461:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105465:	74 1c                	je     105483 <printnum+0x58>
  105467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10546a:	ba 00 00 00 00       	mov    $0x0,%edx
  10546f:	f7 75 e4             	divl   -0x1c(%ebp)
  105472:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105478:	ba 00 00 00 00       	mov    $0x0,%edx
  10547d:	f7 75 e4             	divl   -0x1c(%ebp)
  105480:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105483:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105486:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105489:	f7 75 e4             	divl   -0x1c(%ebp)
  10548c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10548f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105495:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105498:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10549b:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10549e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054a1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1054a4:	8b 45 18             	mov    0x18(%ebp),%eax
  1054a7:	ba 00 00 00 00       	mov    $0x0,%edx
  1054ac:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054af:	77 56                	ja     105507 <printnum+0xdc>
  1054b1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054b4:	72 05                	jb     1054bb <printnum+0x90>
  1054b6:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1054b9:	77 4c                	ja     105507 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1054bb:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1054be:	8d 50 ff             	lea    -0x1(%eax),%edx
  1054c1:	8b 45 20             	mov    0x20(%ebp),%eax
  1054c4:	89 44 24 18          	mov    %eax,0x18(%esp)
  1054c8:	89 54 24 14          	mov    %edx,0x14(%esp)
  1054cc:	8b 45 18             	mov    0x18(%ebp),%eax
  1054cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  1054d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1054dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1054e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1054e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1054eb:	89 04 24             	mov    %eax,(%esp)
  1054ee:	e8 38 ff ff ff       	call   10542b <printnum>
  1054f3:	eb 1c                	jmp    105511 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1054f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1054fc:	8b 45 20             	mov    0x20(%ebp),%eax
  1054ff:	89 04 24             	mov    %eax,(%esp)
  105502:	8b 45 08             	mov    0x8(%ebp),%eax
  105505:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105507:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  10550b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10550f:	7f e4                	jg     1054f5 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105511:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105514:	05 3c 71 10 00       	add    $0x10713c,%eax
  105519:	0f b6 00             	movzbl (%eax),%eax
  10551c:	0f be c0             	movsbl %al,%eax
  10551f:	8b 55 0c             	mov    0xc(%ebp),%edx
  105522:	89 54 24 04          	mov    %edx,0x4(%esp)
  105526:	89 04 24             	mov    %eax,(%esp)
  105529:	8b 45 08             	mov    0x8(%ebp),%eax
  10552c:	ff d0                	call   *%eax
}
  10552e:	c9                   	leave  
  10552f:	c3                   	ret    

00105530 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105530:	55                   	push   %ebp
  105531:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105533:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105537:	7e 14                	jle    10554d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105539:	8b 45 08             	mov    0x8(%ebp),%eax
  10553c:	8b 00                	mov    (%eax),%eax
  10553e:	8d 48 08             	lea    0x8(%eax),%ecx
  105541:	8b 55 08             	mov    0x8(%ebp),%edx
  105544:	89 0a                	mov    %ecx,(%edx)
  105546:	8b 50 04             	mov    0x4(%eax),%edx
  105549:	8b 00                	mov    (%eax),%eax
  10554b:	eb 30                	jmp    10557d <getuint+0x4d>
    }
    else if (lflag) {
  10554d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105551:	74 16                	je     105569 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105553:	8b 45 08             	mov    0x8(%ebp),%eax
  105556:	8b 00                	mov    (%eax),%eax
  105558:	8d 48 04             	lea    0x4(%eax),%ecx
  10555b:	8b 55 08             	mov    0x8(%ebp),%edx
  10555e:	89 0a                	mov    %ecx,(%edx)
  105560:	8b 00                	mov    (%eax),%eax
  105562:	ba 00 00 00 00       	mov    $0x0,%edx
  105567:	eb 14                	jmp    10557d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105569:	8b 45 08             	mov    0x8(%ebp),%eax
  10556c:	8b 00                	mov    (%eax),%eax
  10556e:	8d 48 04             	lea    0x4(%eax),%ecx
  105571:	8b 55 08             	mov    0x8(%ebp),%edx
  105574:	89 0a                	mov    %ecx,(%edx)
  105576:	8b 00                	mov    (%eax),%eax
  105578:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10557d:	5d                   	pop    %ebp
  10557e:	c3                   	ret    

0010557f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10557f:	55                   	push   %ebp
  105580:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105582:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105586:	7e 14                	jle    10559c <getint+0x1d>
        return va_arg(*ap, long long);
  105588:	8b 45 08             	mov    0x8(%ebp),%eax
  10558b:	8b 00                	mov    (%eax),%eax
  10558d:	8d 48 08             	lea    0x8(%eax),%ecx
  105590:	8b 55 08             	mov    0x8(%ebp),%edx
  105593:	89 0a                	mov    %ecx,(%edx)
  105595:	8b 50 04             	mov    0x4(%eax),%edx
  105598:	8b 00                	mov    (%eax),%eax
  10559a:	eb 28                	jmp    1055c4 <getint+0x45>
    }
    else if (lflag) {
  10559c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055a0:	74 12                	je     1055b4 <getint+0x35>
        return va_arg(*ap, long);
  1055a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1055a5:	8b 00                	mov    (%eax),%eax
  1055a7:	8d 48 04             	lea    0x4(%eax),%ecx
  1055aa:	8b 55 08             	mov    0x8(%ebp),%edx
  1055ad:	89 0a                	mov    %ecx,(%edx)
  1055af:	8b 00                	mov    (%eax),%eax
  1055b1:	99                   	cltd   
  1055b2:	eb 10                	jmp    1055c4 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1055b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b7:	8b 00                	mov    (%eax),%eax
  1055b9:	8d 48 04             	lea    0x4(%eax),%ecx
  1055bc:	8b 55 08             	mov    0x8(%ebp),%edx
  1055bf:	89 0a                	mov    %ecx,(%edx)
  1055c1:	8b 00                	mov    (%eax),%eax
  1055c3:	99                   	cltd   
    }
}
  1055c4:	5d                   	pop    %ebp
  1055c5:	c3                   	ret    

001055c6 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1055c6:	55                   	push   %ebp
  1055c7:	89 e5                	mov    %esp,%ebp
  1055c9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1055cc:	8d 45 14             	lea    0x14(%ebp),%eax
  1055cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1055d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1055d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1055dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1055e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1055e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ea:	89 04 24             	mov    %eax,(%esp)
  1055ed:	e8 02 00 00 00       	call   1055f4 <vprintfmt>
    va_end(ap);
}
  1055f2:	c9                   	leave  
  1055f3:	c3                   	ret    

001055f4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1055f4:	55                   	push   %ebp
  1055f5:	89 e5                	mov    %esp,%ebp
  1055f7:	56                   	push   %esi
  1055f8:	53                   	push   %ebx
  1055f9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1055fc:	eb 18                	jmp    105616 <vprintfmt+0x22>
            if (ch == '\0') {
  1055fe:	85 db                	test   %ebx,%ebx
  105600:	75 05                	jne    105607 <vprintfmt+0x13>
                return;
  105602:	e9 d1 03 00 00       	jmp    1059d8 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105607:	8b 45 0c             	mov    0xc(%ebp),%eax
  10560a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10560e:	89 1c 24             	mov    %ebx,(%esp)
  105611:	8b 45 08             	mov    0x8(%ebp),%eax
  105614:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105616:	8b 45 10             	mov    0x10(%ebp),%eax
  105619:	8d 50 01             	lea    0x1(%eax),%edx
  10561c:	89 55 10             	mov    %edx,0x10(%ebp)
  10561f:	0f b6 00             	movzbl (%eax),%eax
  105622:	0f b6 d8             	movzbl %al,%ebx
  105625:	83 fb 25             	cmp    $0x25,%ebx
  105628:	75 d4                	jne    1055fe <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  10562a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  10562e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105638:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  10563b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105642:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105645:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105648:	8b 45 10             	mov    0x10(%ebp),%eax
  10564b:	8d 50 01             	lea    0x1(%eax),%edx
  10564e:	89 55 10             	mov    %edx,0x10(%ebp)
  105651:	0f b6 00             	movzbl (%eax),%eax
  105654:	0f b6 d8             	movzbl %al,%ebx
  105657:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10565a:	83 f8 55             	cmp    $0x55,%eax
  10565d:	0f 87 44 03 00 00    	ja     1059a7 <vprintfmt+0x3b3>
  105663:	8b 04 85 60 71 10 00 	mov    0x107160(,%eax,4),%eax
  10566a:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10566c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105670:	eb d6                	jmp    105648 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105672:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105676:	eb d0                	jmp    105648 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105678:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10567f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105682:	89 d0                	mov    %edx,%eax
  105684:	c1 e0 02             	shl    $0x2,%eax
  105687:	01 d0                	add    %edx,%eax
  105689:	01 c0                	add    %eax,%eax
  10568b:	01 d8                	add    %ebx,%eax
  10568d:	83 e8 30             	sub    $0x30,%eax
  105690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105693:	8b 45 10             	mov    0x10(%ebp),%eax
  105696:	0f b6 00             	movzbl (%eax),%eax
  105699:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10569c:	83 fb 2f             	cmp    $0x2f,%ebx
  10569f:	7e 0b                	jle    1056ac <vprintfmt+0xb8>
  1056a1:	83 fb 39             	cmp    $0x39,%ebx
  1056a4:	7f 06                	jg     1056ac <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1056a6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1056aa:	eb d3                	jmp    10567f <vprintfmt+0x8b>
            goto process_precision;
  1056ac:	eb 33                	jmp    1056e1 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1056ae:	8b 45 14             	mov    0x14(%ebp),%eax
  1056b1:	8d 50 04             	lea    0x4(%eax),%edx
  1056b4:	89 55 14             	mov    %edx,0x14(%ebp)
  1056b7:	8b 00                	mov    (%eax),%eax
  1056b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1056bc:	eb 23                	jmp    1056e1 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1056be:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056c2:	79 0c                	jns    1056d0 <vprintfmt+0xdc>
                width = 0;
  1056c4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1056cb:	e9 78 ff ff ff       	jmp    105648 <vprintfmt+0x54>
  1056d0:	e9 73 ff ff ff       	jmp    105648 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1056d5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1056dc:	e9 67 ff ff ff       	jmp    105648 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1056e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056e5:	79 12                	jns    1056f9 <vprintfmt+0x105>
                width = precision, precision = -1;
  1056e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1056ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1056ed:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1056f4:	e9 4f ff ff ff       	jmp    105648 <vprintfmt+0x54>
  1056f9:	e9 4a ff ff ff       	jmp    105648 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1056fe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105702:	e9 41 ff ff ff       	jmp    105648 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105707:	8b 45 14             	mov    0x14(%ebp),%eax
  10570a:	8d 50 04             	lea    0x4(%eax),%edx
  10570d:	89 55 14             	mov    %edx,0x14(%ebp)
  105710:	8b 00                	mov    (%eax),%eax
  105712:	8b 55 0c             	mov    0xc(%ebp),%edx
  105715:	89 54 24 04          	mov    %edx,0x4(%esp)
  105719:	89 04 24             	mov    %eax,(%esp)
  10571c:	8b 45 08             	mov    0x8(%ebp),%eax
  10571f:	ff d0                	call   *%eax
            break;
  105721:	e9 ac 02 00 00       	jmp    1059d2 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105726:	8b 45 14             	mov    0x14(%ebp),%eax
  105729:	8d 50 04             	lea    0x4(%eax),%edx
  10572c:	89 55 14             	mov    %edx,0x14(%ebp)
  10572f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105731:	85 db                	test   %ebx,%ebx
  105733:	79 02                	jns    105737 <vprintfmt+0x143>
                err = -err;
  105735:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105737:	83 fb 06             	cmp    $0x6,%ebx
  10573a:	7f 0b                	jg     105747 <vprintfmt+0x153>
  10573c:	8b 34 9d 20 71 10 00 	mov    0x107120(,%ebx,4),%esi
  105743:	85 f6                	test   %esi,%esi
  105745:	75 23                	jne    10576a <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105747:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10574b:	c7 44 24 08 4d 71 10 	movl   $0x10714d,0x8(%esp)
  105752:	00 
  105753:	8b 45 0c             	mov    0xc(%ebp),%eax
  105756:	89 44 24 04          	mov    %eax,0x4(%esp)
  10575a:	8b 45 08             	mov    0x8(%ebp),%eax
  10575d:	89 04 24             	mov    %eax,(%esp)
  105760:	e8 61 fe ff ff       	call   1055c6 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105765:	e9 68 02 00 00       	jmp    1059d2 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  10576a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10576e:	c7 44 24 08 56 71 10 	movl   $0x107156,0x8(%esp)
  105775:	00 
  105776:	8b 45 0c             	mov    0xc(%ebp),%eax
  105779:	89 44 24 04          	mov    %eax,0x4(%esp)
  10577d:	8b 45 08             	mov    0x8(%ebp),%eax
  105780:	89 04 24             	mov    %eax,(%esp)
  105783:	e8 3e fe ff ff       	call   1055c6 <printfmt>
            }
            break;
  105788:	e9 45 02 00 00       	jmp    1059d2 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10578d:	8b 45 14             	mov    0x14(%ebp),%eax
  105790:	8d 50 04             	lea    0x4(%eax),%edx
  105793:	89 55 14             	mov    %edx,0x14(%ebp)
  105796:	8b 30                	mov    (%eax),%esi
  105798:	85 f6                	test   %esi,%esi
  10579a:	75 05                	jne    1057a1 <vprintfmt+0x1ad>
                p = "(null)";
  10579c:	be 59 71 10 00       	mov    $0x107159,%esi
            }
            if (width > 0 && padc != '-') {
  1057a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057a5:	7e 3e                	jle    1057e5 <vprintfmt+0x1f1>
  1057a7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1057ab:	74 38                	je     1057e5 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057ad:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  1057b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057b7:	89 34 24             	mov    %esi,(%esp)
  1057ba:	e8 15 03 00 00       	call   105ad4 <strnlen>
  1057bf:	29 c3                	sub    %eax,%ebx
  1057c1:	89 d8                	mov    %ebx,%eax
  1057c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057c6:	eb 17                	jmp    1057df <vprintfmt+0x1eb>
                    putch(padc, putdat);
  1057c8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1057cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057d3:	89 04 24             	mov    %eax,(%esp)
  1057d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d9:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057db:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1057df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057e3:	7f e3                	jg     1057c8 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1057e5:	eb 38                	jmp    10581f <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  1057e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1057eb:	74 1f                	je     10580c <vprintfmt+0x218>
  1057ed:	83 fb 1f             	cmp    $0x1f,%ebx
  1057f0:	7e 05                	jle    1057f7 <vprintfmt+0x203>
  1057f2:	83 fb 7e             	cmp    $0x7e,%ebx
  1057f5:	7e 15                	jle    10580c <vprintfmt+0x218>
                    putch('?', putdat);
  1057f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057fe:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105805:	8b 45 08             	mov    0x8(%ebp),%eax
  105808:	ff d0                	call   *%eax
  10580a:	eb 0f                	jmp    10581b <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  10580c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10580f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105813:	89 1c 24             	mov    %ebx,(%esp)
  105816:	8b 45 08             	mov    0x8(%ebp),%eax
  105819:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10581b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10581f:	89 f0                	mov    %esi,%eax
  105821:	8d 70 01             	lea    0x1(%eax),%esi
  105824:	0f b6 00             	movzbl (%eax),%eax
  105827:	0f be d8             	movsbl %al,%ebx
  10582a:	85 db                	test   %ebx,%ebx
  10582c:	74 10                	je     10583e <vprintfmt+0x24a>
  10582e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105832:	78 b3                	js     1057e7 <vprintfmt+0x1f3>
  105834:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105838:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10583c:	79 a9                	jns    1057e7 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10583e:	eb 17                	jmp    105857 <vprintfmt+0x263>
                putch(' ', putdat);
  105840:	8b 45 0c             	mov    0xc(%ebp),%eax
  105843:	89 44 24 04          	mov    %eax,0x4(%esp)
  105847:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10584e:	8b 45 08             	mov    0x8(%ebp),%eax
  105851:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105853:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105857:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10585b:	7f e3                	jg     105840 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  10585d:	e9 70 01 00 00       	jmp    1059d2 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105862:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105865:	89 44 24 04          	mov    %eax,0x4(%esp)
  105869:	8d 45 14             	lea    0x14(%ebp),%eax
  10586c:	89 04 24             	mov    %eax,(%esp)
  10586f:	e8 0b fd ff ff       	call   10557f <getint>
  105874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105877:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  10587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10587d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105880:	85 d2                	test   %edx,%edx
  105882:	79 26                	jns    1058aa <vprintfmt+0x2b6>
                putch('-', putdat);
  105884:	8b 45 0c             	mov    0xc(%ebp),%eax
  105887:	89 44 24 04          	mov    %eax,0x4(%esp)
  10588b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105892:	8b 45 08             	mov    0x8(%ebp),%eax
  105895:	ff d0                	call   *%eax
                num = -(long long)num;
  105897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10589a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10589d:	f7 d8                	neg    %eax
  10589f:	83 d2 00             	adc    $0x0,%edx
  1058a2:	f7 da                	neg    %edx
  1058a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1058aa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058b1:	e9 a8 00 00 00       	jmp    10595e <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1058b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058bd:	8d 45 14             	lea    0x14(%ebp),%eax
  1058c0:	89 04 24             	mov    %eax,(%esp)
  1058c3:	e8 68 fc ff ff       	call   105530 <getuint>
  1058c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1058ce:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058d5:	e9 84 00 00 00       	jmp    10595e <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1058da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058e1:	8d 45 14             	lea    0x14(%ebp),%eax
  1058e4:	89 04 24             	mov    %eax,(%esp)
  1058e7:	e8 44 fc ff ff       	call   105530 <getuint>
  1058ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1058f2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1058f9:	eb 63                	jmp    10595e <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  1058fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  105902:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105909:	8b 45 08             	mov    0x8(%ebp),%eax
  10590c:	ff d0                	call   *%eax
            putch('x', putdat);
  10590e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105911:	89 44 24 04          	mov    %eax,0x4(%esp)
  105915:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10591c:	8b 45 08             	mov    0x8(%ebp),%eax
  10591f:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105921:	8b 45 14             	mov    0x14(%ebp),%eax
  105924:	8d 50 04             	lea    0x4(%eax),%edx
  105927:	89 55 14             	mov    %edx,0x14(%ebp)
  10592a:	8b 00                	mov    (%eax),%eax
  10592c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10592f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105936:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  10593d:	eb 1f                	jmp    10595e <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10593f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105942:	89 44 24 04          	mov    %eax,0x4(%esp)
  105946:	8d 45 14             	lea    0x14(%ebp),%eax
  105949:	89 04 24             	mov    %eax,(%esp)
  10594c:	e8 df fb ff ff       	call   105530 <getuint>
  105951:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105954:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105957:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10595e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105962:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105965:	89 54 24 18          	mov    %edx,0x18(%esp)
  105969:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10596c:	89 54 24 14          	mov    %edx,0x14(%esp)
  105970:	89 44 24 10          	mov    %eax,0x10(%esp)
  105974:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105977:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10597a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10597e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105982:	8b 45 0c             	mov    0xc(%ebp),%eax
  105985:	89 44 24 04          	mov    %eax,0x4(%esp)
  105989:	8b 45 08             	mov    0x8(%ebp),%eax
  10598c:	89 04 24             	mov    %eax,(%esp)
  10598f:	e8 97 fa ff ff       	call   10542b <printnum>
            break;
  105994:	eb 3c                	jmp    1059d2 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105996:	8b 45 0c             	mov    0xc(%ebp),%eax
  105999:	89 44 24 04          	mov    %eax,0x4(%esp)
  10599d:	89 1c 24             	mov    %ebx,(%esp)
  1059a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a3:	ff d0                	call   *%eax
            break;
  1059a5:	eb 2b                	jmp    1059d2 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1059b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b8:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1059ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1059be:	eb 04                	jmp    1059c4 <vprintfmt+0x3d0>
  1059c0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1059c4:	8b 45 10             	mov    0x10(%ebp),%eax
  1059c7:	83 e8 01             	sub    $0x1,%eax
  1059ca:	0f b6 00             	movzbl (%eax),%eax
  1059cd:	3c 25                	cmp    $0x25,%al
  1059cf:	75 ef                	jne    1059c0 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  1059d1:	90                   	nop
        }
    }
  1059d2:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059d3:	e9 3e fc ff ff       	jmp    105616 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1059d8:	83 c4 40             	add    $0x40,%esp
  1059db:	5b                   	pop    %ebx
  1059dc:	5e                   	pop    %esi
  1059dd:	5d                   	pop    %ebp
  1059de:	c3                   	ret    

001059df <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1059df:	55                   	push   %ebp
  1059e0:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1059e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059e5:	8b 40 08             	mov    0x8(%eax),%eax
  1059e8:	8d 50 01             	lea    0x1(%eax),%edx
  1059eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059ee:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059f4:	8b 10                	mov    (%eax),%edx
  1059f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059f9:	8b 40 04             	mov    0x4(%eax),%eax
  1059fc:	39 c2                	cmp    %eax,%edx
  1059fe:	73 12                	jae    105a12 <sprintputch+0x33>
        *b->buf ++ = ch;
  105a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a03:	8b 00                	mov    (%eax),%eax
  105a05:	8d 48 01             	lea    0x1(%eax),%ecx
  105a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a0b:	89 0a                	mov    %ecx,(%edx)
  105a0d:	8b 55 08             	mov    0x8(%ebp),%edx
  105a10:	88 10                	mov    %dl,(%eax)
    }
}
  105a12:	5d                   	pop    %ebp
  105a13:	c3                   	ret    

00105a14 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105a14:	55                   	push   %ebp
  105a15:	89 e5                	mov    %esp,%ebp
  105a17:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105a1a:	8d 45 14             	lea    0x14(%ebp),%eax
  105a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a27:	8b 45 10             	mov    0x10(%ebp),%eax
  105a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a31:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a35:	8b 45 08             	mov    0x8(%ebp),%eax
  105a38:	89 04 24             	mov    %eax,(%esp)
  105a3b:	e8 08 00 00 00       	call   105a48 <vsnprintf>
  105a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105a46:	c9                   	leave  
  105a47:	c3                   	ret    

00105a48 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105a48:	55                   	push   %ebp
  105a49:	89 e5                	mov    %esp,%ebp
  105a4b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  105a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a57:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5d:	01 d0                	add    %edx,%eax
  105a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105a69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105a6d:	74 0a                	je     105a79 <vsnprintf+0x31>
  105a6f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a75:	39 c2                	cmp    %eax,%edx
  105a77:	76 07                	jbe    105a80 <vsnprintf+0x38>
        return -E_INVAL;
  105a79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105a7e:	eb 2a                	jmp    105aaa <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105a80:	8b 45 14             	mov    0x14(%ebp),%eax
  105a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a87:	8b 45 10             	mov    0x10(%ebp),%eax
  105a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a95:	c7 04 24 df 59 10 00 	movl   $0x1059df,(%esp)
  105a9c:	e8 53 fb ff ff       	call   1055f4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105aa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105aa4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105aaa:	c9                   	leave  
  105aab:	c3                   	ret    

00105aac <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105aac:	55                   	push   %ebp
  105aad:	89 e5                	mov    %esp,%ebp
  105aaf:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105ab2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105ab9:	eb 04                	jmp    105abf <strlen+0x13>
        cnt ++;
  105abb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105abf:	8b 45 08             	mov    0x8(%ebp),%eax
  105ac2:	8d 50 01             	lea    0x1(%eax),%edx
  105ac5:	89 55 08             	mov    %edx,0x8(%ebp)
  105ac8:	0f b6 00             	movzbl (%eax),%eax
  105acb:	84 c0                	test   %al,%al
  105acd:	75 ec                	jne    105abb <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105acf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105ad2:	c9                   	leave  
  105ad3:	c3                   	ret    

00105ad4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105ad4:	55                   	push   %ebp
  105ad5:	89 e5                	mov    %esp,%ebp
  105ad7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105ada:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105ae1:	eb 04                	jmp    105ae7 <strnlen+0x13>
        cnt ++;
  105ae3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105ae7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105aea:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105aed:	73 10                	jae    105aff <strnlen+0x2b>
  105aef:	8b 45 08             	mov    0x8(%ebp),%eax
  105af2:	8d 50 01             	lea    0x1(%eax),%edx
  105af5:	89 55 08             	mov    %edx,0x8(%ebp)
  105af8:	0f b6 00             	movzbl (%eax),%eax
  105afb:	84 c0                	test   %al,%al
  105afd:	75 e4                	jne    105ae3 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105aff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b02:	c9                   	leave  
  105b03:	c3                   	ret    

00105b04 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105b04:	55                   	push   %ebp
  105b05:	89 e5                	mov    %esp,%ebp
  105b07:	57                   	push   %edi
  105b08:	56                   	push   %esi
  105b09:	83 ec 20             	sub    $0x20,%esp
  105b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105b18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b1e:	89 d1                	mov    %edx,%ecx
  105b20:	89 c2                	mov    %eax,%edx
  105b22:	89 ce                	mov    %ecx,%esi
  105b24:	89 d7                	mov    %edx,%edi
  105b26:	ac                   	lods   %ds:(%esi),%al
  105b27:	aa                   	stos   %al,%es:(%edi)
  105b28:	84 c0                	test   %al,%al
  105b2a:	75 fa                	jne    105b26 <strcpy+0x22>
  105b2c:	89 fa                	mov    %edi,%edx
  105b2e:	89 f1                	mov    %esi,%ecx
  105b30:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105b33:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105b36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105b3c:	83 c4 20             	add    $0x20,%esp
  105b3f:	5e                   	pop    %esi
  105b40:	5f                   	pop    %edi
  105b41:	5d                   	pop    %ebp
  105b42:	c3                   	ret    

00105b43 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105b43:	55                   	push   %ebp
  105b44:	89 e5                	mov    %esp,%ebp
  105b46:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105b49:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105b4f:	eb 21                	jmp    105b72 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b54:	0f b6 10             	movzbl (%eax),%edx
  105b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b5a:	88 10                	mov    %dl,(%eax)
  105b5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b5f:	0f b6 00             	movzbl (%eax),%eax
  105b62:	84 c0                	test   %al,%al
  105b64:	74 04                	je     105b6a <strncpy+0x27>
            src ++;
  105b66:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105b6a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105b6e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105b72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b76:	75 d9                	jne    105b51 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105b78:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105b7b:	c9                   	leave  
  105b7c:	c3                   	ret    

00105b7d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105b7d:	55                   	push   %ebp
  105b7e:	89 e5                	mov    %esp,%ebp
  105b80:	57                   	push   %edi
  105b81:	56                   	push   %esi
  105b82:	83 ec 20             	sub    $0x20,%esp
  105b85:	8b 45 08             	mov    0x8(%ebp),%eax
  105b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b97:	89 d1                	mov    %edx,%ecx
  105b99:	89 c2                	mov    %eax,%edx
  105b9b:	89 ce                	mov    %ecx,%esi
  105b9d:	89 d7                	mov    %edx,%edi
  105b9f:	ac                   	lods   %ds:(%esi),%al
  105ba0:	ae                   	scas   %es:(%edi),%al
  105ba1:	75 08                	jne    105bab <strcmp+0x2e>
  105ba3:	84 c0                	test   %al,%al
  105ba5:	75 f8                	jne    105b9f <strcmp+0x22>
  105ba7:	31 c0                	xor    %eax,%eax
  105ba9:	eb 04                	jmp    105baf <strcmp+0x32>
  105bab:	19 c0                	sbb    %eax,%eax
  105bad:	0c 01                	or     $0x1,%al
  105baf:	89 fa                	mov    %edi,%edx
  105bb1:	89 f1                	mov    %esi,%ecx
  105bb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105bb6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105bb9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105bbf:	83 c4 20             	add    $0x20,%esp
  105bc2:	5e                   	pop    %esi
  105bc3:	5f                   	pop    %edi
  105bc4:	5d                   	pop    %ebp
  105bc5:	c3                   	ret    

00105bc6 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105bc6:	55                   	push   %ebp
  105bc7:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bc9:	eb 0c                	jmp    105bd7 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105bcb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105bcf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105bd3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105bdb:	74 1a                	je     105bf7 <strncmp+0x31>
  105bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  105be0:	0f b6 00             	movzbl (%eax),%eax
  105be3:	84 c0                	test   %al,%al
  105be5:	74 10                	je     105bf7 <strncmp+0x31>
  105be7:	8b 45 08             	mov    0x8(%ebp),%eax
  105bea:	0f b6 10             	movzbl (%eax),%edx
  105bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bf0:	0f b6 00             	movzbl (%eax),%eax
  105bf3:	38 c2                	cmp    %al,%dl
  105bf5:	74 d4                	je     105bcb <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105bf7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105bfb:	74 18                	je     105c15 <strncmp+0x4f>
  105bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  105c00:	0f b6 00             	movzbl (%eax),%eax
  105c03:	0f b6 d0             	movzbl %al,%edx
  105c06:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c09:	0f b6 00             	movzbl (%eax),%eax
  105c0c:	0f b6 c0             	movzbl %al,%eax
  105c0f:	29 c2                	sub    %eax,%edx
  105c11:	89 d0                	mov    %edx,%eax
  105c13:	eb 05                	jmp    105c1a <strncmp+0x54>
  105c15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c1a:	5d                   	pop    %ebp
  105c1b:	c3                   	ret    

00105c1c <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105c1c:	55                   	push   %ebp
  105c1d:	89 e5                	mov    %esp,%ebp
  105c1f:	83 ec 04             	sub    $0x4,%esp
  105c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c25:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c28:	eb 14                	jmp    105c3e <strchr+0x22>
        if (*s == c) {
  105c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c2d:	0f b6 00             	movzbl (%eax),%eax
  105c30:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105c33:	75 05                	jne    105c3a <strchr+0x1e>
            return (char *)s;
  105c35:	8b 45 08             	mov    0x8(%ebp),%eax
  105c38:	eb 13                	jmp    105c4d <strchr+0x31>
        }
        s ++;
  105c3a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  105c41:	0f b6 00             	movzbl (%eax),%eax
  105c44:	84 c0                	test   %al,%al
  105c46:	75 e2                	jne    105c2a <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105c48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c4d:	c9                   	leave  
  105c4e:	c3                   	ret    

00105c4f <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105c4f:	55                   	push   %ebp
  105c50:	89 e5                	mov    %esp,%ebp
  105c52:	83 ec 04             	sub    $0x4,%esp
  105c55:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c58:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c5b:	eb 11                	jmp    105c6e <strfind+0x1f>
        if (*s == c) {
  105c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c60:	0f b6 00             	movzbl (%eax),%eax
  105c63:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105c66:	75 02                	jne    105c6a <strfind+0x1b>
            break;
  105c68:	eb 0e                	jmp    105c78 <strfind+0x29>
        }
        s ++;
  105c6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  105c71:	0f b6 00             	movzbl (%eax),%eax
  105c74:	84 c0                	test   %al,%al
  105c76:	75 e5                	jne    105c5d <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105c78:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105c7b:	c9                   	leave  
  105c7c:	c3                   	ret    

00105c7d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105c7d:	55                   	push   %ebp
  105c7e:	89 e5                	mov    %esp,%ebp
  105c80:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105c83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105c8a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105c91:	eb 04                	jmp    105c97 <strtol+0x1a>
        s ++;
  105c93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105c97:	8b 45 08             	mov    0x8(%ebp),%eax
  105c9a:	0f b6 00             	movzbl (%eax),%eax
  105c9d:	3c 20                	cmp    $0x20,%al
  105c9f:	74 f2                	je     105c93 <strtol+0x16>
  105ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ca4:	0f b6 00             	movzbl (%eax),%eax
  105ca7:	3c 09                	cmp    $0x9,%al
  105ca9:	74 e8                	je     105c93 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105cab:	8b 45 08             	mov    0x8(%ebp),%eax
  105cae:	0f b6 00             	movzbl (%eax),%eax
  105cb1:	3c 2b                	cmp    $0x2b,%al
  105cb3:	75 06                	jne    105cbb <strtol+0x3e>
        s ++;
  105cb5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105cb9:	eb 15                	jmp    105cd0 <strtol+0x53>
    }
    else if (*s == '-') {
  105cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  105cbe:	0f b6 00             	movzbl (%eax),%eax
  105cc1:	3c 2d                	cmp    $0x2d,%al
  105cc3:	75 0b                	jne    105cd0 <strtol+0x53>
        s ++, neg = 1;
  105cc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105cc9:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105cd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105cd4:	74 06                	je     105cdc <strtol+0x5f>
  105cd6:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105cda:	75 24                	jne    105d00 <strtol+0x83>
  105cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  105cdf:	0f b6 00             	movzbl (%eax),%eax
  105ce2:	3c 30                	cmp    $0x30,%al
  105ce4:	75 1a                	jne    105d00 <strtol+0x83>
  105ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce9:	83 c0 01             	add    $0x1,%eax
  105cec:	0f b6 00             	movzbl (%eax),%eax
  105cef:	3c 78                	cmp    $0x78,%al
  105cf1:	75 0d                	jne    105d00 <strtol+0x83>
        s += 2, base = 16;
  105cf3:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105cf7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105cfe:	eb 2a                	jmp    105d2a <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105d00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d04:	75 17                	jne    105d1d <strtol+0xa0>
  105d06:	8b 45 08             	mov    0x8(%ebp),%eax
  105d09:	0f b6 00             	movzbl (%eax),%eax
  105d0c:	3c 30                	cmp    $0x30,%al
  105d0e:	75 0d                	jne    105d1d <strtol+0xa0>
        s ++, base = 8;
  105d10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d14:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105d1b:	eb 0d                	jmp    105d2a <strtol+0xad>
    }
    else if (base == 0) {
  105d1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d21:	75 07                	jne    105d2a <strtol+0xad>
        base = 10;
  105d23:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2d:	0f b6 00             	movzbl (%eax),%eax
  105d30:	3c 2f                	cmp    $0x2f,%al
  105d32:	7e 1b                	jle    105d4f <strtol+0xd2>
  105d34:	8b 45 08             	mov    0x8(%ebp),%eax
  105d37:	0f b6 00             	movzbl (%eax),%eax
  105d3a:	3c 39                	cmp    $0x39,%al
  105d3c:	7f 11                	jg     105d4f <strtol+0xd2>
            dig = *s - '0';
  105d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d41:	0f b6 00             	movzbl (%eax),%eax
  105d44:	0f be c0             	movsbl %al,%eax
  105d47:	83 e8 30             	sub    $0x30,%eax
  105d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d4d:	eb 48                	jmp    105d97 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  105d52:	0f b6 00             	movzbl (%eax),%eax
  105d55:	3c 60                	cmp    $0x60,%al
  105d57:	7e 1b                	jle    105d74 <strtol+0xf7>
  105d59:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5c:	0f b6 00             	movzbl (%eax),%eax
  105d5f:	3c 7a                	cmp    $0x7a,%al
  105d61:	7f 11                	jg     105d74 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105d63:	8b 45 08             	mov    0x8(%ebp),%eax
  105d66:	0f b6 00             	movzbl (%eax),%eax
  105d69:	0f be c0             	movsbl %al,%eax
  105d6c:	83 e8 57             	sub    $0x57,%eax
  105d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d72:	eb 23                	jmp    105d97 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105d74:	8b 45 08             	mov    0x8(%ebp),%eax
  105d77:	0f b6 00             	movzbl (%eax),%eax
  105d7a:	3c 40                	cmp    $0x40,%al
  105d7c:	7e 3d                	jle    105dbb <strtol+0x13e>
  105d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d81:	0f b6 00             	movzbl (%eax),%eax
  105d84:	3c 5a                	cmp    $0x5a,%al
  105d86:	7f 33                	jg     105dbb <strtol+0x13e>
            dig = *s - 'A' + 10;
  105d88:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8b:	0f b6 00             	movzbl (%eax),%eax
  105d8e:	0f be c0             	movsbl %al,%eax
  105d91:	83 e8 37             	sub    $0x37,%eax
  105d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d9a:	3b 45 10             	cmp    0x10(%ebp),%eax
  105d9d:	7c 02                	jl     105da1 <strtol+0x124>
            break;
  105d9f:	eb 1a                	jmp    105dbb <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105da1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105da5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105da8:	0f af 45 10          	imul   0x10(%ebp),%eax
  105dac:	89 c2                	mov    %eax,%edx
  105dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105db1:	01 d0                	add    %edx,%eax
  105db3:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105db6:	e9 6f ff ff ff       	jmp    105d2a <strtol+0xad>

    if (endptr) {
  105dbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105dbf:	74 08                	je     105dc9 <strtol+0x14c>
        *endptr = (char *) s;
  105dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  105dc7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105dc9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105dcd:	74 07                	je     105dd6 <strtol+0x159>
  105dcf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105dd2:	f7 d8                	neg    %eax
  105dd4:	eb 03                	jmp    105dd9 <strtol+0x15c>
  105dd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105dd9:	c9                   	leave  
  105dda:	c3                   	ret    

00105ddb <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105ddb:	55                   	push   %ebp
  105ddc:	89 e5                	mov    %esp,%ebp
  105dde:	57                   	push   %edi
  105ddf:	83 ec 24             	sub    $0x24,%esp
  105de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105de5:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105de8:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105dec:	8b 55 08             	mov    0x8(%ebp),%edx
  105def:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105df2:	88 45 f7             	mov    %al,-0x9(%ebp)
  105df5:	8b 45 10             	mov    0x10(%ebp),%eax
  105df8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105dfb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105dfe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105e02:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105e05:	89 d7                	mov    %edx,%edi
  105e07:	f3 aa                	rep stos %al,%es:(%edi)
  105e09:	89 fa                	mov    %edi,%edx
  105e0b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105e0e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105e11:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105e14:	83 c4 24             	add    $0x24,%esp
  105e17:	5f                   	pop    %edi
  105e18:	5d                   	pop    %ebp
  105e19:	c3                   	ret    

00105e1a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105e1a:	55                   	push   %ebp
  105e1b:	89 e5                	mov    %esp,%ebp
  105e1d:	57                   	push   %edi
  105e1e:	56                   	push   %esi
  105e1f:	53                   	push   %ebx
  105e20:	83 ec 30             	sub    $0x30,%esp
  105e23:	8b 45 08             	mov    0x8(%ebp),%eax
  105e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e29:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e2f:	8b 45 10             	mov    0x10(%ebp),%eax
  105e32:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e38:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105e3b:	73 42                	jae    105e7f <memmove+0x65>
  105e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e4c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e52:	c1 e8 02             	shr    $0x2,%eax
  105e55:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105e57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e5d:	89 d7                	mov    %edx,%edi
  105e5f:	89 c6                	mov    %eax,%esi
  105e61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105e63:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105e66:	83 e1 03             	and    $0x3,%ecx
  105e69:	74 02                	je     105e6d <memmove+0x53>
  105e6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105e6d:	89 f0                	mov    %esi,%eax
  105e6f:	89 fa                	mov    %edi,%edx
  105e71:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105e74:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105e77:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105e7d:	eb 36                	jmp    105eb5 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105e7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e82:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e88:	01 c2                	add    %eax,%edx
  105e8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e8d:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e93:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e99:	89 c1                	mov    %eax,%ecx
  105e9b:	89 d8                	mov    %ebx,%eax
  105e9d:	89 d6                	mov    %edx,%esi
  105e9f:	89 c7                	mov    %eax,%edi
  105ea1:	fd                   	std    
  105ea2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ea4:	fc                   	cld    
  105ea5:	89 f8                	mov    %edi,%eax
  105ea7:	89 f2                	mov    %esi,%edx
  105ea9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105eac:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105eaf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105eb5:	83 c4 30             	add    $0x30,%esp
  105eb8:	5b                   	pop    %ebx
  105eb9:	5e                   	pop    %esi
  105eba:	5f                   	pop    %edi
  105ebb:	5d                   	pop    %ebp
  105ebc:	c3                   	ret    

00105ebd <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105ebd:	55                   	push   %ebp
  105ebe:	89 e5                	mov    %esp,%ebp
  105ec0:	57                   	push   %edi
  105ec1:	56                   	push   %esi
  105ec2:	83 ec 20             	sub    $0x20,%esp
  105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ed1:	8b 45 10             	mov    0x10(%ebp),%eax
  105ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105eda:	c1 e8 02             	shr    $0x2,%eax
  105edd:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105edf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ee5:	89 d7                	mov    %edx,%edi
  105ee7:	89 c6                	mov    %eax,%esi
  105ee9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105eeb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105eee:	83 e1 03             	and    $0x3,%ecx
  105ef1:	74 02                	je     105ef5 <memcpy+0x38>
  105ef3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ef5:	89 f0                	mov    %esi,%eax
  105ef7:	89 fa                	mov    %edi,%edx
  105ef9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105efc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105eff:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105f05:	83 c4 20             	add    $0x20,%esp
  105f08:	5e                   	pop    %esi
  105f09:	5f                   	pop    %edi
  105f0a:	5d                   	pop    %ebp
  105f0b:	c3                   	ret    

00105f0c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105f0c:	55                   	push   %ebp
  105f0d:	89 e5                	mov    %esp,%ebp
  105f0f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105f12:	8b 45 08             	mov    0x8(%ebp),%eax
  105f15:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f1b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105f1e:	eb 30                	jmp    105f50 <memcmp+0x44>
        if (*s1 != *s2) {
  105f20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f23:	0f b6 10             	movzbl (%eax),%edx
  105f26:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f29:	0f b6 00             	movzbl (%eax),%eax
  105f2c:	38 c2                	cmp    %al,%dl
  105f2e:	74 18                	je     105f48 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f33:	0f b6 00             	movzbl (%eax),%eax
  105f36:	0f b6 d0             	movzbl %al,%edx
  105f39:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f3c:	0f b6 00             	movzbl (%eax),%eax
  105f3f:	0f b6 c0             	movzbl %al,%eax
  105f42:	29 c2                	sub    %eax,%edx
  105f44:	89 d0                	mov    %edx,%eax
  105f46:	eb 1a                	jmp    105f62 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105f48:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105f4c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105f50:	8b 45 10             	mov    0x10(%ebp),%eax
  105f53:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f56:	89 55 10             	mov    %edx,0x10(%ebp)
  105f59:	85 c0                	test   %eax,%eax
  105f5b:	75 c3                	jne    105f20 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105f5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105f62:	c9                   	leave  
  105f63:	c3                   	ret    
