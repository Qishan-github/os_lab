
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
  10005d:	e8 c2 5b 00 00       	call   105c24 <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 c0 5d 10 00 	movl   $0x105dc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 dc 5d 10 00 	movl   $0x105ddc,(%esp)
  10007c:	e8 c7 02 00 00       	call   100348 <cprintf>

    print_kerninfo();
  100081:	e8 f6 07 00 00       	call   10087c <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 8e 42 00 00       	call   10431e <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 bb 16 00 00       	call   101750 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 0d 18 00 00       	call   1018a7 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 fe 0c 00 00       	call   100d9d <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 1a 16 00 00       	call   1016be <intr_enable>
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
  1000c3:	e8 f6 0b 00 00       	call   100cbe <mon_backtrace>
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
  100161:	c7 04 24 e1 5d 10 00 	movl   $0x105de1,(%esp)
  100168:	e8 db 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 ef 5d 10 00 	movl   $0x105def,(%esp)
  100188:	e8 bb 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 fd 5d 10 00 	movl   $0x105dfd,(%esp)
  1001a8:	e8 9b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 0b 5e 10 00 	movl   $0x105e0b,(%esp)
  1001c8:	e8 7b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 19 5e 10 00 	movl   $0x105e19,(%esp)
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
  100211:	c7 04 24 28 5e 10 00 	movl   $0x105e28,(%esp)
  100218:	e8 2b 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 48 5e 10 00 	movl   $0x105e48,(%esp)
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
  100252:	c7 04 24 67 5e 10 00 	movl   $0x105e67,(%esp)
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
  100301:	e8 0d 13 00 00       	call   101613 <cons_putc>
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
  10033e:	e8 fa 50 00 00       	call   10543d <vprintfmt>
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
  10037a:	e8 94 12 00 00       	call   101613 <cons_putc>
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
  1003d6:	e8 74 12 00 00       	call   10164f <cons_getc>
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
  100548:	c7 00 6c 5e 10 00    	movl   $0x105e6c,(%eax)
    info->eip_line = 0;
  10054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	c7 40 08 6c 5e 10 00 	movl   $0x105e6c,0x8(%eax)
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
  10057f:	c7 45 f4 18 71 10 00 	movl   $0x107118,-0xc(%ebp)
    stab_end = __STAB_END__;
  100586:	c7 45 f0 d8 19 11 00 	movl   $0x1119d8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec d9 19 11 00 	movl   $0x1119d9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 f0 43 11 00 	movl   $0x1143f0,-0x18(%ebp)

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
  1006f3:	e8 a0 53 00 00       	call   105a98 <strfind>
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
  100882:	c7 04 24 76 5e 10 00 	movl   $0x105e76,(%esp)
  100889:	e8 ba fa ff ff       	call   100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100895:	00 
  100896:	c7 04 24 8f 5e 10 00 	movl   $0x105e8f,(%esp)
  10089d:	e8 a6 fa ff ff       	call   100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a2:	c7 44 24 04 ad 5d 10 	movl   $0x105dad,0x4(%esp)
  1008a9:	00 
  1008aa:	c7 04 24 a7 5e 10 00 	movl   $0x105ea7,(%esp)
  1008b1:	e8 92 fa ff ff       	call   100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b6:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008bd:	00 
  1008be:	c7 04 24 bf 5e 10 00 	movl   $0x105ebf,(%esp)
  1008c5:	e8 7e fa ff ff       	call   100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008ca:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  1008d1:	00 
  1008d2:	c7 04 24 d7 5e 10 00 	movl   $0x105ed7,(%esp)
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
  100904:	c7 04 24 f0 5e 10 00 	movl   $0x105ef0,(%esp)
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
  100938:	c7 04 24 1a 5f 10 00 	movl   $0x105f1a,(%esp)
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
  1009a7:	c7 04 24 36 5f 10 00 	movl   $0x105f36,(%esp)
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
  1009c9:	53                   	push   %ebx
  1009ca:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cd:	89 e8                	mov    %ebp,%eax
  1009cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */

    uint32_t ebp = read_ebp();
  1009d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  1009d8:	e8 d8 ff ff ff       	call   1009b5 <read_eip>
  1009dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    for(i = 0;ebp != 0&&i < STACKFRAME_DEPTH;i++) {
  1009e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e7:	e9 81 00 00 00       	jmp    100a6d <print_stackframe+0xa7>
        // 参数位置定位
        uint32_t *arguments = (uint32_t*)ebp + 2;
  1009ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ef:	83 c0 08             	add    $0x8,%eax
  1009f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // 显示传入的参数
        cprintf("ebp:0x%08x eip:0x%08x args:0x%08x 0x%08x 0x%08x 0x%08x",ebp,eip,arguments[0],arguments[1],arguments[2],arguments[3]);
  1009f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009f8:	83 c0 0c             	add    $0xc,%eax
  1009fb:	8b 18                	mov    (%eax),%ebx
  1009fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a00:	83 c0 08             	add    $0x8,%eax
  100a03:	8b 08                	mov    (%eax),%ecx
  100a05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a08:	83 c0 04             	add    $0x4,%eax
  100a0b:	8b 10                	mov    (%eax),%edx
  100a0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a10:	8b 00                	mov    (%eax),%eax
  100a12:	89 5c 24 18          	mov    %ebx,0x18(%esp)
  100a16:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  100a1a:	89 54 24 10          	mov    %edx,0x10(%esp)
  100a1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a30:	c7 04 24 48 5f 10 00 	movl   $0x105f48,(%esp)
  100a37:	e8 0c f9 ff ff       	call   100348 <cprintf>
        cprintf("\n");
  100a3c:	c7 04 24 7f 5f 10 00 	movl   $0x105f7f,(%esp)
  100a43:	e8 00 f9 ff ff       	call   100348 <cprintf>
        print_debuginfo(eip - 1);
  100a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a4b:	83 e8 01             	sub    $0x1,%eax
  100a4e:	89 04 24             	mov    %eax,(%esp)
  100a51:	e8 bc fe ff ff       	call   100912 <print_debuginfo>
        // 寻找上一个调用者栈低位置，即模拟函数返回的过程
        eip = ((uint32_t*)ebp)[1];
  100a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a59:	83 c0 04             	add    $0x4,%eax
  100a5c:	8b 00                	mov    (%eax),%eax
  100a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t*)ebp)[0];
  100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a64:	8b 00                	mov    (%eax),%eax
  100a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
      */

    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    int i;
    for(i = 0;ebp != 0&&i < STACKFRAME_DEPTH;i++) {
  100a69:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a71:	74 0a                	je     100a7d <print_stackframe+0xb7>
  100a73:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a77:	0f 8e 6f ff ff ff    	jle    1009ec <print_stackframe+0x26>
        // 寻找上一个调用者栈低位置，即模拟函数返回的过程
        eip = ((uint32_t*)ebp)[1];
        ebp = ((uint32_t*)ebp)[0];
    }

}
  100a7d:	83 c4 44             	add    $0x44,%esp
  100a80:	5b                   	pop    %ebx
  100a81:	5d                   	pop    %ebp
  100a82:	c3                   	ret    

00100a83 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a90:	eb 0c                	jmp    100a9e <parse+0x1b>
            *buf ++ = '\0';
  100a92:	8b 45 08             	mov    0x8(%ebp),%eax
  100a95:	8d 50 01             	lea    0x1(%eax),%edx
  100a98:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9b:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa1:	0f b6 00             	movzbl (%eax),%eax
  100aa4:	84 c0                	test   %al,%al
  100aa6:	74 1d                	je     100ac5 <parse+0x42>
  100aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  100aab:	0f b6 00             	movzbl (%eax),%eax
  100aae:	0f be c0             	movsbl %al,%eax
  100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab5:	c7 04 24 04 60 10 00 	movl   $0x106004,(%esp)
  100abc:	e8 a4 4f 00 00       	call   105a65 <strchr>
  100ac1:	85 c0                	test   %eax,%eax
  100ac3:	75 cd                	jne    100a92 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac8:	0f b6 00             	movzbl (%eax),%eax
  100acb:	84 c0                	test   %al,%al
  100acd:	75 02                	jne    100ad1 <parse+0x4e>
            break;
  100acf:	eb 67                	jmp    100b38 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ad1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad5:	75 14                	jne    100aeb <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ade:	00 
  100adf:	c7 04 24 09 60 10 00 	movl   $0x106009,(%esp)
  100ae6:	e8 5d f8 ff ff       	call   100348 <cprintf>
        }
        argv[argc ++] = buf;
  100aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aee:	8d 50 01             	lea    0x1(%eax),%edx
  100af1:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  100afe:	01 c2                	add    %eax,%edx
  100b00:	8b 45 08             	mov    0x8(%ebp),%eax
  100b03:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b05:	eb 04                	jmp    100b0b <parse+0x88>
            buf ++;
  100b07:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0e:	0f b6 00             	movzbl (%eax),%eax
  100b11:	84 c0                	test   %al,%al
  100b13:	74 1d                	je     100b32 <parse+0xaf>
  100b15:	8b 45 08             	mov    0x8(%ebp),%eax
  100b18:	0f b6 00             	movzbl (%eax),%eax
  100b1b:	0f be c0             	movsbl %al,%eax
  100b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b22:	c7 04 24 04 60 10 00 	movl   $0x106004,(%esp)
  100b29:	e8 37 4f 00 00       	call   105a65 <strchr>
  100b2e:	85 c0                	test   %eax,%eax
  100b30:	74 d5                	je     100b07 <parse+0x84>
            buf ++;
        }
    }
  100b32:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b33:	e9 66 ff ff ff       	jmp    100a9e <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b3b:	c9                   	leave  
  100b3c:	c3                   	ret    

00100b3d <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3d:	55                   	push   %ebp
  100b3e:	89 e5                	mov    %esp,%ebp
  100b40:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b43:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4d:	89 04 24             	mov    %eax,(%esp)
  100b50:	e8 2e ff ff ff       	call   100a83 <parse>
  100b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5c:	75 0a                	jne    100b68 <runcmd+0x2b>
        return 0;
  100b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  100b63:	e9 85 00 00 00       	jmp    100bed <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b6f:	eb 5c                	jmp    100bcd <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b71:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b77:	89 d0                	mov    %edx,%eax
  100b79:	01 c0                	add    %eax,%eax
  100b7b:	01 d0                	add    %edx,%eax
  100b7d:	c1 e0 02             	shl    $0x2,%eax
  100b80:	05 00 70 11 00       	add    $0x117000,%eax
  100b85:	8b 00                	mov    (%eax),%eax
  100b87:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b8b:	89 04 24             	mov    %eax,(%esp)
  100b8e:	e8 33 4e 00 00       	call   1059c6 <strcmp>
  100b93:	85 c0                	test   %eax,%eax
  100b95:	75 32                	jne    100bc9 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9a:	89 d0                	mov    %edx,%eax
  100b9c:	01 c0                	add    %eax,%eax
  100b9e:	01 d0                	add    %edx,%eax
  100ba0:	c1 e0 02             	shl    $0x2,%eax
  100ba3:	05 00 70 11 00       	add    $0x117000,%eax
  100ba8:	8b 40 08             	mov    0x8(%eax),%eax
  100bab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bae:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bb4:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bb8:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bbb:	83 c2 04             	add    $0x4,%edx
  100bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bc2:	89 0c 24             	mov    %ecx,(%esp)
  100bc5:	ff d0                	call   *%eax
  100bc7:	eb 24                	jmp    100bed <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd0:	83 f8 02             	cmp    $0x2,%eax
  100bd3:	76 9c                	jbe    100b71 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdc:	c7 04 24 27 60 10 00 	movl   $0x106027,(%esp)
  100be3:	e8 60 f7 ff ff       	call   100348 <cprintf>
    return 0;
  100be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bed:	c9                   	leave  
  100bee:	c3                   	ret    

00100bef <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bef:	55                   	push   %ebp
  100bf0:	89 e5                	mov    %esp,%ebp
  100bf2:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bf5:	c7 04 24 40 60 10 00 	movl   $0x106040,(%esp)
  100bfc:	e8 47 f7 ff ff       	call   100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c01:	c7 04 24 68 60 10 00 	movl   $0x106068,(%esp)
  100c08:	e8 3b f7 ff ff       	call   100348 <cprintf>

    if (tf != NULL) {
  100c0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c11:	74 0b                	je     100c1e <kmonitor+0x2f>
        print_trapframe(tf);
  100c13:	8b 45 08             	mov    0x8(%ebp),%eax
  100c16:	89 04 24             	mov    %eax,(%esp)
  100c19:	e8 40 0e 00 00       	call   101a5e <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c1e:	c7 04 24 8d 60 10 00 	movl   $0x10608d,(%esp)
  100c25:	e8 15 f6 ff ff       	call   10023f <readline>
  100c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c31:	74 18                	je     100c4b <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c33:	8b 45 08             	mov    0x8(%ebp),%eax
  100c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c3d:	89 04 24             	mov    %eax,(%esp)
  100c40:	e8 f8 fe ff ff       	call   100b3d <runcmd>
  100c45:	85 c0                	test   %eax,%eax
  100c47:	79 02                	jns    100c4b <kmonitor+0x5c>
                break;
  100c49:	eb 02                	jmp    100c4d <kmonitor+0x5e>
            }
        }
    }
  100c4b:	eb d1                	jmp    100c1e <kmonitor+0x2f>
}
  100c4d:	c9                   	leave  
  100c4e:	c3                   	ret    

00100c4f <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c4f:	55                   	push   %ebp
  100c50:	89 e5                	mov    %esp,%ebp
  100c52:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c5c:	eb 3f                	jmp    100c9d <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c61:	89 d0                	mov    %edx,%eax
  100c63:	01 c0                	add    %eax,%eax
  100c65:	01 d0                	add    %edx,%eax
  100c67:	c1 e0 02             	shl    $0x2,%eax
  100c6a:	05 00 70 11 00       	add    $0x117000,%eax
  100c6f:	8b 48 04             	mov    0x4(%eax),%ecx
  100c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c75:	89 d0                	mov    %edx,%eax
  100c77:	01 c0                	add    %eax,%eax
  100c79:	01 d0                	add    %edx,%eax
  100c7b:	c1 e0 02             	shl    $0x2,%eax
  100c7e:	05 00 70 11 00       	add    $0x117000,%eax
  100c83:	8b 00                	mov    (%eax),%eax
  100c85:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c8d:	c7 04 24 91 60 10 00 	movl   $0x106091,(%esp)
  100c94:	e8 af f6 ff ff       	call   100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca0:	83 f8 02             	cmp    $0x2,%eax
  100ca3:	76 b9                	jbe    100c5e <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100ca5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100caa:	c9                   	leave  
  100cab:	c3                   	ret    

00100cac <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cac:	55                   	push   %ebp
  100cad:	89 e5                	mov    %esp,%ebp
  100caf:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb2:	e8 c5 fb ff ff       	call   10087c <print_kerninfo>
    return 0;
  100cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbc:	c9                   	leave  
  100cbd:	c3                   	ret    

00100cbe <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cbe:	55                   	push   %ebp
  100cbf:	89 e5                	mov    %esp,%ebp
  100cc1:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc4:	e8 fd fc ff ff       	call   1009c6 <print_stackframe>
    return 0;
  100cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cce:	c9                   	leave  
  100ccf:	c3                   	ret    

00100cd0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cd0:	55                   	push   %ebp
  100cd1:	89 e5                	mov    %esp,%ebp
  100cd3:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd6:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100cdb:	85 c0                	test   %eax,%eax
  100cdd:	74 02                	je     100ce1 <__panic+0x11>
        goto panic_dead;
  100cdf:	eb 59                	jmp    100d3a <__panic+0x6a>
    }
    is_panic = 1;
  100ce1:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100ce8:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ceb:	8d 45 14             	lea    0x14(%ebp),%eax
  100cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  100cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cff:	c7 04 24 9a 60 10 00 	movl   $0x10609a,(%esp)
  100d06:	e8 3d f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d12:	8b 45 10             	mov    0x10(%ebp),%eax
  100d15:	89 04 24             	mov    %eax,(%esp)
  100d18:	e8 f8 f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d1d:	c7 04 24 b6 60 10 00 	movl   $0x1060b6,(%esp)
  100d24:	e8 1f f6 ff ff       	call   100348 <cprintf>
    
    cprintf("stack trackback:\n");
  100d29:	c7 04 24 b8 60 10 00 	movl   $0x1060b8,(%esp)
  100d30:	e8 13 f6 ff ff       	call   100348 <cprintf>
    print_stackframe();
  100d35:	e8 8c fc ff ff       	call   1009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d3a:	e8 85 09 00 00       	call   1016c4 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d46:	e8 a4 fe ff ff       	call   100bef <kmonitor>
    }
  100d4b:	eb f2                	jmp    100d3f <__panic+0x6f>

00100d4d <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d4d:	55                   	push   %ebp
  100d4e:	89 e5                	mov    %esp,%ebp
  100d50:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d53:	8d 45 14             	lea    0x14(%ebp),%eax
  100d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d60:	8b 45 08             	mov    0x8(%ebp),%eax
  100d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d67:	c7 04 24 ca 60 10 00 	movl   $0x1060ca,(%esp)
  100d6e:	e8 d5 f5 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d76:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7a:	8b 45 10             	mov    0x10(%ebp),%eax
  100d7d:	89 04 24             	mov    %eax,(%esp)
  100d80:	e8 90 f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d85:	c7 04 24 b6 60 10 00 	movl   $0x1060b6,(%esp)
  100d8c:	e8 b7 f5 ff ff       	call   100348 <cprintf>
    va_end(ap);
}
  100d91:	c9                   	leave  
  100d92:	c3                   	ret    

00100d93 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d93:	55                   	push   %ebp
  100d94:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d96:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100d9b:	5d                   	pop    %ebp
  100d9c:	c3                   	ret    

00100d9d <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9d:	55                   	push   %ebp
  100d9e:	89 e5                	mov    %esp,%ebp
  100da0:	83 ec 28             	sub    $0x28,%esp
  100da3:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100da9:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100db1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100db5:	ee                   	out    %al,(%dx)
  100db6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dbc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dc0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dc8:	ee                   	out    %al,(%dx)
  100dc9:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dcf:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dd3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dd7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ddb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100ddc:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100de3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100de6:	c7 04 24 e8 60 10 00 	movl   $0x1060e8,(%esp)
  100ded:	e8 56 f5 ff ff       	call   100348 <cprintf>
    pic_enable(IRQ_TIMER);
  100df2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100df9:	e8 24 09 00 00       	call   101722 <pic_enable>
}
  100dfe:	c9                   	leave  
  100dff:	c3                   	ret    

00100e00 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e00:	55                   	push   %ebp
  100e01:	89 e5                	mov    %esp,%ebp
  100e03:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e06:	9c                   	pushf  
  100e07:	58                   	pop    %eax
  100e08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e0e:	25 00 02 00 00       	and    $0x200,%eax
  100e13:	85 c0                	test   %eax,%eax
  100e15:	74 0c                	je     100e23 <__intr_save+0x23>
        intr_disable();
  100e17:	e8 a8 08 00 00       	call   1016c4 <intr_disable>
        return 1;
  100e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  100e21:	eb 05                	jmp    100e28 <__intr_save+0x28>
    }
    return 0;
  100e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e28:	c9                   	leave  
  100e29:	c3                   	ret    

00100e2a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e2a:	55                   	push   %ebp
  100e2b:	89 e5                	mov    %esp,%ebp
  100e2d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e34:	74 05                	je     100e3b <__intr_restore+0x11>
        intr_enable();
  100e36:	e8 83 08 00 00       	call   1016be <intr_enable>
    }
}
  100e3b:	c9                   	leave  
  100e3c:	c3                   	ret    

00100e3d <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e3d:	55                   	push   %ebp
  100e3e:	89 e5                	mov    %esp,%ebp
  100e40:	83 ec 10             	sub    $0x10,%esp
  100e43:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e49:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e4d:	89 c2                	mov    %eax,%edx
  100e4f:	ec                   	in     (%dx),%al
  100e50:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e53:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e59:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5d:	89 c2                	mov    %eax,%edx
  100e5f:	ec                   	in     (%dx),%al
  100e60:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e63:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e69:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6d:	89 c2                	mov    %eax,%edx
  100e6f:	ec                   	in     (%dx),%al
  100e70:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e73:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e79:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e7d:	89 c2                	mov    %eax,%edx
  100e7f:	ec                   	in     (%dx),%al
  100e80:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e83:	c9                   	leave  
  100e84:	c3                   	ret    

00100e85 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e85:	55                   	push   %ebp
  100e86:	89 e5                	mov    %esp,%ebp
  100e88:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e8b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e95:	0f b7 00             	movzwl (%eax),%eax
  100e98:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e9f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea7:	0f b7 00             	movzwl (%eax),%eax
  100eaa:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100eae:	74 12                	je     100ec2 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100eb0:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eb7:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ebe:	b4 03 
  100ec0:	eb 13                	jmp    100ed5 <cga_init+0x50>
    } else {
        *cp = was;
  100ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ec9:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ecc:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ed3:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ed5:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100edc:	0f b7 c0             	movzwl %ax,%eax
  100edf:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ee3:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ee7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eeb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100eef:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ef0:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ef7:	83 c0 01             	add    $0x1,%eax
  100efa:	0f b7 c0             	movzwl %ax,%eax
  100efd:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f01:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f05:	89 c2                	mov    %eax,%edx
  100f07:	ec                   	in     (%dx),%al
  100f08:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f0b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f0f:	0f b6 c0             	movzbl %al,%eax
  100f12:	c1 e0 08             	shl    $0x8,%eax
  100f15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f18:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f1f:	0f b7 c0             	movzwl %ax,%eax
  100f22:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f26:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f2a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f2e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f32:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f33:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f3a:	83 c0 01             	add    $0x1,%eax
  100f3d:	0f b7 c0             	movzwl %ax,%eax
  100f40:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f44:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f48:	89 c2                	mov    %eax,%edx
  100f4a:	ec                   	in     (%dx),%al
  100f4b:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f4e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f52:	0f b6 c0             	movzbl %al,%eax
  100f55:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f58:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f5b:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f63:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f69:	c9                   	leave  
  100f6a:	c3                   	ret    

00100f6b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f6b:	55                   	push   %ebp
  100f6c:	89 e5                	mov    %esp,%ebp
  100f6e:	83 ec 48             	sub    $0x48,%esp
  100f71:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f77:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f7b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f7f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f83:	ee                   	out    %al,(%dx)
  100f84:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f8a:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f8e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f92:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f96:	ee                   	out    %al,(%dx)
  100f97:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f9d:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fa1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fa5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fa9:	ee                   	out    %al,(%dx)
  100faa:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fb0:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fb4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fb8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fbc:	ee                   	out    %al,(%dx)
  100fbd:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fc3:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fc7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fcf:	ee                   	out    %al,(%dx)
  100fd0:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fd6:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fda:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fde:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe2:	ee                   	out    %al,(%dx)
  100fe3:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fe9:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100fed:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ff1:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100ff5:	ee                   	out    %al,(%dx)
  100ff6:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ffc:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  101000:	89 c2                	mov    %eax,%edx
  101002:	ec                   	in     (%dx),%al
  101003:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101006:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10100a:	3c ff                	cmp    $0xff,%al
  10100c:	0f 95 c0             	setne  %al
  10100f:	0f b6 c0             	movzbl %al,%eax
  101012:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101017:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10101d:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101021:	89 c2                	mov    %eax,%edx
  101023:	ec                   	in     (%dx),%al
  101024:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101027:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10102d:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101031:	89 c2                	mov    %eax,%edx
  101033:	ec                   	in     (%dx),%al
  101034:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101037:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10103c:	85 c0                	test   %eax,%eax
  10103e:	74 0c                	je     10104c <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101040:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101047:	e8 d6 06 00 00       	call   101722 <pic_enable>
    }
}
  10104c:	c9                   	leave  
  10104d:	c3                   	ret    

0010104e <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10104e:	55                   	push   %ebp
  10104f:	89 e5                	mov    %esp,%ebp
  101051:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101054:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10105b:	eb 09                	jmp    101066 <lpt_putc_sub+0x18>
        delay();
  10105d:	e8 db fd ff ff       	call   100e3d <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101062:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101066:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10106c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101070:	89 c2                	mov    %eax,%edx
  101072:	ec                   	in     (%dx),%al
  101073:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101076:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10107a:	84 c0                	test   %al,%al
  10107c:	78 09                	js     101087 <lpt_putc_sub+0x39>
  10107e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101085:	7e d6                	jle    10105d <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101087:	8b 45 08             	mov    0x8(%ebp),%eax
  10108a:	0f b6 c0             	movzbl %al,%eax
  10108d:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101093:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101096:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10109a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10109e:	ee                   	out    %al,(%dx)
  10109f:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010a5:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010a9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010ad:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010b1:	ee                   	out    %al,(%dx)
  1010b2:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010b8:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010bc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c4:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010c5:	c9                   	leave  
  1010c6:	c3                   	ret    

001010c7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010c7:	55                   	push   %ebp
  1010c8:	89 e5                	mov    %esp,%ebp
  1010ca:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010cd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010d1:	74 0d                	je     1010e0 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d6:	89 04 24             	mov    %eax,(%esp)
  1010d9:	e8 70 ff ff ff       	call   10104e <lpt_putc_sub>
  1010de:	eb 24                	jmp    101104 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010e0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e7:	e8 62 ff ff ff       	call   10104e <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010ec:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010f3:	e8 56 ff ff ff       	call   10104e <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010f8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010ff:	e8 4a ff ff ff       	call   10104e <lpt_putc_sub>
    }
}
  101104:	c9                   	leave  
  101105:	c3                   	ret    

00101106 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101106:	55                   	push   %ebp
  101107:	89 e5                	mov    %esp,%ebp
  101109:	53                   	push   %ebx
  10110a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	b0 00                	mov    $0x0,%al
  101112:	85 c0                	test   %eax,%eax
  101114:	75 07                	jne    10111d <cga_putc+0x17>
        c |= 0x0700;
  101116:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10111d:	8b 45 08             	mov    0x8(%ebp),%eax
  101120:	0f b6 c0             	movzbl %al,%eax
  101123:	83 f8 0a             	cmp    $0xa,%eax
  101126:	74 4c                	je     101174 <cga_putc+0x6e>
  101128:	83 f8 0d             	cmp    $0xd,%eax
  10112b:	74 57                	je     101184 <cga_putc+0x7e>
  10112d:	83 f8 08             	cmp    $0x8,%eax
  101130:	0f 85 88 00 00 00    	jne    1011be <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101136:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10113d:	66 85 c0             	test   %ax,%ax
  101140:	74 30                	je     101172 <cga_putc+0x6c>
            crt_pos --;
  101142:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101149:	83 e8 01             	sub    $0x1,%eax
  10114c:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101152:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101157:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  10115e:	0f b7 d2             	movzwl %dx,%edx
  101161:	01 d2                	add    %edx,%edx
  101163:	01 c2                	add    %eax,%edx
  101165:	8b 45 08             	mov    0x8(%ebp),%eax
  101168:	b0 00                	mov    $0x0,%al
  10116a:	83 c8 20             	or     $0x20,%eax
  10116d:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101170:	eb 72                	jmp    1011e4 <cga_putc+0xde>
  101172:	eb 70                	jmp    1011e4 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101174:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10117b:	83 c0 50             	add    $0x50,%eax
  10117e:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101184:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  10118b:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101192:	0f b7 c1             	movzwl %cx,%eax
  101195:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10119b:	c1 e8 10             	shr    $0x10,%eax
  10119e:	89 c2                	mov    %eax,%edx
  1011a0:	66 c1 ea 06          	shr    $0x6,%dx
  1011a4:	89 d0                	mov    %edx,%eax
  1011a6:	c1 e0 02             	shl    $0x2,%eax
  1011a9:	01 d0                	add    %edx,%eax
  1011ab:	c1 e0 04             	shl    $0x4,%eax
  1011ae:	29 c1                	sub    %eax,%ecx
  1011b0:	89 ca                	mov    %ecx,%edx
  1011b2:	89 d8                	mov    %ebx,%eax
  1011b4:	29 d0                	sub    %edx,%eax
  1011b6:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011bc:	eb 26                	jmp    1011e4 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011be:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011c4:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011cb:	8d 50 01             	lea    0x1(%eax),%edx
  1011ce:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011d5:	0f b7 c0             	movzwl %ax,%eax
  1011d8:	01 c0                	add    %eax,%eax
  1011da:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1011e0:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e3:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e4:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011eb:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011ef:	76 5b                	jbe    10124c <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f1:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011f6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011fc:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101201:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101208:	00 
  101209:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120d:	89 04 24             	mov    %eax,(%esp)
  101210:	e8 4e 4a 00 00       	call   105c63 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101215:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121c:	eb 15                	jmp    101233 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  10121e:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101223:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101226:	01 d2                	add    %edx,%edx
  101228:	01 d0                	add    %edx,%eax
  10122a:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10122f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101233:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123a:	7e e2                	jle    10121e <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10123c:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101243:	83 e8 50             	sub    $0x50,%eax
  101246:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124c:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101253:	0f b7 c0             	movzwl %ax,%eax
  101256:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10125a:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  10125e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101262:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101266:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101267:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10126e:	66 c1 e8 08          	shr    $0x8,%ax
  101272:	0f b6 c0             	movzbl %al,%eax
  101275:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10127c:	83 c2 01             	add    $0x1,%edx
  10127f:	0f b7 d2             	movzwl %dx,%edx
  101282:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101286:	88 45 ed             	mov    %al,-0x13(%ebp)
  101289:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10128d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101291:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101292:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101299:	0f b7 c0             	movzwl %ax,%eax
  10129c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012a0:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012a4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012a8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012ac:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012ad:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012b4:	0f b6 c0             	movzbl %al,%eax
  1012b7:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012be:	83 c2 01             	add    $0x1,%edx
  1012c1:	0f b7 d2             	movzwl %dx,%edx
  1012c4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012c8:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012cb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012cf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012d3:	ee                   	out    %al,(%dx)
}
  1012d4:	83 c4 34             	add    $0x34,%esp
  1012d7:	5b                   	pop    %ebx
  1012d8:	5d                   	pop    %ebp
  1012d9:	c3                   	ret    

001012da <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012da:	55                   	push   %ebp
  1012db:	89 e5                	mov    %esp,%ebp
  1012dd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e7:	eb 09                	jmp    1012f2 <serial_putc_sub+0x18>
        delay();
  1012e9:	e8 4f fb ff ff       	call   100e3d <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012f2:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012f8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fc:	89 c2                	mov    %eax,%edx
  1012fe:	ec                   	in     (%dx),%al
  1012ff:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101302:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101306:	0f b6 c0             	movzbl %al,%eax
  101309:	83 e0 20             	and    $0x20,%eax
  10130c:	85 c0                	test   %eax,%eax
  10130e:	75 09                	jne    101319 <serial_putc_sub+0x3f>
  101310:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101317:	7e d0                	jle    1012e9 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101319:	8b 45 08             	mov    0x8(%ebp),%eax
  10131c:	0f b6 c0             	movzbl %al,%eax
  10131f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101325:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101328:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101330:	ee                   	out    %al,(%dx)
}
  101331:	c9                   	leave  
  101332:	c3                   	ret    

00101333 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101333:	55                   	push   %ebp
  101334:	89 e5                	mov    %esp,%ebp
  101336:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101339:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133d:	74 0d                	je     10134c <serial_putc+0x19>
        serial_putc_sub(c);
  10133f:	8b 45 08             	mov    0x8(%ebp),%eax
  101342:	89 04 24             	mov    %eax,(%esp)
  101345:	e8 90 ff ff ff       	call   1012da <serial_putc_sub>
  10134a:	eb 24                	jmp    101370 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  10134c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101353:	e8 82 ff ff ff       	call   1012da <serial_putc_sub>
        serial_putc_sub(' ');
  101358:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10135f:	e8 76 ff ff ff       	call   1012da <serial_putc_sub>
        serial_putc_sub('\b');
  101364:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136b:	e8 6a ff ff ff       	call   1012da <serial_putc_sub>
    }
}
  101370:	c9                   	leave  
  101371:	c3                   	ret    

00101372 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101372:	55                   	push   %ebp
  101373:	89 e5                	mov    %esp,%ebp
  101375:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101378:	eb 33                	jmp    1013ad <cons_intr+0x3b>
        if (c != 0) {
  10137a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10137e:	74 2d                	je     1013ad <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101380:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101385:	8d 50 01             	lea    0x1(%eax),%edx
  101388:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  10138e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101391:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101397:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10139c:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a1:	75 0a                	jne    1013ad <cons_intr+0x3b>
                cons.wpos = 0;
  1013a3:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013aa:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b0:	ff d0                	call   *%eax
  1013b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013b5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013b9:	75 bf                	jne    10137a <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013bb:	c9                   	leave  
  1013bc:	c3                   	ret    

001013bd <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013bd:	55                   	push   %ebp
  1013be:	89 e5                	mov    %esp,%ebp
  1013c0:	83 ec 10             	sub    $0x10,%esp
  1013c3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013c9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cd:	89 c2                	mov    %eax,%edx
  1013cf:	ec                   	in     (%dx),%al
  1013d0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013d3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d7:	0f b6 c0             	movzbl %al,%eax
  1013da:	83 e0 01             	and    $0x1,%eax
  1013dd:	85 c0                	test   %eax,%eax
  1013df:	75 07                	jne    1013e8 <serial_proc_data+0x2b>
        return -1;
  1013e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e6:	eb 2a                	jmp    101412 <serial_proc_data+0x55>
  1013e8:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013ee:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013f2:	89 c2                	mov    %eax,%edx
  1013f4:	ec                   	in     (%dx),%al
  1013f5:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013f8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013fc:	0f b6 c0             	movzbl %al,%eax
  1013ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101402:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101406:	75 07                	jne    10140f <serial_proc_data+0x52>
        c = '\b';
  101408:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10140f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101412:	c9                   	leave  
  101413:	c3                   	ret    

00101414 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101414:	55                   	push   %ebp
  101415:	89 e5                	mov    %esp,%ebp
  101417:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10141a:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10141f:	85 c0                	test   %eax,%eax
  101421:	74 0c                	je     10142f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101423:	c7 04 24 bd 13 10 00 	movl   $0x1013bd,(%esp)
  10142a:	e8 43 ff ff ff       	call   101372 <cons_intr>
    }
}
  10142f:	c9                   	leave  
  101430:	c3                   	ret    

00101431 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101431:	55                   	push   %ebp
  101432:	89 e5                	mov    %esp,%ebp
  101434:	83 ec 38             	sub    $0x38,%esp
  101437:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10143d:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101441:	89 c2                	mov    %eax,%edx
  101443:	ec                   	in     (%dx),%al
  101444:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101447:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10144b:	0f b6 c0             	movzbl %al,%eax
  10144e:	83 e0 01             	and    $0x1,%eax
  101451:	85 c0                	test   %eax,%eax
  101453:	75 0a                	jne    10145f <kbd_proc_data+0x2e>
        return -1;
  101455:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10145a:	e9 59 01 00 00       	jmp    1015b8 <kbd_proc_data+0x187>
  10145f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101465:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101469:	89 c2                	mov    %eax,%edx
  10146b:	ec                   	in     (%dx),%al
  10146c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10146f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101473:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101476:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10147a:	75 17                	jne    101493 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10147c:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101481:	83 c8 40             	or     $0x40,%eax
  101484:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  101489:	b8 00 00 00 00       	mov    $0x0,%eax
  10148e:	e9 25 01 00 00       	jmp    1015b8 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101493:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101497:	84 c0                	test   %al,%al
  101499:	79 47                	jns    1014e2 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149b:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014a0:	83 e0 40             	and    $0x40,%eax
  1014a3:	85 c0                	test   %eax,%eax
  1014a5:	75 09                	jne    1014b0 <kbd_proc_data+0x7f>
  1014a7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ab:	83 e0 7f             	and    $0x7f,%eax
  1014ae:	eb 04                	jmp    1014b4 <kbd_proc_data+0x83>
  1014b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bb:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014c2:	83 c8 40             	or     $0x40,%eax
  1014c5:	0f b6 c0             	movzbl %al,%eax
  1014c8:	f7 d0                	not    %eax
  1014ca:	89 c2                	mov    %eax,%edx
  1014cc:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d1:	21 d0                	and    %edx,%eax
  1014d3:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014d8:	b8 00 00 00 00       	mov    $0x0,%eax
  1014dd:	e9 d6 00 00 00       	jmp    1015b8 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014e2:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014e7:	83 e0 40             	and    $0x40,%eax
  1014ea:	85 c0                	test   %eax,%eax
  1014ec:	74 11                	je     1014ff <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014ee:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f2:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f7:	83 e0 bf             	and    $0xffffffbf,%eax
  1014fa:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  1014ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101503:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  10150a:	0f b6 d0             	movzbl %al,%edx
  10150d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101512:	09 d0                	or     %edx,%eax
  101514:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  101519:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151d:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101524:	0f b6 d0             	movzbl %al,%edx
  101527:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152c:	31 d0                	xor    %edx,%eax
  10152e:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101533:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101538:	83 e0 03             	and    $0x3,%eax
  10153b:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101542:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101546:	01 d0                	add    %edx,%eax
  101548:	0f b6 00             	movzbl (%eax),%eax
  10154b:	0f b6 c0             	movzbl %al,%eax
  10154e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101551:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101556:	83 e0 08             	and    $0x8,%eax
  101559:	85 c0                	test   %eax,%eax
  10155b:	74 22                	je     10157f <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10155d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101561:	7e 0c                	jle    10156f <kbd_proc_data+0x13e>
  101563:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101567:	7f 06                	jg     10156f <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101569:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10156d:	eb 10                	jmp    10157f <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10156f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101573:	7e 0a                	jle    10157f <kbd_proc_data+0x14e>
  101575:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101579:	7f 04                	jg     10157f <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10157b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10157f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101584:	f7 d0                	not    %eax
  101586:	83 e0 06             	and    $0x6,%eax
  101589:	85 c0                	test   %eax,%eax
  10158b:	75 28                	jne    1015b5 <kbd_proc_data+0x184>
  10158d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101594:	75 1f                	jne    1015b5 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101596:	c7 04 24 03 61 10 00 	movl   $0x106103,(%esp)
  10159d:	e8 a6 ed ff ff       	call   100348 <cprintf>
  1015a2:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015a8:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ac:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015b0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015b4:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015b8:	c9                   	leave  
  1015b9:	c3                   	ret    

001015ba <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015ba:	55                   	push   %ebp
  1015bb:	89 e5                	mov    %esp,%ebp
  1015bd:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015c0:	c7 04 24 31 14 10 00 	movl   $0x101431,(%esp)
  1015c7:	e8 a6 fd ff ff       	call   101372 <cons_intr>
}
  1015cc:	c9                   	leave  
  1015cd:	c3                   	ret    

001015ce <kbd_init>:

static void
kbd_init(void) {
  1015ce:	55                   	push   %ebp
  1015cf:	89 e5                	mov    %esp,%ebp
  1015d1:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015d4:	e8 e1 ff ff ff       	call   1015ba <kbd_intr>
    pic_enable(IRQ_KBD);
  1015d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015e0:	e8 3d 01 00 00       	call   101722 <pic_enable>
}
  1015e5:	c9                   	leave  
  1015e6:	c3                   	ret    

001015e7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e7:	55                   	push   %ebp
  1015e8:	89 e5                	mov    %esp,%ebp
  1015ea:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ed:	e8 93 f8 ff ff       	call   100e85 <cga_init>
    serial_init();
  1015f2:	e8 74 f9 ff ff       	call   100f6b <serial_init>
    kbd_init();
  1015f7:	e8 d2 ff ff ff       	call   1015ce <kbd_init>
    if (!serial_exists) {
  1015fc:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101601:	85 c0                	test   %eax,%eax
  101603:	75 0c                	jne    101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101605:	c7 04 24 0f 61 10 00 	movl   $0x10610f,(%esp)
  10160c:	e8 37 ed ff ff       	call   100348 <cprintf>
    }
}
  101611:	c9                   	leave  
  101612:	c3                   	ret    

00101613 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101613:	55                   	push   %ebp
  101614:	89 e5                	mov    %esp,%ebp
  101616:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101619:	e8 e2 f7 ff ff       	call   100e00 <__intr_save>
  10161e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101621:	8b 45 08             	mov    0x8(%ebp),%eax
  101624:	89 04 24             	mov    %eax,(%esp)
  101627:	e8 9b fa ff ff       	call   1010c7 <lpt_putc>
        cga_putc(c);
  10162c:	8b 45 08             	mov    0x8(%ebp),%eax
  10162f:	89 04 24             	mov    %eax,(%esp)
  101632:	e8 cf fa ff ff       	call   101106 <cga_putc>
        serial_putc(c);
  101637:	8b 45 08             	mov    0x8(%ebp),%eax
  10163a:	89 04 24             	mov    %eax,(%esp)
  10163d:	e8 f1 fc ff ff       	call   101333 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101645:	89 04 24             	mov    %eax,(%esp)
  101648:	e8 dd f7 ff ff       	call   100e2a <__intr_restore>
}
  10164d:	c9                   	leave  
  10164e:	c3                   	ret    

0010164f <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10164f:	55                   	push   %ebp
  101650:	89 e5                	mov    %esp,%ebp
  101652:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10165c:	e8 9f f7 ff ff       	call   100e00 <__intr_save>
  101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101664:	e8 ab fd ff ff       	call   101414 <serial_intr>
        kbd_intr();
  101669:	e8 4c ff ff ff       	call   1015ba <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10166e:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101674:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101679:	39 c2                	cmp    %eax,%edx
  10167b:	74 31                	je     1016ae <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167d:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101682:	8d 50 01             	lea    0x1(%eax),%edx
  101685:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  10168b:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101692:	0f b6 c0             	movzbl %al,%eax
  101695:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101698:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169d:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a2:	75 0a                	jne    1016ae <cons_getc+0x5f>
                cons.rpos = 0;
  1016a4:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016ab:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016b1:	89 04 24             	mov    %eax,(%esp)
  1016b4:	e8 71 f7 ff ff       	call   100e2a <__intr_restore>
    return c;
  1016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016bc:	c9                   	leave  
  1016bd:	c3                   	ret    

001016be <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016be:	55                   	push   %ebp
  1016bf:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016c1:	fb                   	sti    
    sti();
}
  1016c2:	5d                   	pop    %ebp
  1016c3:	c3                   	ret    

001016c4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016c4:	55                   	push   %ebp
  1016c5:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016c7:	fa                   	cli    
    cli();
}
  1016c8:	5d                   	pop    %ebp
  1016c9:	c3                   	ret    

001016ca <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016ca:	55                   	push   %ebp
  1016cb:	89 e5                	mov    %esp,%ebp
  1016cd:	83 ec 14             	sub    $0x14,%esp
  1016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016db:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016e1:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016e6:	85 c0                	test   %eax,%eax
  1016e8:	74 36                	je     101720 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016ee:	0f b6 c0             	movzbl %al,%eax
  1016f1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016f7:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1016fa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016fe:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101702:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101703:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101707:	66 c1 e8 08          	shr    $0x8,%ax
  10170b:	0f b6 c0             	movzbl %al,%eax
  10170e:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101714:	88 45 f9             	mov    %al,-0x7(%ebp)
  101717:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10171b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10171f:	ee                   	out    %al,(%dx)
    }
}
  101720:	c9                   	leave  
  101721:	c3                   	ret    

00101722 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101722:	55                   	push   %ebp
  101723:	89 e5                	mov    %esp,%ebp
  101725:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101728:	8b 45 08             	mov    0x8(%ebp),%eax
  10172b:	ba 01 00 00 00       	mov    $0x1,%edx
  101730:	89 c1                	mov    %eax,%ecx
  101732:	d3 e2                	shl    %cl,%edx
  101734:	89 d0                	mov    %edx,%eax
  101736:	f7 d0                	not    %eax
  101738:	89 c2                	mov    %eax,%edx
  10173a:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101741:	21 d0                	and    %edx,%eax
  101743:	0f b7 c0             	movzwl %ax,%eax
  101746:	89 04 24             	mov    %eax,(%esp)
  101749:	e8 7c ff ff ff       	call   1016ca <pic_setmask>
}
  10174e:	c9                   	leave  
  10174f:	c3                   	ret    

00101750 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101750:	55                   	push   %ebp
  101751:	89 e5                	mov    %esp,%ebp
  101753:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101756:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10175d:	00 00 00 
  101760:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101766:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10176a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10176e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101772:	ee                   	out    %al,(%dx)
  101773:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101779:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10177d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101781:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101785:	ee                   	out    %al,(%dx)
  101786:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10178c:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101790:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101794:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101798:	ee                   	out    %al,(%dx)
  101799:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  10179f:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017a3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017a7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017ab:	ee                   	out    %al,(%dx)
  1017ac:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017b2:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017b6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017ba:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017be:	ee                   	out    %al,(%dx)
  1017bf:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017c5:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017c9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017cd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017d1:	ee                   	out    %al,(%dx)
  1017d2:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017d8:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017dc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017e4:	ee                   	out    %al,(%dx)
  1017e5:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017eb:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017ef:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017f3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f7:	ee                   	out    %al,(%dx)
  1017f8:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  1017fe:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101802:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101806:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10180a:	ee                   	out    %al,(%dx)
  10180b:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101811:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101815:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101819:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10181d:	ee                   	out    %al,(%dx)
  10181e:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101824:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101828:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10182c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101830:	ee                   	out    %al,(%dx)
  101831:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101837:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  10183b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10183f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101843:	ee                   	out    %al,(%dx)
  101844:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10184a:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  10184e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101852:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101856:	ee                   	out    %al,(%dx)
  101857:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10185d:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101861:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101865:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101869:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10186a:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101871:	66 83 f8 ff          	cmp    $0xffff,%ax
  101875:	74 12                	je     101889 <pic_init+0x139>
        pic_setmask(irq_mask);
  101877:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10187e:	0f b7 c0             	movzwl %ax,%eax
  101881:	89 04 24             	mov    %eax,(%esp)
  101884:	e8 41 fe ff ff       	call   1016ca <pic_setmask>
    }
}
  101889:	c9                   	leave  
  10188a:	c3                   	ret    

0010188b <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10188b:	55                   	push   %ebp
  10188c:	89 e5                	mov    %esp,%ebp
  10188e:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101891:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101898:	00 
  101899:	c7 04 24 40 61 10 00 	movl   $0x106140,(%esp)
  1018a0:	e8 a3 ea ff ff       	call   100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018a5:	c9                   	leave  
  1018a6:	c3                   	ret    

001018a7 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018a7:	55                   	push   %ebp
  1018a8:	89 e5                	mov    %esp,%ebp
  1018aa:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
extern uintptr_t __vectors[];
int i; 
for(i=0; i<256; i++)
  1018ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018b4:	e9 c3 00 00 00       	jmp    10197c <idt_init+0xd5>
 {
 SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  1018b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bc:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018c3:	89 c2                	mov    %eax,%edx
  1018c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c8:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018cf:	00 
  1018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d3:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018da:	00 08 00 
  1018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e0:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018e7:	00 
  1018e8:	83 e2 e0             	and    $0xffffffe0,%edx
  1018eb:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f5:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018fc:	00 
  1018fd:	83 e2 1f             	and    $0x1f,%edx
  101900:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101907:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190a:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101911:	00 
  101912:	83 e2 f0             	and    $0xfffffff0,%edx
  101915:	83 ca 0e             	or     $0xe,%edx
  101918:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10191f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101922:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101929:	00 
  10192a:	83 e2 ef             	and    $0xffffffef,%edx
  10192d:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101934:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101937:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10193e:	00 
  10193f:	83 e2 9f             	and    $0xffffff9f,%edx
  101942:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101949:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194c:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101953:	00 
  101954:	83 ca 80             	or     $0xffffff80,%edx
  101957:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10195e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101961:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101968:	c1 e8 10             	shr    $0x10,%eax
  10196b:	89 c2                	mov    %eax,%edx
  10196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101970:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  101977:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
extern uintptr_t __vectors[];
int i; 
for(i=0; i<256; i++)
  101978:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10197c:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101983:	0f 8e 30 ff ff ff    	jle    1018b9 <idt_init+0x12>
 {
 SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
 
 }
 SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK],
  101989:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  10198e:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  101994:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  10199b:	08 00 
  10199d:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019a4:	83 e0 e0             	and    $0xffffffe0,%eax
  1019a7:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019ac:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019b3:	83 e0 1f             	and    $0x1f,%eax
  1019b6:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019bb:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019c2:	83 e0 f0             	and    $0xfffffff0,%eax
  1019c5:	83 c8 0e             	or     $0xe,%eax
  1019c8:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019cd:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019d4:	83 e0 ef             	and    $0xffffffef,%eax
  1019d7:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019dc:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019e3:	83 c8 60             	or     $0x60,%eax
  1019e6:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019eb:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019f2:	83 c8 80             	or     $0xffffff80,%eax
  1019f5:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019fa:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019ff:	c1 e8 10             	shr    $0x10,%eax
  101a02:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a08:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a12:	0f 01 18             	lidtl  (%eax)
DPL_USER);
 
 lidt(&idt_pd);
 
}
  101a15:	c9                   	leave  
  101a16:	c3                   	ret    

00101a17 <trapname>:

static const char *
trapname(int trapno) {
  101a17:	55                   	push   %ebp
  101a18:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1d:	83 f8 13             	cmp    $0x13,%eax
  101a20:	77 0c                	ja     101a2e <trapname+0x17>
        return excnames[trapno];
  101a22:	8b 45 08             	mov    0x8(%ebp),%eax
  101a25:	8b 04 85 a0 64 10 00 	mov    0x1064a0(,%eax,4),%eax
  101a2c:	eb 18                	jmp    101a46 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a2e:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a32:	7e 0d                	jle    101a41 <trapname+0x2a>
  101a34:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a38:	7f 07                	jg     101a41 <trapname+0x2a>
        return "Hardware Interrupt";
  101a3a:	b8 4a 61 10 00       	mov    $0x10614a,%eax
  101a3f:	eb 05                	jmp    101a46 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a41:	b8 5d 61 10 00       	mov    $0x10615d,%eax
}
  101a46:	5d                   	pop    %ebp
  101a47:	c3                   	ret    

00101a48 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a48:	55                   	push   %ebp
  101a49:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a52:	66 83 f8 08          	cmp    $0x8,%ax
  101a56:	0f 94 c0             	sete   %al
  101a59:	0f b6 c0             	movzbl %al,%eax
}
  101a5c:	5d                   	pop    %ebp
  101a5d:	c3                   	ret    

00101a5e <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a5e:	55                   	push   %ebp
  101a5f:	89 e5                	mov    %esp,%ebp
  101a61:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a64:	8b 45 08             	mov    0x8(%ebp),%eax
  101a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6b:	c7 04 24 9e 61 10 00 	movl   $0x10619e,(%esp)
  101a72:	e8 d1 e8 ff ff       	call   100348 <cprintf>
    print_regs(&tf->tf_regs);
  101a77:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7a:	89 04 24             	mov    %eax,(%esp)
  101a7d:	e8 a1 01 00 00       	call   101c23 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a82:	8b 45 08             	mov    0x8(%ebp),%eax
  101a85:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a89:	0f b7 c0             	movzwl %ax,%eax
  101a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a90:	c7 04 24 af 61 10 00 	movl   $0x1061af,(%esp)
  101a97:	e8 ac e8 ff ff       	call   100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a9f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aa3:	0f b7 c0             	movzwl %ax,%eax
  101aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aaa:	c7 04 24 c2 61 10 00 	movl   $0x1061c2,(%esp)
  101ab1:	e8 92 e8 ff ff       	call   100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101abd:	0f b7 c0             	movzwl %ax,%eax
  101ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac4:	c7 04 24 d5 61 10 00 	movl   $0x1061d5,(%esp)
  101acb:	e8 78 e8 ff ff       	call   100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad3:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ad7:	0f b7 c0             	movzwl %ax,%eax
  101ada:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ade:	c7 04 24 e8 61 10 00 	movl   $0x1061e8,(%esp)
  101ae5:	e8 5e e8 ff ff       	call   100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101aea:	8b 45 08             	mov    0x8(%ebp),%eax
  101aed:	8b 40 30             	mov    0x30(%eax),%eax
  101af0:	89 04 24             	mov    %eax,(%esp)
  101af3:	e8 1f ff ff ff       	call   101a17 <trapname>
  101af8:	8b 55 08             	mov    0x8(%ebp),%edx
  101afb:	8b 52 30             	mov    0x30(%edx),%edx
  101afe:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b02:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b06:	c7 04 24 fb 61 10 00 	movl   $0x1061fb,(%esp)
  101b0d:	e8 36 e8 ff ff       	call   100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b12:	8b 45 08             	mov    0x8(%ebp),%eax
  101b15:	8b 40 34             	mov    0x34(%eax),%eax
  101b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1c:	c7 04 24 0d 62 10 00 	movl   $0x10620d,(%esp)
  101b23:	e8 20 e8 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b28:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2b:	8b 40 38             	mov    0x38(%eax),%eax
  101b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b32:	c7 04 24 1c 62 10 00 	movl   $0x10621c,(%esp)
  101b39:	e8 0a e8 ff ff       	call   100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b41:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b45:	0f b7 c0             	movzwl %ax,%eax
  101b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4c:	c7 04 24 2b 62 10 00 	movl   $0x10622b,(%esp)
  101b53:	e8 f0 e7 ff ff       	call   100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	8b 40 40             	mov    0x40(%eax),%eax
  101b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b62:	c7 04 24 3e 62 10 00 	movl   $0x10623e,(%esp)
  101b69:	e8 da e7 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b75:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b7c:	eb 3e                	jmp    101bbc <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b81:	8b 50 40             	mov    0x40(%eax),%edx
  101b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b87:	21 d0                	and    %edx,%eax
  101b89:	85 c0                	test   %eax,%eax
  101b8b:	74 28                	je     101bb5 <print_trapframe+0x157>
  101b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b90:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b97:	85 c0                	test   %eax,%eax
  101b99:	74 1a                	je     101bb5 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b9e:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba9:	c7 04 24 4d 62 10 00 	movl   $0x10624d,(%esp)
  101bb0:	e8 93 e7 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bb9:	d1 65 f0             	shll   -0x10(%ebp)
  101bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bbf:	83 f8 17             	cmp    $0x17,%eax
  101bc2:	76 ba                	jbe    101b7e <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc7:	8b 40 40             	mov    0x40(%eax),%eax
  101bca:	25 00 30 00 00       	and    $0x3000,%eax
  101bcf:	c1 e8 0c             	shr    $0xc,%eax
  101bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd6:	c7 04 24 51 62 10 00 	movl   $0x106251,(%esp)
  101bdd:	e8 66 e7 ff ff       	call   100348 <cprintf>

    if (!trap_in_kernel(tf)) {
  101be2:	8b 45 08             	mov    0x8(%ebp),%eax
  101be5:	89 04 24             	mov    %eax,(%esp)
  101be8:	e8 5b fe ff ff       	call   101a48 <trap_in_kernel>
  101bed:	85 c0                	test   %eax,%eax
  101bef:	75 30                	jne    101c21 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf4:	8b 40 44             	mov    0x44(%eax),%eax
  101bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfb:	c7 04 24 5a 62 10 00 	movl   $0x10625a,(%esp)
  101c02:	e8 41 e7 ff ff       	call   100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c07:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0a:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c0e:	0f b7 c0             	movzwl %ax,%eax
  101c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c15:	c7 04 24 69 62 10 00 	movl   $0x106269,(%esp)
  101c1c:	e8 27 e7 ff ff       	call   100348 <cprintf>
    }
}
  101c21:	c9                   	leave  
  101c22:	c3                   	ret    

00101c23 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c23:	55                   	push   %ebp
  101c24:	89 e5                	mov    %esp,%ebp
  101c26:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c29:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2c:	8b 00                	mov    (%eax),%eax
  101c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c32:	c7 04 24 7c 62 10 00 	movl   $0x10627c,(%esp)
  101c39:	e8 0a e7 ff ff       	call   100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c41:	8b 40 04             	mov    0x4(%eax),%eax
  101c44:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c48:	c7 04 24 8b 62 10 00 	movl   $0x10628b,(%esp)
  101c4f:	e8 f4 e6 ff ff       	call   100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c54:	8b 45 08             	mov    0x8(%ebp),%eax
  101c57:	8b 40 08             	mov    0x8(%eax),%eax
  101c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5e:	c7 04 24 9a 62 10 00 	movl   $0x10629a,(%esp)
  101c65:	e8 de e6 ff ff       	call   100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6d:	8b 40 0c             	mov    0xc(%eax),%eax
  101c70:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c74:	c7 04 24 a9 62 10 00 	movl   $0x1062a9,(%esp)
  101c7b:	e8 c8 e6 ff ff       	call   100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c80:	8b 45 08             	mov    0x8(%ebp),%eax
  101c83:	8b 40 10             	mov    0x10(%eax),%eax
  101c86:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c8a:	c7 04 24 b8 62 10 00 	movl   $0x1062b8,(%esp)
  101c91:	e8 b2 e6 ff ff       	call   100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c96:	8b 45 08             	mov    0x8(%ebp),%eax
  101c99:	8b 40 14             	mov    0x14(%eax),%eax
  101c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca0:	c7 04 24 c7 62 10 00 	movl   $0x1062c7,(%esp)
  101ca7:	e8 9c e6 ff ff       	call   100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cac:	8b 45 08             	mov    0x8(%ebp),%eax
  101caf:	8b 40 18             	mov    0x18(%eax),%eax
  101cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb6:	c7 04 24 d6 62 10 00 	movl   $0x1062d6,(%esp)
  101cbd:	e8 86 e6 ff ff       	call   100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc5:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ccc:	c7 04 24 e5 62 10 00 	movl   $0x1062e5,(%esp)
  101cd3:	e8 70 e6 ff ff       	call   100348 <cprintf>
}
  101cd8:	c9                   	leave  
  101cd9:	c3                   	ret    

00101cda <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cda:	55                   	push   %ebp
  101cdb:	89 e5                	mov    %esp,%ebp
  101cdd:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce3:	8b 40 30             	mov    0x30(%eax),%eax
  101ce6:	83 f8 2f             	cmp    $0x2f,%eax
  101ce9:	77 1e                	ja     101d09 <trap_dispatch+0x2f>
  101ceb:	83 f8 2e             	cmp    $0x2e,%eax
  101cee:	0f 83 bf 00 00 00    	jae    101db3 <trap_dispatch+0xd9>
  101cf4:	83 f8 21             	cmp    $0x21,%eax
  101cf7:	74 40                	je     101d39 <trap_dispatch+0x5f>
  101cf9:	83 f8 24             	cmp    $0x24,%eax
  101cfc:	74 15                	je     101d13 <trap_dispatch+0x39>
  101cfe:	83 f8 20             	cmp    $0x20,%eax
  101d01:	0f 84 af 00 00 00    	je     101db6 <trap_dispatch+0xdc>
  101d07:	eb 72                	jmp    101d7b <trap_dispatch+0xa1>
  101d09:	83 e8 78             	sub    $0x78,%eax
  101d0c:	83 f8 01             	cmp    $0x1,%eax
  101d0f:	77 6a                	ja     101d7b <trap_dispatch+0xa1>
  101d11:	eb 4c                	jmp    101d5f <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d13:	e8 37 f9 ff ff       	call   10164f <cons_getc>
  101d18:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d1b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d1f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d23:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d2b:	c7 04 24 f4 62 10 00 	movl   $0x1062f4,(%esp)
  101d32:	e8 11 e6 ff ff       	call   100348 <cprintf>
        break;
  101d37:	eb 7e                	jmp    101db7 <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d39:	e8 11 f9 ff ff       	call   10164f <cons_getc>
  101d3e:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d41:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d45:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d49:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d51:	c7 04 24 06 63 10 00 	movl   $0x106306,(%esp)
  101d58:	e8 eb e5 ff ff       	call   100348 <cprintf>
        break;
  101d5d:	eb 58                	jmp    101db7 <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d5f:	c7 44 24 08 15 63 10 	movl   $0x106315,0x8(%esp)
  101d66:	00 
  101d67:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  101d6e:	00 
  101d6f:	c7 04 24 25 63 10 00 	movl   $0x106325,(%esp)
  101d76:	e8 55 ef ff ff       	call   100cd0 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d7e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d82:	0f b7 c0             	movzwl %ax,%eax
  101d85:	83 e0 03             	and    $0x3,%eax
  101d88:	85 c0                	test   %eax,%eax
  101d8a:	75 2b                	jne    101db7 <trap_dispatch+0xdd>
            print_trapframe(tf);
  101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8f:	89 04 24             	mov    %eax,(%esp)
  101d92:	e8 c7 fc ff ff       	call   101a5e <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d97:	c7 44 24 08 36 63 10 	movl   $0x106336,0x8(%esp)
  101d9e:	00 
  101d9f:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  101da6:	00 
  101da7:	c7 04 24 25 63 10 00 	movl   $0x106325,(%esp)
  101dae:	e8 1d ef ff ff       	call   100cd0 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101db3:	90                   	nop
  101db4:	eb 01                	jmp    101db7 <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
  101db6:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101db7:	c9                   	leave  
  101db8:	c3                   	ret    

00101db9 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101db9:	55                   	push   %ebp
  101dba:	89 e5                	mov    %esp,%ebp
  101dbc:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc2:	89 04 24             	mov    %eax,(%esp)
  101dc5:	e8 10 ff ff ff       	call   101cda <trap_dispatch>
}
  101dca:	c9                   	leave  
  101dcb:	c3                   	ret    

00101dcc <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101dcc:	1e                   	push   %ds
    pushl %es
  101dcd:	06                   	push   %es
    pushl %fs
  101dce:	0f a0                	push   %fs
    pushl %gs
  101dd0:	0f a8                	push   %gs
    pushal
  101dd2:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101dd3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101dd8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101dda:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101ddc:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101ddd:	e8 d7 ff ff ff       	call   101db9 <trap>

    # pop the pushed stack pointer
    popl %esp
  101de2:	5c                   	pop    %esp

00101de3 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101de3:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101de4:	0f a9                	pop    %gs
    popl %fs
  101de6:	0f a1                	pop    %fs
    popl %es
  101de8:	07                   	pop    %es
    popl %ds
  101de9:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101dea:	83 c4 08             	add    $0x8,%esp
    iret
  101ded:	cf                   	iret   

00101dee <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101dee:	6a 00                	push   $0x0
  pushl $0
  101df0:	6a 00                	push   $0x0
  jmp __alltraps
  101df2:	e9 d5 ff ff ff       	jmp    101dcc <__alltraps>

00101df7 <vector1>:
.globl vector1
vector1:
  pushl $0
  101df7:	6a 00                	push   $0x0
  pushl $1
  101df9:	6a 01                	push   $0x1
  jmp __alltraps
  101dfb:	e9 cc ff ff ff       	jmp    101dcc <__alltraps>

00101e00 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e00:	6a 00                	push   $0x0
  pushl $2
  101e02:	6a 02                	push   $0x2
  jmp __alltraps
  101e04:	e9 c3 ff ff ff       	jmp    101dcc <__alltraps>

00101e09 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e09:	6a 00                	push   $0x0
  pushl $3
  101e0b:	6a 03                	push   $0x3
  jmp __alltraps
  101e0d:	e9 ba ff ff ff       	jmp    101dcc <__alltraps>

00101e12 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e12:	6a 00                	push   $0x0
  pushl $4
  101e14:	6a 04                	push   $0x4
  jmp __alltraps
  101e16:	e9 b1 ff ff ff       	jmp    101dcc <__alltraps>

00101e1b <vector5>:
.globl vector5
vector5:
  pushl $0
  101e1b:	6a 00                	push   $0x0
  pushl $5
  101e1d:	6a 05                	push   $0x5
  jmp __alltraps
  101e1f:	e9 a8 ff ff ff       	jmp    101dcc <__alltraps>

00101e24 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e24:	6a 00                	push   $0x0
  pushl $6
  101e26:	6a 06                	push   $0x6
  jmp __alltraps
  101e28:	e9 9f ff ff ff       	jmp    101dcc <__alltraps>

00101e2d <vector7>:
.globl vector7
vector7:
  pushl $0
  101e2d:	6a 00                	push   $0x0
  pushl $7
  101e2f:	6a 07                	push   $0x7
  jmp __alltraps
  101e31:	e9 96 ff ff ff       	jmp    101dcc <__alltraps>

00101e36 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e36:	6a 08                	push   $0x8
  jmp __alltraps
  101e38:	e9 8f ff ff ff       	jmp    101dcc <__alltraps>

00101e3d <vector9>:
.globl vector9
vector9:
  pushl $0
  101e3d:	6a 00                	push   $0x0
  pushl $9
  101e3f:	6a 09                	push   $0x9
  jmp __alltraps
  101e41:	e9 86 ff ff ff       	jmp    101dcc <__alltraps>

00101e46 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e46:	6a 0a                	push   $0xa
  jmp __alltraps
  101e48:	e9 7f ff ff ff       	jmp    101dcc <__alltraps>

00101e4d <vector11>:
.globl vector11
vector11:
  pushl $11
  101e4d:	6a 0b                	push   $0xb
  jmp __alltraps
  101e4f:	e9 78 ff ff ff       	jmp    101dcc <__alltraps>

00101e54 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e54:	6a 0c                	push   $0xc
  jmp __alltraps
  101e56:	e9 71 ff ff ff       	jmp    101dcc <__alltraps>

00101e5b <vector13>:
.globl vector13
vector13:
  pushl $13
  101e5b:	6a 0d                	push   $0xd
  jmp __alltraps
  101e5d:	e9 6a ff ff ff       	jmp    101dcc <__alltraps>

00101e62 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e62:	6a 0e                	push   $0xe
  jmp __alltraps
  101e64:	e9 63 ff ff ff       	jmp    101dcc <__alltraps>

00101e69 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e69:	6a 00                	push   $0x0
  pushl $15
  101e6b:	6a 0f                	push   $0xf
  jmp __alltraps
  101e6d:	e9 5a ff ff ff       	jmp    101dcc <__alltraps>

00101e72 <vector16>:
.globl vector16
vector16:
  pushl $0
  101e72:	6a 00                	push   $0x0
  pushl $16
  101e74:	6a 10                	push   $0x10
  jmp __alltraps
  101e76:	e9 51 ff ff ff       	jmp    101dcc <__alltraps>

00101e7b <vector17>:
.globl vector17
vector17:
  pushl $17
  101e7b:	6a 11                	push   $0x11
  jmp __alltraps
  101e7d:	e9 4a ff ff ff       	jmp    101dcc <__alltraps>

00101e82 <vector18>:
.globl vector18
vector18:
  pushl $0
  101e82:	6a 00                	push   $0x0
  pushl $18
  101e84:	6a 12                	push   $0x12
  jmp __alltraps
  101e86:	e9 41 ff ff ff       	jmp    101dcc <__alltraps>

00101e8b <vector19>:
.globl vector19
vector19:
  pushl $0
  101e8b:	6a 00                	push   $0x0
  pushl $19
  101e8d:	6a 13                	push   $0x13
  jmp __alltraps
  101e8f:	e9 38 ff ff ff       	jmp    101dcc <__alltraps>

00101e94 <vector20>:
.globl vector20
vector20:
  pushl $0
  101e94:	6a 00                	push   $0x0
  pushl $20
  101e96:	6a 14                	push   $0x14
  jmp __alltraps
  101e98:	e9 2f ff ff ff       	jmp    101dcc <__alltraps>

00101e9d <vector21>:
.globl vector21
vector21:
  pushl $0
  101e9d:	6a 00                	push   $0x0
  pushl $21
  101e9f:	6a 15                	push   $0x15
  jmp __alltraps
  101ea1:	e9 26 ff ff ff       	jmp    101dcc <__alltraps>

00101ea6 <vector22>:
.globl vector22
vector22:
  pushl $0
  101ea6:	6a 00                	push   $0x0
  pushl $22
  101ea8:	6a 16                	push   $0x16
  jmp __alltraps
  101eaa:	e9 1d ff ff ff       	jmp    101dcc <__alltraps>

00101eaf <vector23>:
.globl vector23
vector23:
  pushl $0
  101eaf:	6a 00                	push   $0x0
  pushl $23
  101eb1:	6a 17                	push   $0x17
  jmp __alltraps
  101eb3:	e9 14 ff ff ff       	jmp    101dcc <__alltraps>

00101eb8 <vector24>:
.globl vector24
vector24:
  pushl $0
  101eb8:	6a 00                	push   $0x0
  pushl $24
  101eba:	6a 18                	push   $0x18
  jmp __alltraps
  101ebc:	e9 0b ff ff ff       	jmp    101dcc <__alltraps>

00101ec1 <vector25>:
.globl vector25
vector25:
  pushl $0
  101ec1:	6a 00                	push   $0x0
  pushl $25
  101ec3:	6a 19                	push   $0x19
  jmp __alltraps
  101ec5:	e9 02 ff ff ff       	jmp    101dcc <__alltraps>

00101eca <vector26>:
.globl vector26
vector26:
  pushl $0
  101eca:	6a 00                	push   $0x0
  pushl $26
  101ecc:	6a 1a                	push   $0x1a
  jmp __alltraps
  101ece:	e9 f9 fe ff ff       	jmp    101dcc <__alltraps>

00101ed3 <vector27>:
.globl vector27
vector27:
  pushl $0
  101ed3:	6a 00                	push   $0x0
  pushl $27
  101ed5:	6a 1b                	push   $0x1b
  jmp __alltraps
  101ed7:	e9 f0 fe ff ff       	jmp    101dcc <__alltraps>

00101edc <vector28>:
.globl vector28
vector28:
  pushl $0
  101edc:	6a 00                	push   $0x0
  pushl $28
  101ede:	6a 1c                	push   $0x1c
  jmp __alltraps
  101ee0:	e9 e7 fe ff ff       	jmp    101dcc <__alltraps>

00101ee5 <vector29>:
.globl vector29
vector29:
  pushl $0
  101ee5:	6a 00                	push   $0x0
  pushl $29
  101ee7:	6a 1d                	push   $0x1d
  jmp __alltraps
  101ee9:	e9 de fe ff ff       	jmp    101dcc <__alltraps>

00101eee <vector30>:
.globl vector30
vector30:
  pushl $0
  101eee:	6a 00                	push   $0x0
  pushl $30
  101ef0:	6a 1e                	push   $0x1e
  jmp __alltraps
  101ef2:	e9 d5 fe ff ff       	jmp    101dcc <__alltraps>

00101ef7 <vector31>:
.globl vector31
vector31:
  pushl $0
  101ef7:	6a 00                	push   $0x0
  pushl $31
  101ef9:	6a 1f                	push   $0x1f
  jmp __alltraps
  101efb:	e9 cc fe ff ff       	jmp    101dcc <__alltraps>

00101f00 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f00:	6a 00                	push   $0x0
  pushl $32
  101f02:	6a 20                	push   $0x20
  jmp __alltraps
  101f04:	e9 c3 fe ff ff       	jmp    101dcc <__alltraps>

00101f09 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f09:	6a 00                	push   $0x0
  pushl $33
  101f0b:	6a 21                	push   $0x21
  jmp __alltraps
  101f0d:	e9 ba fe ff ff       	jmp    101dcc <__alltraps>

00101f12 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f12:	6a 00                	push   $0x0
  pushl $34
  101f14:	6a 22                	push   $0x22
  jmp __alltraps
  101f16:	e9 b1 fe ff ff       	jmp    101dcc <__alltraps>

00101f1b <vector35>:
.globl vector35
vector35:
  pushl $0
  101f1b:	6a 00                	push   $0x0
  pushl $35
  101f1d:	6a 23                	push   $0x23
  jmp __alltraps
  101f1f:	e9 a8 fe ff ff       	jmp    101dcc <__alltraps>

00101f24 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f24:	6a 00                	push   $0x0
  pushl $36
  101f26:	6a 24                	push   $0x24
  jmp __alltraps
  101f28:	e9 9f fe ff ff       	jmp    101dcc <__alltraps>

00101f2d <vector37>:
.globl vector37
vector37:
  pushl $0
  101f2d:	6a 00                	push   $0x0
  pushl $37
  101f2f:	6a 25                	push   $0x25
  jmp __alltraps
  101f31:	e9 96 fe ff ff       	jmp    101dcc <__alltraps>

00101f36 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f36:	6a 00                	push   $0x0
  pushl $38
  101f38:	6a 26                	push   $0x26
  jmp __alltraps
  101f3a:	e9 8d fe ff ff       	jmp    101dcc <__alltraps>

00101f3f <vector39>:
.globl vector39
vector39:
  pushl $0
  101f3f:	6a 00                	push   $0x0
  pushl $39
  101f41:	6a 27                	push   $0x27
  jmp __alltraps
  101f43:	e9 84 fe ff ff       	jmp    101dcc <__alltraps>

00101f48 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f48:	6a 00                	push   $0x0
  pushl $40
  101f4a:	6a 28                	push   $0x28
  jmp __alltraps
  101f4c:	e9 7b fe ff ff       	jmp    101dcc <__alltraps>

00101f51 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f51:	6a 00                	push   $0x0
  pushl $41
  101f53:	6a 29                	push   $0x29
  jmp __alltraps
  101f55:	e9 72 fe ff ff       	jmp    101dcc <__alltraps>

00101f5a <vector42>:
.globl vector42
vector42:
  pushl $0
  101f5a:	6a 00                	push   $0x0
  pushl $42
  101f5c:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f5e:	e9 69 fe ff ff       	jmp    101dcc <__alltraps>

00101f63 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f63:	6a 00                	push   $0x0
  pushl $43
  101f65:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f67:	e9 60 fe ff ff       	jmp    101dcc <__alltraps>

00101f6c <vector44>:
.globl vector44
vector44:
  pushl $0
  101f6c:	6a 00                	push   $0x0
  pushl $44
  101f6e:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f70:	e9 57 fe ff ff       	jmp    101dcc <__alltraps>

00101f75 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f75:	6a 00                	push   $0x0
  pushl $45
  101f77:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f79:	e9 4e fe ff ff       	jmp    101dcc <__alltraps>

00101f7e <vector46>:
.globl vector46
vector46:
  pushl $0
  101f7e:	6a 00                	push   $0x0
  pushl $46
  101f80:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f82:	e9 45 fe ff ff       	jmp    101dcc <__alltraps>

00101f87 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $47
  101f89:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f8b:	e9 3c fe ff ff       	jmp    101dcc <__alltraps>

00101f90 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $48
  101f92:	6a 30                	push   $0x30
  jmp __alltraps
  101f94:	e9 33 fe ff ff       	jmp    101dcc <__alltraps>

00101f99 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $49
  101f9b:	6a 31                	push   $0x31
  jmp __alltraps
  101f9d:	e9 2a fe ff ff       	jmp    101dcc <__alltraps>

00101fa2 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $50
  101fa4:	6a 32                	push   $0x32
  jmp __alltraps
  101fa6:	e9 21 fe ff ff       	jmp    101dcc <__alltraps>

00101fab <vector51>:
.globl vector51
vector51:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $51
  101fad:	6a 33                	push   $0x33
  jmp __alltraps
  101faf:	e9 18 fe ff ff       	jmp    101dcc <__alltraps>

00101fb4 <vector52>:
.globl vector52
vector52:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $52
  101fb6:	6a 34                	push   $0x34
  jmp __alltraps
  101fb8:	e9 0f fe ff ff       	jmp    101dcc <__alltraps>

00101fbd <vector53>:
.globl vector53
vector53:
  pushl $0
  101fbd:	6a 00                	push   $0x0
  pushl $53
  101fbf:	6a 35                	push   $0x35
  jmp __alltraps
  101fc1:	e9 06 fe ff ff       	jmp    101dcc <__alltraps>

00101fc6 <vector54>:
.globl vector54
vector54:
  pushl $0
  101fc6:	6a 00                	push   $0x0
  pushl $54
  101fc8:	6a 36                	push   $0x36
  jmp __alltraps
  101fca:	e9 fd fd ff ff       	jmp    101dcc <__alltraps>

00101fcf <vector55>:
.globl vector55
vector55:
  pushl $0
  101fcf:	6a 00                	push   $0x0
  pushl $55
  101fd1:	6a 37                	push   $0x37
  jmp __alltraps
  101fd3:	e9 f4 fd ff ff       	jmp    101dcc <__alltraps>

00101fd8 <vector56>:
.globl vector56
vector56:
  pushl $0
  101fd8:	6a 00                	push   $0x0
  pushl $56
  101fda:	6a 38                	push   $0x38
  jmp __alltraps
  101fdc:	e9 eb fd ff ff       	jmp    101dcc <__alltraps>

00101fe1 <vector57>:
.globl vector57
vector57:
  pushl $0
  101fe1:	6a 00                	push   $0x0
  pushl $57
  101fe3:	6a 39                	push   $0x39
  jmp __alltraps
  101fe5:	e9 e2 fd ff ff       	jmp    101dcc <__alltraps>

00101fea <vector58>:
.globl vector58
vector58:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $58
  101fec:	6a 3a                	push   $0x3a
  jmp __alltraps
  101fee:	e9 d9 fd ff ff       	jmp    101dcc <__alltraps>

00101ff3 <vector59>:
.globl vector59
vector59:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $59
  101ff5:	6a 3b                	push   $0x3b
  jmp __alltraps
  101ff7:	e9 d0 fd ff ff       	jmp    101dcc <__alltraps>

00101ffc <vector60>:
.globl vector60
vector60:
  pushl $0
  101ffc:	6a 00                	push   $0x0
  pushl $60
  101ffe:	6a 3c                	push   $0x3c
  jmp __alltraps
  102000:	e9 c7 fd ff ff       	jmp    101dcc <__alltraps>

00102005 <vector61>:
.globl vector61
vector61:
  pushl $0
  102005:	6a 00                	push   $0x0
  pushl $61
  102007:	6a 3d                	push   $0x3d
  jmp __alltraps
  102009:	e9 be fd ff ff       	jmp    101dcc <__alltraps>

0010200e <vector62>:
.globl vector62
vector62:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $62
  102010:	6a 3e                	push   $0x3e
  jmp __alltraps
  102012:	e9 b5 fd ff ff       	jmp    101dcc <__alltraps>

00102017 <vector63>:
.globl vector63
vector63:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $63
  102019:	6a 3f                	push   $0x3f
  jmp __alltraps
  10201b:	e9 ac fd ff ff       	jmp    101dcc <__alltraps>

00102020 <vector64>:
.globl vector64
vector64:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $64
  102022:	6a 40                	push   $0x40
  jmp __alltraps
  102024:	e9 a3 fd ff ff       	jmp    101dcc <__alltraps>

00102029 <vector65>:
.globl vector65
vector65:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $65
  10202b:	6a 41                	push   $0x41
  jmp __alltraps
  10202d:	e9 9a fd ff ff       	jmp    101dcc <__alltraps>

00102032 <vector66>:
.globl vector66
vector66:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $66
  102034:	6a 42                	push   $0x42
  jmp __alltraps
  102036:	e9 91 fd ff ff       	jmp    101dcc <__alltraps>

0010203b <vector67>:
.globl vector67
vector67:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $67
  10203d:	6a 43                	push   $0x43
  jmp __alltraps
  10203f:	e9 88 fd ff ff       	jmp    101dcc <__alltraps>

00102044 <vector68>:
.globl vector68
vector68:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $68
  102046:	6a 44                	push   $0x44
  jmp __alltraps
  102048:	e9 7f fd ff ff       	jmp    101dcc <__alltraps>

0010204d <vector69>:
.globl vector69
vector69:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $69
  10204f:	6a 45                	push   $0x45
  jmp __alltraps
  102051:	e9 76 fd ff ff       	jmp    101dcc <__alltraps>

00102056 <vector70>:
.globl vector70
vector70:
  pushl $0
  102056:	6a 00                	push   $0x0
  pushl $70
  102058:	6a 46                	push   $0x46
  jmp __alltraps
  10205a:	e9 6d fd ff ff       	jmp    101dcc <__alltraps>

0010205f <vector71>:
.globl vector71
vector71:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $71
  102061:	6a 47                	push   $0x47
  jmp __alltraps
  102063:	e9 64 fd ff ff       	jmp    101dcc <__alltraps>

00102068 <vector72>:
.globl vector72
vector72:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $72
  10206a:	6a 48                	push   $0x48
  jmp __alltraps
  10206c:	e9 5b fd ff ff       	jmp    101dcc <__alltraps>

00102071 <vector73>:
.globl vector73
vector73:
  pushl $0
  102071:	6a 00                	push   $0x0
  pushl $73
  102073:	6a 49                	push   $0x49
  jmp __alltraps
  102075:	e9 52 fd ff ff       	jmp    101dcc <__alltraps>

0010207a <vector74>:
.globl vector74
vector74:
  pushl $0
  10207a:	6a 00                	push   $0x0
  pushl $74
  10207c:	6a 4a                	push   $0x4a
  jmp __alltraps
  10207e:	e9 49 fd ff ff       	jmp    101dcc <__alltraps>

00102083 <vector75>:
.globl vector75
vector75:
  pushl $0
  102083:	6a 00                	push   $0x0
  pushl $75
  102085:	6a 4b                	push   $0x4b
  jmp __alltraps
  102087:	e9 40 fd ff ff       	jmp    101dcc <__alltraps>

0010208c <vector76>:
.globl vector76
vector76:
  pushl $0
  10208c:	6a 00                	push   $0x0
  pushl $76
  10208e:	6a 4c                	push   $0x4c
  jmp __alltraps
  102090:	e9 37 fd ff ff       	jmp    101dcc <__alltraps>

00102095 <vector77>:
.globl vector77
vector77:
  pushl $0
  102095:	6a 00                	push   $0x0
  pushl $77
  102097:	6a 4d                	push   $0x4d
  jmp __alltraps
  102099:	e9 2e fd ff ff       	jmp    101dcc <__alltraps>

0010209e <vector78>:
.globl vector78
vector78:
  pushl $0
  10209e:	6a 00                	push   $0x0
  pushl $78
  1020a0:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020a2:	e9 25 fd ff ff       	jmp    101dcc <__alltraps>

001020a7 <vector79>:
.globl vector79
vector79:
  pushl $0
  1020a7:	6a 00                	push   $0x0
  pushl $79
  1020a9:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020ab:	e9 1c fd ff ff       	jmp    101dcc <__alltraps>

001020b0 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $80
  1020b2:	6a 50                	push   $0x50
  jmp __alltraps
  1020b4:	e9 13 fd ff ff       	jmp    101dcc <__alltraps>

001020b9 <vector81>:
.globl vector81
vector81:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $81
  1020bb:	6a 51                	push   $0x51
  jmp __alltraps
  1020bd:	e9 0a fd ff ff       	jmp    101dcc <__alltraps>

001020c2 <vector82>:
.globl vector82
vector82:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $82
  1020c4:	6a 52                	push   $0x52
  jmp __alltraps
  1020c6:	e9 01 fd ff ff       	jmp    101dcc <__alltraps>

001020cb <vector83>:
.globl vector83
vector83:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $83
  1020cd:	6a 53                	push   $0x53
  jmp __alltraps
  1020cf:	e9 f8 fc ff ff       	jmp    101dcc <__alltraps>

001020d4 <vector84>:
.globl vector84
vector84:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $84
  1020d6:	6a 54                	push   $0x54
  jmp __alltraps
  1020d8:	e9 ef fc ff ff       	jmp    101dcc <__alltraps>

001020dd <vector85>:
.globl vector85
vector85:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $85
  1020df:	6a 55                	push   $0x55
  jmp __alltraps
  1020e1:	e9 e6 fc ff ff       	jmp    101dcc <__alltraps>

001020e6 <vector86>:
.globl vector86
vector86:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $86
  1020e8:	6a 56                	push   $0x56
  jmp __alltraps
  1020ea:	e9 dd fc ff ff       	jmp    101dcc <__alltraps>

001020ef <vector87>:
.globl vector87
vector87:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $87
  1020f1:	6a 57                	push   $0x57
  jmp __alltraps
  1020f3:	e9 d4 fc ff ff       	jmp    101dcc <__alltraps>

001020f8 <vector88>:
.globl vector88
vector88:
  pushl $0
  1020f8:	6a 00                	push   $0x0
  pushl $88
  1020fa:	6a 58                	push   $0x58
  jmp __alltraps
  1020fc:	e9 cb fc ff ff       	jmp    101dcc <__alltraps>

00102101 <vector89>:
.globl vector89
vector89:
  pushl $0
  102101:	6a 00                	push   $0x0
  pushl $89
  102103:	6a 59                	push   $0x59
  jmp __alltraps
  102105:	e9 c2 fc ff ff       	jmp    101dcc <__alltraps>

0010210a <vector90>:
.globl vector90
vector90:
  pushl $0
  10210a:	6a 00                	push   $0x0
  pushl $90
  10210c:	6a 5a                	push   $0x5a
  jmp __alltraps
  10210e:	e9 b9 fc ff ff       	jmp    101dcc <__alltraps>

00102113 <vector91>:
.globl vector91
vector91:
  pushl $0
  102113:	6a 00                	push   $0x0
  pushl $91
  102115:	6a 5b                	push   $0x5b
  jmp __alltraps
  102117:	e9 b0 fc ff ff       	jmp    101dcc <__alltraps>

0010211c <vector92>:
.globl vector92
vector92:
  pushl $0
  10211c:	6a 00                	push   $0x0
  pushl $92
  10211e:	6a 5c                	push   $0x5c
  jmp __alltraps
  102120:	e9 a7 fc ff ff       	jmp    101dcc <__alltraps>

00102125 <vector93>:
.globl vector93
vector93:
  pushl $0
  102125:	6a 00                	push   $0x0
  pushl $93
  102127:	6a 5d                	push   $0x5d
  jmp __alltraps
  102129:	e9 9e fc ff ff       	jmp    101dcc <__alltraps>

0010212e <vector94>:
.globl vector94
vector94:
  pushl $0
  10212e:	6a 00                	push   $0x0
  pushl $94
  102130:	6a 5e                	push   $0x5e
  jmp __alltraps
  102132:	e9 95 fc ff ff       	jmp    101dcc <__alltraps>

00102137 <vector95>:
.globl vector95
vector95:
  pushl $0
  102137:	6a 00                	push   $0x0
  pushl $95
  102139:	6a 5f                	push   $0x5f
  jmp __alltraps
  10213b:	e9 8c fc ff ff       	jmp    101dcc <__alltraps>

00102140 <vector96>:
.globl vector96
vector96:
  pushl $0
  102140:	6a 00                	push   $0x0
  pushl $96
  102142:	6a 60                	push   $0x60
  jmp __alltraps
  102144:	e9 83 fc ff ff       	jmp    101dcc <__alltraps>

00102149 <vector97>:
.globl vector97
vector97:
  pushl $0
  102149:	6a 00                	push   $0x0
  pushl $97
  10214b:	6a 61                	push   $0x61
  jmp __alltraps
  10214d:	e9 7a fc ff ff       	jmp    101dcc <__alltraps>

00102152 <vector98>:
.globl vector98
vector98:
  pushl $0
  102152:	6a 00                	push   $0x0
  pushl $98
  102154:	6a 62                	push   $0x62
  jmp __alltraps
  102156:	e9 71 fc ff ff       	jmp    101dcc <__alltraps>

0010215b <vector99>:
.globl vector99
vector99:
  pushl $0
  10215b:	6a 00                	push   $0x0
  pushl $99
  10215d:	6a 63                	push   $0x63
  jmp __alltraps
  10215f:	e9 68 fc ff ff       	jmp    101dcc <__alltraps>

00102164 <vector100>:
.globl vector100
vector100:
  pushl $0
  102164:	6a 00                	push   $0x0
  pushl $100
  102166:	6a 64                	push   $0x64
  jmp __alltraps
  102168:	e9 5f fc ff ff       	jmp    101dcc <__alltraps>

0010216d <vector101>:
.globl vector101
vector101:
  pushl $0
  10216d:	6a 00                	push   $0x0
  pushl $101
  10216f:	6a 65                	push   $0x65
  jmp __alltraps
  102171:	e9 56 fc ff ff       	jmp    101dcc <__alltraps>

00102176 <vector102>:
.globl vector102
vector102:
  pushl $0
  102176:	6a 00                	push   $0x0
  pushl $102
  102178:	6a 66                	push   $0x66
  jmp __alltraps
  10217a:	e9 4d fc ff ff       	jmp    101dcc <__alltraps>

0010217f <vector103>:
.globl vector103
vector103:
  pushl $0
  10217f:	6a 00                	push   $0x0
  pushl $103
  102181:	6a 67                	push   $0x67
  jmp __alltraps
  102183:	e9 44 fc ff ff       	jmp    101dcc <__alltraps>

00102188 <vector104>:
.globl vector104
vector104:
  pushl $0
  102188:	6a 00                	push   $0x0
  pushl $104
  10218a:	6a 68                	push   $0x68
  jmp __alltraps
  10218c:	e9 3b fc ff ff       	jmp    101dcc <__alltraps>

00102191 <vector105>:
.globl vector105
vector105:
  pushl $0
  102191:	6a 00                	push   $0x0
  pushl $105
  102193:	6a 69                	push   $0x69
  jmp __alltraps
  102195:	e9 32 fc ff ff       	jmp    101dcc <__alltraps>

0010219a <vector106>:
.globl vector106
vector106:
  pushl $0
  10219a:	6a 00                	push   $0x0
  pushl $106
  10219c:	6a 6a                	push   $0x6a
  jmp __alltraps
  10219e:	e9 29 fc ff ff       	jmp    101dcc <__alltraps>

001021a3 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021a3:	6a 00                	push   $0x0
  pushl $107
  1021a5:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021a7:	e9 20 fc ff ff       	jmp    101dcc <__alltraps>

001021ac <vector108>:
.globl vector108
vector108:
  pushl $0
  1021ac:	6a 00                	push   $0x0
  pushl $108
  1021ae:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021b0:	e9 17 fc ff ff       	jmp    101dcc <__alltraps>

001021b5 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021b5:	6a 00                	push   $0x0
  pushl $109
  1021b7:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021b9:	e9 0e fc ff ff       	jmp    101dcc <__alltraps>

001021be <vector110>:
.globl vector110
vector110:
  pushl $0
  1021be:	6a 00                	push   $0x0
  pushl $110
  1021c0:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021c2:	e9 05 fc ff ff       	jmp    101dcc <__alltraps>

001021c7 <vector111>:
.globl vector111
vector111:
  pushl $0
  1021c7:	6a 00                	push   $0x0
  pushl $111
  1021c9:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021cb:	e9 fc fb ff ff       	jmp    101dcc <__alltraps>

001021d0 <vector112>:
.globl vector112
vector112:
  pushl $0
  1021d0:	6a 00                	push   $0x0
  pushl $112
  1021d2:	6a 70                	push   $0x70
  jmp __alltraps
  1021d4:	e9 f3 fb ff ff       	jmp    101dcc <__alltraps>

001021d9 <vector113>:
.globl vector113
vector113:
  pushl $0
  1021d9:	6a 00                	push   $0x0
  pushl $113
  1021db:	6a 71                	push   $0x71
  jmp __alltraps
  1021dd:	e9 ea fb ff ff       	jmp    101dcc <__alltraps>

001021e2 <vector114>:
.globl vector114
vector114:
  pushl $0
  1021e2:	6a 00                	push   $0x0
  pushl $114
  1021e4:	6a 72                	push   $0x72
  jmp __alltraps
  1021e6:	e9 e1 fb ff ff       	jmp    101dcc <__alltraps>

001021eb <vector115>:
.globl vector115
vector115:
  pushl $0
  1021eb:	6a 00                	push   $0x0
  pushl $115
  1021ed:	6a 73                	push   $0x73
  jmp __alltraps
  1021ef:	e9 d8 fb ff ff       	jmp    101dcc <__alltraps>

001021f4 <vector116>:
.globl vector116
vector116:
  pushl $0
  1021f4:	6a 00                	push   $0x0
  pushl $116
  1021f6:	6a 74                	push   $0x74
  jmp __alltraps
  1021f8:	e9 cf fb ff ff       	jmp    101dcc <__alltraps>

001021fd <vector117>:
.globl vector117
vector117:
  pushl $0
  1021fd:	6a 00                	push   $0x0
  pushl $117
  1021ff:	6a 75                	push   $0x75
  jmp __alltraps
  102201:	e9 c6 fb ff ff       	jmp    101dcc <__alltraps>

00102206 <vector118>:
.globl vector118
vector118:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $118
  102208:	6a 76                	push   $0x76
  jmp __alltraps
  10220a:	e9 bd fb ff ff       	jmp    101dcc <__alltraps>

0010220f <vector119>:
.globl vector119
vector119:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $119
  102211:	6a 77                	push   $0x77
  jmp __alltraps
  102213:	e9 b4 fb ff ff       	jmp    101dcc <__alltraps>

00102218 <vector120>:
.globl vector120
vector120:
  pushl $0
  102218:	6a 00                	push   $0x0
  pushl $120
  10221a:	6a 78                	push   $0x78
  jmp __alltraps
  10221c:	e9 ab fb ff ff       	jmp    101dcc <__alltraps>

00102221 <vector121>:
.globl vector121
vector121:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $121
  102223:	6a 79                	push   $0x79
  jmp __alltraps
  102225:	e9 a2 fb ff ff       	jmp    101dcc <__alltraps>

0010222a <vector122>:
.globl vector122
vector122:
  pushl $0
  10222a:	6a 00                	push   $0x0
  pushl $122
  10222c:	6a 7a                	push   $0x7a
  jmp __alltraps
  10222e:	e9 99 fb ff ff       	jmp    101dcc <__alltraps>

00102233 <vector123>:
.globl vector123
vector123:
  pushl $0
  102233:	6a 00                	push   $0x0
  pushl $123
  102235:	6a 7b                	push   $0x7b
  jmp __alltraps
  102237:	e9 90 fb ff ff       	jmp    101dcc <__alltraps>

0010223c <vector124>:
.globl vector124
vector124:
  pushl $0
  10223c:	6a 00                	push   $0x0
  pushl $124
  10223e:	6a 7c                	push   $0x7c
  jmp __alltraps
  102240:	e9 87 fb ff ff       	jmp    101dcc <__alltraps>

00102245 <vector125>:
.globl vector125
vector125:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $125
  102247:	6a 7d                	push   $0x7d
  jmp __alltraps
  102249:	e9 7e fb ff ff       	jmp    101dcc <__alltraps>

0010224e <vector126>:
.globl vector126
vector126:
  pushl $0
  10224e:	6a 00                	push   $0x0
  pushl $126
  102250:	6a 7e                	push   $0x7e
  jmp __alltraps
  102252:	e9 75 fb ff ff       	jmp    101dcc <__alltraps>

00102257 <vector127>:
.globl vector127
vector127:
  pushl $0
  102257:	6a 00                	push   $0x0
  pushl $127
  102259:	6a 7f                	push   $0x7f
  jmp __alltraps
  10225b:	e9 6c fb ff ff       	jmp    101dcc <__alltraps>

00102260 <vector128>:
.globl vector128
vector128:
  pushl $0
  102260:	6a 00                	push   $0x0
  pushl $128
  102262:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102267:	e9 60 fb ff ff       	jmp    101dcc <__alltraps>

0010226c <vector129>:
.globl vector129
vector129:
  pushl $0
  10226c:	6a 00                	push   $0x0
  pushl $129
  10226e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102273:	e9 54 fb ff ff       	jmp    101dcc <__alltraps>

00102278 <vector130>:
.globl vector130
vector130:
  pushl $0
  102278:	6a 00                	push   $0x0
  pushl $130
  10227a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10227f:	e9 48 fb ff ff       	jmp    101dcc <__alltraps>

00102284 <vector131>:
.globl vector131
vector131:
  pushl $0
  102284:	6a 00                	push   $0x0
  pushl $131
  102286:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10228b:	e9 3c fb ff ff       	jmp    101dcc <__alltraps>

00102290 <vector132>:
.globl vector132
vector132:
  pushl $0
  102290:	6a 00                	push   $0x0
  pushl $132
  102292:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102297:	e9 30 fb ff ff       	jmp    101dcc <__alltraps>

0010229c <vector133>:
.globl vector133
vector133:
  pushl $0
  10229c:	6a 00                	push   $0x0
  pushl $133
  10229e:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022a3:	e9 24 fb ff ff       	jmp    101dcc <__alltraps>

001022a8 <vector134>:
.globl vector134
vector134:
  pushl $0
  1022a8:	6a 00                	push   $0x0
  pushl $134
  1022aa:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022af:	e9 18 fb ff ff       	jmp    101dcc <__alltraps>

001022b4 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022b4:	6a 00                	push   $0x0
  pushl $135
  1022b6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022bb:	e9 0c fb ff ff       	jmp    101dcc <__alltraps>

001022c0 <vector136>:
.globl vector136
vector136:
  pushl $0
  1022c0:	6a 00                	push   $0x0
  pushl $136
  1022c2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022c7:	e9 00 fb ff ff       	jmp    101dcc <__alltraps>

001022cc <vector137>:
.globl vector137
vector137:
  pushl $0
  1022cc:	6a 00                	push   $0x0
  pushl $137
  1022ce:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1022d3:	e9 f4 fa ff ff       	jmp    101dcc <__alltraps>

001022d8 <vector138>:
.globl vector138
vector138:
  pushl $0
  1022d8:	6a 00                	push   $0x0
  pushl $138
  1022da:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022df:	e9 e8 fa ff ff       	jmp    101dcc <__alltraps>

001022e4 <vector139>:
.globl vector139
vector139:
  pushl $0
  1022e4:	6a 00                	push   $0x0
  pushl $139
  1022e6:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1022eb:	e9 dc fa ff ff       	jmp    101dcc <__alltraps>

001022f0 <vector140>:
.globl vector140
vector140:
  pushl $0
  1022f0:	6a 00                	push   $0x0
  pushl $140
  1022f2:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022f7:	e9 d0 fa ff ff       	jmp    101dcc <__alltraps>

001022fc <vector141>:
.globl vector141
vector141:
  pushl $0
  1022fc:	6a 00                	push   $0x0
  pushl $141
  1022fe:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102303:	e9 c4 fa ff ff       	jmp    101dcc <__alltraps>

00102308 <vector142>:
.globl vector142
vector142:
  pushl $0
  102308:	6a 00                	push   $0x0
  pushl $142
  10230a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10230f:	e9 b8 fa ff ff       	jmp    101dcc <__alltraps>

00102314 <vector143>:
.globl vector143
vector143:
  pushl $0
  102314:	6a 00                	push   $0x0
  pushl $143
  102316:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10231b:	e9 ac fa ff ff       	jmp    101dcc <__alltraps>

00102320 <vector144>:
.globl vector144
vector144:
  pushl $0
  102320:	6a 00                	push   $0x0
  pushl $144
  102322:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102327:	e9 a0 fa ff ff       	jmp    101dcc <__alltraps>

0010232c <vector145>:
.globl vector145
vector145:
  pushl $0
  10232c:	6a 00                	push   $0x0
  pushl $145
  10232e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102333:	e9 94 fa ff ff       	jmp    101dcc <__alltraps>

00102338 <vector146>:
.globl vector146
vector146:
  pushl $0
  102338:	6a 00                	push   $0x0
  pushl $146
  10233a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10233f:	e9 88 fa ff ff       	jmp    101dcc <__alltraps>

00102344 <vector147>:
.globl vector147
vector147:
  pushl $0
  102344:	6a 00                	push   $0x0
  pushl $147
  102346:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10234b:	e9 7c fa ff ff       	jmp    101dcc <__alltraps>

00102350 <vector148>:
.globl vector148
vector148:
  pushl $0
  102350:	6a 00                	push   $0x0
  pushl $148
  102352:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102357:	e9 70 fa ff ff       	jmp    101dcc <__alltraps>

0010235c <vector149>:
.globl vector149
vector149:
  pushl $0
  10235c:	6a 00                	push   $0x0
  pushl $149
  10235e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102363:	e9 64 fa ff ff       	jmp    101dcc <__alltraps>

00102368 <vector150>:
.globl vector150
vector150:
  pushl $0
  102368:	6a 00                	push   $0x0
  pushl $150
  10236a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10236f:	e9 58 fa ff ff       	jmp    101dcc <__alltraps>

00102374 <vector151>:
.globl vector151
vector151:
  pushl $0
  102374:	6a 00                	push   $0x0
  pushl $151
  102376:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10237b:	e9 4c fa ff ff       	jmp    101dcc <__alltraps>

00102380 <vector152>:
.globl vector152
vector152:
  pushl $0
  102380:	6a 00                	push   $0x0
  pushl $152
  102382:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102387:	e9 40 fa ff ff       	jmp    101dcc <__alltraps>

0010238c <vector153>:
.globl vector153
vector153:
  pushl $0
  10238c:	6a 00                	push   $0x0
  pushl $153
  10238e:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102393:	e9 34 fa ff ff       	jmp    101dcc <__alltraps>

00102398 <vector154>:
.globl vector154
vector154:
  pushl $0
  102398:	6a 00                	push   $0x0
  pushl $154
  10239a:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10239f:	e9 28 fa ff ff       	jmp    101dcc <__alltraps>

001023a4 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023a4:	6a 00                	push   $0x0
  pushl $155
  1023a6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023ab:	e9 1c fa ff ff       	jmp    101dcc <__alltraps>

001023b0 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023b0:	6a 00                	push   $0x0
  pushl $156
  1023b2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023b7:	e9 10 fa ff ff       	jmp    101dcc <__alltraps>

001023bc <vector157>:
.globl vector157
vector157:
  pushl $0
  1023bc:	6a 00                	push   $0x0
  pushl $157
  1023be:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023c3:	e9 04 fa ff ff       	jmp    101dcc <__alltraps>

001023c8 <vector158>:
.globl vector158
vector158:
  pushl $0
  1023c8:	6a 00                	push   $0x0
  pushl $158
  1023ca:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1023cf:	e9 f8 f9 ff ff       	jmp    101dcc <__alltraps>

001023d4 <vector159>:
.globl vector159
vector159:
  pushl $0
  1023d4:	6a 00                	push   $0x0
  pushl $159
  1023d6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1023db:	e9 ec f9 ff ff       	jmp    101dcc <__alltraps>

001023e0 <vector160>:
.globl vector160
vector160:
  pushl $0
  1023e0:	6a 00                	push   $0x0
  pushl $160
  1023e2:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1023e7:	e9 e0 f9 ff ff       	jmp    101dcc <__alltraps>

001023ec <vector161>:
.globl vector161
vector161:
  pushl $0
  1023ec:	6a 00                	push   $0x0
  pushl $161
  1023ee:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1023f3:	e9 d4 f9 ff ff       	jmp    101dcc <__alltraps>

001023f8 <vector162>:
.globl vector162
vector162:
  pushl $0
  1023f8:	6a 00                	push   $0x0
  pushl $162
  1023fa:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023ff:	e9 c8 f9 ff ff       	jmp    101dcc <__alltraps>

00102404 <vector163>:
.globl vector163
vector163:
  pushl $0
  102404:	6a 00                	push   $0x0
  pushl $163
  102406:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10240b:	e9 bc f9 ff ff       	jmp    101dcc <__alltraps>

00102410 <vector164>:
.globl vector164
vector164:
  pushl $0
  102410:	6a 00                	push   $0x0
  pushl $164
  102412:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102417:	e9 b0 f9 ff ff       	jmp    101dcc <__alltraps>

0010241c <vector165>:
.globl vector165
vector165:
  pushl $0
  10241c:	6a 00                	push   $0x0
  pushl $165
  10241e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102423:	e9 a4 f9 ff ff       	jmp    101dcc <__alltraps>

00102428 <vector166>:
.globl vector166
vector166:
  pushl $0
  102428:	6a 00                	push   $0x0
  pushl $166
  10242a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10242f:	e9 98 f9 ff ff       	jmp    101dcc <__alltraps>

00102434 <vector167>:
.globl vector167
vector167:
  pushl $0
  102434:	6a 00                	push   $0x0
  pushl $167
  102436:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10243b:	e9 8c f9 ff ff       	jmp    101dcc <__alltraps>

00102440 <vector168>:
.globl vector168
vector168:
  pushl $0
  102440:	6a 00                	push   $0x0
  pushl $168
  102442:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102447:	e9 80 f9 ff ff       	jmp    101dcc <__alltraps>

0010244c <vector169>:
.globl vector169
vector169:
  pushl $0
  10244c:	6a 00                	push   $0x0
  pushl $169
  10244e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102453:	e9 74 f9 ff ff       	jmp    101dcc <__alltraps>

00102458 <vector170>:
.globl vector170
vector170:
  pushl $0
  102458:	6a 00                	push   $0x0
  pushl $170
  10245a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10245f:	e9 68 f9 ff ff       	jmp    101dcc <__alltraps>

00102464 <vector171>:
.globl vector171
vector171:
  pushl $0
  102464:	6a 00                	push   $0x0
  pushl $171
  102466:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10246b:	e9 5c f9 ff ff       	jmp    101dcc <__alltraps>

00102470 <vector172>:
.globl vector172
vector172:
  pushl $0
  102470:	6a 00                	push   $0x0
  pushl $172
  102472:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102477:	e9 50 f9 ff ff       	jmp    101dcc <__alltraps>

0010247c <vector173>:
.globl vector173
vector173:
  pushl $0
  10247c:	6a 00                	push   $0x0
  pushl $173
  10247e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102483:	e9 44 f9 ff ff       	jmp    101dcc <__alltraps>

00102488 <vector174>:
.globl vector174
vector174:
  pushl $0
  102488:	6a 00                	push   $0x0
  pushl $174
  10248a:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10248f:	e9 38 f9 ff ff       	jmp    101dcc <__alltraps>

00102494 <vector175>:
.globl vector175
vector175:
  pushl $0
  102494:	6a 00                	push   $0x0
  pushl $175
  102496:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10249b:	e9 2c f9 ff ff       	jmp    101dcc <__alltraps>

001024a0 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024a0:	6a 00                	push   $0x0
  pushl $176
  1024a2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024a7:	e9 20 f9 ff ff       	jmp    101dcc <__alltraps>

001024ac <vector177>:
.globl vector177
vector177:
  pushl $0
  1024ac:	6a 00                	push   $0x0
  pushl $177
  1024ae:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024b3:	e9 14 f9 ff ff       	jmp    101dcc <__alltraps>

001024b8 <vector178>:
.globl vector178
vector178:
  pushl $0
  1024b8:	6a 00                	push   $0x0
  pushl $178
  1024ba:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024bf:	e9 08 f9 ff ff       	jmp    101dcc <__alltraps>

001024c4 <vector179>:
.globl vector179
vector179:
  pushl $0
  1024c4:	6a 00                	push   $0x0
  pushl $179
  1024c6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024cb:	e9 fc f8 ff ff       	jmp    101dcc <__alltraps>

001024d0 <vector180>:
.globl vector180
vector180:
  pushl $0
  1024d0:	6a 00                	push   $0x0
  pushl $180
  1024d2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1024d7:	e9 f0 f8 ff ff       	jmp    101dcc <__alltraps>

001024dc <vector181>:
.globl vector181
vector181:
  pushl $0
  1024dc:	6a 00                	push   $0x0
  pushl $181
  1024de:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024e3:	e9 e4 f8 ff ff       	jmp    101dcc <__alltraps>

001024e8 <vector182>:
.globl vector182
vector182:
  pushl $0
  1024e8:	6a 00                	push   $0x0
  pushl $182
  1024ea:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1024ef:	e9 d8 f8 ff ff       	jmp    101dcc <__alltraps>

001024f4 <vector183>:
.globl vector183
vector183:
  pushl $0
  1024f4:	6a 00                	push   $0x0
  pushl $183
  1024f6:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024fb:	e9 cc f8 ff ff       	jmp    101dcc <__alltraps>

00102500 <vector184>:
.globl vector184
vector184:
  pushl $0
  102500:	6a 00                	push   $0x0
  pushl $184
  102502:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102507:	e9 c0 f8 ff ff       	jmp    101dcc <__alltraps>

0010250c <vector185>:
.globl vector185
vector185:
  pushl $0
  10250c:	6a 00                	push   $0x0
  pushl $185
  10250e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102513:	e9 b4 f8 ff ff       	jmp    101dcc <__alltraps>

00102518 <vector186>:
.globl vector186
vector186:
  pushl $0
  102518:	6a 00                	push   $0x0
  pushl $186
  10251a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10251f:	e9 a8 f8 ff ff       	jmp    101dcc <__alltraps>

00102524 <vector187>:
.globl vector187
vector187:
  pushl $0
  102524:	6a 00                	push   $0x0
  pushl $187
  102526:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10252b:	e9 9c f8 ff ff       	jmp    101dcc <__alltraps>

00102530 <vector188>:
.globl vector188
vector188:
  pushl $0
  102530:	6a 00                	push   $0x0
  pushl $188
  102532:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102537:	e9 90 f8 ff ff       	jmp    101dcc <__alltraps>

0010253c <vector189>:
.globl vector189
vector189:
  pushl $0
  10253c:	6a 00                	push   $0x0
  pushl $189
  10253e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102543:	e9 84 f8 ff ff       	jmp    101dcc <__alltraps>

00102548 <vector190>:
.globl vector190
vector190:
  pushl $0
  102548:	6a 00                	push   $0x0
  pushl $190
  10254a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10254f:	e9 78 f8 ff ff       	jmp    101dcc <__alltraps>

00102554 <vector191>:
.globl vector191
vector191:
  pushl $0
  102554:	6a 00                	push   $0x0
  pushl $191
  102556:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10255b:	e9 6c f8 ff ff       	jmp    101dcc <__alltraps>

00102560 <vector192>:
.globl vector192
vector192:
  pushl $0
  102560:	6a 00                	push   $0x0
  pushl $192
  102562:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102567:	e9 60 f8 ff ff       	jmp    101dcc <__alltraps>

0010256c <vector193>:
.globl vector193
vector193:
  pushl $0
  10256c:	6a 00                	push   $0x0
  pushl $193
  10256e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102573:	e9 54 f8 ff ff       	jmp    101dcc <__alltraps>

00102578 <vector194>:
.globl vector194
vector194:
  pushl $0
  102578:	6a 00                	push   $0x0
  pushl $194
  10257a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10257f:	e9 48 f8 ff ff       	jmp    101dcc <__alltraps>

00102584 <vector195>:
.globl vector195
vector195:
  pushl $0
  102584:	6a 00                	push   $0x0
  pushl $195
  102586:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10258b:	e9 3c f8 ff ff       	jmp    101dcc <__alltraps>

00102590 <vector196>:
.globl vector196
vector196:
  pushl $0
  102590:	6a 00                	push   $0x0
  pushl $196
  102592:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102597:	e9 30 f8 ff ff       	jmp    101dcc <__alltraps>

0010259c <vector197>:
.globl vector197
vector197:
  pushl $0
  10259c:	6a 00                	push   $0x0
  pushl $197
  10259e:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025a3:	e9 24 f8 ff ff       	jmp    101dcc <__alltraps>

001025a8 <vector198>:
.globl vector198
vector198:
  pushl $0
  1025a8:	6a 00                	push   $0x0
  pushl $198
  1025aa:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025af:	e9 18 f8 ff ff       	jmp    101dcc <__alltraps>

001025b4 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025b4:	6a 00                	push   $0x0
  pushl $199
  1025b6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025bb:	e9 0c f8 ff ff       	jmp    101dcc <__alltraps>

001025c0 <vector200>:
.globl vector200
vector200:
  pushl $0
  1025c0:	6a 00                	push   $0x0
  pushl $200
  1025c2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025c7:	e9 00 f8 ff ff       	jmp    101dcc <__alltraps>

001025cc <vector201>:
.globl vector201
vector201:
  pushl $0
  1025cc:	6a 00                	push   $0x0
  pushl $201
  1025ce:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1025d3:	e9 f4 f7 ff ff       	jmp    101dcc <__alltraps>

001025d8 <vector202>:
.globl vector202
vector202:
  pushl $0
  1025d8:	6a 00                	push   $0x0
  pushl $202
  1025da:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025df:	e9 e8 f7 ff ff       	jmp    101dcc <__alltraps>

001025e4 <vector203>:
.globl vector203
vector203:
  pushl $0
  1025e4:	6a 00                	push   $0x0
  pushl $203
  1025e6:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1025eb:	e9 dc f7 ff ff       	jmp    101dcc <__alltraps>

001025f0 <vector204>:
.globl vector204
vector204:
  pushl $0
  1025f0:	6a 00                	push   $0x0
  pushl $204
  1025f2:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025f7:	e9 d0 f7 ff ff       	jmp    101dcc <__alltraps>

001025fc <vector205>:
.globl vector205
vector205:
  pushl $0
  1025fc:	6a 00                	push   $0x0
  pushl $205
  1025fe:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102603:	e9 c4 f7 ff ff       	jmp    101dcc <__alltraps>

00102608 <vector206>:
.globl vector206
vector206:
  pushl $0
  102608:	6a 00                	push   $0x0
  pushl $206
  10260a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10260f:	e9 b8 f7 ff ff       	jmp    101dcc <__alltraps>

00102614 <vector207>:
.globl vector207
vector207:
  pushl $0
  102614:	6a 00                	push   $0x0
  pushl $207
  102616:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10261b:	e9 ac f7 ff ff       	jmp    101dcc <__alltraps>

00102620 <vector208>:
.globl vector208
vector208:
  pushl $0
  102620:	6a 00                	push   $0x0
  pushl $208
  102622:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102627:	e9 a0 f7 ff ff       	jmp    101dcc <__alltraps>

0010262c <vector209>:
.globl vector209
vector209:
  pushl $0
  10262c:	6a 00                	push   $0x0
  pushl $209
  10262e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102633:	e9 94 f7 ff ff       	jmp    101dcc <__alltraps>

00102638 <vector210>:
.globl vector210
vector210:
  pushl $0
  102638:	6a 00                	push   $0x0
  pushl $210
  10263a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10263f:	e9 88 f7 ff ff       	jmp    101dcc <__alltraps>

00102644 <vector211>:
.globl vector211
vector211:
  pushl $0
  102644:	6a 00                	push   $0x0
  pushl $211
  102646:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10264b:	e9 7c f7 ff ff       	jmp    101dcc <__alltraps>

00102650 <vector212>:
.globl vector212
vector212:
  pushl $0
  102650:	6a 00                	push   $0x0
  pushl $212
  102652:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102657:	e9 70 f7 ff ff       	jmp    101dcc <__alltraps>

0010265c <vector213>:
.globl vector213
vector213:
  pushl $0
  10265c:	6a 00                	push   $0x0
  pushl $213
  10265e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102663:	e9 64 f7 ff ff       	jmp    101dcc <__alltraps>

00102668 <vector214>:
.globl vector214
vector214:
  pushl $0
  102668:	6a 00                	push   $0x0
  pushl $214
  10266a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10266f:	e9 58 f7 ff ff       	jmp    101dcc <__alltraps>

00102674 <vector215>:
.globl vector215
vector215:
  pushl $0
  102674:	6a 00                	push   $0x0
  pushl $215
  102676:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10267b:	e9 4c f7 ff ff       	jmp    101dcc <__alltraps>

00102680 <vector216>:
.globl vector216
vector216:
  pushl $0
  102680:	6a 00                	push   $0x0
  pushl $216
  102682:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102687:	e9 40 f7 ff ff       	jmp    101dcc <__alltraps>

0010268c <vector217>:
.globl vector217
vector217:
  pushl $0
  10268c:	6a 00                	push   $0x0
  pushl $217
  10268e:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102693:	e9 34 f7 ff ff       	jmp    101dcc <__alltraps>

00102698 <vector218>:
.globl vector218
vector218:
  pushl $0
  102698:	6a 00                	push   $0x0
  pushl $218
  10269a:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10269f:	e9 28 f7 ff ff       	jmp    101dcc <__alltraps>

001026a4 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026a4:	6a 00                	push   $0x0
  pushl $219
  1026a6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026ab:	e9 1c f7 ff ff       	jmp    101dcc <__alltraps>

001026b0 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026b0:	6a 00                	push   $0x0
  pushl $220
  1026b2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026b7:	e9 10 f7 ff ff       	jmp    101dcc <__alltraps>

001026bc <vector221>:
.globl vector221
vector221:
  pushl $0
  1026bc:	6a 00                	push   $0x0
  pushl $221
  1026be:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026c3:	e9 04 f7 ff ff       	jmp    101dcc <__alltraps>

001026c8 <vector222>:
.globl vector222
vector222:
  pushl $0
  1026c8:	6a 00                	push   $0x0
  pushl $222
  1026ca:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1026cf:	e9 f8 f6 ff ff       	jmp    101dcc <__alltraps>

001026d4 <vector223>:
.globl vector223
vector223:
  pushl $0
  1026d4:	6a 00                	push   $0x0
  pushl $223
  1026d6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1026db:	e9 ec f6 ff ff       	jmp    101dcc <__alltraps>

001026e0 <vector224>:
.globl vector224
vector224:
  pushl $0
  1026e0:	6a 00                	push   $0x0
  pushl $224
  1026e2:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1026e7:	e9 e0 f6 ff ff       	jmp    101dcc <__alltraps>

001026ec <vector225>:
.globl vector225
vector225:
  pushl $0
  1026ec:	6a 00                	push   $0x0
  pushl $225
  1026ee:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1026f3:	e9 d4 f6 ff ff       	jmp    101dcc <__alltraps>

001026f8 <vector226>:
.globl vector226
vector226:
  pushl $0
  1026f8:	6a 00                	push   $0x0
  pushl $226
  1026fa:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026ff:	e9 c8 f6 ff ff       	jmp    101dcc <__alltraps>

00102704 <vector227>:
.globl vector227
vector227:
  pushl $0
  102704:	6a 00                	push   $0x0
  pushl $227
  102706:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10270b:	e9 bc f6 ff ff       	jmp    101dcc <__alltraps>

00102710 <vector228>:
.globl vector228
vector228:
  pushl $0
  102710:	6a 00                	push   $0x0
  pushl $228
  102712:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102717:	e9 b0 f6 ff ff       	jmp    101dcc <__alltraps>

0010271c <vector229>:
.globl vector229
vector229:
  pushl $0
  10271c:	6a 00                	push   $0x0
  pushl $229
  10271e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102723:	e9 a4 f6 ff ff       	jmp    101dcc <__alltraps>

00102728 <vector230>:
.globl vector230
vector230:
  pushl $0
  102728:	6a 00                	push   $0x0
  pushl $230
  10272a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10272f:	e9 98 f6 ff ff       	jmp    101dcc <__alltraps>

00102734 <vector231>:
.globl vector231
vector231:
  pushl $0
  102734:	6a 00                	push   $0x0
  pushl $231
  102736:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10273b:	e9 8c f6 ff ff       	jmp    101dcc <__alltraps>

00102740 <vector232>:
.globl vector232
vector232:
  pushl $0
  102740:	6a 00                	push   $0x0
  pushl $232
  102742:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102747:	e9 80 f6 ff ff       	jmp    101dcc <__alltraps>

0010274c <vector233>:
.globl vector233
vector233:
  pushl $0
  10274c:	6a 00                	push   $0x0
  pushl $233
  10274e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102753:	e9 74 f6 ff ff       	jmp    101dcc <__alltraps>

00102758 <vector234>:
.globl vector234
vector234:
  pushl $0
  102758:	6a 00                	push   $0x0
  pushl $234
  10275a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10275f:	e9 68 f6 ff ff       	jmp    101dcc <__alltraps>

00102764 <vector235>:
.globl vector235
vector235:
  pushl $0
  102764:	6a 00                	push   $0x0
  pushl $235
  102766:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10276b:	e9 5c f6 ff ff       	jmp    101dcc <__alltraps>

00102770 <vector236>:
.globl vector236
vector236:
  pushl $0
  102770:	6a 00                	push   $0x0
  pushl $236
  102772:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102777:	e9 50 f6 ff ff       	jmp    101dcc <__alltraps>

0010277c <vector237>:
.globl vector237
vector237:
  pushl $0
  10277c:	6a 00                	push   $0x0
  pushl $237
  10277e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102783:	e9 44 f6 ff ff       	jmp    101dcc <__alltraps>

00102788 <vector238>:
.globl vector238
vector238:
  pushl $0
  102788:	6a 00                	push   $0x0
  pushl $238
  10278a:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10278f:	e9 38 f6 ff ff       	jmp    101dcc <__alltraps>

00102794 <vector239>:
.globl vector239
vector239:
  pushl $0
  102794:	6a 00                	push   $0x0
  pushl $239
  102796:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10279b:	e9 2c f6 ff ff       	jmp    101dcc <__alltraps>

001027a0 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027a0:	6a 00                	push   $0x0
  pushl $240
  1027a2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027a7:	e9 20 f6 ff ff       	jmp    101dcc <__alltraps>

001027ac <vector241>:
.globl vector241
vector241:
  pushl $0
  1027ac:	6a 00                	push   $0x0
  pushl $241
  1027ae:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027b3:	e9 14 f6 ff ff       	jmp    101dcc <__alltraps>

001027b8 <vector242>:
.globl vector242
vector242:
  pushl $0
  1027b8:	6a 00                	push   $0x0
  pushl $242
  1027ba:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027bf:	e9 08 f6 ff ff       	jmp    101dcc <__alltraps>

001027c4 <vector243>:
.globl vector243
vector243:
  pushl $0
  1027c4:	6a 00                	push   $0x0
  pushl $243
  1027c6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027cb:	e9 fc f5 ff ff       	jmp    101dcc <__alltraps>

001027d0 <vector244>:
.globl vector244
vector244:
  pushl $0
  1027d0:	6a 00                	push   $0x0
  pushl $244
  1027d2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1027d7:	e9 f0 f5 ff ff       	jmp    101dcc <__alltraps>

001027dc <vector245>:
.globl vector245
vector245:
  pushl $0
  1027dc:	6a 00                	push   $0x0
  pushl $245
  1027de:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027e3:	e9 e4 f5 ff ff       	jmp    101dcc <__alltraps>

001027e8 <vector246>:
.globl vector246
vector246:
  pushl $0
  1027e8:	6a 00                	push   $0x0
  pushl $246
  1027ea:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1027ef:	e9 d8 f5 ff ff       	jmp    101dcc <__alltraps>

001027f4 <vector247>:
.globl vector247
vector247:
  pushl $0
  1027f4:	6a 00                	push   $0x0
  pushl $247
  1027f6:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027fb:	e9 cc f5 ff ff       	jmp    101dcc <__alltraps>

00102800 <vector248>:
.globl vector248
vector248:
  pushl $0
  102800:	6a 00                	push   $0x0
  pushl $248
  102802:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102807:	e9 c0 f5 ff ff       	jmp    101dcc <__alltraps>

0010280c <vector249>:
.globl vector249
vector249:
  pushl $0
  10280c:	6a 00                	push   $0x0
  pushl $249
  10280e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102813:	e9 b4 f5 ff ff       	jmp    101dcc <__alltraps>

00102818 <vector250>:
.globl vector250
vector250:
  pushl $0
  102818:	6a 00                	push   $0x0
  pushl $250
  10281a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  10281f:	e9 a8 f5 ff ff       	jmp    101dcc <__alltraps>

00102824 <vector251>:
.globl vector251
vector251:
  pushl $0
  102824:	6a 00                	push   $0x0
  pushl $251
  102826:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10282b:	e9 9c f5 ff ff       	jmp    101dcc <__alltraps>

00102830 <vector252>:
.globl vector252
vector252:
  pushl $0
  102830:	6a 00                	push   $0x0
  pushl $252
  102832:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102837:	e9 90 f5 ff ff       	jmp    101dcc <__alltraps>

0010283c <vector253>:
.globl vector253
vector253:
  pushl $0
  10283c:	6a 00                	push   $0x0
  pushl $253
  10283e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102843:	e9 84 f5 ff ff       	jmp    101dcc <__alltraps>

00102848 <vector254>:
.globl vector254
vector254:
  pushl $0
  102848:	6a 00                	push   $0x0
  pushl $254
  10284a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10284f:	e9 78 f5 ff ff       	jmp    101dcc <__alltraps>

00102854 <vector255>:
.globl vector255
vector255:
  pushl $0
  102854:	6a 00                	push   $0x0
  pushl $255
  102856:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10285b:	e9 6c f5 ff ff       	jmp    101dcc <__alltraps>

00102860 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102860:	55                   	push   %ebp
  102861:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102863:	8b 55 08             	mov    0x8(%ebp),%edx
  102866:	a1 24 af 11 00       	mov    0x11af24,%eax
  10286b:	29 c2                	sub    %eax,%edx
  10286d:	89 d0                	mov    %edx,%eax
  10286f:	c1 f8 02             	sar    $0x2,%eax
  102872:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102878:	5d                   	pop    %ebp
  102879:	c3                   	ret    

0010287a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  10287a:	55                   	push   %ebp
  10287b:	89 e5                	mov    %esp,%ebp
  10287d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102880:	8b 45 08             	mov    0x8(%ebp),%eax
  102883:	89 04 24             	mov    %eax,(%esp)
  102886:	e8 d5 ff ff ff       	call   102860 <page2ppn>
  10288b:	c1 e0 0c             	shl    $0xc,%eax
}
  10288e:	c9                   	leave  
  10288f:	c3                   	ret    

00102890 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102890:	55                   	push   %ebp
  102891:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102893:	8b 45 08             	mov    0x8(%ebp),%eax
  102896:	8b 00                	mov    (%eax),%eax
}
  102898:	5d                   	pop    %ebp
  102899:	c3                   	ret    

0010289a <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  10289a:	55                   	push   %ebp
  10289b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10289d:	8b 45 08             	mov    0x8(%ebp),%eax
  1028a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1028a3:	89 10                	mov    %edx,(%eax)
}
  1028a5:	5d                   	pop    %ebp
  1028a6:	c3                   	ret    

001028a7 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1028a7:	55                   	push   %ebp
  1028a8:	89 e5                	mov    %esp,%ebp
  1028aa:	83 ec 10             	sub    $0x10,%esp
  1028ad:	c7 45 fc 10 af 11 00 	movl   $0x11af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1028b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1028ba:	89 50 04             	mov    %edx,0x4(%eax)
  1028bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028c0:	8b 50 04             	mov    0x4(%eax),%edx
  1028c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028c6:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1028c8:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1028cf:	00 00 00 
}
  1028d2:	c9                   	leave  
  1028d3:	c3                   	ret    

001028d4 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1028d4:	55                   	push   %ebp
  1028d5:	89 e5                	mov    %esp,%ebp
  1028d7:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  1028da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1028de:	75 24                	jne    102904 <default_init_memmap+0x30>
  1028e0:	c7 44 24 0c f0 64 10 	movl   $0x1064f0,0xc(%esp)
  1028e7:	00 
  1028e8:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1028ef:	00 
  1028f0:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1028f7:	00 
  1028f8:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1028ff:	e8 cc e3 ff ff       	call   100cd0 <__panic>
    struct Page *p = base;
  102904:	8b 45 08             	mov    0x8(%ebp),%eax
  102907:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10290a:	eb 7d                	jmp    102989 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  10290c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10290f:	83 c0 04             	add    $0x4,%eax
  102912:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102919:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10291c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10291f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102922:	0f a3 10             	bt     %edx,(%eax)
  102925:	19 c0                	sbb    %eax,%eax
  102927:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  10292a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10292e:	0f 95 c0             	setne  %al
  102931:	0f b6 c0             	movzbl %al,%eax
  102934:	85 c0                	test   %eax,%eax
  102936:	75 24                	jne    10295c <default_init_memmap+0x88>
  102938:	c7 44 24 0c 21 65 10 	movl   $0x106521,0xc(%esp)
  10293f:	00 
  102940:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102947:	00 
  102948:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10294f:	00 
  102950:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102957:	e8 74 e3 ff ff       	call   100cd0 <__panic>
        p->flags = p->property = 0;
  10295c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10295f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102969:	8b 50 08             	mov    0x8(%eax),%edx
  10296c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10296f:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102972:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102979:	00 
  10297a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10297d:	89 04 24             	mov    %eax,(%esp)
  102980:	e8 15 ff ff ff       	call   10289a <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102985:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102989:	8b 55 0c             	mov    0xc(%ebp),%edx
  10298c:	89 d0                	mov    %edx,%eax
  10298e:	c1 e0 02             	shl    $0x2,%eax
  102991:	01 d0                	add    %edx,%eax
  102993:	c1 e0 02             	shl    $0x2,%eax
  102996:	89 c2                	mov    %eax,%edx
  102998:	8b 45 08             	mov    0x8(%ebp),%eax
  10299b:	01 d0                	add    %edx,%eax
  10299d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1029a0:	0f 85 66 ff ff ff    	jne    10290c <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  1029a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029ac:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1029af:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b2:	83 c0 04             	add    $0x4,%eax
  1029b5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1029bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1029bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1029c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1029c5:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1029c8:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029d1:	01 d0                	add    %edx,%eax
  1029d3:	a3 18 af 11 00       	mov    %eax,0x11af18
    list_add(&free_list, &(base->page_link));
  1029d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029db:	83 c0 0c             	add    $0xc,%eax
  1029de:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
  1029e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1029e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1029eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1029ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1029f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  1029f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1029f7:	8b 40 04             	mov    0x4(%eax),%eax
  1029fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1029fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102a00:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a03:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102a06:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102a09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102a0c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102a0f:	89 10                	mov    %edx,(%eax)
  102a11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102a14:	8b 10                	mov    (%eax),%edx
  102a16:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102a19:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102a1c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a1f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102a22:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102a25:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a28:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102a2b:	89 10                	mov    %edx,(%eax)
}
  102a2d:	c9                   	leave  
  102a2e:	c3                   	ret    

00102a2f <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102a2f:	55                   	push   %ebp
  102a30:	89 e5                	mov    %esp,%ebp
  102a32:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102a35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a39:	75 24                	jne    102a5f <default_alloc_pages+0x30>
  102a3b:	c7 44 24 0c f0 64 10 	movl   $0x1064f0,0xc(%esp)
  102a42:	00 
  102a43:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102a4a:	00 
  102a4b:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102a52:	00 
  102a53:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102a5a:	e8 71 e2 ff ff       	call   100cd0 <__panic>
    if (n > nr_free) {
  102a5f:	a1 18 af 11 00       	mov    0x11af18,%eax
  102a64:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a67:	73 0a                	jae    102a73 <default_alloc_pages+0x44>
        return NULL;
  102a69:	b8 00 00 00 00       	mov    $0x0,%eax
  102a6e:	e9 2a 01 00 00       	jmp    102b9d <default_alloc_pages+0x16e>
    }
    struct Page *page = NULL;
  102a73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102a7a:	c7 45 f0 10 af 11 00 	movl   $0x11af10,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  102a81:	eb 1c                	jmp    102a9f <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a86:	83 e8 0c             	sub    $0xc,%eax
  102a89:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a8f:	8b 40 08             	mov    0x8(%eax),%eax
  102a92:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a95:	72 08                	jb     102a9f <default_alloc_pages+0x70>
            page = p;
  102a97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102a9d:	eb 18                	jmp    102ab7 <default_alloc_pages+0x88>
  102a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102aa2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102aa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102aa8:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  102aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102aae:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102ab5:	75 cc                	jne    102a83 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102ab7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102abb:	0f 84 d9 00 00 00    	je     102b9a <default_alloc_pages+0x16b>
        list_del(&(page->page_link));
  102ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ac4:	83 c0 0c             	add    $0xc,%eax
  102ac7:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102aca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102acd:	8b 40 04             	mov    0x4(%eax),%eax
  102ad0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102ad3:	8b 12                	mov    (%edx),%edx
  102ad5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102adb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ade:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102ae1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102ae4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102ae7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102aea:	89 10                	mov    %edx,(%eax)
        if (page->property > n) {
  102aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aef:	8b 40 08             	mov    0x8(%eax),%eax
  102af2:	3b 45 08             	cmp    0x8(%ebp),%eax
  102af5:	76 7d                	jbe    102b74 <default_alloc_pages+0x145>
            struct Page *p = page + n;
  102af7:	8b 55 08             	mov    0x8(%ebp),%edx
  102afa:	89 d0                	mov    %edx,%eax
  102afc:	c1 e0 02             	shl    $0x2,%eax
  102aff:	01 d0                	add    %edx,%eax
  102b01:	c1 e0 02             	shl    $0x2,%eax
  102b04:	89 c2                	mov    %eax,%edx
  102b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b09:	01 d0                	add    %edx,%eax
  102b0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  102b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b11:	8b 40 08             	mov    0x8(%eax),%eax
  102b14:	2b 45 08             	sub    0x8(%ebp),%eax
  102b17:	89 c2                	mov    %eax,%edx
  102b19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b1c:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
  102b1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b22:	83 c0 0c             	add    $0xc,%eax
  102b25:	c7 45 d4 10 af 11 00 	movl   $0x11af10,-0x2c(%ebp)
  102b2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102b2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102b32:	89 45 cc             	mov    %eax,-0x34(%ebp)
  102b35:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b38:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102b3b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b3e:	8b 40 04             	mov    0x4(%eax),%eax
  102b41:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b44:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  102b47:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b4a:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102b4d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b50:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102b53:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102b56:	89 10                	mov    %edx,(%eax)
  102b58:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102b5b:	8b 10                	mov    (%eax),%edx
  102b5d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b60:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b63:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b66:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102b69:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b6c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b6f:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102b72:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
  102b74:	a1 18 af 11 00       	mov    0x11af18,%eax
  102b79:	2b 45 08             	sub    0x8(%ebp),%eax
  102b7c:	a3 18 af 11 00       	mov    %eax,0x11af18
        ClearPageProperty(page);
  102b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b84:	83 c0 04             	add    $0x4,%eax
  102b87:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102b8e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b91:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102b94:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102b97:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102b9d:	c9                   	leave  
  102b9e:	c3                   	ret    

00102b9f <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102b9f:	55                   	push   %ebp
  102ba0:	89 e5                	mov    %esp,%ebp
  102ba2:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102ba8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102bac:	75 24                	jne    102bd2 <default_free_pages+0x33>
  102bae:	c7 44 24 0c f0 64 10 	movl   $0x1064f0,0xc(%esp)
  102bb5:	00 
  102bb6:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102bbd:	00 
  102bbe:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  102bc5:	00 
  102bc6:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102bcd:	e8 fe e0 ff ff       	call   100cd0 <__panic>
    struct Page *p = base;
  102bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102bd8:	e9 9d 00 00 00       	jmp    102c7a <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102be0:	83 c0 04             	add    $0x4,%eax
  102be3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102bea:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102bed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bf0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102bf3:	0f a3 10             	bt     %edx,(%eax)
  102bf6:	19 c0                	sbb    %eax,%eax
  102bf8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102bfb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102bff:	0f 95 c0             	setne  %al
  102c02:	0f b6 c0             	movzbl %al,%eax
  102c05:	85 c0                	test   %eax,%eax
  102c07:	75 2c                	jne    102c35 <default_free_pages+0x96>
  102c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c0c:	83 c0 04             	add    $0x4,%eax
  102c0f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102c16:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c19:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c1f:	0f a3 10             	bt     %edx,(%eax)
  102c22:	19 c0                	sbb    %eax,%eax
  102c24:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102c27:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102c2b:	0f 95 c0             	setne  %al
  102c2e:	0f b6 c0             	movzbl %al,%eax
  102c31:	85 c0                	test   %eax,%eax
  102c33:	74 24                	je     102c59 <default_free_pages+0xba>
  102c35:	c7 44 24 0c 34 65 10 	movl   $0x106534,0xc(%esp)
  102c3c:	00 
  102c3d:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102c44:	00 
  102c45:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  102c4c:	00 
  102c4d:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102c54:	e8 77 e0 ff ff       	call   100cd0 <__panic>
        p->flags = 0;
  102c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c5c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102c63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102c6a:	00 
  102c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c6e:	89 04 24             	mov    %eax,(%esp)
  102c71:	e8 24 fc ff ff       	call   10289a <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102c76:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c7d:	89 d0                	mov    %edx,%eax
  102c7f:	c1 e0 02             	shl    $0x2,%eax
  102c82:	01 d0                	add    %edx,%eax
  102c84:	c1 e0 02             	shl    $0x2,%eax
  102c87:	89 c2                	mov    %eax,%edx
  102c89:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8c:	01 d0                	add    %edx,%eax
  102c8e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102c91:	0f 85 46 ff ff ff    	jne    102bdd <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102c97:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c9d:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ca3:	83 c0 04             	add    $0x4,%eax
  102ca6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102cad:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102cb0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102cb3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102cb6:	0f ab 10             	bts    %edx,(%eax)
  102cb9:	c7 45 cc 10 af 11 00 	movl   $0x11af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102cc0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102cc3:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102cc9:	e9 08 01 00 00       	jmp    102dd6 <default_free_pages+0x237>
        p = le2page(le, page_link);
  102cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cd1:	83 e8 0c             	sub    $0xc,%eax
  102cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cda:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102cdd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102ce0:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce9:	8b 50 08             	mov    0x8(%eax),%edx
  102cec:	89 d0                	mov    %edx,%eax
  102cee:	c1 e0 02             	shl    $0x2,%eax
  102cf1:	01 d0                	add    %edx,%eax
  102cf3:	c1 e0 02             	shl    $0x2,%eax
  102cf6:	89 c2                	mov    %eax,%edx
  102cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  102cfb:	01 d0                	add    %edx,%eax
  102cfd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102d00:	75 5a                	jne    102d5c <default_free_pages+0x1bd>
            base->property += p->property;
  102d02:	8b 45 08             	mov    0x8(%ebp),%eax
  102d05:	8b 50 08             	mov    0x8(%eax),%edx
  102d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d0b:	8b 40 08             	mov    0x8(%eax),%eax
  102d0e:	01 c2                	add    %eax,%edx
  102d10:	8b 45 08             	mov    0x8(%ebp),%eax
  102d13:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d19:	83 c0 04             	add    $0x4,%eax
  102d1c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102d23:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d26:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d29:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d2c:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d32:	83 c0 0c             	add    $0xc,%eax
  102d35:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d38:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d3b:	8b 40 04             	mov    0x4(%eax),%eax
  102d3e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d41:	8b 12                	mov    (%edx),%edx
  102d43:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102d46:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102d49:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d4c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d4f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102d52:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102d55:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102d58:	89 10                	mov    %edx,(%eax)
  102d5a:	eb 7a                	jmp    102dd6 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d5f:	8b 50 08             	mov    0x8(%eax),%edx
  102d62:	89 d0                	mov    %edx,%eax
  102d64:	c1 e0 02             	shl    $0x2,%eax
  102d67:	01 d0                	add    %edx,%eax
  102d69:	c1 e0 02             	shl    $0x2,%eax
  102d6c:	89 c2                	mov    %eax,%edx
  102d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d71:	01 d0                	add    %edx,%eax
  102d73:	3b 45 08             	cmp    0x8(%ebp),%eax
  102d76:	75 5e                	jne    102dd6 <default_free_pages+0x237>
            p->property += base->property;
  102d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d7b:	8b 50 08             	mov    0x8(%eax),%edx
  102d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d81:	8b 40 08             	mov    0x8(%eax),%eax
  102d84:	01 c2                	add    %eax,%edx
  102d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d89:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d8f:	83 c0 04             	add    $0x4,%eax
  102d92:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102d99:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102d9c:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102d9f:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102da2:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102da8:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dae:	83 c0 0c             	add    $0xc,%eax
  102db1:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102db4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102db7:	8b 40 04             	mov    0x4(%eax),%eax
  102dba:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102dbd:	8b 12                	mov    (%edx),%edx
  102dbf:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102dc2:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102dc5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102dc8:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102dcb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102dce:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102dd1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102dd4:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  102dd6:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102ddd:	0f 85 eb fe ff ff    	jne    102cce <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102de3:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102de9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dec:	01 d0                	add    %edx,%eax
  102dee:	a3 18 af 11 00       	mov    %eax,0x11af18
    list_add(&free_list, &(base->page_link));
  102df3:	8b 45 08             	mov    0x8(%ebp),%eax
  102df6:	83 c0 0c             	add    $0xc,%eax
  102df9:	c7 45 9c 10 af 11 00 	movl   $0x11af10,-0x64(%ebp)
  102e00:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e03:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102e06:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102e09:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e0c:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102e0f:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102e12:	8b 40 04             	mov    0x4(%eax),%eax
  102e15:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e18:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102e1b:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102e1e:	89 55 88             	mov    %edx,-0x78(%ebp)
  102e21:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102e24:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102e27:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102e2a:	89 10                	mov    %edx,(%eax)
  102e2c:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102e2f:	8b 10                	mov    (%eax),%edx
  102e31:	8b 45 88             	mov    -0x78(%ebp),%eax
  102e34:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102e37:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e3a:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102e3d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102e40:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e43:	8b 55 88             	mov    -0x78(%ebp),%edx
  102e46:	89 10                	mov    %edx,(%eax)
}
  102e48:	c9                   	leave  
  102e49:	c3                   	ret    

00102e4a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102e4a:	55                   	push   %ebp
  102e4b:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102e4d:	a1 18 af 11 00       	mov    0x11af18,%eax
}
  102e52:	5d                   	pop    %ebp
  102e53:	c3                   	ret    

00102e54 <basic_check>:

static void
basic_check(void) {
  102e54:	55                   	push   %ebp
  102e55:	89 e5                	mov    %esp,%ebp
  102e57:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102e5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102e6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102e74:	e8 ce 0e 00 00       	call   103d47 <alloc_pages>
  102e79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e7c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102e80:	75 24                	jne    102ea6 <basic_check+0x52>
  102e82:	c7 44 24 0c 59 65 10 	movl   $0x106559,0xc(%esp)
  102e89:	00 
  102e8a:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102e91:	00 
  102e92:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  102e99:	00 
  102e9a:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102ea1:	e8 2a de ff ff       	call   100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102ea6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102ead:	e8 95 0e 00 00       	call   103d47 <alloc_pages>
  102eb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102eb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102eb9:	75 24                	jne    102edf <basic_check+0x8b>
  102ebb:	c7 44 24 0c 75 65 10 	movl   $0x106575,0xc(%esp)
  102ec2:	00 
  102ec3:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102eca:	00 
  102ecb:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  102ed2:	00 
  102ed3:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102eda:	e8 f1 dd ff ff       	call   100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102edf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102ee6:	e8 5c 0e 00 00       	call   103d47 <alloc_pages>
  102eeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102eee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102ef2:	75 24                	jne    102f18 <basic_check+0xc4>
  102ef4:	c7 44 24 0c 91 65 10 	movl   $0x106591,0xc(%esp)
  102efb:	00 
  102efc:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102f03:	00 
  102f04:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  102f0b:	00 
  102f0c:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102f13:	e8 b8 dd ff ff       	call   100cd0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102f1e:	74 10                	je     102f30 <basic_check+0xdc>
  102f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f26:	74 08                	je     102f30 <basic_check+0xdc>
  102f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f2b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f2e:	75 24                	jne    102f54 <basic_check+0x100>
  102f30:	c7 44 24 0c b0 65 10 	movl   $0x1065b0,0xc(%esp)
  102f37:	00 
  102f38:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102f3f:	00 
  102f40:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  102f47:	00 
  102f48:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102f4f:	e8 7c dd ff ff       	call   100cd0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f57:	89 04 24             	mov    %eax,(%esp)
  102f5a:	e8 31 f9 ff ff       	call   102890 <page_ref>
  102f5f:	85 c0                	test   %eax,%eax
  102f61:	75 1e                	jne    102f81 <basic_check+0x12d>
  102f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f66:	89 04 24             	mov    %eax,(%esp)
  102f69:	e8 22 f9 ff ff       	call   102890 <page_ref>
  102f6e:	85 c0                	test   %eax,%eax
  102f70:	75 0f                	jne    102f81 <basic_check+0x12d>
  102f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f75:	89 04 24             	mov    %eax,(%esp)
  102f78:	e8 13 f9 ff ff       	call   102890 <page_ref>
  102f7d:	85 c0                	test   %eax,%eax
  102f7f:	74 24                	je     102fa5 <basic_check+0x151>
  102f81:	c7 44 24 0c d4 65 10 	movl   $0x1065d4,0xc(%esp)
  102f88:	00 
  102f89:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102f90:	00 
  102f91:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  102f98:	00 
  102f99:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102fa0:	e8 2b dd ff ff       	call   100cd0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  102fa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fa8:	89 04 24             	mov    %eax,(%esp)
  102fab:	e8 ca f8 ff ff       	call   10287a <page2pa>
  102fb0:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102fb6:	c1 e2 0c             	shl    $0xc,%edx
  102fb9:	39 d0                	cmp    %edx,%eax
  102fbb:	72 24                	jb     102fe1 <basic_check+0x18d>
  102fbd:	c7 44 24 0c 10 66 10 	movl   $0x106610,0xc(%esp)
  102fc4:	00 
  102fc5:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  102fcc:	00 
  102fcd:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  102fd4:	00 
  102fd5:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  102fdc:	e8 ef dc ff ff       	call   100cd0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  102fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fe4:	89 04 24             	mov    %eax,(%esp)
  102fe7:	e8 8e f8 ff ff       	call   10287a <page2pa>
  102fec:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102ff2:	c1 e2 0c             	shl    $0xc,%edx
  102ff5:	39 d0                	cmp    %edx,%eax
  102ff7:	72 24                	jb     10301d <basic_check+0x1c9>
  102ff9:	c7 44 24 0c 2d 66 10 	movl   $0x10662d,0xc(%esp)
  103000:	00 
  103001:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103008:	00 
  103009:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  103010:	00 
  103011:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103018:	e8 b3 dc ff ff       	call   100cd0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  10301d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103020:	89 04 24             	mov    %eax,(%esp)
  103023:	e8 52 f8 ff ff       	call   10287a <page2pa>
  103028:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10302e:	c1 e2 0c             	shl    $0xc,%edx
  103031:	39 d0                	cmp    %edx,%eax
  103033:	72 24                	jb     103059 <basic_check+0x205>
  103035:	c7 44 24 0c 4a 66 10 	movl   $0x10664a,0xc(%esp)
  10303c:	00 
  10303d:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103044:	00 
  103045:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  10304c:	00 
  10304d:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103054:	e8 77 dc ff ff       	call   100cd0 <__panic>

    list_entry_t free_list_store = free_list;
  103059:	a1 10 af 11 00       	mov    0x11af10,%eax
  10305e:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  103064:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103067:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10306a:	c7 45 e0 10 af 11 00 	movl   $0x11af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103071:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103074:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103077:	89 50 04             	mov    %edx,0x4(%eax)
  10307a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10307d:	8b 50 04             	mov    0x4(%eax),%edx
  103080:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103083:	89 10                	mov    %edx,(%eax)
  103085:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  10308c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10308f:	8b 40 04             	mov    0x4(%eax),%eax
  103092:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103095:	0f 94 c0             	sete   %al
  103098:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10309b:	85 c0                	test   %eax,%eax
  10309d:	75 24                	jne    1030c3 <basic_check+0x26f>
  10309f:	c7 44 24 0c 67 66 10 	movl   $0x106667,0xc(%esp)
  1030a6:	00 
  1030a7:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1030ae:	00 
  1030af:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  1030b6:	00 
  1030b7:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1030be:	e8 0d dc ff ff       	call   100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
  1030c3:	a1 18 af 11 00       	mov    0x11af18,%eax
  1030c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1030cb:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1030d2:	00 00 00 

    assert(alloc_page() == NULL);
  1030d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030dc:	e8 66 0c 00 00       	call   103d47 <alloc_pages>
  1030e1:	85 c0                	test   %eax,%eax
  1030e3:	74 24                	je     103109 <basic_check+0x2b5>
  1030e5:	c7 44 24 0c 7e 66 10 	movl   $0x10667e,0xc(%esp)
  1030ec:	00 
  1030ed:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1030f4:	00 
  1030f5:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  1030fc:	00 
  1030fd:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103104:	e8 c7 db ff ff       	call   100cd0 <__panic>

    free_page(p0);
  103109:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103110:	00 
  103111:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103114:	89 04 24             	mov    %eax,(%esp)
  103117:	e8 63 0c 00 00       	call   103d7f <free_pages>
    free_page(p1);
  10311c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103123:	00 
  103124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103127:	89 04 24             	mov    %eax,(%esp)
  10312a:	e8 50 0c 00 00       	call   103d7f <free_pages>
    free_page(p2);
  10312f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103136:	00 
  103137:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10313a:	89 04 24             	mov    %eax,(%esp)
  10313d:	e8 3d 0c 00 00       	call   103d7f <free_pages>
    assert(nr_free == 3);
  103142:	a1 18 af 11 00       	mov    0x11af18,%eax
  103147:	83 f8 03             	cmp    $0x3,%eax
  10314a:	74 24                	je     103170 <basic_check+0x31c>
  10314c:	c7 44 24 0c 93 66 10 	movl   $0x106693,0xc(%esp)
  103153:	00 
  103154:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10315b:	00 
  10315c:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  103163:	00 
  103164:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10316b:	e8 60 db ff ff       	call   100cd0 <__panic>

    assert((p0 = alloc_page()) != NULL);
  103170:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103177:	e8 cb 0b 00 00       	call   103d47 <alloc_pages>
  10317c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10317f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103183:	75 24                	jne    1031a9 <basic_check+0x355>
  103185:	c7 44 24 0c 59 65 10 	movl   $0x106559,0xc(%esp)
  10318c:	00 
  10318d:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103194:	00 
  103195:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  10319c:	00 
  10319d:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1031a4:	e8 27 db ff ff       	call   100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1031a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031b0:	e8 92 0b 00 00       	call   103d47 <alloc_pages>
  1031b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1031bc:	75 24                	jne    1031e2 <basic_check+0x38e>
  1031be:	c7 44 24 0c 75 65 10 	movl   $0x106575,0xc(%esp)
  1031c5:	00 
  1031c6:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1031cd:	00 
  1031ce:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  1031d5:	00 
  1031d6:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1031dd:	e8 ee da ff ff       	call   100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1031e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031e9:	e8 59 0b 00 00       	call   103d47 <alloc_pages>
  1031ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1031f5:	75 24                	jne    10321b <basic_check+0x3c7>
  1031f7:	c7 44 24 0c 91 65 10 	movl   $0x106591,0xc(%esp)
  1031fe:	00 
  1031ff:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103206:	00 
  103207:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  10320e:	00 
  10320f:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103216:	e8 b5 da ff ff       	call   100cd0 <__panic>

    assert(alloc_page() == NULL);
  10321b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103222:	e8 20 0b 00 00       	call   103d47 <alloc_pages>
  103227:	85 c0                	test   %eax,%eax
  103229:	74 24                	je     10324f <basic_check+0x3fb>
  10322b:	c7 44 24 0c 7e 66 10 	movl   $0x10667e,0xc(%esp)
  103232:	00 
  103233:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10323a:	00 
  10323b:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  103242:	00 
  103243:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10324a:	e8 81 da ff ff       	call   100cd0 <__panic>

    free_page(p0);
  10324f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103256:	00 
  103257:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10325a:	89 04 24             	mov    %eax,(%esp)
  10325d:	e8 1d 0b 00 00       	call   103d7f <free_pages>
  103262:	c7 45 d8 10 af 11 00 	movl   $0x11af10,-0x28(%ebp)
  103269:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10326c:	8b 40 04             	mov    0x4(%eax),%eax
  10326f:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103272:	0f 94 c0             	sete   %al
  103275:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103278:	85 c0                	test   %eax,%eax
  10327a:	74 24                	je     1032a0 <basic_check+0x44c>
  10327c:	c7 44 24 0c a0 66 10 	movl   $0x1066a0,0xc(%esp)
  103283:	00 
  103284:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10328b:	00 
  10328c:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  103293:	00 
  103294:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10329b:	e8 30 da ff ff       	call   100cd0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1032a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032a7:	e8 9b 0a 00 00       	call   103d47 <alloc_pages>
  1032ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032b2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1032b5:	74 24                	je     1032db <basic_check+0x487>
  1032b7:	c7 44 24 0c b8 66 10 	movl   $0x1066b8,0xc(%esp)
  1032be:	00 
  1032bf:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1032c6:	00 
  1032c7:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  1032ce:	00 
  1032cf:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1032d6:	e8 f5 d9 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  1032db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032e2:	e8 60 0a 00 00       	call   103d47 <alloc_pages>
  1032e7:	85 c0                	test   %eax,%eax
  1032e9:	74 24                	je     10330f <basic_check+0x4bb>
  1032eb:	c7 44 24 0c 7e 66 10 	movl   $0x10667e,0xc(%esp)
  1032f2:	00 
  1032f3:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1032fa:	00 
  1032fb:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  103302:	00 
  103303:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10330a:	e8 c1 d9 ff ff       	call   100cd0 <__panic>

    assert(nr_free == 0);
  10330f:	a1 18 af 11 00       	mov    0x11af18,%eax
  103314:	85 c0                	test   %eax,%eax
  103316:	74 24                	je     10333c <basic_check+0x4e8>
  103318:	c7 44 24 0c d1 66 10 	movl   $0x1066d1,0xc(%esp)
  10331f:	00 
  103320:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103327:	00 
  103328:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  10332f:	00 
  103330:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103337:	e8 94 d9 ff ff       	call   100cd0 <__panic>
    free_list = free_list_store;
  10333c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10333f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103342:	a3 10 af 11 00       	mov    %eax,0x11af10
  103347:	89 15 14 af 11 00    	mov    %edx,0x11af14
    nr_free = nr_free_store;
  10334d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103350:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_page(p);
  103355:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10335c:	00 
  10335d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103360:	89 04 24             	mov    %eax,(%esp)
  103363:	e8 17 0a 00 00       	call   103d7f <free_pages>
    free_page(p1);
  103368:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10336f:	00 
  103370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103373:	89 04 24             	mov    %eax,(%esp)
  103376:	e8 04 0a 00 00       	call   103d7f <free_pages>
    free_page(p2);
  10337b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103382:	00 
  103383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103386:	89 04 24             	mov    %eax,(%esp)
  103389:	e8 f1 09 00 00       	call   103d7f <free_pages>
}
  10338e:	c9                   	leave  
  10338f:	c3                   	ret    

00103390 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  103390:	55                   	push   %ebp
  103391:	89 e5                	mov    %esp,%ebp
  103393:	53                   	push   %ebx
  103394:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  10339a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1033a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1033a8:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1033af:	eb 6b                	jmp    10341c <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  1033b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033b4:	83 e8 0c             	sub    $0xc,%eax
  1033b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  1033ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033bd:	83 c0 04             	add    $0x4,%eax
  1033c0:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1033c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1033ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1033cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1033d0:	0f a3 10             	bt     %edx,(%eax)
  1033d3:	19 c0                	sbb    %eax,%eax
  1033d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1033d8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1033dc:	0f 95 c0             	setne  %al
  1033df:	0f b6 c0             	movzbl %al,%eax
  1033e2:	85 c0                	test   %eax,%eax
  1033e4:	75 24                	jne    10340a <default_check+0x7a>
  1033e6:	c7 44 24 0c de 66 10 	movl   $0x1066de,0xc(%esp)
  1033ed:	00 
  1033ee:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1033f5:	00 
  1033f6:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  1033fd:	00 
  1033fe:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103405:	e8 c6 d8 ff ff       	call   100cd0 <__panic>
        count ++, total += p->property;
  10340a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10340e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103411:	8b 50 08             	mov    0x8(%eax),%edx
  103414:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103417:	01 d0                	add    %edx,%eax
  103419:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10341c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10341f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103422:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103425:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103428:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10342b:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  103432:	0f 85 79 ff ff ff    	jne    1033b1 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  103438:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  10343b:	e8 71 09 00 00       	call   103db1 <nr_free_pages>
  103440:	39 c3                	cmp    %eax,%ebx
  103442:	74 24                	je     103468 <default_check+0xd8>
  103444:	c7 44 24 0c ee 66 10 	movl   $0x1066ee,0xc(%esp)
  10344b:	00 
  10344c:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103453:	00 
  103454:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  10345b:	00 
  10345c:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103463:	e8 68 d8 ff ff       	call   100cd0 <__panic>

    basic_check();
  103468:	e8 e7 f9 ff ff       	call   102e54 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10346d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103474:	e8 ce 08 00 00       	call   103d47 <alloc_pages>
  103479:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  10347c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103480:	75 24                	jne    1034a6 <default_check+0x116>
  103482:	c7 44 24 0c 07 67 10 	movl   $0x106707,0xc(%esp)
  103489:	00 
  10348a:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103491:	00 
  103492:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  103499:	00 
  10349a:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1034a1:	e8 2a d8 ff ff       	call   100cd0 <__panic>
    assert(!PageProperty(p0));
  1034a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034a9:	83 c0 04             	add    $0x4,%eax
  1034ac:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1034b3:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1034b6:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1034b9:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1034bc:	0f a3 10             	bt     %edx,(%eax)
  1034bf:	19 c0                	sbb    %eax,%eax
  1034c1:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1034c4:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1034c8:	0f 95 c0             	setne  %al
  1034cb:	0f b6 c0             	movzbl %al,%eax
  1034ce:	85 c0                	test   %eax,%eax
  1034d0:	74 24                	je     1034f6 <default_check+0x166>
  1034d2:	c7 44 24 0c 12 67 10 	movl   $0x106712,0xc(%esp)
  1034d9:	00 
  1034da:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1034e1:	00 
  1034e2:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  1034e9:	00 
  1034ea:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1034f1:	e8 da d7 ff ff       	call   100cd0 <__panic>

    list_entry_t free_list_store = free_list;
  1034f6:	a1 10 af 11 00       	mov    0x11af10,%eax
  1034fb:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  103501:	89 45 80             	mov    %eax,-0x80(%ebp)
  103504:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103507:	c7 45 b4 10 af 11 00 	movl   $0x11af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10350e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103511:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103514:	89 50 04             	mov    %edx,0x4(%eax)
  103517:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10351a:	8b 50 04             	mov    0x4(%eax),%edx
  10351d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103520:	89 10                	mov    %edx,(%eax)
  103522:	c7 45 b0 10 af 11 00 	movl   $0x11af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103529:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10352c:	8b 40 04             	mov    0x4(%eax),%eax
  10352f:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  103532:	0f 94 c0             	sete   %al
  103535:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103538:	85 c0                	test   %eax,%eax
  10353a:	75 24                	jne    103560 <default_check+0x1d0>
  10353c:	c7 44 24 0c 67 66 10 	movl   $0x106667,0xc(%esp)
  103543:	00 
  103544:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10354b:	00 
  10354c:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  103553:	00 
  103554:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10355b:	e8 70 d7 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  103560:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103567:	e8 db 07 00 00       	call   103d47 <alloc_pages>
  10356c:	85 c0                	test   %eax,%eax
  10356e:	74 24                	je     103594 <default_check+0x204>
  103570:	c7 44 24 0c 7e 66 10 	movl   $0x10667e,0xc(%esp)
  103577:	00 
  103578:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10357f:	00 
  103580:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  103587:	00 
  103588:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10358f:	e8 3c d7 ff ff       	call   100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
  103594:	a1 18 af 11 00       	mov    0x11af18,%eax
  103599:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  10359c:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1035a3:	00 00 00 

    free_pages(p0 + 2, 3);
  1035a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1035a9:	83 c0 28             	add    $0x28,%eax
  1035ac:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1035b3:	00 
  1035b4:	89 04 24             	mov    %eax,(%esp)
  1035b7:	e8 c3 07 00 00       	call   103d7f <free_pages>
    assert(alloc_pages(4) == NULL);
  1035bc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1035c3:	e8 7f 07 00 00       	call   103d47 <alloc_pages>
  1035c8:	85 c0                	test   %eax,%eax
  1035ca:	74 24                	je     1035f0 <default_check+0x260>
  1035cc:	c7 44 24 0c 24 67 10 	movl   $0x106724,0xc(%esp)
  1035d3:	00 
  1035d4:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1035db:	00 
  1035dc:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  1035e3:	00 
  1035e4:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1035eb:	e8 e0 d6 ff ff       	call   100cd0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1035f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1035f3:	83 c0 28             	add    $0x28,%eax
  1035f6:	83 c0 04             	add    $0x4,%eax
  1035f9:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  103600:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103603:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103606:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103609:	0f a3 10             	bt     %edx,(%eax)
  10360c:	19 c0                	sbb    %eax,%eax
  10360e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  103611:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  103615:	0f 95 c0             	setne  %al
  103618:	0f b6 c0             	movzbl %al,%eax
  10361b:	85 c0                	test   %eax,%eax
  10361d:	74 0e                	je     10362d <default_check+0x29d>
  10361f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103622:	83 c0 28             	add    $0x28,%eax
  103625:	8b 40 08             	mov    0x8(%eax),%eax
  103628:	83 f8 03             	cmp    $0x3,%eax
  10362b:	74 24                	je     103651 <default_check+0x2c1>
  10362d:	c7 44 24 0c 3c 67 10 	movl   $0x10673c,0xc(%esp)
  103634:	00 
  103635:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10363c:	00 
  10363d:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  103644:	00 
  103645:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10364c:	e8 7f d6 ff ff       	call   100cd0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  103651:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103658:	e8 ea 06 00 00       	call   103d47 <alloc_pages>
  10365d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103660:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103664:	75 24                	jne    10368a <default_check+0x2fa>
  103666:	c7 44 24 0c 68 67 10 	movl   $0x106768,0xc(%esp)
  10366d:	00 
  10366e:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103675:	00 
  103676:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  10367d:	00 
  10367e:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103685:	e8 46 d6 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  10368a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103691:	e8 b1 06 00 00       	call   103d47 <alloc_pages>
  103696:	85 c0                	test   %eax,%eax
  103698:	74 24                	je     1036be <default_check+0x32e>
  10369a:	c7 44 24 0c 7e 66 10 	movl   $0x10667e,0xc(%esp)
  1036a1:	00 
  1036a2:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1036a9:	00 
  1036aa:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1036b1:	00 
  1036b2:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1036b9:	e8 12 d6 ff ff       	call   100cd0 <__panic>
    assert(p0 + 2 == p1);
  1036be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036c1:	83 c0 28             	add    $0x28,%eax
  1036c4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1036c7:	74 24                	je     1036ed <default_check+0x35d>
  1036c9:	c7 44 24 0c 86 67 10 	movl   $0x106786,0xc(%esp)
  1036d0:	00 
  1036d1:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1036d8:	00 
  1036d9:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  1036e0:	00 
  1036e1:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1036e8:	e8 e3 d5 ff ff       	call   100cd0 <__panic>

    p2 = p0 + 1;
  1036ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036f0:	83 c0 14             	add    $0x14,%eax
  1036f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  1036f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1036fd:	00 
  1036fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103701:	89 04 24             	mov    %eax,(%esp)
  103704:	e8 76 06 00 00       	call   103d7f <free_pages>
    free_pages(p1, 3);
  103709:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103710:	00 
  103711:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103714:	89 04 24             	mov    %eax,(%esp)
  103717:	e8 63 06 00 00       	call   103d7f <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10371c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10371f:	83 c0 04             	add    $0x4,%eax
  103722:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103729:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10372c:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10372f:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103732:	0f a3 10             	bt     %edx,(%eax)
  103735:	19 c0                	sbb    %eax,%eax
  103737:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  10373a:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  10373e:	0f 95 c0             	setne  %al
  103741:	0f b6 c0             	movzbl %al,%eax
  103744:	85 c0                	test   %eax,%eax
  103746:	74 0b                	je     103753 <default_check+0x3c3>
  103748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10374b:	8b 40 08             	mov    0x8(%eax),%eax
  10374e:	83 f8 01             	cmp    $0x1,%eax
  103751:	74 24                	je     103777 <default_check+0x3e7>
  103753:	c7 44 24 0c 94 67 10 	movl   $0x106794,0xc(%esp)
  10375a:	00 
  10375b:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103762:	00 
  103763:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  10376a:	00 
  10376b:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103772:	e8 59 d5 ff ff       	call   100cd0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103777:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10377a:	83 c0 04             	add    $0x4,%eax
  10377d:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103784:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103787:	8b 45 90             	mov    -0x70(%ebp),%eax
  10378a:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10378d:	0f a3 10             	bt     %edx,(%eax)
  103790:	19 c0                	sbb    %eax,%eax
  103792:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103795:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103799:	0f 95 c0             	setne  %al
  10379c:	0f b6 c0             	movzbl %al,%eax
  10379f:	85 c0                	test   %eax,%eax
  1037a1:	74 0b                	je     1037ae <default_check+0x41e>
  1037a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037a6:	8b 40 08             	mov    0x8(%eax),%eax
  1037a9:	83 f8 03             	cmp    $0x3,%eax
  1037ac:	74 24                	je     1037d2 <default_check+0x442>
  1037ae:	c7 44 24 0c bc 67 10 	movl   $0x1067bc,0xc(%esp)
  1037b5:	00 
  1037b6:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1037bd:	00 
  1037be:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1037c5:	00 
  1037c6:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1037cd:	e8 fe d4 ff ff       	call   100cd0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1037d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037d9:	e8 69 05 00 00       	call   103d47 <alloc_pages>
  1037de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1037e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1037e4:	83 e8 14             	sub    $0x14,%eax
  1037e7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1037ea:	74 24                	je     103810 <default_check+0x480>
  1037ec:	c7 44 24 0c e2 67 10 	movl   $0x1067e2,0xc(%esp)
  1037f3:	00 
  1037f4:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1037fb:	00 
  1037fc:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  103803:	00 
  103804:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10380b:	e8 c0 d4 ff ff       	call   100cd0 <__panic>
    free_page(p0);
  103810:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103817:	00 
  103818:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10381b:	89 04 24             	mov    %eax,(%esp)
  10381e:	e8 5c 05 00 00       	call   103d7f <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103823:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10382a:	e8 18 05 00 00       	call   103d47 <alloc_pages>
  10382f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103832:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103835:	83 c0 14             	add    $0x14,%eax
  103838:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10383b:	74 24                	je     103861 <default_check+0x4d1>
  10383d:	c7 44 24 0c 00 68 10 	movl   $0x106800,0xc(%esp)
  103844:	00 
  103845:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10384c:	00 
  10384d:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  103854:	00 
  103855:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10385c:	e8 6f d4 ff ff       	call   100cd0 <__panic>

    free_pages(p0, 2);
  103861:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103868:	00 
  103869:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10386c:	89 04 24             	mov    %eax,(%esp)
  10386f:	e8 0b 05 00 00       	call   103d7f <free_pages>
    free_page(p2);
  103874:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10387b:	00 
  10387c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10387f:	89 04 24             	mov    %eax,(%esp)
  103882:	e8 f8 04 00 00       	call   103d7f <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103887:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10388e:	e8 b4 04 00 00       	call   103d47 <alloc_pages>
  103893:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103896:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10389a:	75 24                	jne    1038c0 <default_check+0x530>
  10389c:	c7 44 24 0c 20 68 10 	movl   $0x106820,0xc(%esp)
  1038a3:	00 
  1038a4:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1038ab:	00 
  1038ac:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1038b3:	00 
  1038b4:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1038bb:	e8 10 d4 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  1038c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038c7:	e8 7b 04 00 00       	call   103d47 <alloc_pages>
  1038cc:	85 c0                	test   %eax,%eax
  1038ce:	74 24                	je     1038f4 <default_check+0x564>
  1038d0:	c7 44 24 0c 7e 66 10 	movl   $0x10667e,0xc(%esp)
  1038d7:	00 
  1038d8:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1038df:	00 
  1038e0:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1038e7:	00 
  1038e8:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1038ef:	e8 dc d3 ff ff       	call   100cd0 <__panic>

    assert(nr_free == 0);
  1038f4:	a1 18 af 11 00       	mov    0x11af18,%eax
  1038f9:	85 c0                	test   %eax,%eax
  1038fb:	74 24                	je     103921 <default_check+0x591>
  1038fd:	c7 44 24 0c d1 66 10 	movl   $0x1066d1,0xc(%esp)
  103904:	00 
  103905:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10390c:	00 
  10390d:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  103914:	00 
  103915:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10391c:	e8 af d3 ff ff       	call   100cd0 <__panic>
    nr_free = nr_free_store;
  103921:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103924:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_list = free_list_store;
  103929:	8b 45 80             	mov    -0x80(%ebp),%eax
  10392c:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10392f:	a3 10 af 11 00       	mov    %eax,0x11af10
  103934:	89 15 14 af 11 00    	mov    %edx,0x11af14
    free_pages(p0, 5);
  10393a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103941:	00 
  103942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103945:	89 04 24             	mov    %eax,(%esp)
  103948:	e8 32 04 00 00       	call   103d7f <free_pages>

    le = &free_list;
  10394d:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103954:	eb 5b                	jmp    1039b1 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  103956:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103959:	8b 40 04             	mov    0x4(%eax),%eax
  10395c:	8b 00                	mov    (%eax),%eax
  10395e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103961:	75 0d                	jne    103970 <default_check+0x5e0>
  103963:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103966:	8b 00                	mov    (%eax),%eax
  103968:	8b 40 04             	mov    0x4(%eax),%eax
  10396b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10396e:	74 24                	je     103994 <default_check+0x604>
  103970:	c7 44 24 0c 40 68 10 	movl   $0x106840,0xc(%esp)
  103977:	00 
  103978:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  10397f:	00 
  103980:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  103987:	00 
  103988:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  10398f:	e8 3c d3 ff ff       	call   100cd0 <__panic>
        struct Page *p = le2page(le, page_link);
  103994:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103997:	83 e8 0c             	sub    $0xc,%eax
  10399a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  10399d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1039a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1039a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1039a7:	8b 40 08             	mov    0x8(%eax),%eax
  1039aa:	29 c2                	sub    %eax,%edx
  1039ac:	89 d0                	mov    %edx,%eax
  1039ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1039b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039b4:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1039b7:	8b 45 88             	mov    -0x78(%ebp),%eax
  1039ba:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1039bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1039c0:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  1039c7:	75 8d                	jne    103956 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  1039c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1039cd:	74 24                	je     1039f3 <default_check+0x663>
  1039cf:	c7 44 24 0c 6d 68 10 	movl   $0x10686d,0xc(%esp)
  1039d6:	00 
  1039d7:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  1039de:	00 
  1039df:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  1039e6:	00 
  1039e7:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  1039ee:	e8 dd d2 ff ff       	call   100cd0 <__panic>
    assert(total == 0);
  1039f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1039f7:	74 24                	je     103a1d <default_check+0x68d>
  1039f9:	c7 44 24 0c 78 68 10 	movl   $0x106878,0xc(%esp)
  103a00:	00 
  103a01:	c7 44 24 08 f6 64 10 	movl   $0x1064f6,0x8(%esp)
  103a08:	00 
  103a09:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  103a10:	00 
  103a11:	c7 04 24 0b 65 10 00 	movl   $0x10650b,(%esp)
  103a18:	e8 b3 d2 ff ff       	call   100cd0 <__panic>
}
  103a1d:	81 c4 94 00 00 00    	add    $0x94,%esp
  103a23:	5b                   	pop    %ebx
  103a24:	5d                   	pop    %ebp
  103a25:	c3                   	ret    

00103a26 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103a26:	55                   	push   %ebp
  103a27:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103a29:	8b 55 08             	mov    0x8(%ebp),%edx
  103a2c:	a1 24 af 11 00       	mov    0x11af24,%eax
  103a31:	29 c2                	sub    %eax,%edx
  103a33:	89 d0                	mov    %edx,%eax
  103a35:	c1 f8 02             	sar    $0x2,%eax
  103a38:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103a3e:	5d                   	pop    %ebp
  103a3f:	c3                   	ret    

00103a40 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103a40:	55                   	push   %ebp
  103a41:	89 e5                	mov    %esp,%ebp
  103a43:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103a46:	8b 45 08             	mov    0x8(%ebp),%eax
  103a49:	89 04 24             	mov    %eax,(%esp)
  103a4c:	e8 d5 ff ff ff       	call   103a26 <page2ppn>
  103a51:	c1 e0 0c             	shl    $0xc,%eax
}
  103a54:	c9                   	leave  
  103a55:	c3                   	ret    

00103a56 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103a56:	55                   	push   %ebp
  103a57:	89 e5                	mov    %esp,%ebp
  103a59:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  103a5f:	c1 e8 0c             	shr    $0xc,%eax
  103a62:	89 c2                	mov    %eax,%edx
  103a64:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103a69:	39 c2                	cmp    %eax,%edx
  103a6b:	72 1c                	jb     103a89 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103a6d:	c7 44 24 08 b4 68 10 	movl   $0x1068b4,0x8(%esp)
  103a74:	00 
  103a75:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103a7c:	00 
  103a7d:	c7 04 24 d3 68 10 00 	movl   $0x1068d3,(%esp)
  103a84:	e8 47 d2 ff ff       	call   100cd0 <__panic>
    }
    return &pages[PPN(pa)];
  103a89:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  103a92:	c1 e8 0c             	shr    $0xc,%eax
  103a95:	89 c2                	mov    %eax,%edx
  103a97:	89 d0                	mov    %edx,%eax
  103a99:	c1 e0 02             	shl    $0x2,%eax
  103a9c:	01 d0                	add    %edx,%eax
  103a9e:	c1 e0 02             	shl    $0x2,%eax
  103aa1:	01 c8                	add    %ecx,%eax
}
  103aa3:	c9                   	leave  
  103aa4:	c3                   	ret    

00103aa5 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103aa5:	55                   	push   %ebp
  103aa6:	89 e5                	mov    %esp,%ebp
  103aa8:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103aab:	8b 45 08             	mov    0x8(%ebp),%eax
  103aae:	89 04 24             	mov    %eax,(%esp)
  103ab1:	e8 8a ff ff ff       	call   103a40 <page2pa>
  103ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103abc:	c1 e8 0c             	shr    $0xc,%eax
  103abf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ac2:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103ac7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103aca:	72 23                	jb     103aef <page2kva+0x4a>
  103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103ad3:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  103ada:	00 
  103adb:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103ae2:	00 
  103ae3:	c7 04 24 d3 68 10 00 	movl   $0x1068d3,(%esp)
  103aea:	e8 e1 d1 ff ff       	call   100cd0 <__panic>
  103aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103af2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103af7:	c9                   	leave  
  103af8:	c3                   	ret    

00103af9 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103af9:	55                   	push   %ebp
  103afa:	89 e5                	mov    %esp,%ebp
  103afc:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103aff:	8b 45 08             	mov    0x8(%ebp),%eax
  103b02:	83 e0 01             	and    $0x1,%eax
  103b05:	85 c0                	test   %eax,%eax
  103b07:	75 1c                	jne    103b25 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103b09:	c7 44 24 08 08 69 10 	movl   $0x106908,0x8(%esp)
  103b10:	00 
  103b11:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103b18:	00 
  103b19:	c7 04 24 d3 68 10 00 	movl   $0x1068d3,(%esp)
  103b20:	e8 ab d1 ff ff       	call   100cd0 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103b25:	8b 45 08             	mov    0x8(%ebp),%eax
  103b28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b2d:	89 04 24             	mov    %eax,(%esp)
  103b30:	e8 21 ff ff ff       	call   103a56 <pa2page>
}
  103b35:	c9                   	leave  
  103b36:	c3                   	ret    

00103b37 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103b37:	55                   	push   %ebp
  103b38:	89 e5                	mov    %esp,%ebp
  103b3a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  103b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b45:	89 04 24             	mov    %eax,(%esp)
  103b48:	e8 09 ff ff ff       	call   103a56 <pa2page>
}
  103b4d:	c9                   	leave  
  103b4e:	c3                   	ret    

00103b4f <page_ref>:

static inline int
page_ref(struct Page *page) {
  103b4f:	55                   	push   %ebp
  103b50:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103b52:	8b 45 08             	mov    0x8(%ebp),%eax
  103b55:	8b 00                	mov    (%eax),%eax
}
  103b57:	5d                   	pop    %ebp
  103b58:	c3                   	ret    

00103b59 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
  103b59:	55                   	push   %ebp
  103b5a:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  103b5f:	8b 00                	mov    (%eax),%eax
  103b61:	8d 50 01             	lea    0x1(%eax),%edx
  103b64:	8b 45 08             	mov    0x8(%ebp),%eax
  103b67:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b69:	8b 45 08             	mov    0x8(%ebp),%eax
  103b6c:	8b 00                	mov    (%eax),%eax
}
  103b6e:	5d                   	pop    %ebp
  103b6f:	c3                   	ret    

00103b70 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103b70:	55                   	push   %ebp
  103b71:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103b73:	8b 45 08             	mov    0x8(%ebp),%eax
  103b76:	8b 00                	mov    (%eax),%eax
  103b78:	8d 50 ff             	lea    -0x1(%eax),%edx
  103b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  103b7e:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b80:	8b 45 08             	mov    0x8(%ebp),%eax
  103b83:	8b 00                	mov    (%eax),%eax
}
  103b85:	5d                   	pop    %ebp
  103b86:	c3                   	ret    

00103b87 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103b87:	55                   	push   %ebp
  103b88:	89 e5                	mov    %esp,%ebp
  103b8a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103b8d:	9c                   	pushf  
  103b8e:	58                   	pop    %eax
  103b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103b95:	25 00 02 00 00       	and    $0x200,%eax
  103b9a:	85 c0                	test   %eax,%eax
  103b9c:	74 0c                	je     103baa <__intr_save+0x23>
        intr_disable();
  103b9e:	e8 21 db ff ff       	call   1016c4 <intr_disable>
        return 1;
  103ba3:	b8 01 00 00 00       	mov    $0x1,%eax
  103ba8:	eb 05                	jmp    103baf <__intr_save+0x28>
    }
    return 0;
  103baa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103baf:	c9                   	leave  
  103bb0:	c3                   	ret    

00103bb1 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103bb1:	55                   	push   %ebp
  103bb2:	89 e5                	mov    %esp,%ebp
  103bb4:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103bb7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103bbb:	74 05                	je     103bc2 <__intr_restore+0x11>
        intr_enable();
  103bbd:	e8 fc da ff ff       	call   1016be <intr_enable>
    }
}
  103bc2:	c9                   	leave  
  103bc3:	c3                   	ret    

00103bc4 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103bc4:	55                   	push   %ebp
  103bc5:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  103bca:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103bcd:	b8 23 00 00 00       	mov    $0x23,%eax
  103bd2:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103bd4:	b8 23 00 00 00       	mov    $0x23,%eax
  103bd9:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103bdb:	b8 10 00 00 00       	mov    $0x10,%eax
  103be0:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103be2:	b8 10 00 00 00       	mov    $0x10,%eax
  103be7:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103be9:	b8 10 00 00 00       	mov    $0x10,%eax
  103bee:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103bf0:	ea f7 3b 10 00 08 00 	ljmp   $0x8,$0x103bf7
}
  103bf7:	5d                   	pop    %ebp
  103bf8:	c3                   	ret    

00103bf9 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103bf9:	55                   	push   %ebp
  103bfa:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  103bff:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103c04:	5d                   	pop    %ebp
  103c05:	c3                   	ret    

00103c06 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103c06:	55                   	push   %ebp
  103c07:	89 e5                	mov    %esp,%ebp
  103c09:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103c0c:	b8 00 70 11 00       	mov    $0x117000,%eax
  103c11:	89 04 24             	mov    %eax,(%esp)
  103c14:	e8 e0 ff ff ff       	call   103bf9 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103c19:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103c20:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103c22:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103c29:	68 00 
  103c2b:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c30:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103c36:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c3b:	c1 e8 10             	shr    $0x10,%eax
  103c3e:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103c43:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c4a:	83 e0 f0             	and    $0xfffffff0,%eax
  103c4d:	83 c8 09             	or     $0x9,%eax
  103c50:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c55:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c5c:	83 e0 ef             	and    $0xffffffef,%eax
  103c5f:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c64:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c6b:	83 e0 9f             	and    $0xffffff9f,%eax
  103c6e:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c73:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c7a:	83 c8 80             	or     $0xffffff80,%eax
  103c7d:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c82:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c89:	83 e0 f0             	and    $0xfffffff0,%eax
  103c8c:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103c91:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c98:	83 e0 ef             	and    $0xffffffef,%eax
  103c9b:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ca0:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ca7:	83 e0 df             	and    $0xffffffdf,%eax
  103caa:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103caf:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cb6:	83 c8 40             	or     $0x40,%eax
  103cb9:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cbe:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cc5:	83 e0 7f             	and    $0x7f,%eax
  103cc8:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ccd:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103cd2:	c1 e8 18             	shr    $0x18,%eax
  103cd5:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103cda:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103ce1:	e8 de fe ff ff       	call   103bc4 <lgdt>
  103ce6:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103cec:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103cf0:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103cf3:	c9                   	leave  
  103cf4:	c3                   	ret    

00103cf5 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103cf5:	55                   	push   %ebp
  103cf6:	89 e5                	mov    %esp,%ebp
  103cf8:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103cfb:	c7 05 1c af 11 00 98 	movl   $0x106898,0x11af1c
  103d02:	68 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103d05:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d0a:	8b 00                	mov    (%eax),%eax
  103d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d10:	c7 04 24 34 69 10 00 	movl   $0x106934,(%esp)
  103d17:	e8 2c c6 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  103d1c:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d21:	8b 40 04             	mov    0x4(%eax),%eax
  103d24:	ff d0                	call   *%eax
}
  103d26:	c9                   	leave  
  103d27:	c3                   	ret    

00103d28 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103d28:	55                   	push   %ebp
  103d29:	89 e5                	mov    %esp,%ebp
  103d2b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103d2e:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d33:	8b 40 08             	mov    0x8(%eax),%eax
  103d36:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d39:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  103d40:	89 14 24             	mov    %edx,(%esp)
  103d43:	ff d0                	call   *%eax
}
  103d45:	c9                   	leave  
  103d46:	c3                   	ret    

00103d47 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103d47:	55                   	push   %ebp
  103d48:	89 e5                	mov    %esp,%ebp
  103d4a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103d4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103d54:	e8 2e fe ff ff       	call   103b87 <__intr_save>
  103d59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103d5c:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d61:	8b 40 0c             	mov    0xc(%eax),%eax
  103d64:	8b 55 08             	mov    0x8(%ebp),%edx
  103d67:	89 14 24             	mov    %edx,(%esp)
  103d6a:	ff d0                	call   *%eax
  103d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d72:	89 04 24             	mov    %eax,(%esp)
  103d75:	e8 37 fe ff ff       	call   103bb1 <__intr_restore>
    return page;
  103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103d7d:	c9                   	leave  
  103d7e:	c3                   	ret    

00103d7f <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103d7f:	55                   	push   %ebp
  103d80:	89 e5                	mov    %esp,%ebp
  103d82:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103d85:	e8 fd fd ff ff       	call   103b87 <__intr_save>
  103d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103d8d:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d92:	8b 40 10             	mov    0x10(%eax),%eax
  103d95:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d98:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  103d9f:	89 14 24             	mov    %edx,(%esp)
  103da2:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103da7:	89 04 24             	mov    %eax,(%esp)
  103daa:	e8 02 fe ff ff       	call   103bb1 <__intr_restore>
}
  103daf:	c9                   	leave  
  103db0:	c3                   	ret    

00103db1 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103db1:	55                   	push   %ebp
  103db2:	89 e5                	mov    %esp,%ebp
  103db4:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103db7:	e8 cb fd ff ff       	call   103b87 <__intr_save>
  103dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103dbf:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103dc4:	8b 40 14             	mov    0x14(%eax),%eax
  103dc7:	ff d0                	call   *%eax
  103dc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103dcf:	89 04 24             	mov    %eax,(%esp)
  103dd2:	e8 da fd ff ff       	call   103bb1 <__intr_restore>
    return ret;
  103dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103dda:	c9                   	leave  
  103ddb:	c3                   	ret    

00103ddc <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103ddc:	55                   	push   %ebp
  103ddd:	89 e5                	mov    %esp,%ebp
  103ddf:	57                   	push   %edi
  103de0:	56                   	push   %esi
  103de1:	53                   	push   %ebx
  103de2:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103de8:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103def:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103df6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103dfd:	c7 04 24 4b 69 10 00 	movl   $0x10694b,(%esp)
  103e04:	e8 3f c5 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103e09:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103e10:	e9 15 01 00 00       	jmp    103f2a <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103e15:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e1b:	89 d0                	mov    %edx,%eax
  103e1d:	c1 e0 02             	shl    $0x2,%eax
  103e20:	01 d0                	add    %edx,%eax
  103e22:	c1 e0 02             	shl    $0x2,%eax
  103e25:	01 c8                	add    %ecx,%eax
  103e27:	8b 50 08             	mov    0x8(%eax),%edx
  103e2a:	8b 40 04             	mov    0x4(%eax),%eax
  103e2d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103e30:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103e33:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e36:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e39:	89 d0                	mov    %edx,%eax
  103e3b:	c1 e0 02             	shl    $0x2,%eax
  103e3e:	01 d0                	add    %edx,%eax
  103e40:	c1 e0 02             	shl    $0x2,%eax
  103e43:	01 c8                	add    %ecx,%eax
  103e45:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e48:	8b 58 10             	mov    0x10(%eax),%ebx
  103e4b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103e4e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103e51:	01 c8                	add    %ecx,%eax
  103e53:	11 da                	adc    %ebx,%edx
  103e55:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103e58:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103e5b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e61:	89 d0                	mov    %edx,%eax
  103e63:	c1 e0 02             	shl    $0x2,%eax
  103e66:	01 d0                	add    %edx,%eax
  103e68:	c1 e0 02             	shl    $0x2,%eax
  103e6b:	01 c8                	add    %ecx,%eax
  103e6d:	83 c0 14             	add    $0x14,%eax
  103e70:	8b 00                	mov    (%eax),%eax
  103e72:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103e78:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103e7b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103e7e:	83 c0 ff             	add    $0xffffffff,%eax
  103e81:	83 d2 ff             	adc    $0xffffffff,%edx
  103e84:	89 c6                	mov    %eax,%esi
  103e86:	89 d7                	mov    %edx,%edi
  103e88:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e8b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e8e:	89 d0                	mov    %edx,%eax
  103e90:	c1 e0 02             	shl    $0x2,%eax
  103e93:	01 d0                	add    %edx,%eax
  103e95:	c1 e0 02             	shl    $0x2,%eax
  103e98:	01 c8                	add    %ecx,%eax
  103e9a:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e9d:	8b 58 10             	mov    0x10(%eax),%ebx
  103ea0:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103ea6:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103eaa:	89 74 24 14          	mov    %esi,0x14(%esp)
  103eae:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103eb2:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103eb5:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103ebc:	89 54 24 10          	mov    %edx,0x10(%esp)
  103ec0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103ec4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103ec8:	c7 04 24 58 69 10 00 	movl   $0x106958,(%esp)
  103ecf:	e8 74 c4 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103ed4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ed7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103eda:	89 d0                	mov    %edx,%eax
  103edc:	c1 e0 02             	shl    $0x2,%eax
  103edf:	01 d0                	add    %edx,%eax
  103ee1:	c1 e0 02             	shl    $0x2,%eax
  103ee4:	01 c8                	add    %ecx,%eax
  103ee6:	83 c0 14             	add    $0x14,%eax
  103ee9:	8b 00                	mov    (%eax),%eax
  103eeb:	83 f8 01             	cmp    $0x1,%eax
  103eee:	75 36                	jne    103f26 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103ef3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103ef6:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103ef9:	77 2b                	ja     103f26 <page_init+0x14a>
  103efb:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103efe:	72 05                	jb     103f05 <page_init+0x129>
  103f00:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103f03:	73 21                	jae    103f26 <page_init+0x14a>
  103f05:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f09:	77 1b                	ja     103f26 <page_init+0x14a>
  103f0b:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f0f:	72 09                	jb     103f1a <page_init+0x13e>
  103f11:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103f18:	77 0c                	ja     103f26 <page_init+0x14a>
                maxpa = end;
  103f1a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f1d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103f23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103f26:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103f2a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103f2d:	8b 00                	mov    (%eax),%eax
  103f2f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103f32:	0f 8f dd fe ff ff    	jg     103e15 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103f38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f3c:	72 1d                	jb     103f5b <page_init+0x17f>
  103f3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f42:	77 09                	ja     103f4d <page_init+0x171>
  103f44:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103f4b:	76 0e                	jbe    103f5b <page_init+0x17f>
        maxpa = KMEMSIZE;
  103f4d:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103f54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f61:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103f65:	c1 ea 0c             	shr    $0xc,%edx
  103f68:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103f6d:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103f74:	b8 28 af 11 00       	mov    $0x11af28,%eax
  103f79:	8d 50 ff             	lea    -0x1(%eax),%edx
  103f7c:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103f7f:	01 d0                	add    %edx,%eax
  103f81:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103f84:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103f87:	ba 00 00 00 00       	mov    $0x0,%edx
  103f8c:	f7 75 ac             	divl   -0x54(%ebp)
  103f8f:	89 d0                	mov    %edx,%eax
  103f91:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103f94:	29 c2                	sub    %eax,%edx
  103f96:	89 d0                	mov    %edx,%eax
  103f98:	a3 24 af 11 00       	mov    %eax,0x11af24

    for (i = 0; i < npage; i ++) {
  103f9d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fa4:	eb 2f                	jmp    103fd5 <page_init+0x1f9>
        SetPageReserved(pages + i);
  103fa6:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103fac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103faf:	89 d0                	mov    %edx,%eax
  103fb1:	c1 e0 02             	shl    $0x2,%eax
  103fb4:	01 d0                	add    %edx,%eax
  103fb6:	c1 e0 02             	shl    $0x2,%eax
  103fb9:	01 c8                	add    %ecx,%eax
  103fbb:	83 c0 04             	add    $0x4,%eax
  103fbe:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  103fc5:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103fc8:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103fcb:	8b 55 90             	mov    -0x70(%ebp),%edx
  103fce:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  103fd1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103fd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fd8:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103fdd:	39 c2                	cmp    %eax,%edx
  103fdf:	72 c5                	jb     103fa6 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103fe1:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103fe7:	89 d0                	mov    %edx,%eax
  103fe9:	c1 e0 02             	shl    $0x2,%eax
  103fec:	01 d0                	add    %edx,%eax
  103fee:	c1 e0 02             	shl    $0x2,%eax
  103ff1:	89 c2                	mov    %eax,%edx
  103ff3:	a1 24 af 11 00       	mov    0x11af24,%eax
  103ff8:	01 d0                	add    %edx,%eax
  103ffa:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  103ffd:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  104004:	77 23                	ja     104029 <page_init+0x24d>
  104006:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10400d:	c7 44 24 08 88 69 10 	movl   $0x106988,0x8(%esp)
  104014:	00 
  104015:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10401c:	00 
  10401d:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104024:	e8 a7 cc ff ff       	call   100cd0 <__panic>
  104029:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10402c:	05 00 00 00 40       	add    $0x40000000,%eax
  104031:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104034:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10403b:	e9 74 01 00 00       	jmp    1041b4 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104040:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104043:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104046:	89 d0                	mov    %edx,%eax
  104048:	c1 e0 02             	shl    $0x2,%eax
  10404b:	01 d0                	add    %edx,%eax
  10404d:	c1 e0 02             	shl    $0x2,%eax
  104050:	01 c8                	add    %ecx,%eax
  104052:	8b 50 08             	mov    0x8(%eax),%edx
  104055:	8b 40 04             	mov    0x4(%eax),%eax
  104058:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10405b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10405e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104061:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104064:	89 d0                	mov    %edx,%eax
  104066:	c1 e0 02             	shl    $0x2,%eax
  104069:	01 d0                	add    %edx,%eax
  10406b:	c1 e0 02             	shl    $0x2,%eax
  10406e:	01 c8                	add    %ecx,%eax
  104070:	8b 48 0c             	mov    0xc(%eax),%ecx
  104073:	8b 58 10             	mov    0x10(%eax),%ebx
  104076:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104079:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10407c:	01 c8                	add    %ecx,%eax
  10407e:	11 da                	adc    %ebx,%edx
  104080:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104083:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104086:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104089:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10408c:	89 d0                	mov    %edx,%eax
  10408e:	c1 e0 02             	shl    $0x2,%eax
  104091:	01 d0                	add    %edx,%eax
  104093:	c1 e0 02             	shl    $0x2,%eax
  104096:	01 c8                	add    %ecx,%eax
  104098:	83 c0 14             	add    $0x14,%eax
  10409b:	8b 00                	mov    (%eax),%eax
  10409d:	83 f8 01             	cmp    $0x1,%eax
  1040a0:	0f 85 0a 01 00 00    	jne    1041b0 <page_init+0x3d4>
            if (begin < freemem) {
  1040a6:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040a9:	ba 00 00 00 00       	mov    $0x0,%edx
  1040ae:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040b1:	72 17                	jb     1040ca <page_init+0x2ee>
  1040b3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040b6:	77 05                	ja     1040bd <page_init+0x2e1>
  1040b8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1040bb:	76 0d                	jbe    1040ca <page_init+0x2ee>
                begin = freemem;
  1040bd:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1040ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1040ce:	72 1d                	jb     1040ed <page_init+0x311>
  1040d0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1040d4:	77 09                	ja     1040df <page_init+0x303>
  1040d6:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1040dd:	76 0e                	jbe    1040ed <page_init+0x311>
                end = KMEMSIZE;
  1040df:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1040e6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1040ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1040f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1040f3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1040f6:	0f 87 b4 00 00 00    	ja     1041b0 <page_init+0x3d4>
  1040fc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1040ff:	72 09                	jb     10410a <page_init+0x32e>
  104101:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104104:	0f 83 a6 00 00 00    	jae    1041b0 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  10410a:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104111:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104114:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104117:	01 d0                	add    %edx,%eax
  104119:	83 e8 01             	sub    $0x1,%eax
  10411c:	89 45 98             	mov    %eax,-0x68(%ebp)
  10411f:	8b 45 98             	mov    -0x68(%ebp),%eax
  104122:	ba 00 00 00 00       	mov    $0x0,%edx
  104127:	f7 75 9c             	divl   -0x64(%ebp)
  10412a:	89 d0                	mov    %edx,%eax
  10412c:	8b 55 98             	mov    -0x68(%ebp),%edx
  10412f:	29 c2                	sub    %eax,%edx
  104131:	89 d0                	mov    %edx,%eax
  104133:	ba 00 00 00 00       	mov    $0x0,%edx
  104138:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10413b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  10413e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104141:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104144:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104147:	ba 00 00 00 00       	mov    $0x0,%edx
  10414c:	89 c7                	mov    %eax,%edi
  10414e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104154:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104157:	89 d0                	mov    %edx,%eax
  104159:	83 e0 00             	and    $0x0,%eax
  10415c:	89 45 84             	mov    %eax,-0x7c(%ebp)
  10415f:	8b 45 80             	mov    -0x80(%ebp),%eax
  104162:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104165:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104168:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  10416b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10416e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104171:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104174:	77 3a                	ja     1041b0 <page_init+0x3d4>
  104176:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104179:	72 05                	jb     104180 <page_init+0x3a4>
  10417b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10417e:	73 30                	jae    1041b0 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104180:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  104183:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104186:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104189:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10418c:	29 c8                	sub    %ecx,%eax
  10418e:	19 da                	sbb    %ebx,%edx
  104190:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104194:	c1 ea 0c             	shr    $0xc,%edx
  104197:	89 c3                	mov    %eax,%ebx
  104199:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10419c:	89 04 24             	mov    %eax,(%esp)
  10419f:	e8 b2 f8 ff ff       	call   103a56 <pa2page>
  1041a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041a8:	89 04 24             	mov    %eax,(%esp)
  1041ab:	e8 78 fb ff ff       	call   103d28 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  1041b0:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1041b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1041b7:	8b 00                	mov    (%eax),%eax
  1041b9:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1041bc:	0f 8f 7e fe ff ff    	jg     104040 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  1041c2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1041c8:	5b                   	pop    %ebx
  1041c9:	5e                   	pop    %esi
  1041ca:	5f                   	pop    %edi
  1041cb:	5d                   	pop    %ebp
  1041cc:	c3                   	ret    

001041cd <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1041cd:	55                   	push   %ebp
  1041ce:	89 e5                	mov    %esp,%ebp
  1041d0:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1041d3:	8b 45 14             	mov    0x14(%ebp),%eax
  1041d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1041d9:	31 d0                	xor    %edx,%eax
  1041db:	25 ff 0f 00 00       	and    $0xfff,%eax
  1041e0:	85 c0                	test   %eax,%eax
  1041e2:	74 24                	je     104208 <boot_map_segment+0x3b>
  1041e4:	c7 44 24 0c ba 69 10 	movl   $0x1069ba,0xc(%esp)
  1041eb:	00 
  1041ec:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  1041f3:	00 
  1041f4:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1041fb:	00 
  1041fc:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104203:	e8 c8 ca ff ff       	call   100cd0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104208:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10420f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104212:	25 ff 0f 00 00       	and    $0xfff,%eax
  104217:	89 c2                	mov    %eax,%edx
  104219:	8b 45 10             	mov    0x10(%ebp),%eax
  10421c:	01 c2                	add    %eax,%edx
  10421e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104221:	01 d0                	add    %edx,%eax
  104223:	83 e8 01             	sub    $0x1,%eax
  104226:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104229:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10422c:	ba 00 00 00 00       	mov    $0x0,%edx
  104231:	f7 75 f0             	divl   -0x10(%ebp)
  104234:	89 d0                	mov    %edx,%eax
  104236:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104239:	29 c2                	sub    %eax,%edx
  10423b:	89 d0                	mov    %edx,%eax
  10423d:	c1 e8 0c             	shr    $0xc,%eax
  104240:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104243:	8b 45 0c             	mov    0xc(%ebp),%eax
  104246:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104249:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10424c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104251:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104254:	8b 45 14             	mov    0x14(%ebp),%eax
  104257:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10425a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10425d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104262:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104265:	eb 6b                	jmp    1042d2 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104267:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10426e:	00 
  10426f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104272:	89 44 24 04          	mov    %eax,0x4(%esp)
  104276:	8b 45 08             	mov    0x8(%ebp),%eax
  104279:	89 04 24             	mov    %eax,(%esp)
  10427c:	e8 82 01 00 00       	call   104403 <get_pte>
  104281:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104284:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104288:	75 24                	jne    1042ae <boot_map_segment+0xe1>
  10428a:	c7 44 24 0c e6 69 10 	movl   $0x1069e6,0xc(%esp)
  104291:	00 
  104292:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104299:	00 
  10429a:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1042a1:	00 
  1042a2:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1042a9:	e8 22 ca ff ff       	call   100cd0 <__panic>
        *ptep = pa | PTE_P | perm;
  1042ae:	8b 45 18             	mov    0x18(%ebp),%eax
  1042b1:	8b 55 14             	mov    0x14(%ebp),%edx
  1042b4:	09 d0                	or     %edx,%eax
  1042b6:	83 c8 01             	or     $0x1,%eax
  1042b9:	89 c2                	mov    %eax,%edx
  1042bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1042be:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1042c0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1042c4:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1042cb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1042d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1042d6:	75 8f                	jne    104267 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  1042d8:	c9                   	leave  
  1042d9:	c3                   	ret    

001042da <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1042da:	55                   	push   %ebp
  1042db:	89 e5                	mov    %esp,%ebp
  1042dd:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1042e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1042e7:	e8 5b fa ff ff       	call   103d47 <alloc_pages>
  1042ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1042ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1042f3:	75 1c                	jne    104311 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1042f5:	c7 44 24 08 f3 69 10 	movl   $0x1069f3,0x8(%esp)
  1042fc:	00 
  1042fd:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104304:	00 
  104305:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10430c:	e8 bf c9 ff ff       	call   100cd0 <__panic>
    }
    return page2kva(p);
  104311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104314:	89 04 24             	mov    %eax,(%esp)
  104317:	e8 89 f7 ff ff       	call   103aa5 <page2kva>
}
  10431c:	c9                   	leave  
  10431d:	c3                   	ret    

0010431e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10431e:	55                   	push   %ebp
  10431f:	89 e5                	mov    %esp,%ebp
  104321:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104324:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104329:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10432c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104333:	77 23                	ja     104358 <pmm_init+0x3a>
  104335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104338:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10433c:	c7 44 24 08 88 69 10 	movl   $0x106988,0x8(%esp)
  104343:	00 
  104344:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  10434b:	00 
  10434c:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104353:	e8 78 c9 ff ff       	call   100cd0 <__panic>
  104358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10435b:	05 00 00 00 40       	add    $0x40000000,%eax
  104360:	a3 20 af 11 00       	mov    %eax,0x11af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  104365:	e8 8b f9 ff ff       	call   103cf5 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10436a:	e8 6d fa ff ff       	call   103ddc <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10436f:	e8 4c 02 00 00       	call   1045c0 <check_alloc_page>

    check_pgdir();
  104374:	e8 65 02 00 00       	call   1045de <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  104379:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10437e:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  104384:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104389:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10438c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104393:	77 23                	ja     1043b8 <pmm_init+0x9a>
  104395:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104398:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10439c:	c7 44 24 08 88 69 10 	movl   $0x106988,0x8(%esp)
  1043a3:	00 
  1043a4:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1043ab:	00 
  1043ac:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1043b3:	e8 18 c9 ff ff       	call   100cd0 <__panic>
  1043b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043bb:	05 00 00 00 40       	add    $0x40000000,%eax
  1043c0:	83 c8 03             	or     $0x3,%eax
  1043c3:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1043c5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043ca:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1043d1:	00 
  1043d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1043d9:	00 
  1043da:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1043e1:	38 
  1043e2:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1043e9:	c0 
  1043ea:	89 04 24             	mov    %eax,(%esp)
  1043ed:	e8 db fd ff ff       	call   1041cd <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1043f2:	e8 0f f8 ff ff       	call   103c06 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1043f7:	e8 7d 08 00 00       	call   104c79 <check_boot_pgdir>

    print_pgdir();
  1043fc:	e8 05 0d 00 00       	call   105106 <print_pgdir>

}
  104401:	c9                   	leave  
  104402:	c3                   	ret    

00104403 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  104403:	55                   	push   %ebp
  104404:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  104406:	5d                   	pop    %ebp
  104407:	c3                   	ret    

00104408 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  104408:	55                   	push   %ebp
  104409:	89 e5                	mov    %esp,%ebp
  10440b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10440e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104415:	00 
  104416:	8b 45 0c             	mov    0xc(%ebp),%eax
  104419:	89 44 24 04          	mov    %eax,0x4(%esp)
  10441d:	8b 45 08             	mov    0x8(%ebp),%eax
  104420:	89 04 24             	mov    %eax,(%esp)
  104423:	e8 db ff ff ff       	call   104403 <get_pte>
  104428:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10442b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10442f:	74 08                	je     104439 <get_page+0x31>
        *ptep_store = ptep;
  104431:	8b 45 10             	mov    0x10(%ebp),%eax
  104434:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104437:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10443d:	74 1b                	je     10445a <get_page+0x52>
  10443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104442:	8b 00                	mov    (%eax),%eax
  104444:	83 e0 01             	and    $0x1,%eax
  104447:	85 c0                	test   %eax,%eax
  104449:	74 0f                	je     10445a <get_page+0x52>
        return pte2page(*ptep);
  10444b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10444e:	8b 00                	mov    (%eax),%eax
  104450:	89 04 24             	mov    %eax,(%esp)
  104453:	e8 a1 f6 ff ff       	call   103af9 <pte2page>
  104458:	eb 05                	jmp    10445f <get_page+0x57>
    }
    return NULL;
  10445a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10445f:	c9                   	leave  
  104460:	c3                   	ret    

00104461 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104461:	55                   	push   %ebp
  104462:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  104464:	5d                   	pop    %ebp
  104465:	c3                   	ret    

00104466 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  104466:	55                   	push   %ebp
  104467:	89 e5                	mov    %esp,%ebp
  104469:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10446c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104473:	00 
  104474:	8b 45 0c             	mov    0xc(%ebp),%eax
  104477:	89 44 24 04          	mov    %eax,0x4(%esp)
  10447b:	8b 45 08             	mov    0x8(%ebp),%eax
  10447e:	89 04 24             	mov    %eax,(%esp)
  104481:	e8 7d ff ff ff       	call   104403 <get_pte>
  104486:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
  104489:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10448d:	74 19                	je     1044a8 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10448f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104492:	89 44 24 08          	mov    %eax,0x8(%esp)
  104496:	8b 45 0c             	mov    0xc(%ebp),%eax
  104499:	89 44 24 04          	mov    %eax,0x4(%esp)
  10449d:	8b 45 08             	mov    0x8(%ebp),%eax
  1044a0:	89 04 24             	mov    %eax,(%esp)
  1044a3:	e8 b9 ff ff ff       	call   104461 <page_remove_pte>
    }
}
  1044a8:	c9                   	leave  
  1044a9:	c3                   	ret    

001044aa <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1044aa:	55                   	push   %ebp
  1044ab:	89 e5                	mov    %esp,%ebp
  1044ad:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1044b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1044b7:	00 
  1044b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1044bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1044bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1044c2:	89 04 24             	mov    %eax,(%esp)
  1044c5:	e8 39 ff ff ff       	call   104403 <get_pte>
  1044ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1044cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1044d1:	75 0a                	jne    1044dd <page_insert+0x33>
        return -E_NO_MEM;
  1044d3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1044d8:	e9 84 00 00 00       	jmp    104561 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1044dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044e0:	89 04 24             	mov    %eax,(%esp)
  1044e3:	e8 71 f6 ff ff       	call   103b59 <page_ref_inc>
    if (*ptep & PTE_P) {
  1044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044eb:	8b 00                	mov    (%eax),%eax
  1044ed:	83 e0 01             	and    $0x1,%eax
  1044f0:	85 c0                	test   %eax,%eax
  1044f2:	74 3e                	je     104532 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f7:	8b 00                	mov    (%eax),%eax
  1044f9:	89 04 24             	mov    %eax,(%esp)
  1044fc:	e8 f8 f5 ff ff       	call   103af9 <pte2page>
  104501:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  104504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104507:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10450a:	75 0d                	jne    104519 <page_insert+0x6f>
            page_ref_dec(page);
  10450c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10450f:	89 04 24             	mov    %eax,(%esp)
  104512:	e8 59 f6 ff ff       	call   103b70 <page_ref_dec>
  104517:	eb 19                	jmp    104532 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10451c:	89 44 24 08          	mov    %eax,0x8(%esp)
  104520:	8b 45 10             	mov    0x10(%ebp),%eax
  104523:	89 44 24 04          	mov    %eax,0x4(%esp)
  104527:	8b 45 08             	mov    0x8(%ebp),%eax
  10452a:	89 04 24             	mov    %eax,(%esp)
  10452d:	e8 2f ff ff ff       	call   104461 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104532:	8b 45 0c             	mov    0xc(%ebp),%eax
  104535:	89 04 24             	mov    %eax,(%esp)
  104538:	e8 03 f5 ff ff       	call   103a40 <page2pa>
  10453d:	0b 45 14             	or     0x14(%ebp),%eax
  104540:	83 c8 01             	or     $0x1,%eax
  104543:	89 c2                	mov    %eax,%edx
  104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104548:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10454a:	8b 45 10             	mov    0x10(%ebp),%eax
  10454d:	89 44 24 04          	mov    %eax,0x4(%esp)
  104551:	8b 45 08             	mov    0x8(%ebp),%eax
  104554:	89 04 24             	mov    %eax,(%esp)
  104557:	e8 07 00 00 00       	call   104563 <tlb_invalidate>
    return 0;
  10455c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104561:	c9                   	leave  
  104562:	c3                   	ret    

00104563 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104563:	55                   	push   %ebp
  104564:	89 e5                	mov    %esp,%ebp
  104566:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104569:	0f 20 d8             	mov    %cr3,%eax
  10456c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10456f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  104572:	89 c2                	mov    %eax,%edx
  104574:	8b 45 08             	mov    0x8(%ebp),%eax
  104577:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10457a:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104581:	77 23                	ja     1045a6 <tlb_invalidate+0x43>
  104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10458a:	c7 44 24 08 88 69 10 	movl   $0x106988,0x8(%esp)
  104591:	00 
  104592:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  104599:	00 
  10459a:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1045a1:	e8 2a c7 ff ff       	call   100cd0 <__panic>
  1045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045a9:	05 00 00 00 40       	add    $0x40000000,%eax
  1045ae:	39 c2                	cmp    %eax,%edx
  1045b0:	75 0c                	jne    1045be <tlb_invalidate+0x5b>
        invlpg((void *)la);
  1045b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1045b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045bb:	0f 01 38             	invlpg (%eax)
    }
}
  1045be:	c9                   	leave  
  1045bf:	c3                   	ret    

001045c0 <check_alloc_page>:

static void
check_alloc_page(void) {
  1045c0:	55                   	push   %ebp
  1045c1:	89 e5                	mov    %esp,%ebp
  1045c3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1045c6:	a1 1c af 11 00       	mov    0x11af1c,%eax
  1045cb:	8b 40 18             	mov    0x18(%eax),%eax
  1045ce:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1045d0:	c7 04 24 0c 6a 10 00 	movl   $0x106a0c,(%esp)
  1045d7:	e8 6c bd ff ff       	call   100348 <cprintf>
}
  1045dc:	c9                   	leave  
  1045dd:	c3                   	ret    

001045de <check_pgdir>:

static void
check_pgdir(void) {
  1045de:	55                   	push   %ebp
  1045df:	89 e5                	mov    %esp,%ebp
  1045e1:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1045e4:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1045e9:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1045ee:	76 24                	jbe    104614 <check_pgdir+0x36>
  1045f0:	c7 44 24 0c 2b 6a 10 	movl   $0x106a2b,0xc(%esp)
  1045f7:	00 
  1045f8:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  1045ff:	00 
  104600:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  104607:	00 
  104608:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10460f:	e8 bc c6 ff ff       	call   100cd0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104614:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104619:	85 c0                	test   %eax,%eax
  10461b:	74 0e                	je     10462b <check_pgdir+0x4d>
  10461d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104622:	25 ff 0f 00 00       	and    $0xfff,%eax
  104627:	85 c0                	test   %eax,%eax
  104629:	74 24                	je     10464f <check_pgdir+0x71>
  10462b:	c7 44 24 0c 48 6a 10 	movl   $0x106a48,0xc(%esp)
  104632:	00 
  104633:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  10463a:	00 
  10463b:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  104642:	00 
  104643:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10464a:	e8 81 c6 ff ff       	call   100cd0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10464f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104654:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10465b:	00 
  10465c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104663:	00 
  104664:	89 04 24             	mov    %eax,(%esp)
  104667:	e8 9c fd ff ff       	call   104408 <get_page>
  10466c:	85 c0                	test   %eax,%eax
  10466e:	74 24                	je     104694 <check_pgdir+0xb6>
  104670:	c7 44 24 0c 80 6a 10 	movl   $0x106a80,0xc(%esp)
  104677:	00 
  104678:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  10467f:	00 
  104680:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  104687:	00 
  104688:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10468f:	e8 3c c6 ff ff       	call   100cd0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104694:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10469b:	e8 a7 f6 ff ff       	call   103d47 <alloc_pages>
  1046a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1046a3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1046a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1046af:	00 
  1046b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1046b7:	00 
  1046b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1046bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  1046bf:	89 04 24             	mov    %eax,(%esp)
  1046c2:	e8 e3 fd ff ff       	call   1044aa <page_insert>
  1046c7:	85 c0                	test   %eax,%eax
  1046c9:	74 24                	je     1046ef <check_pgdir+0x111>
  1046cb:	c7 44 24 0c a8 6a 10 	movl   $0x106aa8,0xc(%esp)
  1046d2:	00 
  1046d3:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  1046da:	00 
  1046db:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  1046e2:	00 
  1046e3:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1046ea:	e8 e1 c5 ff ff       	call   100cd0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1046ef:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1046f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1046fb:	00 
  1046fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104703:	00 
  104704:	89 04 24             	mov    %eax,(%esp)
  104707:	e8 f7 fc ff ff       	call   104403 <get_pte>
  10470c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10470f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104713:	75 24                	jne    104739 <check_pgdir+0x15b>
  104715:	c7 44 24 0c d4 6a 10 	movl   $0x106ad4,0xc(%esp)
  10471c:	00 
  10471d:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104724:	00 
  104725:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  10472c:	00 
  10472d:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104734:	e8 97 c5 ff ff       	call   100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
  104739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10473c:	8b 00                	mov    (%eax),%eax
  10473e:	89 04 24             	mov    %eax,(%esp)
  104741:	e8 b3 f3 ff ff       	call   103af9 <pte2page>
  104746:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104749:	74 24                	je     10476f <check_pgdir+0x191>
  10474b:	c7 44 24 0c 01 6b 10 	movl   $0x106b01,0xc(%esp)
  104752:	00 
  104753:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  10475a:	00 
  10475b:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  104762:	00 
  104763:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10476a:	e8 61 c5 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p1) == 1);
  10476f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104772:	89 04 24             	mov    %eax,(%esp)
  104775:	e8 d5 f3 ff ff       	call   103b4f <page_ref>
  10477a:	83 f8 01             	cmp    $0x1,%eax
  10477d:	74 24                	je     1047a3 <check_pgdir+0x1c5>
  10477f:	c7 44 24 0c 17 6b 10 	movl   $0x106b17,0xc(%esp)
  104786:	00 
  104787:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  10478e:	00 
  10478f:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  104796:	00 
  104797:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10479e:	e8 2d c5 ff ff       	call   100cd0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1047a3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047a8:	8b 00                	mov    (%eax),%eax
  1047aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1047af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1047b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047b5:	c1 e8 0c             	shr    $0xc,%eax
  1047b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1047bb:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1047c0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1047c3:	72 23                	jb     1047e8 <check_pgdir+0x20a>
  1047c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1047cc:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  1047d3:	00 
  1047d4:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  1047db:	00 
  1047dc:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1047e3:	e8 e8 c4 ff ff       	call   100cd0 <__panic>
  1047e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047eb:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1047f0:	83 c0 04             	add    $0x4,%eax
  1047f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1047f6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104802:	00 
  104803:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10480a:	00 
  10480b:	89 04 24             	mov    %eax,(%esp)
  10480e:	e8 f0 fb ff ff       	call   104403 <get_pte>
  104813:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104816:	74 24                	je     10483c <check_pgdir+0x25e>
  104818:	c7 44 24 0c 2c 6b 10 	movl   $0x106b2c,0xc(%esp)
  10481f:	00 
  104820:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104827:	00 
  104828:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  10482f:	00 
  104830:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104837:	e8 94 c4 ff ff       	call   100cd0 <__panic>

    p2 = alloc_page();
  10483c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104843:	e8 ff f4 ff ff       	call   103d47 <alloc_pages>
  104848:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10484b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104850:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104857:	00 
  104858:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10485f:	00 
  104860:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104863:	89 54 24 04          	mov    %edx,0x4(%esp)
  104867:	89 04 24             	mov    %eax,(%esp)
  10486a:	e8 3b fc ff ff       	call   1044aa <page_insert>
  10486f:	85 c0                	test   %eax,%eax
  104871:	74 24                	je     104897 <check_pgdir+0x2b9>
  104873:	c7 44 24 0c 54 6b 10 	movl   $0x106b54,0xc(%esp)
  10487a:	00 
  10487b:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104882:	00 
  104883:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  10488a:	00 
  10488b:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104892:	e8 39 c4 ff ff       	call   100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104897:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10489c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048a3:	00 
  1048a4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1048ab:	00 
  1048ac:	89 04 24             	mov    %eax,(%esp)
  1048af:	e8 4f fb ff ff       	call   104403 <get_pte>
  1048b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048bb:	75 24                	jne    1048e1 <check_pgdir+0x303>
  1048bd:	c7 44 24 0c 8c 6b 10 	movl   $0x106b8c,0xc(%esp)
  1048c4:	00 
  1048c5:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  1048cc:	00 
  1048cd:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  1048d4:	00 
  1048d5:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1048dc:	e8 ef c3 ff ff       	call   100cd0 <__panic>
    assert(*ptep & PTE_U);
  1048e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1048e4:	8b 00                	mov    (%eax),%eax
  1048e6:	83 e0 04             	and    $0x4,%eax
  1048e9:	85 c0                	test   %eax,%eax
  1048eb:	75 24                	jne    104911 <check_pgdir+0x333>
  1048ed:	c7 44 24 0c bc 6b 10 	movl   $0x106bbc,0xc(%esp)
  1048f4:	00 
  1048f5:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  1048fc:	00 
  1048fd:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  104904:	00 
  104905:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10490c:	e8 bf c3 ff ff       	call   100cd0 <__panic>
    assert(*ptep & PTE_W);
  104911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104914:	8b 00                	mov    (%eax),%eax
  104916:	83 e0 02             	and    $0x2,%eax
  104919:	85 c0                	test   %eax,%eax
  10491b:	75 24                	jne    104941 <check_pgdir+0x363>
  10491d:	c7 44 24 0c ca 6b 10 	movl   $0x106bca,0xc(%esp)
  104924:	00 
  104925:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  10492c:	00 
  10492d:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  104934:	00 
  104935:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10493c:	e8 8f c3 ff ff       	call   100cd0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104941:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104946:	8b 00                	mov    (%eax),%eax
  104948:	83 e0 04             	and    $0x4,%eax
  10494b:	85 c0                	test   %eax,%eax
  10494d:	75 24                	jne    104973 <check_pgdir+0x395>
  10494f:	c7 44 24 0c d8 6b 10 	movl   $0x106bd8,0xc(%esp)
  104956:	00 
  104957:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  10495e:	00 
  10495f:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  104966:	00 
  104967:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  10496e:	e8 5d c3 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 1);
  104973:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104976:	89 04 24             	mov    %eax,(%esp)
  104979:	e8 d1 f1 ff ff       	call   103b4f <page_ref>
  10497e:	83 f8 01             	cmp    $0x1,%eax
  104981:	74 24                	je     1049a7 <check_pgdir+0x3c9>
  104983:	c7 44 24 0c ee 6b 10 	movl   $0x106bee,0xc(%esp)
  10498a:	00 
  10498b:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104992:	00 
  104993:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  10499a:	00 
  10499b:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1049a2:	e8 29 c3 ff ff       	call   100cd0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  1049a7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1049b3:	00 
  1049b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1049bb:	00 
  1049bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1049bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  1049c3:	89 04 24             	mov    %eax,(%esp)
  1049c6:	e8 df fa ff ff       	call   1044aa <page_insert>
  1049cb:	85 c0                	test   %eax,%eax
  1049cd:	74 24                	je     1049f3 <check_pgdir+0x415>
  1049cf:	c7 44 24 0c 00 6c 10 	movl   $0x106c00,0xc(%esp)
  1049d6:	00 
  1049d7:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  1049de:	00 
  1049df:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  1049e6:	00 
  1049e7:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  1049ee:	e8 dd c2 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p1) == 2);
  1049f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049f6:	89 04 24             	mov    %eax,(%esp)
  1049f9:	e8 51 f1 ff ff       	call   103b4f <page_ref>
  1049fe:	83 f8 02             	cmp    $0x2,%eax
  104a01:	74 24                	je     104a27 <check_pgdir+0x449>
  104a03:	c7 44 24 0c 2c 6c 10 	movl   $0x106c2c,0xc(%esp)
  104a0a:	00 
  104a0b:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104a12:	00 
  104a13:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  104a1a:	00 
  104a1b:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104a22:	e8 a9 c2 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 0);
  104a27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a2a:	89 04 24             	mov    %eax,(%esp)
  104a2d:	e8 1d f1 ff ff       	call   103b4f <page_ref>
  104a32:	85 c0                	test   %eax,%eax
  104a34:	74 24                	je     104a5a <check_pgdir+0x47c>
  104a36:	c7 44 24 0c 3e 6c 10 	movl   $0x106c3e,0xc(%esp)
  104a3d:	00 
  104a3e:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104a45:	00 
  104a46:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  104a4d:	00 
  104a4e:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104a55:	e8 76 c2 ff ff       	call   100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104a5a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a66:	00 
  104a67:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a6e:	00 
  104a6f:	89 04 24             	mov    %eax,(%esp)
  104a72:	e8 8c f9 ff ff       	call   104403 <get_pte>
  104a77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a7e:	75 24                	jne    104aa4 <check_pgdir+0x4c6>
  104a80:	c7 44 24 0c 8c 6b 10 	movl   $0x106b8c,0xc(%esp)
  104a87:	00 
  104a88:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104a8f:	00 
  104a90:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  104a97:	00 
  104a98:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104a9f:	e8 2c c2 ff ff       	call   100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
  104aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104aa7:	8b 00                	mov    (%eax),%eax
  104aa9:	89 04 24             	mov    %eax,(%esp)
  104aac:	e8 48 f0 ff ff       	call   103af9 <pte2page>
  104ab1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104ab4:	74 24                	je     104ada <check_pgdir+0x4fc>
  104ab6:	c7 44 24 0c 01 6b 10 	movl   $0x106b01,0xc(%esp)
  104abd:	00 
  104abe:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104ac5:	00 
  104ac6:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  104acd:	00 
  104ace:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104ad5:	e8 f6 c1 ff ff       	call   100cd0 <__panic>
    assert((*ptep & PTE_U) == 0);
  104ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104add:	8b 00                	mov    (%eax),%eax
  104adf:	83 e0 04             	and    $0x4,%eax
  104ae2:	85 c0                	test   %eax,%eax
  104ae4:	74 24                	je     104b0a <check_pgdir+0x52c>
  104ae6:	c7 44 24 0c 50 6c 10 	movl   $0x106c50,0xc(%esp)
  104aed:	00 
  104aee:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104af5:	00 
  104af6:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104afd:	00 
  104afe:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104b05:	e8 c6 c1 ff ff       	call   100cd0 <__panic>

    page_remove(boot_pgdir, 0x0);
  104b0a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104b16:	00 
  104b17:	89 04 24             	mov    %eax,(%esp)
  104b1a:	e8 47 f9 ff ff       	call   104466 <page_remove>
    assert(page_ref(p1) == 1);
  104b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b22:	89 04 24             	mov    %eax,(%esp)
  104b25:	e8 25 f0 ff ff       	call   103b4f <page_ref>
  104b2a:	83 f8 01             	cmp    $0x1,%eax
  104b2d:	74 24                	je     104b53 <check_pgdir+0x575>
  104b2f:	c7 44 24 0c 17 6b 10 	movl   $0x106b17,0xc(%esp)
  104b36:	00 
  104b37:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104b3e:	00 
  104b3f:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  104b46:	00 
  104b47:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104b4e:	e8 7d c1 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 0);
  104b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b56:	89 04 24             	mov    %eax,(%esp)
  104b59:	e8 f1 ef ff ff       	call   103b4f <page_ref>
  104b5e:	85 c0                	test   %eax,%eax
  104b60:	74 24                	je     104b86 <check_pgdir+0x5a8>
  104b62:	c7 44 24 0c 3e 6c 10 	movl   $0x106c3e,0xc(%esp)
  104b69:	00 
  104b6a:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104b71:	00 
  104b72:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104b79:	00 
  104b7a:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104b81:	e8 4a c1 ff ff       	call   100cd0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104b86:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b8b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104b92:	00 
  104b93:	89 04 24             	mov    %eax,(%esp)
  104b96:	e8 cb f8 ff ff       	call   104466 <page_remove>
    assert(page_ref(p1) == 0);
  104b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b9e:	89 04 24             	mov    %eax,(%esp)
  104ba1:	e8 a9 ef ff ff       	call   103b4f <page_ref>
  104ba6:	85 c0                	test   %eax,%eax
  104ba8:	74 24                	je     104bce <check_pgdir+0x5f0>
  104baa:	c7 44 24 0c 65 6c 10 	movl   $0x106c65,0xc(%esp)
  104bb1:	00 
  104bb2:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104bb9:	00 
  104bba:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  104bc1:	00 
  104bc2:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104bc9:	e8 02 c1 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 0);
  104bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bd1:	89 04 24             	mov    %eax,(%esp)
  104bd4:	e8 76 ef ff ff       	call   103b4f <page_ref>
  104bd9:	85 c0                	test   %eax,%eax
  104bdb:	74 24                	je     104c01 <check_pgdir+0x623>
  104bdd:	c7 44 24 0c 3e 6c 10 	movl   $0x106c3e,0xc(%esp)
  104be4:	00 
  104be5:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104bec:	00 
  104bed:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104bf4:	00 
  104bf5:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104bfc:	e8 cf c0 ff ff       	call   100cd0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104c01:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c06:	8b 00                	mov    (%eax),%eax
  104c08:	89 04 24             	mov    %eax,(%esp)
  104c0b:	e8 27 ef ff ff       	call   103b37 <pde2page>
  104c10:	89 04 24             	mov    %eax,(%esp)
  104c13:	e8 37 ef ff ff       	call   103b4f <page_ref>
  104c18:	83 f8 01             	cmp    $0x1,%eax
  104c1b:	74 24                	je     104c41 <check_pgdir+0x663>
  104c1d:	c7 44 24 0c 78 6c 10 	movl   $0x106c78,0xc(%esp)
  104c24:	00 
  104c25:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104c2c:	00 
  104c2d:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104c34:	00 
  104c35:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104c3c:	e8 8f c0 ff ff       	call   100cd0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104c41:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c46:	8b 00                	mov    (%eax),%eax
  104c48:	89 04 24             	mov    %eax,(%esp)
  104c4b:	e8 e7 ee ff ff       	call   103b37 <pde2page>
  104c50:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c57:	00 
  104c58:	89 04 24             	mov    %eax,(%esp)
  104c5b:	e8 1f f1 ff ff       	call   103d7f <free_pages>
    boot_pgdir[0] = 0;
  104c60:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104c6b:	c7 04 24 9f 6c 10 00 	movl   $0x106c9f,(%esp)
  104c72:	e8 d1 b6 ff ff       	call   100348 <cprintf>
}
  104c77:	c9                   	leave  
  104c78:	c3                   	ret    

00104c79 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104c79:	55                   	push   %ebp
  104c7a:	89 e5                	mov    %esp,%ebp
  104c7c:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104c7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104c86:	e9 ca 00 00 00       	jmp    104d55 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c94:	c1 e8 0c             	shr    $0xc,%eax
  104c97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104c9a:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104c9f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104ca2:	72 23                	jb     104cc7 <check_boot_pgdir+0x4e>
  104ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ca7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104cab:	c7 44 24 08 e4 68 10 	movl   $0x1068e4,0x8(%esp)
  104cb2:	00 
  104cb3:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104cba:	00 
  104cbb:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104cc2:	e8 09 c0 ff ff       	call   100cd0 <__panic>
  104cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cca:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104ccf:	89 c2                	mov    %eax,%edx
  104cd1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104cd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104cdd:	00 
  104cde:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ce2:	89 04 24             	mov    %eax,(%esp)
  104ce5:	e8 19 f7 ff ff       	call   104403 <get_pte>
  104cea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104ced:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104cf1:	75 24                	jne    104d17 <check_boot_pgdir+0x9e>
  104cf3:	c7 44 24 0c bc 6c 10 	movl   $0x106cbc,0xc(%esp)
  104cfa:	00 
  104cfb:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104d02:	00 
  104d03:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104d0a:	00 
  104d0b:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104d12:	e8 b9 bf ff ff       	call   100cd0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104d17:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d1a:	8b 00                	mov    (%eax),%eax
  104d1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104d21:	89 c2                	mov    %eax,%edx
  104d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d26:	39 c2                	cmp    %eax,%edx
  104d28:	74 24                	je     104d4e <check_boot_pgdir+0xd5>
  104d2a:	c7 44 24 0c f9 6c 10 	movl   $0x106cf9,0xc(%esp)
  104d31:	00 
  104d32:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104d39:	00 
  104d3a:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104d41:	00 
  104d42:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104d49:	e8 82 bf ff ff       	call   100cd0 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104d4e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104d55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104d58:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104d5d:	39 c2                	cmp    %eax,%edx
  104d5f:	0f 82 26 ff ff ff    	jb     104c8b <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104d65:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d6a:	05 ac 0f 00 00       	add    $0xfac,%eax
  104d6f:	8b 00                	mov    (%eax),%eax
  104d71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104d76:	89 c2                	mov    %eax,%edx
  104d78:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104d80:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104d87:	77 23                	ja     104dac <check_boot_pgdir+0x133>
  104d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104d90:	c7 44 24 08 88 69 10 	movl   $0x106988,0x8(%esp)
  104d97:	00 
  104d98:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104d9f:	00 
  104da0:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104da7:	e8 24 bf ff ff       	call   100cd0 <__panic>
  104dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104daf:	05 00 00 00 40       	add    $0x40000000,%eax
  104db4:	39 c2                	cmp    %eax,%edx
  104db6:	74 24                	je     104ddc <check_boot_pgdir+0x163>
  104db8:	c7 44 24 0c 10 6d 10 	movl   $0x106d10,0xc(%esp)
  104dbf:	00 
  104dc0:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104dc7:	00 
  104dc8:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104dcf:	00 
  104dd0:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104dd7:	e8 f4 be ff ff       	call   100cd0 <__panic>

    assert(boot_pgdir[0] == 0);
  104ddc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104de1:	8b 00                	mov    (%eax),%eax
  104de3:	85 c0                	test   %eax,%eax
  104de5:	74 24                	je     104e0b <check_boot_pgdir+0x192>
  104de7:	c7 44 24 0c 44 6d 10 	movl   $0x106d44,0xc(%esp)
  104dee:	00 
  104def:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104df6:	00 
  104df7:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104dfe:	00 
  104dff:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104e06:	e8 c5 be ff ff       	call   100cd0 <__panic>

    struct Page *p;
    p = alloc_page();
  104e0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e12:	e8 30 ef ff ff       	call   103d47 <alloc_pages>
  104e17:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104e1a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e1f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104e26:	00 
  104e27:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  104e2e:	00 
  104e2f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104e32:	89 54 24 04          	mov    %edx,0x4(%esp)
  104e36:	89 04 24             	mov    %eax,(%esp)
  104e39:	e8 6c f6 ff ff       	call   1044aa <page_insert>
  104e3e:	85 c0                	test   %eax,%eax
  104e40:	74 24                	je     104e66 <check_boot_pgdir+0x1ed>
  104e42:	c7 44 24 0c 58 6d 10 	movl   $0x106d58,0xc(%esp)
  104e49:	00 
  104e4a:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104e51:	00 
  104e52:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104e59:	00 
  104e5a:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104e61:	e8 6a be ff ff       	call   100cd0 <__panic>
    assert(page_ref(p) == 1);
  104e66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104e69:	89 04 24             	mov    %eax,(%esp)
  104e6c:	e8 de ec ff ff       	call   103b4f <page_ref>
  104e71:	83 f8 01             	cmp    $0x1,%eax
  104e74:	74 24                	je     104e9a <check_boot_pgdir+0x221>
  104e76:	c7 44 24 0c 86 6d 10 	movl   $0x106d86,0xc(%esp)
  104e7d:	00 
  104e7e:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104e85:	00 
  104e86:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  104e8d:	00 
  104e8e:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104e95:	e8 36 be ff ff       	call   100cd0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  104e9a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e9f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104ea6:	00 
  104ea7:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  104eae:	00 
  104eaf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104eb2:	89 54 24 04          	mov    %edx,0x4(%esp)
  104eb6:	89 04 24             	mov    %eax,(%esp)
  104eb9:	e8 ec f5 ff ff       	call   1044aa <page_insert>
  104ebe:	85 c0                	test   %eax,%eax
  104ec0:	74 24                	je     104ee6 <check_boot_pgdir+0x26d>
  104ec2:	c7 44 24 0c 98 6d 10 	movl   $0x106d98,0xc(%esp)
  104ec9:	00 
  104eca:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104ed1:	00 
  104ed2:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  104ed9:	00 
  104eda:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104ee1:	e8 ea bd ff ff       	call   100cd0 <__panic>
    assert(page_ref(p) == 2);
  104ee6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ee9:	89 04 24             	mov    %eax,(%esp)
  104eec:	e8 5e ec ff ff       	call   103b4f <page_ref>
  104ef1:	83 f8 02             	cmp    $0x2,%eax
  104ef4:	74 24                	je     104f1a <check_boot_pgdir+0x2a1>
  104ef6:	c7 44 24 0c cf 6d 10 	movl   $0x106dcf,0xc(%esp)
  104efd:	00 
  104efe:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104f05:	00 
  104f06:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  104f0d:	00 
  104f0e:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104f15:	e8 b6 bd ff ff       	call   100cd0 <__panic>

    const char *str = "ucore: Hello world!!";
  104f1a:	c7 45 dc e0 6d 10 00 	movl   $0x106de0,-0x24(%ebp)
    strcpy((void *)0x100, str);
  104f21:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f28:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104f2f:	e8 19 0a 00 00       	call   10594d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  104f34:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  104f3b:	00 
  104f3c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104f43:	e8 7e 0a 00 00       	call   1059c6 <strcmp>
  104f48:	85 c0                	test   %eax,%eax
  104f4a:	74 24                	je     104f70 <check_boot_pgdir+0x2f7>
  104f4c:	c7 44 24 0c f8 6d 10 	movl   $0x106df8,0xc(%esp)
  104f53:	00 
  104f54:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104f5b:	00 
  104f5c:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  104f63:	00 
  104f64:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104f6b:	e8 60 bd ff ff       	call   100cd0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  104f70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f73:	89 04 24             	mov    %eax,(%esp)
  104f76:	e8 2a eb ff ff       	call   103aa5 <page2kva>
  104f7b:	05 00 01 00 00       	add    $0x100,%eax
  104f80:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  104f83:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104f8a:	e8 66 09 00 00       	call   1058f5 <strlen>
  104f8f:	85 c0                	test   %eax,%eax
  104f91:	74 24                	je     104fb7 <check_boot_pgdir+0x33e>
  104f93:	c7 44 24 0c 30 6e 10 	movl   $0x106e30,0xc(%esp)
  104f9a:	00 
  104f9b:	c7 44 24 08 d1 69 10 	movl   $0x1069d1,0x8(%esp)
  104fa2:	00 
  104fa3:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104faa:	00 
  104fab:	c7 04 24 ac 69 10 00 	movl   $0x1069ac,(%esp)
  104fb2:	e8 19 bd ff ff       	call   100cd0 <__panic>

    free_page(p);
  104fb7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104fbe:	00 
  104fbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104fc2:	89 04 24             	mov    %eax,(%esp)
  104fc5:	e8 b5 ed ff ff       	call   103d7f <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  104fca:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fcf:	8b 00                	mov    (%eax),%eax
  104fd1:	89 04 24             	mov    %eax,(%esp)
  104fd4:	e8 5e eb ff ff       	call   103b37 <pde2page>
  104fd9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104fe0:	00 
  104fe1:	89 04 24             	mov    %eax,(%esp)
  104fe4:	e8 96 ed ff ff       	call   103d7f <free_pages>
    boot_pgdir[0] = 0;
  104fe9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  104ff4:	c7 04 24 54 6e 10 00 	movl   $0x106e54,(%esp)
  104ffb:	e8 48 b3 ff ff       	call   100348 <cprintf>
}
  105000:	c9                   	leave  
  105001:	c3                   	ret    

00105002 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105002:	55                   	push   %ebp
  105003:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105005:	8b 45 08             	mov    0x8(%ebp),%eax
  105008:	83 e0 04             	and    $0x4,%eax
  10500b:	85 c0                	test   %eax,%eax
  10500d:	74 07                	je     105016 <perm2str+0x14>
  10500f:	b8 75 00 00 00       	mov    $0x75,%eax
  105014:	eb 05                	jmp    10501b <perm2str+0x19>
  105016:	b8 2d 00 00 00       	mov    $0x2d,%eax
  10501b:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  105020:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105027:	8b 45 08             	mov    0x8(%ebp),%eax
  10502a:	83 e0 02             	and    $0x2,%eax
  10502d:	85 c0                	test   %eax,%eax
  10502f:	74 07                	je     105038 <perm2str+0x36>
  105031:	b8 77 00 00 00       	mov    $0x77,%eax
  105036:	eb 05                	jmp    10503d <perm2str+0x3b>
  105038:	b8 2d 00 00 00       	mov    $0x2d,%eax
  10503d:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  105042:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  105049:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  10504e:	5d                   	pop    %ebp
  10504f:	c3                   	ret    

00105050 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105050:	55                   	push   %ebp
  105051:	89 e5                	mov    %esp,%ebp
  105053:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105056:	8b 45 10             	mov    0x10(%ebp),%eax
  105059:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10505c:	72 0a                	jb     105068 <get_pgtable_items+0x18>
        return 0;
  10505e:	b8 00 00 00 00       	mov    $0x0,%eax
  105063:	e9 9c 00 00 00       	jmp    105104 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  105068:	eb 04                	jmp    10506e <get_pgtable_items+0x1e>
        start ++;
  10506a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  10506e:	8b 45 10             	mov    0x10(%ebp),%eax
  105071:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105074:	73 18                	jae    10508e <get_pgtable_items+0x3e>
  105076:	8b 45 10             	mov    0x10(%ebp),%eax
  105079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105080:	8b 45 14             	mov    0x14(%ebp),%eax
  105083:	01 d0                	add    %edx,%eax
  105085:	8b 00                	mov    (%eax),%eax
  105087:	83 e0 01             	and    $0x1,%eax
  10508a:	85 c0                	test   %eax,%eax
  10508c:	74 dc                	je     10506a <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  10508e:	8b 45 10             	mov    0x10(%ebp),%eax
  105091:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105094:	73 69                	jae    1050ff <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  105096:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10509a:	74 08                	je     1050a4 <get_pgtable_items+0x54>
            *left_store = start;
  10509c:	8b 45 18             	mov    0x18(%ebp),%eax
  10509f:	8b 55 10             	mov    0x10(%ebp),%edx
  1050a2:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1050a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1050a7:	8d 50 01             	lea    0x1(%eax),%edx
  1050aa:	89 55 10             	mov    %edx,0x10(%ebp)
  1050ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1050b4:	8b 45 14             	mov    0x14(%ebp),%eax
  1050b7:	01 d0                	add    %edx,%eax
  1050b9:	8b 00                	mov    (%eax),%eax
  1050bb:	83 e0 07             	and    $0x7,%eax
  1050be:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1050c1:	eb 04                	jmp    1050c7 <get_pgtable_items+0x77>
            start ++;
  1050c3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  1050c7:	8b 45 10             	mov    0x10(%ebp),%eax
  1050ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1050cd:	73 1d                	jae    1050ec <get_pgtable_items+0x9c>
  1050cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1050d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1050d9:	8b 45 14             	mov    0x14(%ebp),%eax
  1050dc:	01 d0                	add    %edx,%eax
  1050de:	8b 00                	mov    (%eax),%eax
  1050e0:	83 e0 07             	and    $0x7,%eax
  1050e3:	89 c2                	mov    %eax,%edx
  1050e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1050e8:	39 c2                	cmp    %eax,%edx
  1050ea:	74 d7                	je     1050c3 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  1050ec:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1050f0:	74 08                	je     1050fa <get_pgtable_items+0xaa>
            *right_store = start;
  1050f2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1050f5:	8b 55 10             	mov    0x10(%ebp),%edx
  1050f8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1050fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1050fd:	eb 05                	jmp    105104 <get_pgtable_items+0xb4>
    }
    return 0;
  1050ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105104:	c9                   	leave  
  105105:	c3                   	ret    

00105106 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105106:	55                   	push   %ebp
  105107:	89 e5                	mov    %esp,%ebp
  105109:	57                   	push   %edi
  10510a:	56                   	push   %esi
  10510b:	53                   	push   %ebx
  10510c:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  10510f:	c7 04 24 74 6e 10 00 	movl   $0x106e74,(%esp)
  105116:	e8 2d b2 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  10511b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105122:	e9 fa 00 00 00       	jmp    105221 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10512a:	89 04 24             	mov    %eax,(%esp)
  10512d:	e8 d0 fe ff ff       	call   105002 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105132:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105135:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105138:	29 d1                	sub    %edx,%ecx
  10513a:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10513c:	89 d6                	mov    %edx,%esi
  10513e:	c1 e6 16             	shl    $0x16,%esi
  105141:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105144:	89 d3                	mov    %edx,%ebx
  105146:	c1 e3 16             	shl    $0x16,%ebx
  105149:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10514c:	89 d1                	mov    %edx,%ecx
  10514e:	c1 e1 16             	shl    $0x16,%ecx
  105151:	8b 7d dc             	mov    -0x24(%ebp),%edi
  105154:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105157:	29 d7                	sub    %edx,%edi
  105159:	89 fa                	mov    %edi,%edx
  10515b:	89 44 24 14          	mov    %eax,0x14(%esp)
  10515f:	89 74 24 10          	mov    %esi,0x10(%esp)
  105163:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105167:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10516b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10516f:	c7 04 24 a5 6e 10 00 	movl   $0x106ea5,(%esp)
  105176:	e8 cd b1 ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  10517b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10517e:	c1 e0 0a             	shl    $0xa,%eax
  105181:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105184:	eb 54                	jmp    1051da <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105186:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105189:	89 04 24             	mov    %eax,(%esp)
  10518c:	e8 71 fe ff ff       	call   105002 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  105191:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105194:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105197:	29 d1                	sub    %edx,%ecx
  105199:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10519b:	89 d6                	mov    %edx,%esi
  10519d:	c1 e6 0c             	shl    $0xc,%esi
  1051a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1051a3:	89 d3                	mov    %edx,%ebx
  1051a5:	c1 e3 0c             	shl    $0xc,%ebx
  1051a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1051ab:	c1 e2 0c             	shl    $0xc,%edx
  1051ae:	89 d1                	mov    %edx,%ecx
  1051b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1051b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1051b6:	29 d7                	sub    %edx,%edi
  1051b8:	89 fa                	mov    %edi,%edx
  1051ba:	89 44 24 14          	mov    %eax,0x14(%esp)
  1051be:	89 74 24 10          	mov    %esi,0x10(%esp)
  1051c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1051c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1051ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  1051ce:	c7 04 24 c4 6e 10 00 	movl   $0x106ec4,(%esp)
  1051d5:	e8 6e b1 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1051da:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  1051df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1051e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1051e5:	89 ce                	mov    %ecx,%esi
  1051e7:	c1 e6 0a             	shl    $0xa,%esi
  1051ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1051ed:	89 cb                	mov    %ecx,%ebx
  1051ef:	c1 e3 0a             	shl    $0xa,%ebx
  1051f2:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1051f5:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1051f9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1051fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105200:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105204:	89 44 24 08          	mov    %eax,0x8(%esp)
  105208:	89 74 24 04          	mov    %esi,0x4(%esp)
  10520c:	89 1c 24             	mov    %ebx,(%esp)
  10520f:	e8 3c fe ff ff       	call   105050 <get_pgtable_items>
  105214:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105217:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10521b:	0f 85 65 ff ff ff    	jne    105186 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105221:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  105226:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105229:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  10522c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105230:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  105233:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105237:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10523b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10523f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  105246:	00 
  105247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10524e:	e8 fd fd ff ff       	call   105050 <get_pgtable_items>
  105253:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105256:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10525a:	0f 85 c7 fe ff ff    	jne    105127 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105260:	c7 04 24 e8 6e 10 00 	movl   $0x106ee8,(%esp)
  105267:	e8 dc b0 ff ff       	call   100348 <cprintf>
}
  10526c:	83 c4 4c             	add    $0x4c,%esp
  10526f:	5b                   	pop    %ebx
  105270:	5e                   	pop    %esi
  105271:	5f                   	pop    %edi
  105272:	5d                   	pop    %ebp
  105273:	c3                   	ret    

00105274 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105274:	55                   	push   %ebp
  105275:	89 e5                	mov    %esp,%ebp
  105277:	83 ec 58             	sub    $0x58,%esp
  10527a:	8b 45 10             	mov    0x10(%ebp),%eax
  10527d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105280:	8b 45 14             	mov    0x14(%ebp),%eax
  105283:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105286:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105289:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10528c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10528f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105292:	8b 45 18             	mov    0x18(%ebp),%eax
  105295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105298:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10529b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10529e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1052a1:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1052a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1052a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1052aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1052ae:	74 1c                	je     1052cc <printnum+0x58>
  1052b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1052b3:	ba 00 00 00 00       	mov    $0x0,%edx
  1052b8:	f7 75 e4             	divl   -0x1c(%ebp)
  1052bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1052be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1052c1:	ba 00 00 00 00       	mov    $0x0,%edx
  1052c6:	f7 75 e4             	divl   -0x1c(%ebp)
  1052c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1052cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1052cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1052d2:	f7 75 e4             	divl   -0x1c(%ebp)
  1052d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1052d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1052db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1052de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1052e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1052e4:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1052e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052ea:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1052ed:	8b 45 18             	mov    0x18(%ebp),%eax
  1052f0:	ba 00 00 00 00       	mov    $0x0,%edx
  1052f5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1052f8:	77 56                	ja     105350 <printnum+0xdc>
  1052fa:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1052fd:	72 05                	jb     105304 <printnum+0x90>
  1052ff:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105302:	77 4c                	ja     105350 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105304:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105307:	8d 50 ff             	lea    -0x1(%eax),%edx
  10530a:	8b 45 20             	mov    0x20(%ebp),%eax
  10530d:	89 44 24 18          	mov    %eax,0x18(%esp)
  105311:	89 54 24 14          	mov    %edx,0x14(%esp)
  105315:	8b 45 18             	mov    0x18(%ebp),%eax
  105318:	89 44 24 10          	mov    %eax,0x10(%esp)
  10531c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10531f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105322:	89 44 24 08          	mov    %eax,0x8(%esp)
  105326:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10532a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10532d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105331:	8b 45 08             	mov    0x8(%ebp),%eax
  105334:	89 04 24             	mov    %eax,(%esp)
  105337:	e8 38 ff ff ff       	call   105274 <printnum>
  10533c:	eb 1c                	jmp    10535a <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10533e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105341:	89 44 24 04          	mov    %eax,0x4(%esp)
  105345:	8b 45 20             	mov    0x20(%ebp),%eax
  105348:	89 04 24             	mov    %eax,(%esp)
  10534b:	8b 45 08             	mov    0x8(%ebp),%eax
  10534e:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105350:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  105354:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105358:	7f e4                	jg     10533e <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10535a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10535d:	05 9c 6f 10 00       	add    $0x106f9c,%eax
  105362:	0f b6 00             	movzbl (%eax),%eax
  105365:	0f be c0             	movsbl %al,%eax
  105368:	8b 55 0c             	mov    0xc(%ebp),%edx
  10536b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10536f:	89 04 24             	mov    %eax,(%esp)
  105372:	8b 45 08             	mov    0x8(%ebp),%eax
  105375:	ff d0                	call   *%eax
}
  105377:	c9                   	leave  
  105378:	c3                   	ret    

00105379 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105379:	55                   	push   %ebp
  10537a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10537c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105380:	7e 14                	jle    105396 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105382:	8b 45 08             	mov    0x8(%ebp),%eax
  105385:	8b 00                	mov    (%eax),%eax
  105387:	8d 48 08             	lea    0x8(%eax),%ecx
  10538a:	8b 55 08             	mov    0x8(%ebp),%edx
  10538d:	89 0a                	mov    %ecx,(%edx)
  10538f:	8b 50 04             	mov    0x4(%eax),%edx
  105392:	8b 00                	mov    (%eax),%eax
  105394:	eb 30                	jmp    1053c6 <getuint+0x4d>
    }
    else if (lflag) {
  105396:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10539a:	74 16                	je     1053b2 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10539c:	8b 45 08             	mov    0x8(%ebp),%eax
  10539f:	8b 00                	mov    (%eax),%eax
  1053a1:	8d 48 04             	lea    0x4(%eax),%ecx
  1053a4:	8b 55 08             	mov    0x8(%ebp),%edx
  1053a7:	89 0a                	mov    %ecx,(%edx)
  1053a9:	8b 00                	mov    (%eax),%eax
  1053ab:	ba 00 00 00 00       	mov    $0x0,%edx
  1053b0:	eb 14                	jmp    1053c6 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1053b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1053b5:	8b 00                	mov    (%eax),%eax
  1053b7:	8d 48 04             	lea    0x4(%eax),%ecx
  1053ba:	8b 55 08             	mov    0x8(%ebp),%edx
  1053bd:	89 0a                	mov    %ecx,(%edx)
  1053bf:	8b 00                	mov    (%eax),%eax
  1053c1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1053c6:	5d                   	pop    %ebp
  1053c7:	c3                   	ret    

001053c8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1053c8:	55                   	push   %ebp
  1053c9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1053cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1053cf:	7e 14                	jle    1053e5 <getint+0x1d>
        return va_arg(*ap, long long);
  1053d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1053d4:	8b 00                	mov    (%eax),%eax
  1053d6:	8d 48 08             	lea    0x8(%eax),%ecx
  1053d9:	8b 55 08             	mov    0x8(%ebp),%edx
  1053dc:	89 0a                	mov    %ecx,(%edx)
  1053de:	8b 50 04             	mov    0x4(%eax),%edx
  1053e1:	8b 00                	mov    (%eax),%eax
  1053e3:	eb 28                	jmp    10540d <getint+0x45>
    }
    else if (lflag) {
  1053e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1053e9:	74 12                	je     1053fd <getint+0x35>
        return va_arg(*ap, long);
  1053eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1053ee:	8b 00                	mov    (%eax),%eax
  1053f0:	8d 48 04             	lea    0x4(%eax),%ecx
  1053f3:	8b 55 08             	mov    0x8(%ebp),%edx
  1053f6:	89 0a                	mov    %ecx,(%edx)
  1053f8:	8b 00                	mov    (%eax),%eax
  1053fa:	99                   	cltd   
  1053fb:	eb 10                	jmp    10540d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1053fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105400:	8b 00                	mov    (%eax),%eax
  105402:	8d 48 04             	lea    0x4(%eax),%ecx
  105405:	8b 55 08             	mov    0x8(%ebp),%edx
  105408:	89 0a                	mov    %ecx,(%edx)
  10540a:	8b 00                	mov    (%eax),%eax
  10540c:	99                   	cltd   
    }
}
  10540d:	5d                   	pop    %ebp
  10540e:	c3                   	ret    

0010540f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10540f:	55                   	push   %ebp
  105410:	89 e5                	mov    %esp,%ebp
  105412:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105415:	8d 45 14             	lea    0x14(%ebp),%eax
  105418:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10541b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10541e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105422:	8b 45 10             	mov    0x10(%ebp),%eax
  105425:	89 44 24 08          	mov    %eax,0x8(%esp)
  105429:	8b 45 0c             	mov    0xc(%ebp),%eax
  10542c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105430:	8b 45 08             	mov    0x8(%ebp),%eax
  105433:	89 04 24             	mov    %eax,(%esp)
  105436:	e8 02 00 00 00       	call   10543d <vprintfmt>
    va_end(ap);
}
  10543b:	c9                   	leave  
  10543c:	c3                   	ret    

0010543d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10543d:	55                   	push   %ebp
  10543e:	89 e5                	mov    %esp,%ebp
  105440:	56                   	push   %esi
  105441:	53                   	push   %ebx
  105442:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105445:	eb 18                	jmp    10545f <vprintfmt+0x22>
            if (ch == '\0') {
  105447:	85 db                	test   %ebx,%ebx
  105449:	75 05                	jne    105450 <vprintfmt+0x13>
                return;
  10544b:	e9 d1 03 00 00       	jmp    105821 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105450:	8b 45 0c             	mov    0xc(%ebp),%eax
  105453:	89 44 24 04          	mov    %eax,0x4(%esp)
  105457:	89 1c 24             	mov    %ebx,(%esp)
  10545a:	8b 45 08             	mov    0x8(%ebp),%eax
  10545d:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10545f:	8b 45 10             	mov    0x10(%ebp),%eax
  105462:	8d 50 01             	lea    0x1(%eax),%edx
  105465:	89 55 10             	mov    %edx,0x10(%ebp)
  105468:	0f b6 00             	movzbl (%eax),%eax
  10546b:	0f b6 d8             	movzbl %al,%ebx
  10546e:	83 fb 25             	cmp    $0x25,%ebx
  105471:	75 d4                	jne    105447 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  105473:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105477:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10547e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105481:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105484:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10548b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10548e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105491:	8b 45 10             	mov    0x10(%ebp),%eax
  105494:	8d 50 01             	lea    0x1(%eax),%edx
  105497:	89 55 10             	mov    %edx,0x10(%ebp)
  10549a:	0f b6 00             	movzbl (%eax),%eax
  10549d:	0f b6 d8             	movzbl %al,%ebx
  1054a0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1054a3:	83 f8 55             	cmp    $0x55,%eax
  1054a6:	0f 87 44 03 00 00    	ja     1057f0 <vprintfmt+0x3b3>
  1054ac:	8b 04 85 c0 6f 10 00 	mov    0x106fc0(,%eax,4),%eax
  1054b3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1054b5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1054b9:	eb d6                	jmp    105491 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1054bb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1054bf:	eb d0                	jmp    105491 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1054c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1054c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1054cb:	89 d0                	mov    %edx,%eax
  1054cd:	c1 e0 02             	shl    $0x2,%eax
  1054d0:	01 d0                	add    %edx,%eax
  1054d2:	01 c0                	add    %eax,%eax
  1054d4:	01 d8                	add    %ebx,%eax
  1054d6:	83 e8 30             	sub    $0x30,%eax
  1054d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1054dc:	8b 45 10             	mov    0x10(%ebp),%eax
  1054df:	0f b6 00             	movzbl (%eax),%eax
  1054e2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1054e5:	83 fb 2f             	cmp    $0x2f,%ebx
  1054e8:	7e 0b                	jle    1054f5 <vprintfmt+0xb8>
  1054ea:	83 fb 39             	cmp    $0x39,%ebx
  1054ed:	7f 06                	jg     1054f5 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1054ef:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1054f3:	eb d3                	jmp    1054c8 <vprintfmt+0x8b>
            goto process_precision;
  1054f5:	eb 33                	jmp    10552a <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1054f7:	8b 45 14             	mov    0x14(%ebp),%eax
  1054fa:	8d 50 04             	lea    0x4(%eax),%edx
  1054fd:	89 55 14             	mov    %edx,0x14(%ebp)
  105500:	8b 00                	mov    (%eax),%eax
  105502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105505:	eb 23                	jmp    10552a <vprintfmt+0xed>

        case '.':
            if (width < 0)
  105507:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10550b:	79 0c                	jns    105519 <vprintfmt+0xdc>
                width = 0;
  10550d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105514:	e9 78 ff ff ff       	jmp    105491 <vprintfmt+0x54>
  105519:	e9 73 ff ff ff       	jmp    105491 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  10551e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105525:	e9 67 ff ff ff       	jmp    105491 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  10552a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10552e:	79 12                	jns    105542 <vprintfmt+0x105>
                width = precision, precision = -1;
  105530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105533:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105536:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10553d:	e9 4f ff ff ff       	jmp    105491 <vprintfmt+0x54>
  105542:	e9 4a ff ff ff       	jmp    105491 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105547:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  10554b:	e9 41 ff ff ff       	jmp    105491 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105550:	8b 45 14             	mov    0x14(%ebp),%eax
  105553:	8d 50 04             	lea    0x4(%eax),%edx
  105556:	89 55 14             	mov    %edx,0x14(%ebp)
  105559:	8b 00                	mov    (%eax),%eax
  10555b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10555e:	89 54 24 04          	mov    %edx,0x4(%esp)
  105562:	89 04 24             	mov    %eax,(%esp)
  105565:	8b 45 08             	mov    0x8(%ebp),%eax
  105568:	ff d0                	call   *%eax
            break;
  10556a:	e9 ac 02 00 00       	jmp    10581b <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10556f:	8b 45 14             	mov    0x14(%ebp),%eax
  105572:	8d 50 04             	lea    0x4(%eax),%edx
  105575:	89 55 14             	mov    %edx,0x14(%ebp)
  105578:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10557a:	85 db                	test   %ebx,%ebx
  10557c:	79 02                	jns    105580 <vprintfmt+0x143>
                err = -err;
  10557e:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105580:	83 fb 06             	cmp    $0x6,%ebx
  105583:	7f 0b                	jg     105590 <vprintfmt+0x153>
  105585:	8b 34 9d 80 6f 10 00 	mov    0x106f80(,%ebx,4),%esi
  10558c:	85 f6                	test   %esi,%esi
  10558e:	75 23                	jne    1055b3 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105590:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105594:	c7 44 24 08 ad 6f 10 	movl   $0x106fad,0x8(%esp)
  10559b:	00 
  10559c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10559f:	89 44 24 04          	mov    %eax,0x4(%esp)
  1055a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1055a6:	89 04 24             	mov    %eax,(%esp)
  1055a9:	e8 61 fe ff ff       	call   10540f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1055ae:	e9 68 02 00 00       	jmp    10581b <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  1055b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1055b7:	c7 44 24 08 b6 6f 10 	movl   $0x106fb6,0x8(%esp)
  1055be:	00 
  1055bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1055c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c9:	89 04 24             	mov    %eax,(%esp)
  1055cc:	e8 3e fe ff ff       	call   10540f <printfmt>
            }
            break;
  1055d1:	e9 45 02 00 00       	jmp    10581b <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1055d6:	8b 45 14             	mov    0x14(%ebp),%eax
  1055d9:	8d 50 04             	lea    0x4(%eax),%edx
  1055dc:	89 55 14             	mov    %edx,0x14(%ebp)
  1055df:	8b 30                	mov    (%eax),%esi
  1055e1:	85 f6                	test   %esi,%esi
  1055e3:	75 05                	jne    1055ea <vprintfmt+0x1ad>
                p = "(null)";
  1055e5:	be b9 6f 10 00       	mov    $0x106fb9,%esi
            }
            if (width > 0 && padc != '-') {
  1055ea:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1055ee:	7e 3e                	jle    10562e <vprintfmt+0x1f1>
  1055f0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1055f4:	74 38                	je     10562e <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1055f6:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  1055f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1055fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105600:	89 34 24             	mov    %esi,(%esp)
  105603:	e8 15 03 00 00       	call   10591d <strnlen>
  105608:	29 c3                	sub    %eax,%ebx
  10560a:	89 d8                	mov    %ebx,%eax
  10560c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10560f:	eb 17                	jmp    105628 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105611:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105615:	8b 55 0c             	mov    0xc(%ebp),%edx
  105618:	89 54 24 04          	mov    %edx,0x4(%esp)
  10561c:	89 04 24             	mov    %eax,(%esp)
  10561f:	8b 45 08             	mov    0x8(%ebp),%eax
  105622:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  105624:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105628:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10562c:	7f e3                	jg     105611 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10562e:	eb 38                	jmp    105668 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105630:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105634:	74 1f                	je     105655 <vprintfmt+0x218>
  105636:	83 fb 1f             	cmp    $0x1f,%ebx
  105639:	7e 05                	jle    105640 <vprintfmt+0x203>
  10563b:	83 fb 7e             	cmp    $0x7e,%ebx
  10563e:	7e 15                	jle    105655 <vprintfmt+0x218>
                    putch('?', putdat);
  105640:	8b 45 0c             	mov    0xc(%ebp),%eax
  105643:	89 44 24 04          	mov    %eax,0x4(%esp)
  105647:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  10564e:	8b 45 08             	mov    0x8(%ebp),%eax
  105651:	ff d0                	call   *%eax
  105653:	eb 0f                	jmp    105664 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105655:	8b 45 0c             	mov    0xc(%ebp),%eax
  105658:	89 44 24 04          	mov    %eax,0x4(%esp)
  10565c:	89 1c 24             	mov    %ebx,(%esp)
  10565f:	8b 45 08             	mov    0x8(%ebp),%eax
  105662:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105664:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105668:	89 f0                	mov    %esi,%eax
  10566a:	8d 70 01             	lea    0x1(%eax),%esi
  10566d:	0f b6 00             	movzbl (%eax),%eax
  105670:	0f be d8             	movsbl %al,%ebx
  105673:	85 db                	test   %ebx,%ebx
  105675:	74 10                	je     105687 <vprintfmt+0x24a>
  105677:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10567b:	78 b3                	js     105630 <vprintfmt+0x1f3>
  10567d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105681:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105685:	79 a9                	jns    105630 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105687:	eb 17                	jmp    1056a0 <vprintfmt+0x263>
                putch(' ', putdat);
  105689:	8b 45 0c             	mov    0xc(%ebp),%eax
  10568c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105690:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105697:	8b 45 08             	mov    0x8(%ebp),%eax
  10569a:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10569c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1056a0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056a4:	7f e3                	jg     105689 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  1056a6:	e9 70 01 00 00       	jmp    10581b <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1056ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1056ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056b2:	8d 45 14             	lea    0x14(%ebp),%eax
  1056b5:	89 04 24             	mov    %eax,(%esp)
  1056b8:	e8 0b fd ff ff       	call   1053c8 <getint>
  1056bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1056c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1056c9:	85 d2                	test   %edx,%edx
  1056cb:	79 26                	jns    1056f3 <vprintfmt+0x2b6>
                putch('-', putdat);
  1056cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1056db:	8b 45 08             	mov    0x8(%ebp),%eax
  1056de:	ff d0                	call   *%eax
                num = -(long long)num;
  1056e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1056e6:	f7 d8                	neg    %eax
  1056e8:	83 d2 00             	adc    $0x0,%edx
  1056eb:	f7 da                	neg    %edx
  1056ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1056f3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1056fa:	e9 a8 00 00 00       	jmp    1057a7 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1056ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105702:	89 44 24 04          	mov    %eax,0x4(%esp)
  105706:	8d 45 14             	lea    0x14(%ebp),%eax
  105709:	89 04 24             	mov    %eax,(%esp)
  10570c:	e8 68 fc ff ff       	call   105379 <getuint>
  105711:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105714:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105717:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10571e:	e9 84 00 00 00       	jmp    1057a7 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105723:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105726:	89 44 24 04          	mov    %eax,0x4(%esp)
  10572a:	8d 45 14             	lea    0x14(%ebp),%eax
  10572d:	89 04 24             	mov    %eax,(%esp)
  105730:	e8 44 fc ff ff       	call   105379 <getuint>
  105735:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105738:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10573b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105742:	eb 63                	jmp    1057a7 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105744:	8b 45 0c             	mov    0xc(%ebp),%eax
  105747:	89 44 24 04          	mov    %eax,0x4(%esp)
  10574b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105752:	8b 45 08             	mov    0x8(%ebp),%eax
  105755:	ff d0                	call   *%eax
            putch('x', putdat);
  105757:	8b 45 0c             	mov    0xc(%ebp),%eax
  10575a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10575e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105765:	8b 45 08             	mov    0x8(%ebp),%eax
  105768:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  10576a:	8b 45 14             	mov    0x14(%ebp),%eax
  10576d:	8d 50 04             	lea    0x4(%eax),%edx
  105770:	89 55 14             	mov    %edx,0x14(%ebp)
  105773:	8b 00                	mov    (%eax),%eax
  105775:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10577f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105786:	eb 1f                	jmp    1057a7 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105788:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10578b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10578f:	8d 45 14             	lea    0x14(%ebp),%eax
  105792:	89 04 24             	mov    %eax,(%esp)
  105795:	e8 df fb ff ff       	call   105379 <getuint>
  10579a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10579d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1057a0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1057a7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1057ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057ae:	89 54 24 18          	mov    %edx,0x18(%esp)
  1057b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1057b5:	89 54 24 14          	mov    %edx,0x14(%esp)
  1057b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  1057bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1057c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1057cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d5:	89 04 24             	mov    %eax,(%esp)
  1057d8:	e8 97 fa ff ff       	call   105274 <printnum>
            break;
  1057dd:	eb 3c                	jmp    10581b <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1057df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057e6:	89 1c 24             	mov    %ebx,(%esp)
  1057e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ec:	ff d0                	call   *%eax
            break;
  1057ee:	eb 2b                	jmp    10581b <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1057f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057f7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1057fe:	8b 45 08             	mov    0x8(%ebp),%eax
  105801:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105803:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105807:	eb 04                	jmp    10580d <vprintfmt+0x3d0>
  105809:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10580d:	8b 45 10             	mov    0x10(%ebp),%eax
  105810:	83 e8 01             	sub    $0x1,%eax
  105813:	0f b6 00             	movzbl (%eax),%eax
  105816:	3c 25                	cmp    $0x25,%al
  105818:	75 ef                	jne    105809 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  10581a:	90                   	nop
        }
    }
  10581b:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10581c:	e9 3e fc ff ff       	jmp    10545f <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  105821:	83 c4 40             	add    $0x40,%esp
  105824:	5b                   	pop    %ebx
  105825:	5e                   	pop    %esi
  105826:	5d                   	pop    %ebp
  105827:	c3                   	ret    

00105828 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105828:	55                   	push   %ebp
  105829:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10582b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10582e:	8b 40 08             	mov    0x8(%eax),%eax
  105831:	8d 50 01             	lea    0x1(%eax),%edx
  105834:	8b 45 0c             	mov    0xc(%ebp),%eax
  105837:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  10583a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10583d:	8b 10                	mov    (%eax),%edx
  10583f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105842:	8b 40 04             	mov    0x4(%eax),%eax
  105845:	39 c2                	cmp    %eax,%edx
  105847:	73 12                	jae    10585b <sprintputch+0x33>
        *b->buf ++ = ch;
  105849:	8b 45 0c             	mov    0xc(%ebp),%eax
  10584c:	8b 00                	mov    (%eax),%eax
  10584e:	8d 48 01             	lea    0x1(%eax),%ecx
  105851:	8b 55 0c             	mov    0xc(%ebp),%edx
  105854:	89 0a                	mov    %ecx,(%edx)
  105856:	8b 55 08             	mov    0x8(%ebp),%edx
  105859:	88 10                	mov    %dl,(%eax)
    }
}
  10585b:	5d                   	pop    %ebp
  10585c:	c3                   	ret    

0010585d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  10585d:	55                   	push   %ebp
  10585e:	89 e5                	mov    %esp,%ebp
  105860:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105863:	8d 45 14             	lea    0x14(%ebp),%eax
  105866:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10586c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105870:	8b 45 10             	mov    0x10(%ebp),%eax
  105873:	89 44 24 08          	mov    %eax,0x8(%esp)
  105877:	8b 45 0c             	mov    0xc(%ebp),%eax
  10587a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10587e:	8b 45 08             	mov    0x8(%ebp),%eax
  105881:	89 04 24             	mov    %eax,(%esp)
  105884:	e8 08 00 00 00       	call   105891 <vsnprintf>
  105889:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10588c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10588f:	c9                   	leave  
  105890:	c3                   	ret    

00105891 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105891:	55                   	push   %ebp
  105892:	89 e5                	mov    %esp,%ebp
  105894:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105897:	8b 45 08             	mov    0x8(%ebp),%eax
  10589a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10589d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058a0:	8d 50 ff             	lea    -0x1(%eax),%edx
  1058a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a6:	01 d0                	add    %edx,%eax
  1058a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1058b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1058b6:	74 0a                	je     1058c2 <vsnprintf+0x31>
  1058b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1058bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058be:	39 c2                	cmp    %eax,%edx
  1058c0:	76 07                	jbe    1058c9 <vsnprintf+0x38>
        return -E_INVAL;
  1058c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1058c7:	eb 2a                	jmp    1058f3 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1058c9:	8b 45 14             	mov    0x14(%ebp),%eax
  1058cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1058d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1058d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1058da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058de:	c7 04 24 28 58 10 00 	movl   $0x105828,(%esp)
  1058e5:	e8 53 fb ff ff       	call   10543d <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1058ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058ed:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1058f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1058f3:	c9                   	leave  
  1058f4:	c3                   	ret    

001058f5 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1058f5:	55                   	push   %ebp
  1058f6:	89 e5                	mov    %esp,%ebp
  1058f8:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1058fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105902:	eb 04                	jmp    105908 <strlen+0x13>
        cnt ++;
  105904:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105908:	8b 45 08             	mov    0x8(%ebp),%eax
  10590b:	8d 50 01             	lea    0x1(%eax),%edx
  10590e:	89 55 08             	mov    %edx,0x8(%ebp)
  105911:	0f b6 00             	movzbl (%eax),%eax
  105914:	84 c0                	test   %al,%al
  105916:	75 ec                	jne    105904 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105918:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10591b:	c9                   	leave  
  10591c:	c3                   	ret    

0010591d <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10591d:	55                   	push   %ebp
  10591e:	89 e5                	mov    %esp,%ebp
  105920:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105923:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10592a:	eb 04                	jmp    105930 <strnlen+0x13>
        cnt ++;
  10592c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105930:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105933:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105936:	73 10                	jae    105948 <strnlen+0x2b>
  105938:	8b 45 08             	mov    0x8(%ebp),%eax
  10593b:	8d 50 01             	lea    0x1(%eax),%edx
  10593e:	89 55 08             	mov    %edx,0x8(%ebp)
  105941:	0f b6 00             	movzbl (%eax),%eax
  105944:	84 c0                	test   %al,%al
  105946:	75 e4                	jne    10592c <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105948:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10594b:	c9                   	leave  
  10594c:	c3                   	ret    

0010594d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10594d:	55                   	push   %ebp
  10594e:	89 e5                	mov    %esp,%ebp
  105950:	57                   	push   %edi
  105951:	56                   	push   %esi
  105952:	83 ec 20             	sub    $0x20,%esp
  105955:	8b 45 08             	mov    0x8(%ebp),%eax
  105958:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10595b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10595e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105961:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105964:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105967:	89 d1                	mov    %edx,%ecx
  105969:	89 c2                	mov    %eax,%edx
  10596b:	89 ce                	mov    %ecx,%esi
  10596d:	89 d7                	mov    %edx,%edi
  10596f:	ac                   	lods   %ds:(%esi),%al
  105970:	aa                   	stos   %al,%es:(%edi)
  105971:	84 c0                	test   %al,%al
  105973:	75 fa                	jne    10596f <strcpy+0x22>
  105975:	89 fa                	mov    %edi,%edx
  105977:	89 f1                	mov    %esi,%ecx
  105979:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10597c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10597f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105982:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105985:	83 c4 20             	add    $0x20,%esp
  105988:	5e                   	pop    %esi
  105989:	5f                   	pop    %edi
  10598a:	5d                   	pop    %ebp
  10598b:	c3                   	ret    

0010598c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10598c:	55                   	push   %ebp
  10598d:	89 e5                	mov    %esp,%ebp
  10598f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105992:	8b 45 08             	mov    0x8(%ebp),%eax
  105995:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105998:	eb 21                	jmp    1059bb <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  10599a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10599d:	0f b6 10             	movzbl (%eax),%edx
  1059a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1059a3:	88 10                	mov    %dl,(%eax)
  1059a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1059a8:	0f b6 00             	movzbl (%eax),%eax
  1059ab:	84 c0                	test   %al,%al
  1059ad:	74 04                	je     1059b3 <strncpy+0x27>
            src ++;
  1059af:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1059b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1059b7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  1059bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1059bf:	75 d9                	jne    10599a <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  1059c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1059c4:	c9                   	leave  
  1059c5:	c3                   	ret    

001059c6 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1059c6:	55                   	push   %ebp
  1059c7:	89 e5                	mov    %esp,%ebp
  1059c9:	57                   	push   %edi
  1059ca:	56                   	push   %esi
  1059cb:	83 ec 20             	sub    $0x20,%esp
  1059ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1059d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  1059da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059e0:	89 d1                	mov    %edx,%ecx
  1059e2:	89 c2                	mov    %eax,%edx
  1059e4:	89 ce                	mov    %ecx,%esi
  1059e6:	89 d7                	mov    %edx,%edi
  1059e8:	ac                   	lods   %ds:(%esi),%al
  1059e9:	ae                   	scas   %es:(%edi),%al
  1059ea:	75 08                	jne    1059f4 <strcmp+0x2e>
  1059ec:	84 c0                	test   %al,%al
  1059ee:	75 f8                	jne    1059e8 <strcmp+0x22>
  1059f0:	31 c0                	xor    %eax,%eax
  1059f2:	eb 04                	jmp    1059f8 <strcmp+0x32>
  1059f4:	19 c0                	sbb    %eax,%eax
  1059f6:	0c 01                	or     $0x1,%al
  1059f8:	89 fa                	mov    %edi,%edx
  1059fa:	89 f1                	mov    %esi,%ecx
  1059fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1059ff:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105a02:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105a05:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105a08:	83 c4 20             	add    $0x20,%esp
  105a0b:	5e                   	pop    %esi
  105a0c:	5f                   	pop    %edi
  105a0d:	5d                   	pop    %ebp
  105a0e:	c3                   	ret    

00105a0f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105a0f:	55                   	push   %ebp
  105a10:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105a12:	eb 0c                	jmp    105a20 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105a14:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a18:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105a1c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105a20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a24:	74 1a                	je     105a40 <strncmp+0x31>
  105a26:	8b 45 08             	mov    0x8(%ebp),%eax
  105a29:	0f b6 00             	movzbl (%eax),%eax
  105a2c:	84 c0                	test   %al,%al
  105a2e:	74 10                	je     105a40 <strncmp+0x31>
  105a30:	8b 45 08             	mov    0x8(%ebp),%eax
  105a33:	0f b6 10             	movzbl (%eax),%edx
  105a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a39:	0f b6 00             	movzbl (%eax),%eax
  105a3c:	38 c2                	cmp    %al,%dl
  105a3e:	74 d4                	je     105a14 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105a40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a44:	74 18                	je     105a5e <strncmp+0x4f>
  105a46:	8b 45 08             	mov    0x8(%ebp),%eax
  105a49:	0f b6 00             	movzbl (%eax),%eax
  105a4c:	0f b6 d0             	movzbl %al,%edx
  105a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a52:	0f b6 00             	movzbl (%eax),%eax
  105a55:	0f b6 c0             	movzbl %al,%eax
  105a58:	29 c2                	sub    %eax,%edx
  105a5a:	89 d0                	mov    %edx,%eax
  105a5c:	eb 05                	jmp    105a63 <strncmp+0x54>
  105a5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105a63:	5d                   	pop    %ebp
  105a64:	c3                   	ret    

00105a65 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105a65:	55                   	push   %ebp
  105a66:	89 e5                	mov    %esp,%ebp
  105a68:	83 ec 04             	sub    $0x4,%esp
  105a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a6e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105a71:	eb 14                	jmp    105a87 <strchr+0x22>
        if (*s == c) {
  105a73:	8b 45 08             	mov    0x8(%ebp),%eax
  105a76:	0f b6 00             	movzbl (%eax),%eax
  105a79:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105a7c:	75 05                	jne    105a83 <strchr+0x1e>
            return (char *)s;
  105a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  105a81:	eb 13                	jmp    105a96 <strchr+0x31>
        }
        s ++;
  105a83:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105a87:	8b 45 08             	mov    0x8(%ebp),%eax
  105a8a:	0f b6 00             	movzbl (%eax),%eax
  105a8d:	84 c0                	test   %al,%al
  105a8f:	75 e2                	jne    105a73 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105a96:	c9                   	leave  
  105a97:	c3                   	ret    

00105a98 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105a98:	55                   	push   %ebp
  105a99:	89 e5                	mov    %esp,%ebp
  105a9b:	83 ec 04             	sub    $0x4,%esp
  105a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105aa4:	eb 11                	jmp    105ab7 <strfind+0x1f>
        if (*s == c) {
  105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa9:	0f b6 00             	movzbl (%eax),%eax
  105aac:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105aaf:	75 02                	jne    105ab3 <strfind+0x1b>
            break;
  105ab1:	eb 0e                	jmp    105ac1 <strfind+0x29>
        }
        s ++;
  105ab3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  105aba:	0f b6 00             	movzbl (%eax),%eax
  105abd:	84 c0                	test   %al,%al
  105abf:	75 e5                	jne    105aa6 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105ac1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ac4:	c9                   	leave  
  105ac5:	c3                   	ret    

00105ac6 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105ac6:	55                   	push   %ebp
  105ac7:	89 e5                	mov    %esp,%ebp
  105ac9:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105acc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105ad3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105ada:	eb 04                	jmp    105ae0 <strtol+0x1a>
        s ++;
  105adc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae3:	0f b6 00             	movzbl (%eax),%eax
  105ae6:	3c 20                	cmp    $0x20,%al
  105ae8:	74 f2                	je     105adc <strtol+0x16>
  105aea:	8b 45 08             	mov    0x8(%ebp),%eax
  105aed:	0f b6 00             	movzbl (%eax),%eax
  105af0:	3c 09                	cmp    $0x9,%al
  105af2:	74 e8                	je     105adc <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105af4:	8b 45 08             	mov    0x8(%ebp),%eax
  105af7:	0f b6 00             	movzbl (%eax),%eax
  105afa:	3c 2b                	cmp    $0x2b,%al
  105afc:	75 06                	jne    105b04 <strtol+0x3e>
        s ++;
  105afe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105b02:	eb 15                	jmp    105b19 <strtol+0x53>
    }
    else if (*s == '-') {
  105b04:	8b 45 08             	mov    0x8(%ebp),%eax
  105b07:	0f b6 00             	movzbl (%eax),%eax
  105b0a:	3c 2d                	cmp    $0x2d,%al
  105b0c:	75 0b                	jne    105b19 <strtol+0x53>
        s ++, neg = 1;
  105b0e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105b12:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105b19:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b1d:	74 06                	je     105b25 <strtol+0x5f>
  105b1f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105b23:	75 24                	jne    105b49 <strtol+0x83>
  105b25:	8b 45 08             	mov    0x8(%ebp),%eax
  105b28:	0f b6 00             	movzbl (%eax),%eax
  105b2b:	3c 30                	cmp    $0x30,%al
  105b2d:	75 1a                	jne    105b49 <strtol+0x83>
  105b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b32:	83 c0 01             	add    $0x1,%eax
  105b35:	0f b6 00             	movzbl (%eax),%eax
  105b38:	3c 78                	cmp    $0x78,%al
  105b3a:	75 0d                	jne    105b49 <strtol+0x83>
        s += 2, base = 16;
  105b3c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105b40:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105b47:	eb 2a                	jmp    105b73 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105b49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b4d:	75 17                	jne    105b66 <strtol+0xa0>
  105b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b52:	0f b6 00             	movzbl (%eax),%eax
  105b55:	3c 30                	cmp    $0x30,%al
  105b57:	75 0d                	jne    105b66 <strtol+0xa0>
        s ++, base = 8;
  105b59:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105b5d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105b64:	eb 0d                	jmp    105b73 <strtol+0xad>
    }
    else if (base == 0) {
  105b66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b6a:	75 07                	jne    105b73 <strtol+0xad>
        base = 10;
  105b6c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105b73:	8b 45 08             	mov    0x8(%ebp),%eax
  105b76:	0f b6 00             	movzbl (%eax),%eax
  105b79:	3c 2f                	cmp    $0x2f,%al
  105b7b:	7e 1b                	jle    105b98 <strtol+0xd2>
  105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105b80:	0f b6 00             	movzbl (%eax),%eax
  105b83:	3c 39                	cmp    $0x39,%al
  105b85:	7f 11                	jg     105b98 <strtol+0xd2>
            dig = *s - '0';
  105b87:	8b 45 08             	mov    0x8(%ebp),%eax
  105b8a:	0f b6 00             	movzbl (%eax),%eax
  105b8d:	0f be c0             	movsbl %al,%eax
  105b90:	83 e8 30             	sub    $0x30,%eax
  105b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b96:	eb 48                	jmp    105be0 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105b98:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9b:	0f b6 00             	movzbl (%eax),%eax
  105b9e:	3c 60                	cmp    $0x60,%al
  105ba0:	7e 1b                	jle    105bbd <strtol+0xf7>
  105ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  105ba5:	0f b6 00             	movzbl (%eax),%eax
  105ba8:	3c 7a                	cmp    $0x7a,%al
  105baa:	7f 11                	jg     105bbd <strtol+0xf7>
            dig = *s - 'a' + 10;
  105bac:	8b 45 08             	mov    0x8(%ebp),%eax
  105baf:	0f b6 00             	movzbl (%eax),%eax
  105bb2:	0f be c0             	movsbl %al,%eax
  105bb5:	83 e8 57             	sub    $0x57,%eax
  105bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bbb:	eb 23                	jmp    105be0 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  105bc0:	0f b6 00             	movzbl (%eax),%eax
  105bc3:	3c 40                	cmp    $0x40,%al
  105bc5:	7e 3d                	jle    105c04 <strtol+0x13e>
  105bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  105bca:	0f b6 00             	movzbl (%eax),%eax
  105bcd:	3c 5a                	cmp    $0x5a,%al
  105bcf:	7f 33                	jg     105c04 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd4:	0f b6 00             	movzbl (%eax),%eax
  105bd7:	0f be c0             	movsbl %al,%eax
  105bda:	83 e8 37             	sub    $0x37,%eax
  105bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105be3:	3b 45 10             	cmp    0x10(%ebp),%eax
  105be6:	7c 02                	jl     105bea <strtol+0x124>
            break;
  105be8:	eb 1a                	jmp    105c04 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105bea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105bee:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105bf1:	0f af 45 10          	imul   0x10(%ebp),%eax
  105bf5:	89 c2                	mov    %eax,%edx
  105bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105bfa:	01 d0                	add    %edx,%eax
  105bfc:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105bff:	e9 6f ff ff ff       	jmp    105b73 <strtol+0xad>

    if (endptr) {
  105c04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105c08:	74 08                	je     105c12 <strtol+0x14c>
        *endptr = (char *) s;
  105c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  105c10:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105c12:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105c16:	74 07                	je     105c1f <strtol+0x159>
  105c18:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105c1b:	f7 d8                	neg    %eax
  105c1d:	eb 03                	jmp    105c22 <strtol+0x15c>
  105c1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105c22:	c9                   	leave  
  105c23:	c3                   	ret    

00105c24 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105c24:	55                   	push   %ebp
  105c25:	89 e5                	mov    %esp,%ebp
  105c27:	57                   	push   %edi
  105c28:	83 ec 24             	sub    $0x24,%esp
  105c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c2e:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105c31:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105c35:	8b 55 08             	mov    0x8(%ebp),%edx
  105c38:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105c3b:	88 45 f7             	mov    %al,-0x9(%ebp)
  105c3e:	8b 45 10             	mov    0x10(%ebp),%eax
  105c41:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105c44:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105c47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105c4b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105c4e:	89 d7                	mov    %edx,%edi
  105c50:	f3 aa                	rep stos %al,%es:(%edi)
  105c52:	89 fa                	mov    %edi,%edx
  105c54:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105c57:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105c5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105c5d:	83 c4 24             	add    $0x24,%esp
  105c60:	5f                   	pop    %edi
  105c61:	5d                   	pop    %ebp
  105c62:	c3                   	ret    

00105c63 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105c63:	55                   	push   %ebp
  105c64:	89 e5                	mov    %esp,%ebp
  105c66:	57                   	push   %edi
  105c67:	56                   	push   %esi
  105c68:	53                   	push   %ebx
  105c69:	83 ec 30             	sub    $0x30,%esp
  105c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  105c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c78:	8b 45 10             	mov    0x10(%ebp),%eax
  105c7b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c81:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105c84:	73 42                	jae    105cc8 <memmove+0x65>
  105c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105c8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105c92:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c95:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105c98:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105c9b:	c1 e8 02             	shr    $0x2,%eax
  105c9e:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105ca0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ca3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ca6:	89 d7                	mov    %edx,%edi
  105ca8:	89 c6                	mov    %eax,%esi
  105caa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105cac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105caf:	83 e1 03             	and    $0x3,%ecx
  105cb2:	74 02                	je     105cb6 <memmove+0x53>
  105cb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105cb6:	89 f0                	mov    %esi,%eax
  105cb8:	89 fa                	mov    %edi,%edx
  105cba:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105cbd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105cc0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105cc6:	eb 36                	jmp    105cfe <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105cc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ccb:	8d 50 ff             	lea    -0x1(%eax),%edx
  105cce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105cd1:	01 c2                	add    %eax,%edx
  105cd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105cd6:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cdc:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105cdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ce2:	89 c1                	mov    %eax,%ecx
  105ce4:	89 d8                	mov    %ebx,%eax
  105ce6:	89 d6                	mov    %edx,%esi
  105ce8:	89 c7                	mov    %eax,%edi
  105cea:	fd                   	std    
  105ceb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ced:	fc                   	cld    
  105cee:	89 f8                	mov    %edi,%eax
  105cf0:	89 f2                	mov    %esi,%edx
  105cf2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105cf5:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105cf8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105cfe:	83 c4 30             	add    $0x30,%esp
  105d01:	5b                   	pop    %ebx
  105d02:	5e                   	pop    %esi
  105d03:	5f                   	pop    %edi
  105d04:	5d                   	pop    %ebp
  105d05:	c3                   	ret    

00105d06 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105d06:	55                   	push   %ebp
  105d07:	89 e5                	mov    %esp,%ebp
  105d09:	57                   	push   %edi
  105d0a:	56                   	push   %esi
  105d0b:	83 ec 20             	sub    $0x20,%esp
  105d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d14:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d1a:	8b 45 10             	mov    0x10(%ebp),%eax
  105d1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d23:	c1 e8 02             	shr    $0x2,%eax
  105d26:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105d28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d2e:	89 d7                	mov    %edx,%edi
  105d30:	89 c6                	mov    %eax,%esi
  105d32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105d34:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105d37:	83 e1 03             	and    $0x3,%ecx
  105d3a:	74 02                	je     105d3e <memcpy+0x38>
  105d3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d3e:	89 f0                	mov    %esi,%eax
  105d40:	89 fa                	mov    %edi,%edx
  105d42:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105d45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105d48:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105d4e:	83 c4 20             	add    $0x20,%esp
  105d51:	5e                   	pop    %esi
  105d52:	5f                   	pop    %edi
  105d53:	5d                   	pop    %ebp
  105d54:	c3                   	ret    

00105d55 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105d55:	55                   	push   %ebp
  105d56:	89 e5                	mov    %esp,%ebp
  105d58:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105d61:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d64:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105d67:	eb 30                	jmp    105d99 <memcmp+0x44>
        if (*s1 != *s2) {
  105d69:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d6c:	0f b6 10             	movzbl (%eax),%edx
  105d6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105d72:	0f b6 00             	movzbl (%eax),%eax
  105d75:	38 c2                	cmp    %al,%dl
  105d77:	74 18                	je     105d91 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d7c:	0f b6 00             	movzbl (%eax),%eax
  105d7f:	0f b6 d0             	movzbl %al,%edx
  105d82:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105d85:	0f b6 00             	movzbl (%eax),%eax
  105d88:	0f b6 c0             	movzbl %al,%eax
  105d8b:	29 c2                	sub    %eax,%edx
  105d8d:	89 d0                	mov    %edx,%eax
  105d8f:	eb 1a                	jmp    105dab <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105d91:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105d95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105d99:	8b 45 10             	mov    0x10(%ebp),%eax
  105d9c:	8d 50 ff             	lea    -0x1(%eax),%edx
  105d9f:	89 55 10             	mov    %edx,0x10(%ebp)
  105da2:	85 c0                	test   %eax,%eax
  105da4:	75 c3                	jne    105d69 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105dab:	c9                   	leave  
  105dac:	c3                   	ret    
