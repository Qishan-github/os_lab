
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
  10005d:	e8 86 5d 00 00       	call   105de8 <memset>

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
  10008b:	e8 c3 42 00 00       	call   104353 <pmm_init>

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
  10033e:	e8 be 52 00 00       	call   105601 <vprintfmt>
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
  100586:	c7 45 f0 08 1f 11 00 	movl   $0x111f08,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec 09 1f 11 00 	movl   $0x111f09,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 31 49 11 00 	movl   $0x114931,-0x18(%ebp)

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
  1006f3:	e8 64 55 00 00       	call   105c5c <strfind>
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
  1008a2:	c7 44 24 04 71 5f 10 	movl   $0x105f71,0x4(%esp)
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
  100abe:	e8 66 51 00 00       	call   105c29 <strchr>
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
  100b2b:	e8 f9 50 00 00       	call   105c29 <strchr>
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
  100b90:	e8 f5 4f 00 00       	call   105b8a <strcmp>
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
  101212:	e8 10 4c 00 00       	call   105e27 <memmove>
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
  10289d:	83 ec 58             	sub    $0x58,%esp
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
     int i = 0;
  1028ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     for (; i < n; i++)
  1028d1:	e9 97 00 00 00       	jmp    10296d <default_init_memmap+0xd3>
     {
         struct Page* p = base + i;
  1028d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1028d9:	89 d0                	mov    %edx,%eax
  1028db:	c1 e0 02             	shl    $0x2,%eax
  1028de:	01 d0                	add    %edx,%eax
  1028e0:	c1 e0 02             	shl    $0x2,%eax
  1028e3:	89 c2                	mov    %eax,%edx
  1028e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1028e8:	01 d0                	add    %edx,%eax
  1028ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
         assert(PageReserved(p));
  1028ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1028f0:	83 c0 04             	add    $0x4,%eax
  1028f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1028fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1028fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102900:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102903:	0f a3 10             	bt     %edx,(%eax)
  102906:	19 c0                	sbb    %eax,%eax
  102908:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10290b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10290f:	0f 95 c0             	setne  %al
  102912:	0f b6 c0             	movzbl %al,%eax
  102915:	85 c0                	test   %eax,%eax
  102917:	75 24                	jne    10293d <default_init_memmap+0xa3>
  102919:	c7 44 24 0c c1 66 10 	movl   $0x1066c1,0xc(%esp)
  102920:	00 
  102921:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102928:	00 
  102929:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  102930:	00 
  102931:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102938:	e8 95 e3 ff ff       	call   100cd2 <__panic>
         ClearPageReserved(p);
  10293d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102940:	83 c0 04             	add    $0x4,%eax
  102943:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  10294a:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10294d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102950:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102953:	0f b3 10             	btr    %edx,(%eax)
         p->ref = p->property = 0;//property只有块头使用，其余清零
  102956:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102959:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102960:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102963:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
     assert(n > 0);
     int i = 0;
     for (; i < n; i++)
  102969:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10296d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102970:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102973:	0f 82 5d ff ff ff    	jb     1028d6 <default_init_memmap+0x3c>
         struct Page* p = base + i;
         assert(PageReserved(p));
         ClearPageReserved(p);
         p->ref = p->property = 0;//property只有块头使用，其余清零
     }
     SetPageProperty(base);//首页置零
  102979:	8b 45 08             	mov    0x8(%ebp),%eax
  10297c:	83 c0 04             	add    $0x4,%eax
  10297f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  102986:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102989:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10298c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10298f:	0f ab 10             	bts    %edx,(%eax)
     list_add_before(&free_list, &(base->page_link));//将块头置于链表中管理
  102992:	8b 45 08             	mov    0x8(%ebp),%eax
  102995:	83 c0 0c             	add    $0xc,%eax
  102998:	c7 45 d0 10 af 11 00 	movl   $0x11af10,-0x30(%ebp)
  10299f:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1029a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1029a5:	8b 00                	mov    (%eax),%eax
  1029a7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1029aa:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1029ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  1029b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1029b3:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1029b6:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1029b9:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1029bc:	89 10                	mov    %edx,(%eax)
  1029be:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1029c1:	8b 10                	mov    (%eax),%edx
  1029c3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1029c6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1029c9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1029cc:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1029cf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1029d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1029d5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1029d8:	89 10                	mov    %edx,(%eax)
     base->property = n;//块首页存放当前块内空闲页数量
  1029da:	8b 45 08             	mov    0x8(%ebp),%eax
  1029dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029e0:	89 50 08             	mov    %edx,0x8(%eax)
     nr_free += n;//当前内存链表中总空闲页数量
  1029e3:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1029e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029ec:	01 d0                	add    %edx,%eax
  1029ee:	a3 18 af 11 00       	mov    %eax,0x11af18
}
  1029f3:	c9                   	leave  
  1029f4:	c3                   	ret    

001029f5 <default_alloc_pages>:


static struct Page *
default_alloc_pages(size_t n) {
  1029f5:	55                   	push   %ebp
  1029f6:	89 e5                	mov    %esp,%ebp
  1029f8:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1029fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029ff:	75 24                	jne    102a25 <default_alloc_pages+0x30>
  102a01:	c7 44 24 0c 90 66 10 	movl   $0x106690,0xc(%esp)
  102a08:	00 
  102a09:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102a10:	00 
  102a11:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  102a18:	00 
  102a19:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102a20:	e8 ad e2 ff ff       	call   100cd2 <__panic>
    if (n > nr_free) { //如果所有的空闲页的加起来的大小都不够，那直接返回NULL
  102a25:	a1 18 af 11 00       	mov    0x11af18,%eax
  102a2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a2d:	73 0a                	jae    102a39 <default_alloc_pages+0x44>
        return NULL;
  102a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  102a34:	e9 49 01 00 00       	jmp    102b82 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
  102a39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
  102a40:	c7 45 f0 10 af 11 00 	movl   $0x11af10,-0x10(%ebp)
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
  102a47:	eb 1c                	jmp    102a65 <default_alloc_pages+0x70>
        // 此处 le2page 就是将 le 的地址 - page_link 在 Page 的偏移 从而找到 Page 的地址
        struct Page *p = le2page(le, page_link);//将地址转换成页的结构
  102a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a4c:	83 e8 0c             	sub    $0xc,%eax
  102a4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
  102a52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a55:	8b 40 08             	mov    0x8(%eax),%eax
  102a58:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a5b:	72 08                	jb     102a65 <default_alloc_pages+0x70>
            page = p;
  102a5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102a63:	eb 18                	jmp    102a7d <default_alloc_pages+0x88>
  102a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102a6e:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;//从空闲块链表的头指针开始
    // 查找 n 个或以上 空闲页块 若找到 则判断是否大过 n 则将其拆分 并将拆分后的剩下的空闲页块加回到链表中
    while ((le = list_next(le)) != &free_list) {//依次往下寻找直到回到头指针处,即已经遍历一次
  102a71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a74:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102a7b:	75 cc                	jne    102a49 <default_alloc_pages+0x54>
        if (p->property >= n) {//由于是first-fit，则遇到的第一个大于N的块就选中即可
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102a81:	0f 84 f8 00 00 00    	je     102b7f <default_alloc_pages+0x18a>
        if (page->property > n) {
  102a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a8a:	8b 40 08             	mov    0x8(%eax),%eax
  102a8d:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a90:	0f 86 98 00 00 00    	jbe    102b2e <default_alloc_pages+0x139>
            struct Page *p = page + n;
  102a96:	8b 55 08             	mov    0x8(%ebp),%edx
  102a99:	89 d0                	mov    %edx,%eax
  102a9b:	c1 e0 02             	shl    $0x2,%eax
  102a9e:	01 d0                	add    %edx,%eax
  102aa0:	c1 e0 02             	shl    $0x2,%eax
  102aa3:	89 c2                	mov    %eax,%edx
  102aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aa8:	01 d0                	add    %edx,%eax
  102aaa:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//如果选中的第一个连续的块大于n，只取其中的大小为n的块
  102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ab0:	8b 40 08             	mov    0x8(%eax),%eax
  102ab3:	2b 45 08             	sub    0x8(%ebp),%eax
  102ab6:	89 c2                	mov    %eax,%edx
  102ab8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102abb:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ac1:	83 c0 04             	add    $0x4,%eax
  102ac4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102acb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102ace:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ad1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102ad4:	0f ab 10             	bts    %edx,(%eax)
            // 将多出来的插入到 被分配掉的页块 后面
            list_add(&(page->page_link), &(p->page_link));
  102ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ada:	83 c0 0c             	add    $0xc,%eax
  102add:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ae0:	83 c2 0c             	add    $0xc,%edx
  102ae3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102ae6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  102ae9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102aec:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102aef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102af2:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102af5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102af8:	8b 40 04             	mov    0x4(%eax),%eax
  102afb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102afe:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102b01:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b04:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  102b07:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b0a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b0d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b10:	89 10                	mov    %edx,(%eax)
  102b12:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b15:	8b 10                	mov    (%eax),%edx
  102b17:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b1a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b20:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102b23:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b26:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b29:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102b2c:	89 10                	mov    %edx,(%eax)
        }
        // 最后在空闲页链表中删除掉原来的空闲页
        list_del(&(page->page_link));
  102b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b31:	83 c0 0c             	add    $0xc,%eax
  102b34:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102b37:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102b3a:	8b 40 04             	mov    0x4(%eax),%eax
  102b3d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102b40:	8b 12                	mov    (%edx),%edx
  102b42:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102b45:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102b48:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102b4b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102b4e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102b51:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102b54:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102b57:	89 10                	mov    %edx,(%eax)
        nr_free -= n;//当前空闲页的数目减n
  102b59:	a1 18 af 11 00       	mov    0x11af18,%eax
  102b5e:	2b 45 08             	sub    0x8(%ebp),%eax
  102b61:	a3 18 af 11 00       	mov    %eax,0x11af18
        ClearPageProperty(page);
  102b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b69:	83 c0 04             	add    $0x4,%eax
  102b6c:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102b73:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b76:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102b79:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102b7c:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102b82:	c9                   	leave  
  102b83:	c3                   	ret    

00102b84 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102b84:	55                   	push   %ebp
  102b85:	89 e5                	mov    %esp,%ebp
  102b87:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102b8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b91:	75 24                	jne    102bb7 <default_free_pages+0x33>
  102b93:	c7 44 24 0c 90 66 10 	movl   $0x106690,0xc(%esp)
  102b9a:	00 
  102b9b:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102ba2:	00 
  102ba3:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  102baa:	00 
  102bab:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102bb2:	e8 1b e1 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  102bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102bbd:	e9 9d 00 00 00       	jmp    102c5f <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bc5:	83 c0 04             	add    $0x4,%eax
  102bc8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102bcf:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102bd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bd5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102bd8:	0f a3 10             	bt     %edx,(%eax)
  102bdb:	19 c0                	sbb    %eax,%eax
  102bdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102be0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102be4:	0f 95 c0             	setne  %al
  102be7:	0f b6 c0             	movzbl %al,%eax
  102bea:	85 c0                	test   %eax,%eax
  102bec:	75 2c                	jne    102c1a <default_free_pages+0x96>
  102bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bf1:	83 c0 04             	add    $0x4,%eax
  102bf4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102bfb:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102bfe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c01:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c04:	0f a3 10             	bt     %edx,(%eax)
  102c07:	19 c0                	sbb    %eax,%eax
  102c09:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102c0c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102c10:	0f 95 c0             	setne  %al
  102c13:	0f b6 c0             	movzbl %al,%eax
  102c16:	85 c0                	test   %eax,%eax
  102c18:	74 24                	je     102c3e <default_free_pages+0xba>
  102c1a:	c7 44 24 0c d4 66 10 	movl   $0x1066d4,0xc(%esp)
  102c21:	00 
  102c22:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102c29:	00 
  102c2a:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  102c31:	00 
  102c32:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102c39:	e8 94 e0 ff ff       	call   100cd2 <__panic>
        p->flags = 0;//修改标志位
  102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c41:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102c48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102c4f:	00 
  102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c53:	89 04 24             	mov    %eax,(%esp)
  102c56:	e8 05 fc ff ff       	call   102860 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102c5b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c62:	89 d0                	mov    %edx,%eax
  102c64:	c1 e0 02             	shl    $0x2,%eax
  102c67:	01 d0                	add    %edx,%eax
  102c69:	c1 e0 02             	shl    $0x2,%eax
  102c6c:	89 c2                	mov    %eax,%edx
  102c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  102c71:	01 d0                	add    %edx,%eax
  102c73:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102c76:	0f 85 46 ff ff ff    	jne    102bc2 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;//修改标志位
        set_page_ref(p, 0);
    }
    base->property = n;//设置连续大小为n
  102c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  102c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c82:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102c85:	8b 45 08             	mov    0x8(%ebp),%eax
  102c88:	83 c0 04             	add    $0x4,%eax
  102c8b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102c92:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102c95:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102c98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102c9b:	0f ab 10             	bts    %edx,(%eax)
  102c9e:	c7 45 cc 10 af 11 00 	movl   $0x11af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102ca5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102ca8:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102cab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 合并到合适的页块中
    while (le != &free_list) {
  102cae:	e9 08 01 00 00       	jmp    102dbb <default_free_pages+0x237>
        p = le2page(le, page_link);//获取链表对应的Page
  102cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cb6:	83 e8 0c             	sub    $0xc,%eax
  102cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cbf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102cc2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102cc5:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102cc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cce:	8b 50 08             	mov    0x8(%eax),%edx
  102cd1:	89 d0                	mov    %edx,%eax
  102cd3:	c1 e0 02             	shl    $0x2,%eax
  102cd6:	01 d0                	add    %edx,%eax
  102cd8:	c1 e0 02             	shl    $0x2,%eax
  102cdb:	89 c2                	mov    %eax,%edx
  102cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce0:	01 d0                	add    %edx,%eax
  102ce2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ce5:	75 5a                	jne    102d41 <default_free_pages+0x1bd>
            base->property += p->property;
  102ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  102cea:	8b 50 08             	mov    0x8(%eax),%edx
  102ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cf0:	8b 40 08             	mov    0x8(%eax),%eax
  102cf3:	01 c2                	add    %eax,%edx
  102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf8:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cfe:	83 c0 04             	add    $0x4,%eax
  102d01:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102d08:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d0b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d0e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d11:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d17:	83 c0 0c             	add    $0xc,%eax
  102d1a:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d1d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d20:	8b 40 04             	mov    0x4(%eax),%eax
  102d23:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d26:	8b 12                	mov    (%edx),%edx
  102d28:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102d2b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102d2e:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d31:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d34:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102d37:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102d3a:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102d3d:	89 10                	mov    %edx,(%eax)
  102d3f:	eb 7a                	jmp    102dbb <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d44:	8b 50 08             	mov    0x8(%eax),%edx
  102d47:	89 d0                	mov    %edx,%eax
  102d49:	c1 e0 02             	shl    $0x2,%eax
  102d4c:	01 d0                	add    %edx,%eax
  102d4e:	c1 e0 02             	shl    $0x2,%eax
  102d51:	89 c2                	mov    %eax,%edx
  102d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d56:	01 d0                	add    %edx,%eax
  102d58:	3b 45 08             	cmp    0x8(%ebp),%eax
  102d5b:	75 5e                	jne    102dbb <default_free_pages+0x237>
            p->property += base->property;
  102d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d60:	8b 50 08             	mov    0x8(%eax),%edx
  102d63:	8b 45 08             	mov    0x8(%ebp),%eax
  102d66:	8b 40 08             	mov    0x8(%eax),%eax
  102d69:	01 c2                	add    %eax,%edx
  102d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d6e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102d71:	8b 45 08             	mov    0x8(%ebp),%eax
  102d74:	83 c0 04             	add    $0x4,%eax
  102d77:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102d7e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102d81:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102d84:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102d87:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d8d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d93:	83 c0 0c             	add    $0xc,%eax
  102d96:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d99:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102d9c:	8b 40 04             	mov    0x4(%eax),%eax
  102d9f:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102da2:	8b 12                	mov    (%edx),%edx
  102da4:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102da7:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102daa:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102dad:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102db0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102db3:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102db6:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102db9:	89 10                	mov    %edx,(%eax)
    }
    base->property = n;//设置连续大小为n
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    // 合并到合适的页块中
    while (le != &free_list) {
  102dbb:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102dc2:	0f 85 eb fe ff ff    	jne    102cb3 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102dc8:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dd1:	01 d0                	add    %edx,%eax
  102dd3:	a3 18 af 11 00       	mov    %eax,0x11af18
  102dd8:	c7 45 9c 10 af 11 00 	movl   $0x11af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102ddf:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102de2:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  102de5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
  102de8:	eb 36                	jmp    102e20 <default_free_pages+0x29c>
        p = le2page(le, page_link);
  102dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ded:	83 e8 0c             	sub    $0xc,%eax
  102df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  102df3:	8b 45 08             	mov    0x8(%ebp),%eax
  102df6:	8b 50 08             	mov    0x8(%eax),%edx
  102df9:	89 d0                	mov    %edx,%eax
  102dfb:	c1 e0 02             	shl    $0x2,%eax
  102dfe:	01 d0                	add    %edx,%eax
  102e00:	c1 e0 02             	shl    $0x2,%eax
  102e03:	89 c2                	mov    %eax,%edx
  102e05:	8b 45 08             	mov    0x8(%ebp),%eax
  102e08:	01 d0                	add    %edx,%eax
  102e0a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e0d:	77 02                	ja     102e11 <default_free_pages+0x28d>
            break;
  102e0f:	eb 18                	jmp    102e29 <default_free_pages+0x2a5>
  102e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e14:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e17:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e1a:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
  102e1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    // 将合并好的合适的页块添加回空闲页块链表
    while (le != &free_list) {
  102e20:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102e27:	75 c1                	jne    102dea <default_free_pages+0x266>
        if (base + base->property <= p) {
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));//将空闲块插入空闲链表中
  102e29:	8b 45 08             	mov    0x8(%ebp),%eax
  102e2c:	8d 50 0c             	lea    0xc(%eax),%edx
  102e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e32:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102e35:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102e38:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102e3b:	8b 00                	mov    (%eax),%eax
  102e3d:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e40:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102e43:	89 45 88             	mov    %eax,-0x78(%ebp)
  102e46:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102e49:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102e4c:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102e4f:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102e52:	89 10                	mov    %edx,(%eax)
  102e54:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102e57:	8b 10                	mov    (%eax),%edx
  102e59:	8b 45 88             	mov    -0x78(%ebp),%eax
  102e5c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102e5f:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e62:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102e65:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102e68:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e6b:	8b 55 88             	mov    -0x78(%ebp),%edx
  102e6e:	89 10                	mov    %edx,(%eax)
}
  102e70:	c9                   	leave  
  102e71:	c3                   	ret    

00102e72 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102e72:	55                   	push   %ebp
  102e73:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102e75:	a1 18 af 11 00       	mov    0x11af18,%eax
}
  102e7a:	5d                   	pop    %ebp
  102e7b:	c3                   	ret    

00102e7c <basic_check>:

static void
basic_check(void) {
  102e7c:	55                   	push   %ebp
  102e7d:	89 e5                	mov    %esp,%ebp
  102e7f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102e82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e92:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102e95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102e9c:	e8 db 0e 00 00       	call   103d7c <alloc_pages>
  102ea1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102ea4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102ea8:	75 24                	jne    102ece <basic_check+0x52>
  102eaa:	c7 44 24 0c f9 66 10 	movl   $0x1066f9,0xc(%esp)
  102eb1:	00 
  102eb2:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102eb9:	00 
  102eba:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  102ec1:	00 
  102ec2:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102ec9:	e8 04 de ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102ece:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102ed5:	e8 a2 0e 00 00       	call   103d7c <alloc_pages>
  102eda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102edd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102ee1:	75 24                	jne    102f07 <basic_check+0x8b>
  102ee3:	c7 44 24 0c 15 67 10 	movl   $0x106715,0xc(%esp)
  102eea:	00 
  102eeb:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102ef2:	00 
  102ef3:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  102efa:	00 
  102efb:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102f02:	e8 cb dd ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102f07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f0e:	e8 69 0e 00 00       	call   103d7c <alloc_pages>
  102f13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102f1a:	75 24                	jne    102f40 <basic_check+0xc4>
  102f1c:	c7 44 24 0c 31 67 10 	movl   $0x106731,0xc(%esp)
  102f23:	00 
  102f24:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102f2b:	00 
  102f2c:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  102f33:	00 
  102f34:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102f3b:	e8 92 dd ff ff       	call   100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102f40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f43:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102f46:	74 10                	je     102f58 <basic_check+0xdc>
  102f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f4b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f4e:	74 08                	je     102f58 <basic_check+0xdc>
  102f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f53:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102f56:	75 24                	jne    102f7c <basic_check+0x100>
  102f58:	c7 44 24 0c 50 67 10 	movl   $0x106750,0xc(%esp)
  102f5f:	00 
  102f60:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102f67:	00 
  102f68:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  102f6f:	00 
  102f70:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102f77:	e8 56 dd ff ff       	call   100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f7f:	89 04 24             	mov    %eax,(%esp)
  102f82:	e8 cf f8 ff ff       	call   102856 <page_ref>
  102f87:	85 c0                	test   %eax,%eax
  102f89:	75 1e                	jne    102fa9 <basic_check+0x12d>
  102f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f8e:	89 04 24             	mov    %eax,(%esp)
  102f91:	e8 c0 f8 ff ff       	call   102856 <page_ref>
  102f96:	85 c0                	test   %eax,%eax
  102f98:	75 0f                	jne    102fa9 <basic_check+0x12d>
  102f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f9d:	89 04 24             	mov    %eax,(%esp)
  102fa0:	e8 b1 f8 ff ff       	call   102856 <page_ref>
  102fa5:	85 c0                	test   %eax,%eax
  102fa7:	74 24                	je     102fcd <basic_check+0x151>
  102fa9:	c7 44 24 0c 74 67 10 	movl   $0x106774,0xc(%esp)
  102fb0:	00 
  102fb1:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102fb8:	00 
  102fb9:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  102fc0:	00 
  102fc1:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  102fc8:	e8 05 dd ff ff       	call   100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  102fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fd0:	89 04 24             	mov    %eax,(%esp)
  102fd3:	e8 68 f8 ff ff       	call   102840 <page2pa>
  102fd8:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102fde:	c1 e2 0c             	shl    $0xc,%edx
  102fe1:	39 d0                	cmp    %edx,%eax
  102fe3:	72 24                	jb     103009 <basic_check+0x18d>
  102fe5:	c7 44 24 0c b0 67 10 	movl   $0x1067b0,0xc(%esp)
  102fec:	00 
  102fed:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  102ff4:	00 
  102ff5:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  102ffc:	00 
  102ffd:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103004:	e8 c9 dc ff ff       	call   100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  103009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10300c:	89 04 24             	mov    %eax,(%esp)
  10300f:	e8 2c f8 ff ff       	call   102840 <page2pa>
  103014:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10301a:	c1 e2 0c             	shl    $0xc,%edx
  10301d:	39 d0                	cmp    %edx,%eax
  10301f:	72 24                	jb     103045 <basic_check+0x1c9>
  103021:	c7 44 24 0c cd 67 10 	movl   $0x1067cd,0xc(%esp)
  103028:	00 
  103029:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103030:	00 
  103031:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  103038:	00 
  103039:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103040:	e8 8d dc ff ff       	call   100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103048:	89 04 24             	mov    %eax,(%esp)
  10304b:	e8 f0 f7 ff ff       	call   102840 <page2pa>
  103050:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103056:	c1 e2 0c             	shl    $0xc,%edx
  103059:	39 d0                	cmp    %edx,%eax
  10305b:	72 24                	jb     103081 <basic_check+0x205>
  10305d:	c7 44 24 0c ea 67 10 	movl   $0x1067ea,0xc(%esp)
  103064:	00 
  103065:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10306c:	00 
  10306d:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  103074:	00 
  103075:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10307c:	e8 51 dc ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  103081:	a1 10 af 11 00       	mov    0x11af10,%eax
  103086:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  10308c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10308f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103092:	c7 45 e0 10 af 11 00 	movl   $0x11af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103099:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10309c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10309f:	89 50 04             	mov    %edx,0x4(%eax)
  1030a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030a5:	8b 50 04             	mov    0x4(%eax),%edx
  1030a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030ab:	89 10                	mov    %edx,(%eax)
  1030ad:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1030b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1030b7:	8b 40 04             	mov    0x4(%eax),%eax
  1030ba:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1030bd:	0f 94 c0             	sete   %al
  1030c0:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1030c3:	85 c0                	test   %eax,%eax
  1030c5:	75 24                	jne    1030eb <basic_check+0x26f>
  1030c7:	c7 44 24 0c 07 68 10 	movl   $0x106807,0xc(%esp)
  1030ce:	00 
  1030cf:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1030d6:	00 
  1030d7:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  1030de:	00 
  1030df:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1030e6:	e8 e7 db ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  1030eb:	a1 18 af 11 00       	mov    0x11af18,%eax
  1030f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1030f3:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1030fa:	00 00 00 

    assert(alloc_page() == NULL);
  1030fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103104:	e8 73 0c 00 00       	call   103d7c <alloc_pages>
  103109:	85 c0                	test   %eax,%eax
  10310b:	74 24                	je     103131 <basic_check+0x2b5>
  10310d:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  103114:	00 
  103115:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10311c:	00 
  10311d:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  103124:	00 
  103125:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10312c:	e8 a1 db ff ff       	call   100cd2 <__panic>

    free_page(p0);
  103131:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103138:	00 
  103139:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10313c:	89 04 24             	mov    %eax,(%esp)
  10313f:	e8 70 0c 00 00       	call   103db4 <free_pages>
    free_page(p1);
  103144:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10314b:	00 
  10314c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10314f:	89 04 24             	mov    %eax,(%esp)
  103152:	e8 5d 0c 00 00       	call   103db4 <free_pages>
    free_page(p2);
  103157:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10315e:	00 
  10315f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103162:	89 04 24             	mov    %eax,(%esp)
  103165:	e8 4a 0c 00 00       	call   103db4 <free_pages>
    assert(nr_free == 3);
  10316a:	a1 18 af 11 00       	mov    0x11af18,%eax
  10316f:	83 f8 03             	cmp    $0x3,%eax
  103172:	74 24                	je     103198 <basic_check+0x31c>
  103174:	c7 44 24 0c 33 68 10 	movl   $0x106833,0xc(%esp)
  10317b:	00 
  10317c:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103183:	00 
  103184:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
  10318b:	00 
  10318c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103193:	e8 3a db ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
  103198:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10319f:	e8 d8 0b 00 00       	call   103d7c <alloc_pages>
  1031a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1031ab:	75 24                	jne    1031d1 <basic_check+0x355>
  1031ad:	c7 44 24 0c f9 66 10 	movl   $0x1066f9,0xc(%esp)
  1031b4:	00 
  1031b5:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1031bc:	00 
  1031bd:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  1031c4:	00 
  1031c5:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1031cc:	e8 01 db ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1031d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031d8:	e8 9f 0b 00 00       	call   103d7c <alloc_pages>
  1031dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1031e4:	75 24                	jne    10320a <basic_check+0x38e>
  1031e6:	c7 44 24 0c 15 67 10 	movl   $0x106715,0xc(%esp)
  1031ed:	00 
  1031ee:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1031f5:	00 
  1031f6:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  1031fd:	00 
  1031fe:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103205:	e8 c8 da ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10320a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103211:	e8 66 0b 00 00       	call   103d7c <alloc_pages>
  103216:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103219:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10321d:	75 24                	jne    103243 <basic_check+0x3c7>
  10321f:	c7 44 24 0c 31 67 10 	movl   $0x106731,0xc(%esp)
  103226:	00 
  103227:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10322e:	00 
  10322f:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  103236:	00 
  103237:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10323e:	e8 8f da ff ff       	call   100cd2 <__panic>

    assert(alloc_page() == NULL);
  103243:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10324a:	e8 2d 0b 00 00       	call   103d7c <alloc_pages>
  10324f:	85 c0                	test   %eax,%eax
  103251:	74 24                	je     103277 <basic_check+0x3fb>
  103253:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  10325a:	00 
  10325b:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103262:	00 
  103263:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  10326a:	00 
  10326b:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103272:	e8 5b da ff ff       	call   100cd2 <__panic>

    free_page(p0);
  103277:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10327e:	00 
  10327f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103282:	89 04 24             	mov    %eax,(%esp)
  103285:	e8 2a 0b 00 00       	call   103db4 <free_pages>
  10328a:	c7 45 d8 10 af 11 00 	movl   $0x11af10,-0x28(%ebp)
  103291:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103294:	8b 40 04             	mov    0x4(%eax),%eax
  103297:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10329a:	0f 94 c0             	sete   %al
  10329d:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  1032a0:	85 c0                	test   %eax,%eax
  1032a2:	74 24                	je     1032c8 <basic_check+0x44c>
  1032a4:	c7 44 24 0c 40 68 10 	movl   $0x106840,0xc(%esp)
  1032ab:	00 
  1032ac:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1032b3:	00 
  1032b4:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  1032bb:	00 
  1032bc:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1032c3:	e8 0a da ff ff       	call   100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1032c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032cf:	e8 a8 0a 00 00       	call   103d7c <alloc_pages>
  1032d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1032dd:	74 24                	je     103303 <basic_check+0x487>
  1032df:	c7 44 24 0c 58 68 10 	movl   $0x106858,0xc(%esp)
  1032e6:	00 
  1032e7:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1032ee:	00 
  1032ef:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  1032f6:	00 
  1032f7:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1032fe:	e8 cf d9 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  103303:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10330a:	e8 6d 0a 00 00       	call   103d7c <alloc_pages>
  10330f:	85 c0                	test   %eax,%eax
  103311:	74 24                	je     103337 <basic_check+0x4bb>
  103313:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  10331a:	00 
  10331b:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103322:	00 
  103323:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  10332a:	00 
  10332b:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103332:	e8 9b d9 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  103337:	a1 18 af 11 00       	mov    0x11af18,%eax
  10333c:	85 c0                	test   %eax,%eax
  10333e:	74 24                	je     103364 <basic_check+0x4e8>
  103340:	c7 44 24 0c 71 68 10 	movl   $0x106871,0xc(%esp)
  103347:	00 
  103348:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10334f:	00 
  103350:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  103357:	00 
  103358:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10335f:	e8 6e d9 ff ff       	call   100cd2 <__panic>
    free_list = free_list_store;
  103364:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103367:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10336a:	a3 10 af 11 00       	mov    %eax,0x11af10
  10336f:	89 15 14 af 11 00    	mov    %edx,0x11af14
    nr_free = nr_free_store;
  103375:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103378:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_page(p);
  10337d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103384:	00 
  103385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103388:	89 04 24             	mov    %eax,(%esp)
  10338b:	e8 24 0a 00 00       	call   103db4 <free_pages>
    free_page(p1);
  103390:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103397:	00 
  103398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10339b:	89 04 24             	mov    %eax,(%esp)
  10339e:	e8 11 0a 00 00       	call   103db4 <free_pages>
    free_page(p2);
  1033a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033aa:	00 
  1033ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033ae:	89 04 24             	mov    %eax,(%esp)
  1033b1:	e8 fe 09 00 00       	call   103db4 <free_pages>
}
  1033b6:	c9                   	leave  
  1033b7:	c3                   	ret    

001033b8 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1033b8:	55                   	push   %ebp
  1033b9:	89 e5                	mov    %esp,%ebp
  1033bb:	53                   	push   %ebx
  1033bc:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  1033c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1033c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1033d0:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1033d7:	eb 6b                	jmp    103444 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  1033d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033dc:	83 e8 0c             	sub    $0xc,%eax
  1033df:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  1033e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033e5:	83 c0 04             	add    $0x4,%eax
  1033e8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1033ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1033f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1033f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1033f8:	0f a3 10             	bt     %edx,(%eax)
  1033fb:	19 c0                	sbb    %eax,%eax
  1033fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103400:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  103404:	0f 95 c0             	setne  %al
  103407:	0f b6 c0             	movzbl %al,%eax
  10340a:	85 c0                	test   %eax,%eax
  10340c:	75 24                	jne    103432 <default_check+0x7a>
  10340e:	c7 44 24 0c 7e 68 10 	movl   $0x10687e,0xc(%esp)
  103415:	00 
  103416:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10341d:	00 
  10341e:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  103425:	00 
  103426:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10342d:	e8 a0 d8 ff ff       	call   100cd2 <__panic>
        count ++, total += p->property;
  103432:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  103436:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103439:	8b 50 08             	mov    0x8(%eax),%edx
  10343c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10343f:	01 d0                	add    %edx,%eax
  103441:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103444:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103447:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10344a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10344d:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103450:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103453:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  10345a:	0f 85 79 ff ff ff    	jne    1033d9 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  103460:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  103463:	e8 7e 09 00 00       	call   103de6 <nr_free_pages>
  103468:	39 c3                	cmp    %eax,%ebx
  10346a:	74 24                	je     103490 <default_check+0xd8>
  10346c:	c7 44 24 0c 8e 68 10 	movl   $0x10688e,0xc(%esp)
  103473:	00 
  103474:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10347b:	00 
  10347c:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  103483:	00 
  103484:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10348b:	e8 42 d8 ff ff       	call   100cd2 <__panic>

    basic_check();
  103490:	e8 e7 f9 ff ff       	call   102e7c <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103495:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10349c:	e8 db 08 00 00       	call   103d7c <alloc_pages>
  1034a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  1034a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1034a8:	75 24                	jne    1034ce <default_check+0x116>
  1034aa:	c7 44 24 0c a7 68 10 	movl   $0x1068a7,0xc(%esp)
  1034b1:	00 
  1034b2:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1034b9:	00 
  1034ba:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  1034c1:	00 
  1034c2:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1034c9:	e8 04 d8 ff ff       	call   100cd2 <__panic>
    assert(!PageProperty(p0));
  1034ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034d1:	83 c0 04             	add    $0x4,%eax
  1034d4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1034db:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1034de:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1034e1:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1034e4:	0f a3 10             	bt     %edx,(%eax)
  1034e7:	19 c0                	sbb    %eax,%eax
  1034e9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1034ec:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1034f0:	0f 95 c0             	setne  %al
  1034f3:	0f b6 c0             	movzbl %al,%eax
  1034f6:	85 c0                	test   %eax,%eax
  1034f8:	74 24                	je     10351e <default_check+0x166>
  1034fa:	c7 44 24 0c b2 68 10 	movl   $0x1068b2,0xc(%esp)
  103501:	00 
  103502:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103509:	00 
  10350a:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  103511:	00 
  103512:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103519:	e8 b4 d7 ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  10351e:	a1 10 af 11 00       	mov    0x11af10,%eax
  103523:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  103529:	89 45 80             	mov    %eax,-0x80(%ebp)
  10352c:	89 55 84             	mov    %edx,-0x7c(%ebp)
  10352f:	c7 45 b4 10 af 11 00 	movl   $0x11af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103536:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103539:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10353c:	89 50 04             	mov    %edx,0x4(%eax)
  10353f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103542:	8b 50 04             	mov    0x4(%eax),%edx
  103545:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103548:	89 10                	mov    %edx,(%eax)
  10354a:	c7 45 b0 10 af 11 00 	movl   $0x11af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103551:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103554:	8b 40 04             	mov    0x4(%eax),%eax
  103557:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  10355a:	0f 94 c0             	sete   %al
  10355d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103560:	85 c0                	test   %eax,%eax
  103562:	75 24                	jne    103588 <default_check+0x1d0>
  103564:	c7 44 24 0c 07 68 10 	movl   $0x106807,0xc(%esp)
  10356b:	00 
  10356c:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103573:	00 
  103574:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  10357b:	00 
  10357c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103583:	e8 4a d7 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  103588:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10358f:	e8 e8 07 00 00       	call   103d7c <alloc_pages>
  103594:	85 c0                	test   %eax,%eax
  103596:	74 24                	je     1035bc <default_check+0x204>
  103598:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  10359f:	00 
  1035a0:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1035a7:	00 
  1035a8:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1035af:	00 
  1035b0:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1035b7:	e8 16 d7 ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  1035bc:	a1 18 af 11 00       	mov    0x11af18,%eax
  1035c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  1035c4:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1035cb:	00 00 00 

    free_pages(p0 + 2, 3);
  1035ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1035d1:	83 c0 28             	add    $0x28,%eax
  1035d4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1035db:	00 
  1035dc:	89 04 24             	mov    %eax,(%esp)
  1035df:	e8 d0 07 00 00       	call   103db4 <free_pages>
    assert(alloc_pages(4) == NULL);
  1035e4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1035eb:	e8 8c 07 00 00       	call   103d7c <alloc_pages>
  1035f0:	85 c0                	test   %eax,%eax
  1035f2:	74 24                	je     103618 <default_check+0x260>
  1035f4:	c7 44 24 0c c4 68 10 	movl   $0x1068c4,0xc(%esp)
  1035fb:	00 
  1035fc:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103603:	00 
  103604:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  10360b:	00 
  10360c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103613:	e8 ba d6 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  103618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10361b:	83 c0 28             	add    $0x28,%eax
  10361e:	83 c0 04             	add    $0x4,%eax
  103621:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  103628:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10362b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10362e:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103631:	0f a3 10             	bt     %edx,(%eax)
  103634:	19 c0                	sbb    %eax,%eax
  103636:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  103639:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  10363d:	0f 95 c0             	setne  %al
  103640:	0f b6 c0             	movzbl %al,%eax
  103643:	85 c0                	test   %eax,%eax
  103645:	74 0e                	je     103655 <default_check+0x29d>
  103647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10364a:	83 c0 28             	add    $0x28,%eax
  10364d:	8b 40 08             	mov    0x8(%eax),%eax
  103650:	83 f8 03             	cmp    $0x3,%eax
  103653:	74 24                	je     103679 <default_check+0x2c1>
  103655:	c7 44 24 0c dc 68 10 	movl   $0x1068dc,0xc(%esp)
  10365c:	00 
  10365d:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103664:	00 
  103665:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  10366c:	00 
  10366d:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103674:	e8 59 d6 ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  103679:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103680:	e8 f7 06 00 00       	call   103d7c <alloc_pages>
  103685:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103688:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10368c:	75 24                	jne    1036b2 <default_check+0x2fa>
  10368e:	c7 44 24 0c 08 69 10 	movl   $0x106908,0xc(%esp)
  103695:	00 
  103696:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10369d:	00 
  10369e:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1036a5:	00 
  1036a6:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1036ad:	e8 20 d6 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1036b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036b9:	e8 be 06 00 00       	call   103d7c <alloc_pages>
  1036be:	85 c0                	test   %eax,%eax
  1036c0:	74 24                	je     1036e6 <default_check+0x32e>
  1036c2:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  1036c9:	00 
  1036ca:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1036d1:	00 
  1036d2:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  1036d9:	00 
  1036da:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1036e1:	e8 ec d5 ff ff       	call   100cd2 <__panic>
    assert(p0 + 2 == p1);
  1036e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036e9:	83 c0 28             	add    $0x28,%eax
  1036ec:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1036ef:	74 24                	je     103715 <default_check+0x35d>
  1036f1:	c7 44 24 0c 26 69 10 	movl   $0x106926,0xc(%esp)
  1036f8:	00 
  1036f9:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103700:	00 
  103701:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  103708:	00 
  103709:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103710:	e8 bd d5 ff ff       	call   100cd2 <__panic>

    p2 = p0 + 1;
  103715:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103718:	83 c0 14             	add    $0x14,%eax
  10371b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  10371e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103725:	00 
  103726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103729:	89 04 24             	mov    %eax,(%esp)
  10372c:	e8 83 06 00 00       	call   103db4 <free_pages>
    free_pages(p1, 3);
  103731:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103738:	00 
  103739:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10373c:	89 04 24             	mov    %eax,(%esp)
  10373f:	e8 70 06 00 00       	call   103db4 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  103744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103747:	83 c0 04             	add    $0x4,%eax
  10374a:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103751:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103754:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103757:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10375a:	0f a3 10             	bt     %edx,(%eax)
  10375d:	19 c0                	sbb    %eax,%eax
  10375f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103762:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103766:	0f 95 c0             	setne  %al
  103769:	0f b6 c0             	movzbl %al,%eax
  10376c:	85 c0                	test   %eax,%eax
  10376e:	74 0b                	je     10377b <default_check+0x3c3>
  103770:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103773:	8b 40 08             	mov    0x8(%eax),%eax
  103776:	83 f8 01             	cmp    $0x1,%eax
  103779:	74 24                	je     10379f <default_check+0x3e7>
  10377b:	c7 44 24 0c 34 69 10 	movl   $0x106934,0xc(%esp)
  103782:	00 
  103783:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  10378a:	00 
  10378b:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  103792:	00 
  103793:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  10379a:	e8 33 d5 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10379f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037a2:	83 c0 04             	add    $0x4,%eax
  1037a5:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1037ac:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037af:	8b 45 90             	mov    -0x70(%ebp),%eax
  1037b2:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1037b5:	0f a3 10             	bt     %edx,(%eax)
  1037b8:	19 c0                	sbb    %eax,%eax
  1037ba:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1037bd:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1037c1:	0f 95 c0             	setne  %al
  1037c4:	0f b6 c0             	movzbl %al,%eax
  1037c7:	85 c0                	test   %eax,%eax
  1037c9:	74 0b                	je     1037d6 <default_check+0x41e>
  1037cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037ce:	8b 40 08             	mov    0x8(%eax),%eax
  1037d1:	83 f8 03             	cmp    $0x3,%eax
  1037d4:	74 24                	je     1037fa <default_check+0x442>
  1037d6:	c7 44 24 0c 5c 69 10 	movl   $0x10695c,0xc(%esp)
  1037dd:	00 
  1037de:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1037e5:	00 
  1037e6:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  1037ed:	00 
  1037ee:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1037f5:	e8 d8 d4 ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1037fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103801:	e8 76 05 00 00       	call   103d7c <alloc_pages>
  103806:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103809:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10380c:	83 e8 14             	sub    $0x14,%eax
  10380f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103812:	74 24                	je     103838 <default_check+0x480>
  103814:	c7 44 24 0c 82 69 10 	movl   $0x106982,0xc(%esp)
  10381b:	00 
  10381c:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103823:	00 
  103824:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  10382b:	00 
  10382c:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103833:	e8 9a d4 ff ff       	call   100cd2 <__panic>
    free_page(p0);
  103838:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10383f:	00 
  103840:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103843:	89 04 24             	mov    %eax,(%esp)
  103846:	e8 69 05 00 00       	call   103db4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10384b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103852:	e8 25 05 00 00       	call   103d7c <alloc_pages>
  103857:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10385a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10385d:	83 c0 14             	add    $0x14,%eax
  103860:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103863:	74 24                	je     103889 <default_check+0x4d1>
  103865:	c7 44 24 0c a0 69 10 	movl   $0x1069a0,0xc(%esp)
  10386c:	00 
  10386d:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103874:	00 
  103875:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  10387c:	00 
  10387d:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103884:	e8 49 d4 ff ff       	call   100cd2 <__panic>

    free_pages(p0, 2);
  103889:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103890:	00 
  103891:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103894:	89 04 24             	mov    %eax,(%esp)
  103897:	e8 18 05 00 00       	call   103db4 <free_pages>
    free_page(p2);
  10389c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038a3:	00 
  1038a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1038a7:	89 04 24             	mov    %eax,(%esp)
  1038aa:	e8 05 05 00 00       	call   103db4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1038af:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1038b6:	e8 c1 04 00 00       	call   103d7c <alloc_pages>
  1038bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1038c2:	75 24                	jne    1038e8 <default_check+0x530>
  1038c4:	c7 44 24 0c c0 69 10 	movl   $0x1069c0,0xc(%esp)
  1038cb:	00 
  1038cc:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1038d3:	00 
  1038d4:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  1038db:	00 
  1038dc:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1038e3:	e8 ea d3 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1038e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038ef:	e8 88 04 00 00       	call   103d7c <alloc_pages>
  1038f4:	85 c0                	test   %eax,%eax
  1038f6:	74 24                	je     10391c <default_check+0x564>
  1038f8:	c7 44 24 0c 1e 68 10 	movl   $0x10681e,0xc(%esp)
  1038ff:	00 
  103900:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103907:	00 
  103908:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  10390f:	00 
  103910:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103917:	e8 b6 d3 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  10391c:	a1 18 af 11 00       	mov    0x11af18,%eax
  103921:	85 c0                	test   %eax,%eax
  103923:	74 24                	je     103949 <default_check+0x591>
  103925:	c7 44 24 0c 71 68 10 	movl   $0x106871,0xc(%esp)
  10392c:	00 
  10392d:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103934:	00 
  103935:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  10393c:	00 
  10393d:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103944:	e8 89 d3 ff ff       	call   100cd2 <__panic>
    nr_free = nr_free_store;
  103949:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10394c:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_list = free_list_store;
  103951:	8b 45 80             	mov    -0x80(%ebp),%eax
  103954:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103957:	a3 10 af 11 00       	mov    %eax,0x11af10
  10395c:	89 15 14 af 11 00    	mov    %edx,0x11af14
    free_pages(p0, 5);
  103962:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103969:	00 
  10396a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10396d:	89 04 24             	mov    %eax,(%esp)
  103970:	e8 3f 04 00 00       	call   103db4 <free_pages>

    le = &free_list;
  103975:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10397c:	eb 5b                	jmp    1039d9 <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  10397e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103981:	8b 40 04             	mov    0x4(%eax),%eax
  103984:	8b 00                	mov    (%eax),%eax
  103986:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103989:	75 0d                	jne    103998 <default_check+0x5e0>
  10398b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10398e:	8b 00                	mov    (%eax),%eax
  103990:	8b 40 04             	mov    0x4(%eax),%eax
  103993:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103996:	74 24                	je     1039bc <default_check+0x604>
  103998:	c7 44 24 0c e0 69 10 	movl   $0x1069e0,0xc(%esp)
  10399f:	00 
  1039a0:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  1039a7:	00 
  1039a8:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  1039af:	00 
  1039b0:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  1039b7:	e8 16 d3 ff ff       	call   100cd2 <__panic>
        struct Page *p = le2page(le, page_link);
  1039bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039bf:	83 e8 0c             	sub    $0xc,%eax
  1039c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1039c5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1039c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1039cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1039cf:	8b 40 08             	mov    0x8(%eax),%eax
  1039d2:	29 c2                	sub    %eax,%edx
  1039d4:	89 d0                	mov    %edx,%eax
  1039d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1039d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039dc:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1039df:	8b 45 88             	mov    -0x78(%ebp),%eax
  1039e2:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1039e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1039e8:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  1039ef:	75 8d                	jne    10397e <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  1039f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1039f5:	74 24                	je     103a1b <default_check+0x663>
  1039f7:	c7 44 24 0c 0d 6a 10 	movl   $0x106a0d,0xc(%esp)
  1039fe:	00 
  1039ff:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103a06:	00 
  103a07:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  103a0e:	00 
  103a0f:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103a16:	e8 b7 d2 ff ff       	call   100cd2 <__panic>
    assert(total == 0);
  103a1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a1f:	74 24                	je     103a45 <default_check+0x68d>
  103a21:	c7 44 24 0c 18 6a 10 	movl   $0x106a18,0xc(%esp)
  103a28:	00 
  103a29:	c7 44 24 08 96 66 10 	movl   $0x106696,0x8(%esp)
  103a30:	00 
  103a31:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  103a38:	00 
  103a39:	c7 04 24 ab 66 10 00 	movl   $0x1066ab,(%esp)
  103a40:	e8 8d d2 ff ff       	call   100cd2 <__panic>
}
  103a45:	81 c4 94 00 00 00    	add    $0x94,%esp
  103a4b:	5b                   	pop    %ebx
  103a4c:	5d                   	pop    %ebp
  103a4d:	c3                   	ret    

00103a4e <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103a4e:	55                   	push   %ebp
  103a4f:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103a51:	8b 55 08             	mov    0x8(%ebp),%edx
  103a54:	a1 24 af 11 00       	mov    0x11af24,%eax
  103a59:	29 c2                	sub    %eax,%edx
  103a5b:	89 d0                	mov    %edx,%eax
  103a5d:	c1 f8 02             	sar    $0x2,%eax
  103a60:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103a66:	5d                   	pop    %ebp
  103a67:	c3                   	ret    

00103a68 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103a68:	55                   	push   %ebp
  103a69:	89 e5                	mov    %esp,%ebp
  103a6b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  103a71:	89 04 24             	mov    %eax,(%esp)
  103a74:	e8 d5 ff ff ff       	call   103a4e <page2ppn>
  103a79:	c1 e0 0c             	shl    $0xc,%eax
}
  103a7c:	c9                   	leave  
  103a7d:	c3                   	ret    

00103a7e <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103a7e:	55                   	push   %ebp
  103a7f:	89 e5                	mov    %esp,%ebp
  103a81:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103a84:	8b 45 08             	mov    0x8(%ebp),%eax
  103a87:	c1 e8 0c             	shr    $0xc,%eax
  103a8a:	89 c2                	mov    %eax,%edx
  103a8c:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103a91:	39 c2                	cmp    %eax,%edx
  103a93:	72 1c                	jb     103ab1 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103a95:	c7 44 24 08 54 6a 10 	movl   $0x106a54,0x8(%esp)
  103a9c:	00 
  103a9d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103aa4:	00 
  103aa5:	c7 04 24 73 6a 10 00 	movl   $0x106a73,(%esp)
  103aac:	e8 21 d2 ff ff       	call   100cd2 <__panic>
    }
    return &pages[PPN(pa)];
  103ab1:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  103aba:	c1 e8 0c             	shr    $0xc,%eax
  103abd:	89 c2                	mov    %eax,%edx
  103abf:	89 d0                	mov    %edx,%eax
  103ac1:	c1 e0 02             	shl    $0x2,%eax
  103ac4:	01 d0                	add    %edx,%eax
  103ac6:	c1 e0 02             	shl    $0x2,%eax
  103ac9:	01 c8                	add    %ecx,%eax
}
  103acb:	c9                   	leave  
  103acc:	c3                   	ret    

00103acd <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103acd:	55                   	push   %ebp
  103ace:	89 e5                	mov    %esp,%ebp
  103ad0:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  103ad6:	89 04 24             	mov    %eax,(%esp)
  103ad9:	e8 8a ff ff ff       	call   103a68 <page2pa>
  103ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ae4:	c1 e8 0c             	shr    $0xc,%eax
  103ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103aea:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103aef:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103af2:	72 23                	jb     103b17 <page2kva+0x4a>
  103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103af7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103afb:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  103b02:	00 
  103b03:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103b0a:	00 
  103b0b:	c7 04 24 73 6a 10 00 	movl   $0x106a73,(%esp)
  103b12:	e8 bb d1 ff ff       	call   100cd2 <__panic>
  103b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b1a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103b1f:	c9                   	leave  
  103b20:	c3                   	ret    

00103b21 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103b21:	55                   	push   %ebp
  103b22:	89 e5                	mov    %esp,%ebp
  103b24:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103b27:	8b 45 08             	mov    0x8(%ebp),%eax
  103b2a:	83 e0 01             	and    $0x1,%eax
  103b2d:	85 c0                	test   %eax,%eax
  103b2f:	75 1c                	jne    103b4d <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103b31:	c7 44 24 08 a8 6a 10 	movl   $0x106aa8,0x8(%esp)
  103b38:	00 
  103b39:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103b40:	00 
  103b41:	c7 04 24 73 6a 10 00 	movl   $0x106a73,(%esp)
  103b48:	e8 85 d1 ff ff       	call   100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  103b50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b55:	89 04 24             	mov    %eax,(%esp)
  103b58:	e8 21 ff ff ff       	call   103a7e <pa2page>
}
  103b5d:	c9                   	leave  
  103b5e:	c3                   	ret    

00103b5f <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103b5f:	55                   	push   %ebp
  103b60:	89 e5                	mov    %esp,%ebp
  103b62:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103b65:	8b 45 08             	mov    0x8(%ebp),%eax
  103b68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b6d:	89 04 24             	mov    %eax,(%esp)
  103b70:	e8 09 ff ff ff       	call   103a7e <pa2page>
}
  103b75:	c9                   	leave  
  103b76:	c3                   	ret    

00103b77 <page_ref>:

static inline int
page_ref(struct Page *page) {
  103b77:	55                   	push   %ebp
  103b78:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  103b7d:	8b 00                	mov    (%eax),%eax
}
  103b7f:	5d                   	pop    %ebp
  103b80:	c3                   	ret    

00103b81 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103b81:	55                   	push   %ebp
  103b82:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103b84:	8b 45 08             	mov    0x8(%ebp),%eax
  103b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  103b8a:	89 10                	mov    %edx,(%eax)
}
  103b8c:	5d                   	pop    %ebp
  103b8d:	c3                   	ret    

00103b8e <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103b8e:	55                   	push   %ebp
  103b8f:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103b91:	8b 45 08             	mov    0x8(%ebp),%eax
  103b94:	8b 00                	mov    (%eax),%eax
  103b96:	8d 50 01             	lea    0x1(%eax),%edx
  103b99:	8b 45 08             	mov    0x8(%ebp),%eax
  103b9c:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba1:	8b 00                	mov    (%eax),%eax
}
  103ba3:	5d                   	pop    %ebp
  103ba4:	c3                   	ret    

00103ba5 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103ba5:	55                   	push   %ebp
  103ba6:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  103bab:	8b 00                	mov    (%eax),%eax
  103bad:	8d 50 ff             	lea    -0x1(%eax),%edx
  103bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  103bb3:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  103bb8:	8b 00                	mov    (%eax),%eax
}
  103bba:	5d                   	pop    %ebp
  103bbb:	c3                   	ret    

00103bbc <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103bbc:	55                   	push   %ebp
  103bbd:	89 e5                	mov    %esp,%ebp
  103bbf:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103bc2:	9c                   	pushf  
  103bc3:	58                   	pop    %eax
  103bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103bca:	25 00 02 00 00       	and    $0x200,%eax
  103bcf:	85 c0                	test   %eax,%eax
  103bd1:	74 0c                	je     103bdf <__intr_save+0x23>
        intr_disable();
  103bd3:	e8 ee da ff ff       	call   1016c6 <intr_disable>
        return 1;
  103bd8:	b8 01 00 00 00       	mov    $0x1,%eax
  103bdd:	eb 05                	jmp    103be4 <__intr_save+0x28>
    }
    return 0;
  103bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103be4:	c9                   	leave  
  103be5:	c3                   	ret    

00103be6 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103be6:	55                   	push   %ebp
  103be7:	89 e5                	mov    %esp,%ebp
  103be9:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103bec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103bf0:	74 05                	je     103bf7 <__intr_restore+0x11>
        intr_enable();
  103bf2:	e8 c9 da ff ff       	call   1016c0 <intr_enable>
    }
}
  103bf7:	c9                   	leave  
  103bf8:	c3                   	ret    

00103bf9 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103bf9:	55                   	push   %ebp
  103bfa:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  103bff:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103c02:	b8 23 00 00 00       	mov    $0x23,%eax
  103c07:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103c09:	b8 23 00 00 00       	mov    $0x23,%eax
  103c0e:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103c10:	b8 10 00 00 00       	mov    $0x10,%eax
  103c15:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103c17:	b8 10 00 00 00       	mov    $0x10,%eax
  103c1c:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103c1e:	b8 10 00 00 00       	mov    $0x10,%eax
  103c23:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103c25:	ea 2c 3c 10 00 08 00 	ljmp   $0x8,$0x103c2c
}
  103c2c:	5d                   	pop    %ebp
  103c2d:	c3                   	ret    

00103c2e <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103c2e:	55                   	push   %ebp
  103c2f:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103c31:	8b 45 08             	mov    0x8(%ebp),%eax
  103c34:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103c39:	5d                   	pop    %ebp
  103c3a:	c3                   	ret    

00103c3b <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103c3b:	55                   	push   %ebp
  103c3c:	89 e5                	mov    %esp,%ebp
  103c3e:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103c41:	b8 00 70 11 00       	mov    $0x117000,%eax
  103c46:	89 04 24             	mov    %eax,(%esp)
  103c49:	e8 e0 ff ff ff       	call   103c2e <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103c4e:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103c55:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103c57:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103c5e:	68 00 
  103c60:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c65:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103c6b:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c70:	c1 e8 10             	shr    $0x10,%eax
  103c73:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103c78:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c7f:	83 e0 f0             	and    $0xfffffff0,%eax
  103c82:	83 c8 09             	or     $0x9,%eax
  103c85:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c8a:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c91:	83 e0 ef             	and    $0xffffffef,%eax
  103c94:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c99:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103ca0:	83 e0 9f             	and    $0xffffff9f,%eax
  103ca3:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103ca8:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103caf:	83 c8 80             	or     $0xffffff80,%eax
  103cb2:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103cb7:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cbe:	83 e0 f0             	and    $0xfffffff0,%eax
  103cc1:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cc6:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ccd:	83 e0 ef             	and    $0xffffffef,%eax
  103cd0:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cd5:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cdc:	83 e0 df             	and    $0xffffffdf,%eax
  103cdf:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ce4:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ceb:	83 c8 40             	or     $0x40,%eax
  103cee:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cf3:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cfa:	83 e0 7f             	and    $0x7f,%eax
  103cfd:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d02:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103d07:	c1 e8 18             	shr    $0x18,%eax
  103d0a:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103d0f:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103d16:	e8 de fe ff ff       	call   103bf9 <lgdt>
  103d1b:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103d21:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103d25:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103d28:	c9                   	leave  
  103d29:	c3                   	ret    

00103d2a <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103d2a:	55                   	push   %ebp
  103d2b:	89 e5                	mov    %esp,%ebp
  103d2d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103d30:	c7 05 1c af 11 00 38 	movl   $0x106a38,0x11af1c
  103d37:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103d3a:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d3f:	8b 00                	mov    (%eax),%eax
  103d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d45:	c7 04 24 d4 6a 10 00 	movl   $0x106ad4,(%esp)
  103d4c:	e8 f7 c5 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  103d51:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d56:	8b 40 04             	mov    0x4(%eax),%eax
  103d59:	ff d0                	call   *%eax
}
  103d5b:	c9                   	leave  
  103d5c:	c3                   	ret    

00103d5d <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103d5d:	55                   	push   %ebp
  103d5e:	89 e5                	mov    %esp,%ebp
  103d60:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103d63:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d68:	8b 40 08             	mov    0x8(%eax),%eax
  103d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d72:	8b 55 08             	mov    0x8(%ebp),%edx
  103d75:	89 14 24             	mov    %edx,(%esp)
  103d78:	ff d0                	call   *%eax
}
  103d7a:	c9                   	leave  
  103d7b:	c3                   	ret    

00103d7c <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103d7c:	55                   	push   %ebp
  103d7d:	89 e5                	mov    %esp,%ebp
  103d7f:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103d82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103d89:	e8 2e fe ff ff       	call   103bbc <__intr_save>
  103d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103d91:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d96:	8b 40 0c             	mov    0xc(%eax),%eax
  103d99:	8b 55 08             	mov    0x8(%ebp),%edx
  103d9c:	89 14 24             	mov    %edx,(%esp)
  103d9f:	ff d0                	call   *%eax
  103da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103da4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103da7:	89 04 24             	mov    %eax,(%esp)
  103daa:	e8 37 fe ff ff       	call   103be6 <__intr_restore>
    return page;
  103daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103db2:	c9                   	leave  
  103db3:	c3                   	ret    

00103db4 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103db4:	55                   	push   %ebp
  103db5:	89 e5                	mov    %esp,%ebp
  103db7:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103dba:	e8 fd fd ff ff       	call   103bbc <__intr_save>
  103dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103dc2:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103dc7:	8b 40 10             	mov    0x10(%eax),%eax
  103dca:	8b 55 0c             	mov    0xc(%ebp),%edx
  103dcd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  103dd4:	89 14 24             	mov    %edx,(%esp)
  103dd7:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ddc:	89 04 24             	mov    %eax,(%esp)
  103ddf:	e8 02 fe ff ff       	call   103be6 <__intr_restore>
}
  103de4:	c9                   	leave  
  103de5:	c3                   	ret    

00103de6 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103de6:	55                   	push   %ebp
  103de7:	89 e5                	mov    %esp,%ebp
  103de9:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103dec:	e8 cb fd ff ff       	call   103bbc <__intr_save>
  103df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103df4:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103df9:	8b 40 14             	mov    0x14(%eax),%eax
  103dfc:	ff d0                	call   *%eax
  103dfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e04:	89 04 24             	mov    %eax,(%esp)
  103e07:	e8 da fd ff ff       	call   103be6 <__intr_restore>
    return ret;
  103e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103e0f:	c9                   	leave  
  103e10:	c3                   	ret    

00103e11 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103e11:	55                   	push   %ebp
  103e12:	89 e5                	mov    %esp,%ebp
  103e14:	57                   	push   %edi
  103e15:	56                   	push   %esi
  103e16:	53                   	push   %ebx
  103e17:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103e1d:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103e24:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103e2b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103e32:	c7 04 24 eb 6a 10 00 	movl   $0x106aeb,(%esp)
  103e39:	e8 0a c5 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103e3e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103e45:	e9 15 01 00 00       	jmp    103f5f <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103e4a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e50:	89 d0                	mov    %edx,%eax
  103e52:	c1 e0 02             	shl    $0x2,%eax
  103e55:	01 d0                	add    %edx,%eax
  103e57:	c1 e0 02             	shl    $0x2,%eax
  103e5a:	01 c8                	add    %ecx,%eax
  103e5c:	8b 50 08             	mov    0x8(%eax),%edx
  103e5f:	8b 40 04             	mov    0x4(%eax),%eax
  103e62:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103e65:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103e68:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e6e:	89 d0                	mov    %edx,%eax
  103e70:	c1 e0 02             	shl    $0x2,%eax
  103e73:	01 d0                	add    %edx,%eax
  103e75:	c1 e0 02             	shl    $0x2,%eax
  103e78:	01 c8                	add    %ecx,%eax
  103e7a:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e7d:	8b 58 10             	mov    0x10(%eax),%ebx
  103e80:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103e83:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103e86:	01 c8                	add    %ecx,%eax
  103e88:	11 da                	adc    %ebx,%edx
  103e8a:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103e8d:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103e90:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e93:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e96:	89 d0                	mov    %edx,%eax
  103e98:	c1 e0 02             	shl    $0x2,%eax
  103e9b:	01 d0                	add    %edx,%eax
  103e9d:	c1 e0 02             	shl    $0x2,%eax
  103ea0:	01 c8                	add    %ecx,%eax
  103ea2:	83 c0 14             	add    $0x14,%eax
  103ea5:	8b 00                	mov    (%eax),%eax
  103ea7:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103ead:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103eb0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103eb3:	83 c0 ff             	add    $0xffffffff,%eax
  103eb6:	83 d2 ff             	adc    $0xffffffff,%edx
  103eb9:	89 c6                	mov    %eax,%esi
  103ebb:	89 d7                	mov    %edx,%edi
  103ebd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ec0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ec3:	89 d0                	mov    %edx,%eax
  103ec5:	c1 e0 02             	shl    $0x2,%eax
  103ec8:	01 d0                	add    %edx,%eax
  103eca:	c1 e0 02             	shl    $0x2,%eax
  103ecd:	01 c8                	add    %ecx,%eax
  103ecf:	8b 48 0c             	mov    0xc(%eax),%ecx
  103ed2:	8b 58 10             	mov    0x10(%eax),%ebx
  103ed5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103edb:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103edf:	89 74 24 14          	mov    %esi,0x14(%esp)
  103ee3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103ee7:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103eea:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103eed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103ef1:	89 54 24 10          	mov    %edx,0x10(%esp)
  103ef5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103efd:	c7 04 24 f8 6a 10 00 	movl   $0x106af8,(%esp)
  103f04:	e8 3f c4 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103f09:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f0f:	89 d0                	mov    %edx,%eax
  103f11:	c1 e0 02             	shl    $0x2,%eax
  103f14:	01 d0                	add    %edx,%eax
  103f16:	c1 e0 02             	shl    $0x2,%eax
  103f19:	01 c8                	add    %ecx,%eax
  103f1b:	83 c0 14             	add    $0x14,%eax
  103f1e:	8b 00                	mov    (%eax),%eax
  103f20:	83 f8 01             	cmp    $0x1,%eax
  103f23:	75 36                	jne    103f5b <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103f25:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f2b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f2e:	77 2b                	ja     103f5b <page_init+0x14a>
  103f30:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f33:	72 05                	jb     103f3a <page_init+0x129>
  103f35:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103f38:	73 21                	jae    103f5b <page_init+0x14a>
  103f3a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f3e:	77 1b                	ja     103f5b <page_init+0x14a>
  103f40:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f44:	72 09                	jb     103f4f <page_init+0x13e>
  103f46:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103f4d:	77 0c                	ja     103f5b <page_init+0x14a>
                maxpa = end;
  103f4f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f52:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f55:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103f58:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103f5b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103f5f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103f62:	8b 00                	mov    (%eax),%eax
  103f64:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103f67:	0f 8f dd fe ff ff    	jg     103e4a <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103f6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f71:	72 1d                	jb     103f90 <page_init+0x17f>
  103f73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f77:	77 09                	ja     103f82 <page_init+0x171>
  103f79:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103f80:	76 0e                	jbe    103f90 <page_init+0x17f>
        maxpa = KMEMSIZE;
  103f82:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103f89:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f96:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103f9a:	c1 ea 0c             	shr    $0xc,%edx
  103f9d:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103fa2:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103fa9:	b8 28 af 11 00       	mov    $0x11af28,%eax
  103fae:	8d 50 ff             	lea    -0x1(%eax),%edx
  103fb1:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103fb4:	01 d0                	add    %edx,%eax
  103fb6:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103fb9:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103fbc:	ba 00 00 00 00       	mov    $0x0,%edx
  103fc1:	f7 75 ac             	divl   -0x54(%ebp)
  103fc4:	89 d0                	mov    %edx,%eax
  103fc6:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103fc9:	29 c2                	sub    %eax,%edx
  103fcb:	89 d0                	mov    %edx,%eax
  103fcd:	a3 24 af 11 00       	mov    %eax,0x11af24

    for (i = 0; i < npage; i ++) {
  103fd2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fd9:	eb 2f                	jmp    10400a <page_init+0x1f9>
        SetPageReserved(pages + i);
  103fdb:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103fe1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fe4:	89 d0                	mov    %edx,%eax
  103fe6:	c1 e0 02             	shl    $0x2,%eax
  103fe9:	01 d0                	add    %edx,%eax
  103feb:	c1 e0 02             	shl    $0x2,%eax
  103fee:	01 c8                	add    %ecx,%eax
  103ff0:	83 c0 04             	add    $0x4,%eax
  103ff3:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  103ffa:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103ffd:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104000:	8b 55 90             	mov    -0x70(%ebp),%edx
  104003:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  104006:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  10400a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10400d:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104012:	39 c2                	cmp    %eax,%edx
  104014:	72 c5                	jb     103fdb <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104016:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10401c:	89 d0                	mov    %edx,%eax
  10401e:	c1 e0 02             	shl    $0x2,%eax
  104021:	01 d0                	add    %edx,%eax
  104023:	c1 e0 02             	shl    $0x2,%eax
  104026:	89 c2                	mov    %eax,%edx
  104028:	a1 24 af 11 00       	mov    0x11af24,%eax
  10402d:	01 d0                	add    %edx,%eax
  10402f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  104032:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  104039:	77 23                	ja     10405e <page_init+0x24d>
  10403b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10403e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104042:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  104049:	00 
  10404a:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  104051:	00 
  104052:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104059:	e8 74 cc ff ff       	call   100cd2 <__panic>
  10405e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104061:	05 00 00 00 40       	add    $0x40000000,%eax
  104066:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104069:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104070:	e9 74 01 00 00       	jmp    1041e9 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104075:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104078:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10407b:	89 d0                	mov    %edx,%eax
  10407d:	c1 e0 02             	shl    $0x2,%eax
  104080:	01 d0                	add    %edx,%eax
  104082:	c1 e0 02             	shl    $0x2,%eax
  104085:	01 c8                	add    %ecx,%eax
  104087:	8b 50 08             	mov    0x8(%eax),%edx
  10408a:	8b 40 04             	mov    0x4(%eax),%eax
  10408d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104090:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104093:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104096:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104099:	89 d0                	mov    %edx,%eax
  10409b:	c1 e0 02             	shl    $0x2,%eax
  10409e:	01 d0                	add    %edx,%eax
  1040a0:	c1 e0 02             	shl    $0x2,%eax
  1040a3:	01 c8                	add    %ecx,%eax
  1040a5:	8b 48 0c             	mov    0xc(%eax),%ecx
  1040a8:	8b 58 10             	mov    0x10(%eax),%ebx
  1040ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1040ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1040b1:	01 c8                	add    %ecx,%eax
  1040b3:	11 da                	adc    %ebx,%edx
  1040b5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1040b8:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1040bb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040be:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040c1:	89 d0                	mov    %edx,%eax
  1040c3:	c1 e0 02             	shl    $0x2,%eax
  1040c6:	01 d0                	add    %edx,%eax
  1040c8:	c1 e0 02             	shl    $0x2,%eax
  1040cb:	01 c8                	add    %ecx,%eax
  1040cd:	83 c0 14             	add    $0x14,%eax
  1040d0:	8b 00                	mov    (%eax),%eax
  1040d2:	83 f8 01             	cmp    $0x1,%eax
  1040d5:	0f 85 0a 01 00 00    	jne    1041e5 <page_init+0x3d4>
            if (begin < freemem) {
  1040db:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040de:	ba 00 00 00 00       	mov    $0x0,%edx
  1040e3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040e6:	72 17                	jb     1040ff <page_init+0x2ee>
  1040e8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1040eb:	77 05                	ja     1040f2 <page_init+0x2e1>
  1040ed:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1040f0:	76 0d                	jbe    1040ff <page_init+0x2ee>
                begin = freemem;
  1040f2:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1040ff:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104103:	72 1d                	jb     104122 <page_init+0x311>
  104105:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104109:	77 09                	ja     104114 <page_init+0x303>
  10410b:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  104112:	76 0e                	jbe    104122 <page_init+0x311>
                end = KMEMSIZE;
  104114:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  10411b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104122:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104125:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104128:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10412b:	0f 87 b4 00 00 00    	ja     1041e5 <page_init+0x3d4>
  104131:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104134:	72 09                	jb     10413f <page_init+0x32e>
  104136:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104139:	0f 83 a6 00 00 00    	jae    1041e5 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  10413f:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104146:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104149:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10414c:	01 d0                	add    %edx,%eax
  10414e:	83 e8 01             	sub    $0x1,%eax
  104151:	89 45 98             	mov    %eax,-0x68(%ebp)
  104154:	8b 45 98             	mov    -0x68(%ebp),%eax
  104157:	ba 00 00 00 00       	mov    $0x0,%edx
  10415c:	f7 75 9c             	divl   -0x64(%ebp)
  10415f:	89 d0                	mov    %edx,%eax
  104161:	8b 55 98             	mov    -0x68(%ebp),%edx
  104164:	29 c2                	sub    %eax,%edx
  104166:	89 d0                	mov    %edx,%eax
  104168:	ba 00 00 00 00       	mov    $0x0,%edx
  10416d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104170:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104173:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104176:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104179:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10417c:	ba 00 00 00 00       	mov    $0x0,%edx
  104181:	89 c7                	mov    %eax,%edi
  104183:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104189:	89 7d 80             	mov    %edi,-0x80(%ebp)
  10418c:	89 d0                	mov    %edx,%eax
  10418e:	83 e0 00             	and    $0x0,%eax
  104191:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104194:	8b 45 80             	mov    -0x80(%ebp),%eax
  104197:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10419a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10419d:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  1041a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041a6:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041a9:	77 3a                	ja     1041e5 <page_init+0x3d4>
  1041ab:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041ae:	72 05                	jb     1041b5 <page_init+0x3a4>
  1041b0:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1041b3:	73 30                	jae    1041e5 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1041b5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  1041b8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  1041bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1041be:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1041c1:	29 c8                	sub    %ecx,%eax
  1041c3:	19 da                	sbb    %ebx,%edx
  1041c5:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1041c9:	c1 ea 0c             	shr    $0xc,%edx
  1041cc:	89 c3                	mov    %eax,%ebx
  1041ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041d1:	89 04 24             	mov    %eax,(%esp)
  1041d4:	e8 a5 f8 ff ff       	call   103a7e <pa2page>
  1041d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041dd:	89 04 24             	mov    %eax,(%esp)
  1041e0:	e8 78 fb ff ff       	call   103d5d <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  1041e5:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1041e9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1041ec:	8b 00                	mov    (%eax),%eax
  1041ee:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1041f1:	0f 8f 7e fe ff ff    	jg     104075 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  1041f7:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1041fd:	5b                   	pop    %ebx
  1041fe:	5e                   	pop    %esi
  1041ff:	5f                   	pop    %edi
  104200:	5d                   	pop    %ebp
  104201:	c3                   	ret    

00104202 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104202:	55                   	push   %ebp
  104203:	89 e5                	mov    %esp,%ebp
  104205:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104208:	8b 45 14             	mov    0x14(%ebp),%eax
  10420b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10420e:	31 d0                	xor    %edx,%eax
  104210:	25 ff 0f 00 00       	and    $0xfff,%eax
  104215:	85 c0                	test   %eax,%eax
  104217:	74 24                	je     10423d <boot_map_segment+0x3b>
  104219:	c7 44 24 0c 5a 6b 10 	movl   $0x106b5a,0xc(%esp)
  104220:	00 
  104221:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104228:	00 
  104229:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104230:	00 
  104231:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104238:	e8 95 ca ff ff       	call   100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10423d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  104244:	8b 45 0c             	mov    0xc(%ebp),%eax
  104247:	25 ff 0f 00 00       	and    $0xfff,%eax
  10424c:	89 c2                	mov    %eax,%edx
  10424e:	8b 45 10             	mov    0x10(%ebp),%eax
  104251:	01 c2                	add    %eax,%edx
  104253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104256:	01 d0                	add    %edx,%eax
  104258:	83 e8 01             	sub    $0x1,%eax
  10425b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10425e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104261:	ba 00 00 00 00       	mov    $0x0,%edx
  104266:	f7 75 f0             	divl   -0x10(%ebp)
  104269:	89 d0                	mov    %edx,%eax
  10426b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10426e:	29 c2                	sub    %eax,%edx
  104270:	89 d0                	mov    %edx,%eax
  104272:	c1 e8 0c             	shr    $0xc,%eax
  104275:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104278:	8b 45 0c             	mov    0xc(%ebp),%eax
  10427b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10427e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104281:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104286:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104289:	8b 45 14             	mov    0x14(%ebp),%eax
  10428c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10428f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104292:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104297:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10429a:	eb 6b                	jmp    104307 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10429c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1042a3:	00 
  1042a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1042ae:	89 04 24             	mov    %eax,(%esp)
  1042b1:	e8 82 01 00 00       	call   104438 <get_pte>
  1042b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1042b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1042bd:	75 24                	jne    1042e3 <boot_map_segment+0xe1>
  1042bf:	c7 44 24 0c 86 6b 10 	movl   $0x106b86,0xc(%esp)
  1042c6:	00 
  1042c7:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1042ce:	00 
  1042cf:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1042d6:	00 
  1042d7:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1042de:	e8 ef c9 ff ff       	call   100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
  1042e3:	8b 45 18             	mov    0x18(%ebp),%eax
  1042e6:	8b 55 14             	mov    0x14(%ebp),%edx
  1042e9:	09 d0                	or     %edx,%eax
  1042eb:	83 c8 01             	or     $0x1,%eax
  1042ee:	89 c2                	mov    %eax,%edx
  1042f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1042f3:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1042f5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1042f9:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  104300:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10430b:	75 8f                	jne    10429c <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  10430d:	c9                   	leave  
  10430e:	c3                   	ret    

0010430f <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10430f:	55                   	push   %ebp
  104310:	89 e5                	mov    %esp,%ebp
  104312:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  104315:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10431c:	e8 5b fa ff ff       	call   103d7c <alloc_pages>
  104321:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104324:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104328:	75 1c                	jne    104346 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10432a:	c7 44 24 08 93 6b 10 	movl   $0x106b93,0x8(%esp)
  104331:	00 
  104332:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104339:	00 
  10433a:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104341:	e8 8c c9 ff ff       	call   100cd2 <__panic>
    }
    return page2kva(p);
  104346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104349:	89 04 24             	mov    %eax,(%esp)
  10434c:	e8 7c f7 ff ff       	call   103acd <page2kva>
}
  104351:	c9                   	leave  
  104352:	c3                   	ret    

00104353 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104353:	55                   	push   %ebp
  104354:	89 e5                	mov    %esp,%ebp
  104356:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104359:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10435e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104361:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104368:	77 23                	ja     10438d <pmm_init+0x3a>
  10436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10436d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104371:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  104378:	00 
  104379:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104380:	00 
  104381:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104388:	e8 45 c9 ff ff       	call   100cd2 <__panic>
  10438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104390:	05 00 00 00 40       	add    $0x40000000,%eax
  104395:	a3 20 af 11 00       	mov    %eax,0x11af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10439a:	e8 8b f9 ff ff       	call   103d2a <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10439f:	e8 6d fa ff ff       	call   103e11 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1043a4:	e8 db 03 00 00       	call   104784 <check_alloc_page>

    check_pgdir();
  1043a9:	e8 f4 03 00 00       	call   1047a2 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1043ae:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043b3:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1043b9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1043c1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1043c8:	77 23                	ja     1043ed <pmm_init+0x9a>
  1043ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043d1:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  1043d8:	00 
  1043d9:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1043e0:	00 
  1043e1:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1043e8:	e8 e5 c8 ff ff       	call   100cd2 <__panic>
  1043ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043f0:	05 00 00 00 40       	add    $0x40000000,%eax
  1043f5:	83 c8 03             	or     $0x3,%eax
  1043f8:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1043fa:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043ff:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  104406:	00 
  104407:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10440e:	00 
  10440f:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104416:	38 
  104417:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10441e:	c0 
  10441f:	89 04 24             	mov    %eax,(%esp)
  104422:	e8 db fd ff ff       	call   104202 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  104427:	e8 0f f8 ff ff       	call   103c3b <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10442c:	e8 0c 0a 00 00       	call   104e3d <check_boot_pgdir>

    print_pgdir();
  104431:	e8 94 0e 00 00       	call   1052ca <print_pgdir>

}
  104436:	c9                   	leave  
  104437:	c3                   	ret    

00104438 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  104438:	55                   	push   %ebp
  104439:	89 e5                	mov    %esp,%ebp
  10443b:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
pde_t *pdep = &pgdir[PDX(la)]; // 找到 PDE 这里的 pgdir 可以看做是页目录表的基址
  10443e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104441:	c1 e8 16             	shr    $0x16,%eax
  104444:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10444b:	8b 45 08             	mov    0x8(%ebp),%eax
  10444e:	01 d0                	add    %edx,%eax
  104450:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // 看看 PDE 指向的页表是否存在
  104453:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104456:	8b 00                	mov    (%eax),%eax
  104458:	83 e0 01             	and    $0x1,%eax
  10445b:	85 c0                	test   %eax,%eax
  10445d:	0f 85 af 00 00 00    	jne    104512 <get_pte+0xda>
        struct Page* page = alloc_page(); // 不存在就申请一页物理页
  104463:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10446a:	e8 0d f9 ff ff       	call   103d7c <alloc_pages>
  10446f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        
        if (!create || page == NULL) { //不存在且不需要创建，返回NULL
  104472:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104476:	74 06                	je     10447e <get_pte+0x46>
  104478:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10447c:	75 0a                	jne    104488 <get_pte+0x50>
            return NULL;
  10447e:	b8 00 00 00 00       	mov    $0x0,%eax
  104483:	e9 e6 00 00 00       	jmp    10456e <get_pte+0x136>
        }
        set_page_ref(page, 1); //设置此页被引用一次
  104488:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10448f:	00 
  104490:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104493:	89 04 24             	mov    %eax,(%esp)
  104496:	e8 e6 f6 ff ff       	call   103b81 <set_page_ref>
        uintptr_t pa = page2pa(page);//得到 page 管理的那一页的物理地址
  10449b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10449e:	89 04 24             	mov    %eax,(%esp)
  1044a1:	e8 c2 f5 ff ff       	call   103a68 <page2pa>
  1044a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); 
  1044a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1044af:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044b2:	c1 e8 0c             	shr    $0xc,%eax
  1044b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1044b8:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1044bd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1044c0:	72 23                	jb     1044e5 <get_pte+0xad>
  1044c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1044c9:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  1044d0:	00 
  1044d1:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
  1044d8:	00 
  1044d9:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1044e0:	e8 ed c7 ff ff       	call   100cd2 <__panic>
  1044e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044e8:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1044ed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1044f4:	00 
  1044f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1044fc:	00 
  1044fd:	89 04 24             	mov    %eax,(%esp)
  104500:	e8 e3 18 00 00       	call   105de8 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P; // 设置 PDE 权限
  104505:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104508:	83 c8 07             	or     $0x7,%eax
  10450b:	89 c2                	mov    %eax,%edx
  10450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104510:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  104512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104515:	8b 00                	mov    (%eax),%eax
  104517:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10451c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10451f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104522:	c1 e8 0c             	shr    $0xc,%eax
  104525:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104528:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10452d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104530:	72 23                	jb     104555 <get_pte+0x11d>
  104532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104535:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104539:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  104540:	00 
  104541:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
  104548:	00 
  104549:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104550:	e8 7d c7 ff ff       	call   100cd2 <__panic>
  104555:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104558:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10455d:	8b 55 0c             	mov    0xc(%ebp),%edx
  104560:	c1 ea 0c             	shr    $0xc,%edx
  104563:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  104569:	c1 e2 02             	shl    $0x2,%edx
  10456c:	01 d0                	add    %edx,%eax
}
  10456e:	c9                   	leave  
  10456f:	c3                   	ret    

00104570 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  104570:	55                   	push   %ebp
  104571:	89 e5                	mov    %esp,%ebp
  104573:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104576:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10457d:	00 
  10457e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104581:	89 44 24 04          	mov    %eax,0x4(%esp)
  104585:	8b 45 08             	mov    0x8(%ebp),%eax
  104588:	89 04 24             	mov    %eax,(%esp)
  10458b:	e8 a8 fe ff ff       	call   104438 <get_pte>
  104590:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  104593:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104597:	74 08                	je     1045a1 <get_page+0x31>
        *ptep_store = ptep;
  104599:	8b 45 10             	mov    0x10(%ebp),%eax
  10459c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10459f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1045a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1045a5:	74 1b                	je     1045c2 <get_page+0x52>
  1045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045aa:	8b 00                	mov    (%eax),%eax
  1045ac:	83 e0 01             	and    $0x1,%eax
  1045af:	85 c0                	test   %eax,%eax
  1045b1:	74 0f                	je     1045c2 <get_page+0x52>
        return pte2page(*ptep);
  1045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b6:	8b 00                	mov    (%eax),%eax
  1045b8:	89 04 24             	mov    %eax,(%esp)
  1045bb:	e8 61 f5 ff ff       	call   103b21 <pte2page>
  1045c0:	eb 05                	jmp    1045c7 <get_page+0x57>
    }
    return NULL;
  1045c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1045c7:	c9                   	leave  
  1045c8:	c3                   	ret    

001045c9 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1045c9:	55                   	push   %ebp
  1045ca:	89 e5                	mov    %esp,%ebp
  1045cc:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
if ((*ptep & PTE_P)) { //判断页表中该表项是否存在
  1045cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1045d2:	8b 00                	mov    (%eax),%eax
  1045d4:	83 e0 01             	and    $0x1,%eax
  1045d7:	85 c0                	test   %eax,%eax
  1045d9:	74 4d                	je     104628 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);// 将页表项转换为页数据结构
  1045db:	8b 45 10             	mov    0x10(%ebp),%eax
  1045de:	8b 00                	mov    (%eax),%eax
  1045e0:	89 04 24             	mov    %eax,(%esp)
  1045e3:	e8 39 f5 ff ff       	call   103b21 <pte2page>
  1045e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { // 判断是否只被引用了一次，若引用计数减一后为0，则释放该物理页
  1045eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045ee:	89 04 24             	mov    %eax,(%esp)
  1045f1:	e8 af f5 ff ff       	call   103ba5 <page_ref_dec>
  1045f6:	85 c0                	test   %eax,%eax
  1045f8:	75 13                	jne    10460d <page_remove_pte+0x44>
            free_page(page);
  1045fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104601:	00 
  104602:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104605:	89 04 24             	mov    %eax,(%esp)
  104608:	e8 a7 f7 ff ff       	call   103db4 <free_pages>
        }
        *ptep = 0; // //如果被多次引用，则不能释放此页，只用释放二级页表的表项，清空 PTE
  10460d:	8b 45 10             	mov    0x10(%ebp),%eax
  104610:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la); // 刷新 tlb
  104616:	8b 45 0c             	mov    0xc(%ebp),%eax
  104619:	89 44 24 04          	mov    %eax,0x4(%esp)
  10461d:	8b 45 08             	mov    0x8(%ebp),%eax
  104620:	89 04 24             	mov    %eax,(%esp)
  104623:	e8 ff 00 00 00       	call   104727 <tlb_invalidate>
    }
}
  104628:	c9                   	leave  
  104629:	c3                   	ret    

0010462a <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10462a:	55                   	push   %ebp
  10462b:	89 e5                	mov    %esp,%ebp
  10462d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104630:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104637:	00 
  104638:	8b 45 0c             	mov    0xc(%ebp),%eax
  10463b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10463f:	8b 45 08             	mov    0x8(%ebp),%eax
  104642:	89 04 24             	mov    %eax,(%esp)
  104645:	e8 ee fd ff ff       	call   104438 <get_pte>
  10464a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  10464d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104651:	74 19                	je     10466c <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  104653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104656:	89 44 24 08          	mov    %eax,0x8(%esp)
  10465a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10465d:	89 44 24 04          	mov    %eax,0x4(%esp)
  104661:	8b 45 08             	mov    0x8(%ebp),%eax
  104664:	89 04 24             	mov    %eax,(%esp)
  104667:	e8 5d ff ff ff       	call   1045c9 <page_remove_pte>
    }
}
  10466c:	c9                   	leave  
  10466d:	c3                   	ret    

0010466e <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  10466e:	55                   	push   %ebp
  10466f:	89 e5                	mov    %esp,%ebp
  104671:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  104674:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10467b:	00 
  10467c:	8b 45 10             	mov    0x10(%ebp),%eax
  10467f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104683:	8b 45 08             	mov    0x8(%ebp),%eax
  104686:	89 04 24             	mov    %eax,(%esp)
  104689:	e8 aa fd ff ff       	call   104438 <get_pte>
  10468e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104691:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104695:	75 0a                	jne    1046a1 <page_insert+0x33>
        return -E_NO_MEM;
  104697:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10469c:	e9 84 00 00 00       	jmp    104725 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1046a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046a4:	89 04 24             	mov    %eax,(%esp)
  1046a7:	e8 e2 f4 ff ff       	call   103b8e <page_ref_inc>
    if (*ptep & PTE_P) {
  1046ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046af:	8b 00                	mov    (%eax),%eax
  1046b1:	83 e0 01             	and    $0x1,%eax
  1046b4:	85 c0                	test   %eax,%eax
  1046b6:	74 3e                	je     1046f6 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1046b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046bb:	8b 00                	mov    (%eax),%eax
  1046bd:	89 04 24             	mov    %eax,(%esp)
  1046c0:	e8 5c f4 ff ff       	call   103b21 <pte2page>
  1046c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1046c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1046ce:	75 0d                	jne    1046dd <page_insert+0x6f>
            page_ref_dec(page);
  1046d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046d3:	89 04 24             	mov    %eax,(%esp)
  1046d6:	e8 ca f4 ff ff       	call   103ba5 <page_ref_dec>
  1046db:	eb 19                	jmp    1046f6 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046e4:	8b 45 10             	mov    0x10(%ebp),%eax
  1046e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1046ee:	89 04 24             	mov    %eax,(%esp)
  1046f1:	e8 d3 fe ff ff       	call   1045c9 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1046f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046f9:	89 04 24             	mov    %eax,(%esp)
  1046fc:	e8 67 f3 ff ff       	call   103a68 <page2pa>
  104701:	0b 45 14             	or     0x14(%ebp),%eax
  104704:	83 c8 01             	or     $0x1,%eax
  104707:	89 c2                	mov    %eax,%edx
  104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10470c:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10470e:	8b 45 10             	mov    0x10(%ebp),%eax
  104711:	89 44 24 04          	mov    %eax,0x4(%esp)
  104715:	8b 45 08             	mov    0x8(%ebp),%eax
  104718:	89 04 24             	mov    %eax,(%esp)
  10471b:	e8 07 00 00 00       	call   104727 <tlb_invalidate>
    return 0;
  104720:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104725:	c9                   	leave  
  104726:	c3                   	ret    

00104727 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104727:	55                   	push   %ebp
  104728:	89 e5                	mov    %esp,%ebp
  10472a:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  10472d:	0f 20 d8             	mov    %cr3,%eax
  104730:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  104733:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  104736:	89 c2                	mov    %eax,%edx
  104738:	8b 45 08             	mov    0x8(%ebp),%eax
  10473b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10473e:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104745:	77 23                	ja     10476a <tlb_invalidate+0x43>
  104747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10474a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10474e:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  104755:	00 
  104756:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  10475d:	00 
  10475e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104765:	e8 68 c5 ff ff       	call   100cd2 <__panic>
  10476a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10476d:	05 00 00 00 40       	add    $0x40000000,%eax
  104772:	39 c2                	cmp    %eax,%edx
  104774:	75 0c                	jne    104782 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  104776:	8b 45 0c             	mov    0xc(%ebp),%eax
  104779:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  10477c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10477f:	0f 01 38             	invlpg (%eax)
    }
}
  104782:	c9                   	leave  
  104783:	c3                   	ret    

00104784 <check_alloc_page>:

static void
check_alloc_page(void) {
  104784:	55                   	push   %ebp
  104785:	89 e5                	mov    %esp,%ebp
  104787:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10478a:	a1 1c af 11 00       	mov    0x11af1c,%eax
  10478f:	8b 40 18             	mov    0x18(%eax),%eax
  104792:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104794:	c7 04 24 ac 6b 10 00 	movl   $0x106bac,(%esp)
  10479b:	e8 a8 bb ff ff       	call   100348 <cprintf>
}
  1047a0:	c9                   	leave  
  1047a1:	c3                   	ret    

001047a2 <check_pgdir>:

static void
check_pgdir(void) {
  1047a2:	55                   	push   %ebp
  1047a3:	89 e5                	mov    %esp,%ebp
  1047a5:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1047a8:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1047ad:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1047b2:	76 24                	jbe    1047d8 <check_pgdir+0x36>
  1047b4:	c7 44 24 0c cb 6b 10 	movl   $0x106bcb,0xc(%esp)
  1047bb:	00 
  1047bc:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1047c3:	00 
  1047c4:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  1047cb:	00 
  1047cc:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1047d3:	e8 fa c4 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1047d8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047dd:	85 c0                	test   %eax,%eax
  1047df:	74 0e                	je     1047ef <check_pgdir+0x4d>
  1047e1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047e6:	25 ff 0f 00 00       	and    $0xfff,%eax
  1047eb:	85 c0                	test   %eax,%eax
  1047ed:	74 24                	je     104813 <check_pgdir+0x71>
  1047ef:	c7 44 24 0c e8 6b 10 	movl   $0x106be8,0xc(%esp)
  1047f6:	00 
  1047f7:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1047fe:	00 
  1047ff:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  104806:	00 
  104807:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10480e:	e8 bf c4 ff ff       	call   100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104813:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104818:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10481f:	00 
  104820:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104827:	00 
  104828:	89 04 24             	mov    %eax,(%esp)
  10482b:	e8 40 fd ff ff       	call   104570 <get_page>
  104830:	85 c0                	test   %eax,%eax
  104832:	74 24                	je     104858 <check_pgdir+0xb6>
  104834:	c7 44 24 0c 20 6c 10 	movl   $0x106c20,0xc(%esp)
  10483b:	00 
  10483c:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104843:	00 
  104844:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  10484b:	00 
  10484c:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104853:	e8 7a c4 ff ff       	call   100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104858:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10485f:	e8 18 f5 ff ff       	call   103d7c <alloc_pages>
  104864:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  104867:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10486c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104873:	00 
  104874:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10487b:	00 
  10487c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10487f:	89 54 24 04          	mov    %edx,0x4(%esp)
  104883:	89 04 24             	mov    %eax,(%esp)
  104886:	e8 e3 fd ff ff       	call   10466e <page_insert>
  10488b:	85 c0                	test   %eax,%eax
  10488d:	74 24                	je     1048b3 <check_pgdir+0x111>
  10488f:	c7 44 24 0c 48 6c 10 	movl   $0x106c48,0xc(%esp)
  104896:	00 
  104897:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  10489e:	00 
  10489f:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  1048a6:	00 
  1048a7:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1048ae:	e8 1f c4 ff ff       	call   100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1048b3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1048b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048bf:	00 
  1048c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048c7:	00 
  1048c8:	89 04 24             	mov    %eax,(%esp)
  1048cb:	e8 68 fb ff ff       	call   104438 <get_pte>
  1048d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048d7:	75 24                	jne    1048fd <check_pgdir+0x15b>
  1048d9:	c7 44 24 0c 74 6c 10 	movl   $0x106c74,0xc(%esp)
  1048e0:	00 
  1048e1:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1048e8:	00 
  1048e9:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  1048f0:	00 
  1048f1:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1048f8:	e8 d5 c3 ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  1048fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104900:	8b 00                	mov    (%eax),%eax
  104902:	89 04 24             	mov    %eax,(%esp)
  104905:	e8 17 f2 ff ff       	call   103b21 <pte2page>
  10490a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10490d:	74 24                	je     104933 <check_pgdir+0x191>
  10490f:	c7 44 24 0c a1 6c 10 	movl   $0x106ca1,0xc(%esp)
  104916:	00 
  104917:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  10491e:	00 
  10491f:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  104926:	00 
  104927:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10492e:	e8 9f c3 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 1);
  104933:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104936:	89 04 24             	mov    %eax,(%esp)
  104939:	e8 39 f2 ff ff       	call   103b77 <page_ref>
  10493e:	83 f8 01             	cmp    $0x1,%eax
  104941:	74 24                	je     104967 <check_pgdir+0x1c5>
  104943:	c7 44 24 0c b7 6c 10 	movl   $0x106cb7,0xc(%esp)
  10494a:	00 
  10494b:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104952:	00 
  104953:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  10495a:	00 
  10495b:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104962:	e8 6b c3 ff ff       	call   100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104967:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10496c:	8b 00                	mov    (%eax),%eax
  10496e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104973:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104976:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104979:	c1 e8 0c             	shr    $0xc,%eax
  10497c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10497f:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104984:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104987:	72 23                	jb     1049ac <check_pgdir+0x20a>
  104989:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10498c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104990:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  104997:	00 
  104998:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  10499f:	00 
  1049a0:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1049a7:	e8 26 c3 ff ff       	call   100cd2 <__panic>
  1049ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049af:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1049b4:	83 c0 04             	add    $0x4,%eax
  1049b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1049ba:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049c6:	00 
  1049c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1049ce:	00 
  1049cf:	89 04 24             	mov    %eax,(%esp)
  1049d2:	e8 61 fa ff ff       	call   104438 <get_pte>
  1049d7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1049da:	74 24                	je     104a00 <check_pgdir+0x25e>
  1049dc:	c7 44 24 0c cc 6c 10 	movl   $0x106ccc,0xc(%esp)
  1049e3:	00 
  1049e4:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1049eb:	00 
  1049ec:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  1049f3:	00 
  1049f4:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1049fb:	e8 d2 c2 ff ff       	call   100cd2 <__panic>

    p2 = alloc_page();
  104a00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a07:	e8 70 f3 ff ff       	call   103d7c <alloc_pages>
  104a0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104a0f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a14:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104a1b:	00 
  104a1c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104a23:	00 
  104a24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104a27:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a2b:	89 04 24             	mov    %eax,(%esp)
  104a2e:	e8 3b fc ff ff       	call   10466e <page_insert>
  104a33:	85 c0                	test   %eax,%eax
  104a35:	74 24                	je     104a5b <check_pgdir+0x2b9>
  104a37:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  104a3e:	00 
  104a3f:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104a46:	00 
  104a47:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  104a4e:	00 
  104a4f:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104a56:	e8 77 c2 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104a5b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a67:	00 
  104a68:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a6f:	00 
  104a70:	89 04 24             	mov    %eax,(%esp)
  104a73:	e8 c0 f9 ff ff       	call   104438 <get_pte>
  104a78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a7f:	75 24                	jne    104aa5 <check_pgdir+0x303>
  104a81:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  104a88:	00 
  104a89:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104a90:	00 
  104a91:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  104a98:	00 
  104a99:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104aa0:	e8 2d c2 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_U);
  104aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104aa8:	8b 00                	mov    (%eax),%eax
  104aaa:	83 e0 04             	and    $0x4,%eax
  104aad:	85 c0                	test   %eax,%eax
  104aaf:	75 24                	jne    104ad5 <check_pgdir+0x333>
  104ab1:	c7 44 24 0c 5c 6d 10 	movl   $0x106d5c,0xc(%esp)
  104ab8:	00 
  104ab9:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104ac0:	00 
  104ac1:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  104ac8:	00 
  104ac9:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104ad0:	e8 fd c1 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_W);
  104ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ad8:	8b 00                	mov    (%eax),%eax
  104ada:	83 e0 02             	and    $0x2,%eax
  104add:	85 c0                	test   %eax,%eax
  104adf:	75 24                	jne    104b05 <check_pgdir+0x363>
  104ae1:	c7 44 24 0c 6a 6d 10 	movl   $0x106d6a,0xc(%esp)
  104ae8:	00 
  104ae9:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104af0:	00 
  104af1:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  104af8:	00 
  104af9:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104b00:	e8 cd c1 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104b05:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b0a:	8b 00                	mov    (%eax),%eax
  104b0c:	83 e0 04             	and    $0x4,%eax
  104b0f:	85 c0                	test   %eax,%eax
  104b11:	75 24                	jne    104b37 <check_pgdir+0x395>
  104b13:	c7 44 24 0c 78 6d 10 	movl   $0x106d78,0xc(%esp)
  104b1a:	00 
  104b1b:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104b22:	00 
  104b23:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  104b2a:	00 
  104b2b:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104b32:	e8 9b c1 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 1);
  104b37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b3a:	89 04 24             	mov    %eax,(%esp)
  104b3d:	e8 35 f0 ff ff       	call   103b77 <page_ref>
  104b42:	83 f8 01             	cmp    $0x1,%eax
  104b45:	74 24                	je     104b6b <check_pgdir+0x3c9>
  104b47:	c7 44 24 0c 8e 6d 10 	movl   $0x106d8e,0xc(%esp)
  104b4e:	00 
  104b4f:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104b56:	00 
  104b57:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  104b5e:	00 
  104b5f:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104b66:	e8 67 c1 ff ff       	call   100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104b6b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b70:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104b77:	00 
  104b78:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104b7f:	00 
  104b80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b83:	89 54 24 04          	mov    %edx,0x4(%esp)
  104b87:	89 04 24             	mov    %eax,(%esp)
  104b8a:	e8 df fa ff ff       	call   10466e <page_insert>
  104b8f:	85 c0                	test   %eax,%eax
  104b91:	74 24                	je     104bb7 <check_pgdir+0x415>
  104b93:	c7 44 24 0c a0 6d 10 	movl   $0x106da0,0xc(%esp)
  104b9a:	00 
  104b9b:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104ba2:	00 
  104ba3:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  104baa:	00 
  104bab:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104bb2:	e8 1b c1 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 2);
  104bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bba:	89 04 24             	mov    %eax,(%esp)
  104bbd:	e8 b5 ef ff ff       	call   103b77 <page_ref>
  104bc2:	83 f8 02             	cmp    $0x2,%eax
  104bc5:	74 24                	je     104beb <check_pgdir+0x449>
  104bc7:	c7 44 24 0c cc 6d 10 	movl   $0x106dcc,0xc(%esp)
  104bce:	00 
  104bcf:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104bd6:	00 
  104bd7:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  104bde:	00 
  104bdf:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104be6:	e8 e7 c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bee:	89 04 24             	mov    %eax,(%esp)
  104bf1:	e8 81 ef ff ff       	call   103b77 <page_ref>
  104bf6:	85 c0                	test   %eax,%eax
  104bf8:	74 24                	je     104c1e <check_pgdir+0x47c>
  104bfa:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104c01:	00 
  104c02:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104c09:	00 
  104c0a:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  104c11:	00 
  104c12:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104c19:	e8 b4 c0 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c1e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c2a:	00 
  104c2b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c32:	00 
  104c33:	89 04 24             	mov    %eax,(%esp)
  104c36:	e8 fd f7 ff ff       	call   104438 <get_pte>
  104c3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c42:	75 24                	jne    104c68 <check_pgdir+0x4c6>
  104c44:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  104c4b:	00 
  104c4c:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104c53:	00 
  104c54:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  104c5b:	00 
  104c5c:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104c63:	e8 6a c0 ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  104c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c6b:	8b 00                	mov    (%eax),%eax
  104c6d:	89 04 24             	mov    %eax,(%esp)
  104c70:	e8 ac ee ff ff       	call   103b21 <pte2page>
  104c75:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104c78:	74 24                	je     104c9e <check_pgdir+0x4fc>
  104c7a:	c7 44 24 0c a1 6c 10 	movl   $0x106ca1,0xc(%esp)
  104c81:	00 
  104c82:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104c89:	00 
  104c8a:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  104c91:	00 
  104c92:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104c99:	e8 34 c0 ff ff       	call   100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
  104c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ca1:	8b 00                	mov    (%eax),%eax
  104ca3:	83 e0 04             	and    $0x4,%eax
  104ca6:	85 c0                	test   %eax,%eax
  104ca8:	74 24                	je     104cce <check_pgdir+0x52c>
  104caa:	c7 44 24 0c f0 6d 10 	movl   $0x106df0,0xc(%esp)
  104cb1:	00 
  104cb2:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104cb9:	00 
  104cba:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104cc1:	00 
  104cc2:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104cc9:	e8 04 c0 ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
  104cce:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104cd3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104cda:	00 
  104cdb:	89 04 24             	mov    %eax,(%esp)
  104cde:	e8 47 f9 ff ff       	call   10462a <page_remove>
    assert(page_ref(p1) == 1);
  104ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ce6:	89 04 24             	mov    %eax,(%esp)
  104ce9:	e8 89 ee ff ff       	call   103b77 <page_ref>
  104cee:	83 f8 01             	cmp    $0x1,%eax
  104cf1:	74 24                	je     104d17 <check_pgdir+0x575>
  104cf3:	c7 44 24 0c b7 6c 10 	movl   $0x106cb7,0xc(%esp)
  104cfa:	00 
  104cfb:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104d02:	00 
  104d03:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  104d0a:	00 
  104d0b:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104d12:	e8 bb bf ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104d17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d1a:	89 04 24             	mov    %eax,(%esp)
  104d1d:	e8 55 ee ff ff       	call   103b77 <page_ref>
  104d22:	85 c0                	test   %eax,%eax
  104d24:	74 24                	je     104d4a <check_pgdir+0x5a8>
  104d26:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104d2d:	00 
  104d2e:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104d35:	00 
  104d36:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104d3d:	00 
  104d3e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104d45:	e8 88 bf ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104d4a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d4f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d56:	00 
  104d57:	89 04 24             	mov    %eax,(%esp)
  104d5a:	e8 cb f8 ff ff       	call   10462a <page_remove>
    assert(page_ref(p1) == 0);
  104d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d62:	89 04 24             	mov    %eax,(%esp)
  104d65:	e8 0d ee ff ff       	call   103b77 <page_ref>
  104d6a:	85 c0                	test   %eax,%eax
  104d6c:	74 24                	je     104d92 <check_pgdir+0x5f0>
  104d6e:	c7 44 24 0c 05 6e 10 	movl   $0x106e05,0xc(%esp)
  104d75:	00 
  104d76:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104d7d:	00 
  104d7e:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  104d85:	00 
  104d86:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104d8d:	e8 40 bf ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d95:	89 04 24             	mov    %eax,(%esp)
  104d98:	e8 da ed ff ff       	call   103b77 <page_ref>
  104d9d:	85 c0                	test   %eax,%eax
  104d9f:	74 24                	je     104dc5 <check_pgdir+0x623>
  104da1:	c7 44 24 0c de 6d 10 	movl   $0x106dde,0xc(%esp)
  104da8:	00 
  104da9:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104db0:	00 
  104db1:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104db8:	00 
  104db9:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104dc0:	e8 0d bf ff ff       	call   100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104dc5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104dca:	8b 00                	mov    (%eax),%eax
  104dcc:	89 04 24             	mov    %eax,(%esp)
  104dcf:	e8 8b ed ff ff       	call   103b5f <pde2page>
  104dd4:	89 04 24             	mov    %eax,(%esp)
  104dd7:	e8 9b ed ff ff       	call   103b77 <page_ref>
  104ddc:	83 f8 01             	cmp    $0x1,%eax
  104ddf:	74 24                	je     104e05 <check_pgdir+0x663>
  104de1:	c7 44 24 0c 18 6e 10 	movl   $0x106e18,0xc(%esp)
  104de8:	00 
  104de9:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104df0:	00 
  104df1:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104df8:	00 
  104df9:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104e00:	e8 cd be ff ff       	call   100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104e05:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e0a:	8b 00                	mov    (%eax),%eax
  104e0c:	89 04 24             	mov    %eax,(%esp)
  104e0f:	e8 4b ed ff ff       	call   103b5f <pde2page>
  104e14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e1b:	00 
  104e1c:	89 04 24             	mov    %eax,(%esp)
  104e1f:	e8 90 ef ff ff       	call   103db4 <free_pages>
    boot_pgdir[0] = 0;
  104e24:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104e2f:	c7 04 24 3f 6e 10 00 	movl   $0x106e3f,(%esp)
  104e36:	e8 0d b5 ff ff       	call   100348 <cprintf>
}
  104e3b:	c9                   	leave  
  104e3c:	c3                   	ret    

00104e3d <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104e3d:	55                   	push   %ebp
  104e3e:	89 e5                	mov    %esp,%ebp
  104e40:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104e43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e4a:	e9 ca 00 00 00       	jmp    104f19 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e58:	c1 e8 0c             	shr    $0xc,%eax
  104e5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e5e:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104e63:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104e66:	72 23                	jb     104e8b <check_boot_pgdir+0x4e>
  104e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104e6f:	c7 44 24 08 84 6a 10 	movl   $0x106a84,0x8(%esp)
  104e76:	00 
  104e77:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104e7e:	00 
  104e7f:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104e86:	e8 47 be ff ff       	call   100cd2 <__panic>
  104e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e8e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104e93:	89 c2                	mov    %eax,%edx
  104e95:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ea1:	00 
  104ea2:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ea6:	89 04 24             	mov    %eax,(%esp)
  104ea9:	e8 8a f5 ff ff       	call   104438 <get_pte>
  104eae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104eb1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104eb5:	75 24                	jne    104edb <check_boot_pgdir+0x9e>
  104eb7:	c7 44 24 0c 5c 6e 10 	movl   $0x106e5c,0xc(%esp)
  104ebe:	00 
  104ebf:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104ec6:	00 
  104ec7:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104ece:	00 
  104ecf:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104ed6:	e8 f7 bd ff ff       	call   100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104edb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ede:	8b 00                	mov    (%eax),%eax
  104ee0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104ee5:	89 c2                	mov    %eax,%edx
  104ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104eea:	39 c2                	cmp    %eax,%edx
  104eec:	74 24                	je     104f12 <check_boot_pgdir+0xd5>
  104eee:	c7 44 24 0c 99 6e 10 	movl   $0x106e99,0xc(%esp)
  104ef5:	00 
  104ef6:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104efd:	00 
  104efe:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104f05:	00 
  104f06:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104f0d:	e8 c0 bd ff ff       	call   100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104f12:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104f19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104f1c:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104f21:	39 c2                	cmp    %eax,%edx
  104f23:	0f 82 26 ff ff ff    	jb     104e4f <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104f29:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f2e:	05 ac 0f 00 00       	add    $0xfac,%eax
  104f33:	8b 00                	mov    (%eax),%eax
  104f35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f3a:	89 c2                	mov    %eax,%edx
  104f3c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104f44:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104f4b:	77 23                	ja     104f70 <check_boot_pgdir+0x133>
  104f4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104f54:	c7 44 24 08 28 6b 10 	movl   $0x106b28,0x8(%esp)
  104f5b:	00 
  104f5c:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104f63:	00 
  104f64:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104f6b:	e8 62 bd ff ff       	call   100cd2 <__panic>
  104f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f73:	05 00 00 00 40       	add    $0x40000000,%eax
  104f78:	39 c2                	cmp    %eax,%edx
  104f7a:	74 24                	je     104fa0 <check_boot_pgdir+0x163>
  104f7c:	c7 44 24 0c b0 6e 10 	movl   $0x106eb0,0xc(%esp)
  104f83:	00 
  104f84:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104f8b:	00 
  104f8c:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104f93:	00 
  104f94:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104f9b:	e8 32 bd ff ff       	call   100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
  104fa0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fa5:	8b 00                	mov    (%eax),%eax
  104fa7:	85 c0                	test   %eax,%eax
  104fa9:	74 24                	je     104fcf <check_boot_pgdir+0x192>
  104fab:	c7 44 24 0c e4 6e 10 	movl   $0x106ee4,0xc(%esp)
  104fb2:	00 
  104fb3:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  104fba:	00 
  104fbb:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104fc2:	00 
  104fc3:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  104fca:	e8 03 bd ff ff       	call   100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
  104fcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104fd6:	e8 a1 ed ff ff       	call   103d7c <alloc_pages>
  104fdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104fde:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fe3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104fea:	00 
  104feb:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  104ff2:	00 
  104ff3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104ff6:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ffa:	89 04 24             	mov    %eax,(%esp)
  104ffd:	e8 6c f6 ff ff       	call   10466e <page_insert>
  105002:	85 c0                	test   %eax,%eax
  105004:	74 24                	je     10502a <check_boot_pgdir+0x1ed>
  105006:	c7 44 24 0c f8 6e 10 	movl   $0x106ef8,0xc(%esp)
  10500d:	00 
  10500e:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105015:	00 
  105016:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  10501d:	00 
  10501e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105025:	e8 a8 bc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 1);
  10502a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10502d:	89 04 24             	mov    %eax,(%esp)
  105030:	e8 42 eb ff ff       	call   103b77 <page_ref>
  105035:	83 f8 01             	cmp    $0x1,%eax
  105038:	74 24                	je     10505e <check_boot_pgdir+0x221>
  10503a:	c7 44 24 0c 26 6f 10 	movl   $0x106f26,0xc(%esp)
  105041:	00 
  105042:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105049:	00 
  10504a:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  105051:	00 
  105052:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105059:	e8 74 bc ff ff       	call   100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  10505e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105063:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10506a:	00 
  10506b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  105072:	00 
  105073:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105076:	89 54 24 04          	mov    %edx,0x4(%esp)
  10507a:	89 04 24             	mov    %eax,(%esp)
  10507d:	e8 ec f5 ff ff       	call   10466e <page_insert>
  105082:	85 c0                	test   %eax,%eax
  105084:	74 24                	je     1050aa <check_boot_pgdir+0x26d>
  105086:	c7 44 24 0c 38 6f 10 	movl   $0x106f38,0xc(%esp)
  10508d:	00 
  10508e:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105095:	00 
  105096:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  10509d:	00 
  10509e:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1050a5:	e8 28 bc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 2);
  1050aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050ad:	89 04 24             	mov    %eax,(%esp)
  1050b0:	e8 c2 ea ff ff       	call   103b77 <page_ref>
  1050b5:	83 f8 02             	cmp    $0x2,%eax
  1050b8:	74 24                	je     1050de <check_boot_pgdir+0x2a1>
  1050ba:	c7 44 24 0c 6f 6f 10 	movl   $0x106f6f,0xc(%esp)
  1050c1:	00 
  1050c2:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  1050c9:	00 
  1050ca:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  1050d1:	00 
  1050d2:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  1050d9:	e8 f4 bb ff ff       	call   100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
  1050de:	c7 45 dc 80 6f 10 00 	movl   $0x106f80,-0x24(%ebp)
    strcpy((void *)0x100, str);
  1050e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1050e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050ec:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1050f3:	e8 19 0a 00 00       	call   105b11 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1050f8:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1050ff:	00 
  105100:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105107:	e8 7e 0a 00 00       	call   105b8a <strcmp>
  10510c:	85 c0                	test   %eax,%eax
  10510e:	74 24                	je     105134 <check_boot_pgdir+0x2f7>
  105110:	c7 44 24 0c 98 6f 10 	movl   $0x106f98,0xc(%esp)
  105117:	00 
  105118:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  10511f:	00 
  105120:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  105127:	00 
  105128:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  10512f:	e8 9e bb ff ff       	call   100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105134:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105137:	89 04 24             	mov    %eax,(%esp)
  10513a:	e8 8e e9 ff ff       	call   103acd <page2kva>
  10513f:	05 00 01 00 00       	add    $0x100,%eax
  105144:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  105147:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10514e:	e8 66 09 00 00       	call   105ab9 <strlen>
  105153:	85 c0                	test   %eax,%eax
  105155:	74 24                	je     10517b <check_boot_pgdir+0x33e>
  105157:	c7 44 24 0c d0 6f 10 	movl   $0x106fd0,0xc(%esp)
  10515e:	00 
  10515f:	c7 44 24 08 71 6b 10 	movl   $0x106b71,0x8(%esp)
  105166:	00 
  105167:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  10516e:	00 
  10516f:	c7 04 24 4c 6b 10 00 	movl   $0x106b4c,(%esp)
  105176:	e8 57 bb ff ff       	call   100cd2 <__panic>

    free_page(p);
  10517b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105182:	00 
  105183:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105186:	89 04 24             	mov    %eax,(%esp)
  105189:	e8 26 ec ff ff       	call   103db4 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10518e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105193:	8b 00                	mov    (%eax),%eax
  105195:	89 04 24             	mov    %eax,(%esp)
  105198:	e8 c2 e9 ff ff       	call   103b5f <pde2page>
  10519d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051a4:	00 
  1051a5:	89 04 24             	mov    %eax,(%esp)
  1051a8:	e8 07 ec ff ff       	call   103db4 <free_pages>
    boot_pgdir[0] = 0;
  1051ad:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1051b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  1051b8:	c7 04 24 f4 6f 10 00 	movl   $0x106ff4,(%esp)
  1051bf:	e8 84 b1 ff ff       	call   100348 <cprintf>
}
  1051c4:	c9                   	leave  
  1051c5:	c3                   	ret    

001051c6 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1051c6:	55                   	push   %ebp
  1051c7:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1051c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1051cc:	83 e0 04             	and    $0x4,%eax
  1051cf:	85 c0                	test   %eax,%eax
  1051d1:	74 07                	je     1051da <perm2str+0x14>
  1051d3:	b8 75 00 00 00       	mov    $0x75,%eax
  1051d8:	eb 05                	jmp    1051df <perm2str+0x19>
  1051da:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1051df:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  1051e4:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1051eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1051ee:	83 e0 02             	and    $0x2,%eax
  1051f1:	85 c0                	test   %eax,%eax
  1051f3:	74 07                	je     1051fc <perm2str+0x36>
  1051f5:	b8 77 00 00 00       	mov    $0x77,%eax
  1051fa:	eb 05                	jmp    105201 <perm2str+0x3b>
  1051fc:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105201:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  105206:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  10520d:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  105212:	5d                   	pop    %ebp
  105213:	c3                   	ret    

00105214 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105214:	55                   	push   %ebp
  105215:	89 e5                	mov    %esp,%ebp
  105217:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10521a:	8b 45 10             	mov    0x10(%ebp),%eax
  10521d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105220:	72 0a                	jb     10522c <get_pgtable_items+0x18>
        return 0;
  105222:	b8 00 00 00 00       	mov    $0x0,%eax
  105227:	e9 9c 00 00 00       	jmp    1052c8 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  10522c:	eb 04                	jmp    105232 <get_pgtable_items+0x1e>
        start ++;
  10522e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  105232:	8b 45 10             	mov    0x10(%ebp),%eax
  105235:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105238:	73 18                	jae    105252 <get_pgtable_items+0x3e>
  10523a:	8b 45 10             	mov    0x10(%ebp),%eax
  10523d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105244:	8b 45 14             	mov    0x14(%ebp),%eax
  105247:	01 d0                	add    %edx,%eax
  105249:	8b 00                	mov    (%eax),%eax
  10524b:	83 e0 01             	and    $0x1,%eax
  10524e:	85 c0                	test   %eax,%eax
  105250:	74 dc                	je     10522e <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  105252:	8b 45 10             	mov    0x10(%ebp),%eax
  105255:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105258:	73 69                	jae    1052c3 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  10525a:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10525e:	74 08                	je     105268 <get_pgtable_items+0x54>
            *left_store = start;
  105260:	8b 45 18             	mov    0x18(%ebp),%eax
  105263:	8b 55 10             	mov    0x10(%ebp),%edx
  105266:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105268:	8b 45 10             	mov    0x10(%ebp),%eax
  10526b:	8d 50 01             	lea    0x1(%eax),%edx
  10526e:	89 55 10             	mov    %edx,0x10(%ebp)
  105271:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105278:	8b 45 14             	mov    0x14(%ebp),%eax
  10527b:	01 d0                	add    %edx,%eax
  10527d:	8b 00                	mov    (%eax),%eax
  10527f:	83 e0 07             	and    $0x7,%eax
  105282:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105285:	eb 04                	jmp    10528b <get_pgtable_items+0x77>
            start ++;
  105287:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  10528b:	8b 45 10             	mov    0x10(%ebp),%eax
  10528e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105291:	73 1d                	jae    1052b0 <get_pgtable_items+0x9c>
  105293:	8b 45 10             	mov    0x10(%ebp),%eax
  105296:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10529d:	8b 45 14             	mov    0x14(%ebp),%eax
  1052a0:	01 d0                	add    %edx,%eax
  1052a2:	8b 00                	mov    (%eax),%eax
  1052a4:	83 e0 07             	and    $0x7,%eax
  1052a7:	89 c2                	mov    %eax,%edx
  1052a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052ac:	39 c2                	cmp    %eax,%edx
  1052ae:	74 d7                	je     105287 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  1052b0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1052b4:	74 08                	je     1052be <get_pgtable_items+0xaa>
            *right_store = start;
  1052b6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1052b9:	8b 55 10             	mov    0x10(%ebp),%edx
  1052bc:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1052be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052c1:	eb 05                	jmp    1052c8 <get_pgtable_items+0xb4>
    }
    return 0;
  1052c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1052c8:	c9                   	leave  
  1052c9:	c3                   	ret    

001052ca <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1052ca:	55                   	push   %ebp
  1052cb:	89 e5                	mov    %esp,%ebp
  1052cd:	57                   	push   %edi
  1052ce:	56                   	push   %esi
  1052cf:	53                   	push   %ebx
  1052d0:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1052d3:	c7 04 24 14 70 10 00 	movl   $0x107014,(%esp)
  1052da:	e8 69 b0 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  1052df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1052e6:	e9 fa 00 00 00       	jmp    1053e5 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1052eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1052ee:	89 04 24             	mov    %eax,(%esp)
  1052f1:	e8 d0 fe ff ff       	call   1051c6 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1052f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1052f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1052fc:	29 d1                	sub    %edx,%ecx
  1052fe:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105300:	89 d6                	mov    %edx,%esi
  105302:	c1 e6 16             	shl    $0x16,%esi
  105305:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105308:	89 d3                	mov    %edx,%ebx
  10530a:	c1 e3 16             	shl    $0x16,%ebx
  10530d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105310:	89 d1                	mov    %edx,%ecx
  105312:	c1 e1 16             	shl    $0x16,%ecx
  105315:	8b 7d dc             	mov    -0x24(%ebp),%edi
  105318:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10531b:	29 d7                	sub    %edx,%edi
  10531d:	89 fa                	mov    %edi,%edx
  10531f:	89 44 24 14          	mov    %eax,0x14(%esp)
  105323:	89 74 24 10          	mov    %esi,0x10(%esp)
  105327:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10532b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10532f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105333:	c7 04 24 45 70 10 00 	movl   $0x107045,(%esp)
  10533a:	e8 09 b0 ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  10533f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105342:	c1 e0 0a             	shl    $0xa,%eax
  105345:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105348:	eb 54                	jmp    10539e <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10534a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10534d:	89 04 24             	mov    %eax,(%esp)
  105350:	e8 71 fe ff ff       	call   1051c6 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  105355:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105358:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10535b:	29 d1                	sub    %edx,%ecx
  10535d:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10535f:	89 d6                	mov    %edx,%esi
  105361:	c1 e6 0c             	shl    $0xc,%esi
  105364:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105367:	89 d3                	mov    %edx,%ebx
  105369:	c1 e3 0c             	shl    $0xc,%ebx
  10536c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10536f:	c1 e2 0c             	shl    $0xc,%edx
  105372:	89 d1                	mov    %edx,%ecx
  105374:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  105377:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10537a:	29 d7                	sub    %edx,%edi
  10537c:	89 fa                	mov    %edi,%edx
  10537e:	89 44 24 14          	mov    %eax,0x14(%esp)
  105382:	89 74 24 10          	mov    %esi,0x10(%esp)
  105386:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10538a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10538e:	89 54 24 04          	mov    %edx,0x4(%esp)
  105392:	c7 04 24 64 70 10 00 	movl   $0x107064,(%esp)
  105399:	e8 aa af ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10539e:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  1053a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1053a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1053a9:	89 ce                	mov    %ecx,%esi
  1053ab:	c1 e6 0a             	shl    $0xa,%esi
  1053ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1053b1:	89 cb                	mov    %ecx,%ebx
  1053b3:	c1 e3 0a             	shl    $0xa,%ebx
  1053b6:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1053b9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1053bd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1053c0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1053c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1053c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  1053d0:	89 1c 24             	mov    %ebx,(%esp)
  1053d3:	e8 3c fe ff ff       	call   105214 <get_pgtable_items>
  1053d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1053db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1053df:	0f 85 65 ff ff ff    	jne    10534a <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1053e5:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  1053ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053ed:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  1053f0:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1053f4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  1053f7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1053fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1053ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  105403:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10540a:	00 
  10540b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105412:	e8 fd fd ff ff       	call   105214 <get_pgtable_items>
  105417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10541a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10541e:	0f 85 c7 fe ff ff    	jne    1052eb <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105424:	c7 04 24 88 70 10 00 	movl   $0x107088,(%esp)
  10542b:	e8 18 af ff ff       	call   100348 <cprintf>
}
  105430:	83 c4 4c             	add    $0x4c,%esp
  105433:	5b                   	pop    %ebx
  105434:	5e                   	pop    %esi
  105435:	5f                   	pop    %edi
  105436:	5d                   	pop    %ebp
  105437:	c3                   	ret    

00105438 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105438:	55                   	push   %ebp
  105439:	89 e5                	mov    %esp,%ebp
  10543b:	83 ec 58             	sub    $0x58,%esp
  10543e:	8b 45 10             	mov    0x10(%ebp),%eax
  105441:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105444:	8b 45 14             	mov    0x14(%ebp),%eax
  105447:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10544a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10544d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105450:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105453:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105456:	8b 45 18             	mov    0x18(%ebp),%eax
  105459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10545c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10545f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105465:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10546b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10546e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105472:	74 1c                	je     105490 <printnum+0x58>
  105474:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105477:	ba 00 00 00 00       	mov    $0x0,%edx
  10547c:	f7 75 e4             	divl   -0x1c(%ebp)
  10547f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105485:	ba 00 00 00 00       	mov    $0x0,%edx
  10548a:	f7 75 e4             	divl   -0x1c(%ebp)
  10548d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105490:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105493:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105496:	f7 75 e4             	divl   -0x1c(%ebp)
  105499:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10549c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10549f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1054a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054a8:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1054ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054ae:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1054b1:	8b 45 18             	mov    0x18(%ebp),%eax
  1054b4:	ba 00 00 00 00       	mov    $0x0,%edx
  1054b9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054bc:	77 56                	ja     105514 <printnum+0xdc>
  1054be:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054c1:	72 05                	jb     1054c8 <printnum+0x90>
  1054c3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1054c6:	77 4c                	ja     105514 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1054c8:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1054cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1054ce:	8b 45 20             	mov    0x20(%ebp),%eax
  1054d1:	89 44 24 18          	mov    %eax,0x18(%esp)
  1054d5:	89 54 24 14          	mov    %edx,0x14(%esp)
  1054d9:	8b 45 18             	mov    0x18(%ebp),%eax
  1054dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  1054e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1054ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1054ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1054f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1054f8:	89 04 24             	mov    %eax,(%esp)
  1054fb:	e8 38 ff ff ff       	call   105438 <printnum>
  105500:	eb 1c                	jmp    10551e <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105502:	8b 45 0c             	mov    0xc(%ebp),%eax
  105505:	89 44 24 04          	mov    %eax,0x4(%esp)
  105509:	8b 45 20             	mov    0x20(%ebp),%eax
  10550c:	89 04 24             	mov    %eax,(%esp)
  10550f:	8b 45 08             	mov    0x8(%ebp),%eax
  105512:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105514:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  105518:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10551c:	7f e4                	jg     105502 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10551e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105521:	05 3c 71 10 00       	add    $0x10713c,%eax
  105526:	0f b6 00             	movzbl (%eax),%eax
  105529:	0f be c0             	movsbl %al,%eax
  10552c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10552f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105533:	89 04 24             	mov    %eax,(%esp)
  105536:	8b 45 08             	mov    0x8(%ebp),%eax
  105539:	ff d0                	call   *%eax
}
  10553b:	c9                   	leave  
  10553c:	c3                   	ret    

0010553d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  10553d:	55                   	push   %ebp
  10553e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105540:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105544:	7e 14                	jle    10555a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105546:	8b 45 08             	mov    0x8(%ebp),%eax
  105549:	8b 00                	mov    (%eax),%eax
  10554b:	8d 48 08             	lea    0x8(%eax),%ecx
  10554e:	8b 55 08             	mov    0x8(%ebp),%edx
  105551:	89 0a                	mov    %ecx,(%edx)
  105553:	8b 50 04             	mov    0x4(%eax),%edx
  105556:	8b 00                	mov    (%eax),%eax
  105558:	eb 30                	jmp    10558a <getuint+0x4d>
    }
    else if (lflag) {
  10555a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10555e:	74 16                	je     105576 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105560:	8b 45 08             	mov    0x8(%ebp),%eax
  105563:	8b 00                	mov    (%eax),%eax
  105565:	8d 48 04             	lea    0x4(%eax),%ecx
  105568:	8b 55 08             	mov    0x8(%ebp),%edx
  10556b:	89 0a                	mov    %ecx,(%edx)
  10556d:	8b 00                	mov    (%eax),%eax
  10556f:	ba 00 00 00 00       	mov    $0x0,%edx
  105574:	eb 14                	jmp    10558a <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105576:	8b 45 08             	mov    0x8(%ebp),%eax
  105579:	8b 00                	mov    (%eax),%eax
  10557b:	8d 48 04             	lea    0x4(%eax),%ecx
  10557e:	8b 55 08             	mov    0x8(%ebp),%edx
  105581:	89 0a                	mov    %ecx,(%edx)
  105583:	8b 00                	mov    (%eax),%eax
  105585:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10558a:	5d                   	pop    %ebp
  10558b:	c3                   	ret    

0010558c <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10558c:	55                   	push   %ebp
  10558d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10558f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105593:	7e 14                	jle    1055a9 <getint+0x1d>
        return va_arg(*ap, long long);
  105595:	8b 45 08             	mov    0x8(%ebp),%eax
  105598:	8b 00                	mov    (%eax),%eax
  10559a:	8d 48 08             	lea    0x8(%eax),%ecx
  10559d:	8b 55 08             	mov    0x8(%ebp),%edx
  1055a0:	89 0a                	mov    %ecx,(%edx)
  1055a2:	8b 50 04             	mov    0x4(%eax),%edx
  1055a5:	8b 00                	mov    (%eax),%eax
  1055a7:	eb 28                	jmp    1055d1 <getint+0x45>
    }
    else if (lflag) {
  1055a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055ad:	74 12                	je     1055c1 <getint+0x35>
        return va_arg(*ap, long);
  1055af:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b2:	8b 00                	mov    (%eax),%eax
  1055b4:	8d 48 04             	lea    0x4(%eax),%ecx
  1055b7:	8b 55 08             	mov    0x8(%ebp),%edx
  1055ba:	89 0a                	mov    %ecx,(%edx)
  1055bc:	8b 00                	mov    (%eax),%eax
  1055be:	99                   	cltd   
  1055bf:	eb 10                	jmp    1055d1 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1055c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c4:	8b 00                	mov    (%eax),%eax
  1055c6:	8d 48 04             	lea    0x4(%eax),%ecx
  1055c9:	8b 55 08             	mov    0x8(%ebp),%edx
  1055cc:	89 0a                	mov    %ecx,(%edx)
  1055ce:	8b 00                	mov    (%eax),%eax
  1055d0:	99                   	cltd   
    }
}
  1055d1:	5d                   	pop    %ebp
  1055d2:	c3                   	ret    

001055d3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1055d3:	55                   	push   %ebp
  1055d4:	89 e5                	mov    %esp,%ebp
  1055d6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1055d9:	8d 45 14             	lea    0x14(%ebp),%eax
  1055dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1055df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1055e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1055e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1055ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1055f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f7:	89 04 24             	mov    %eax,(%esp)
  1055fa:	e8 02 00 00 00       	call   105601 <vprintfmt>
    va_end(ap);
}
  1055ff:	c9                   	leave  
  105600:	c3                   	ret    

00105601 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105601:	55                   	push   %ebp
  105602:	89 e5                	mov    %esp,%ebp
  105604:	56                   	push   %esi
  105605:	53                   	push   %ebx
  105606:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105609:	eb 18                	jmp    105623 <vprintfmt+0x22>
            if (ch == '\0') {
  10560b:	85 db                	test   %ebx,%ebx
  10560d:	75 05                	jne    105614 <vprintfmt+0x13>
                return;
  10560f:	e9 d1 03 00 00       	jmp    1059e5 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105614:	8b 45 0c             	mov    0xc(%ebp),%eax
  105617:	89 44 24 04          	mov    %eax,0x4(%esp)
  10561b:	89 1c 24             	mov    %ebx,(%esp)
  10561e:	8b 45 08             	mov    0x8(%ebp),%eax
  105621:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105623:	8b 45 10             	mov    0x10(%ebp),%eax
  105626:	8d 50 01             	lea    0x1(%eax),%edx
  105629:	89 55 10             	mov    %edx,0x10(%ebp)
  10562c:	0f b6 00             	movzbl (%eax),%eax
  10562f:	0f b6 d8             	movzbl %al,%ebx
  105632:	83 fb 25             	cmp    $0x25,%ebx
  105635:	75 d4                	jne    10560b <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  105637:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  10563b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105645:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105648:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10564f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105652:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105655:	8b 45 10             	mov    0x10(%ebp),%eax
  105658:	8d 50 01             	lea    0x1(%eax),%edx
  10565b:	89 55 10             	mov    %edx,0x10(%ebp)
  10565e:	0f b6 00             	movzbl (%eax),%eax
  105661:	0f b6 d8             	movzbl %al,%ebx
  105664:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105667:	83 f8 55             	cmp    $0x55,%eax
  10566a:	0f 87 44 03 00 00    	ja     1059b4 <vprintfmt+0x3b3>
  105670:	8b 04 85 60 71 10 00 	mov    0x107160(,%eax,4),%eax
  105677:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105679:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10567d:	eb d6                	jmp    105655 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10567f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105683:	eb d0                	jmp    105655 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105685:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10568c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10568f:	89 d0                	mov    %edx,%eax
  105691:	c1 e0 02             	shl    $0x2,%eax
  105694:	01 d0                	add    %edx,%eax
  105696:	01 c0                	add    %eax,%eax
  105698:	01 d8                	add    %ebx,%eax
  10569a:	83 e8 30             	sub    $0x30,%eax
  10569d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1056a0:	8b 45 10             	mov    0x10(%ebp),%eax
  1056a3:	0f b6 00             	movzbl (%eax),%eax
  1056a6:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1056a9:	83 fb 2f             	cmp    $0x2f,%ebx
  1056ac:	7e 0b                	jle    1056b9 <vprintfmt+0xb8>
  1056ae:	83 fb 39             	cmp    $0x39,%ebx
  1056b1:	7f 06                	jg     1056b9 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1056b3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1056b7:	eb d3                	jmp    10568c <vprintfmt+0x8b>
            goto process_precision;
  1056b9:	eb 33                	jmp    1056ee <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1056bb:	8b 45 14             	mov    0x14(%ebp),%eax
  1056be:	8d 50 04             	lea    0x4(%eax),%edx
  1056c1:	89 55 14             	mov    %edx,0x14(%ebp)
  1056c4:	8b 00                	mov    (%eax),%eax
  1056c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1056c9:	eb 23                	jmp    1056ee <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1056cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056cf:	79 0c                	jns    1056dd <vprintfmt+0xdc>
                width = 0;
  1056d1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1056d8:	e9 78 ff ff ff       	jmp    105655 <vprintfmt+0x54>
  1056dd:	e9 73 ff ff ff       	jmp    105655 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1056e2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1056e9:	e9 67 ff ff ff       	jmp    105655 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1056ee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056f2:	79 12                	jns    105706 <vprintfmt+0x105>
                width = precision, precision = -1;
  1056f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1056f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1056fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105701:	e9 4f ff ff ff       	jmp    105655 <vprintfmt+0x54>
  105706:	e9 4a ff ff ff       	jmp    105655 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  10570b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  10570f:	e9 41 ff ff ff       	jmp    105655 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105714:	8b 45 14             	mov    0x14(%ebp),%eax
  105717:	8d 50 04             	lea    0x4(%eax),%edx
  10571a:	89 55 14             	mov    %edx,0x14(%ebp)
  10571d:	8b 00                	mov    (%eax),%eax
  10571f:	8b 55 0c             	mov    0xc(%ebp),%edx
  105722:	89 54 24 04          	mov    %edx,0x4(%esp)
  105726:	89 04 24             	mov    %eax,(%esp)
  105729:	8b 45 08             	mov    0x8(%ebp),%eax
  10572c:	ff d0                	call   *%eax
            break;
  10572e:	e9 ac 02 00 00       	jmp    1059df <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105733:	8b 45 14             	mov    0x14(%ebp),%eax
  105736:	8d 50 04             	lea    0x4(%eax),%edx
  105739:	89 55 14             	mov    %edx,0x14(%ebp)
  10573c:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10573e:	85 db                	test   %ebx,%ebx
  105740:	79 02                	jns    105744 <vprintfmt+0x143>
                err = -err;
  105742:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105744:	83 fb 06             	cmp    $0x6,%ebx
  105747:	7f 0b                	jg     105754 <vprintfmt+0x153>
  105749:	8b 34 9d 20 71 10 00 	mov    0x107120(,%ebx,4),%esi
  105750:	85 f6                	test   %esi,%esi
  105752:	75 23                	jne    105777 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105754:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105758:	c7 44 24 08 4d 71 10 	movl   $0x10714d,0x8(%esp)
  10575f:	00 
  105760:	8b 45 0c             	mov    0xc(%ebp),%eax
  105763:	89 44 24 04          	mov    %eax,0x4(%esp)
  105767:	8b 45 08             	mov    0x8(%ebp),%eax
  10576a:	89 04 24             	mov    %eax,(%esp)
  10576d:	e8 61 fe ff ff       	call   1055d3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105772:	e9 68 02 00 00       	jmp    1059df <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  105777:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10577b:	c7 44 24 08 56 71 10 	movl   $0x107156,0x8(%esp)
  105782:	00 
  105783:	8b 45 0c             	mov    0xc(%ebp),%eax
  105786:	89 44 24 04          	mov    %eax,0x4(%esp)
  10578a:	8b 45 08             	mov    0x8(%ebp),%eax
  10578d:	89 04 24             	mov    %eax,(%esp)
  105790:	e8 3e fe ff ff       	call   1055d3 <printfmt>
            }
            break;
  105795:	e9 45 02 00 00       	jmp    1059df <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10579a:	8b 45 14             	mov    0x14(%ebp),%eax
  10579d:	8d 50 04             	lea    0x4(%eax),%edx
  1057a0:	89 55 14             	mov    %edx,0x14(%ebp)
  1057a3:	8b 30                	mov    (%eax),%esi
  1057a5:	85 f6                	test   %esi,%esi
  1057a7:	75 05                	jne    1057ae <vprintfmt+0x1ad>
                p = "(null)";
  1057a9:	be 59 71 10 00       	mov    $0x107159,%esi
            }
            if (width > 0 && padc != '-') {
  1057ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057b2:	7e 3e                	jle    1057f2 <vprintfmt+0x1f1>
  1057b4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1057b8:	74 38                	je     1057f2 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057ba:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  1057bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057c4:	89 34 24             	mov    %esi,(%esp)
  1057c7:	e8 15 03 00 00       	call   105ae1 <strnlen>
  1057cc:	29 c3                	sub    %eax,%ebx
  1057ce:	89 d8                	mov    %ebx,%eax
  1057d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057d3:	eb 17                	jmp    1057ec <vprintfmt+0x1eb>
                    putch(padc, putdat);
  1057d5:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1057d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057e0:	89 04 24             	mov    %eax,(%esp)
  1057e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1057e6:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057e8:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1057ec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057f0:	7f e3                	jg     1057d5 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1057f2:	eb 38                	jmp    10582c <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  1057f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1057f8:	74 1f                	je     105819 <vprintfmt+0x218>
  1057fa:	83 fb 1f             	cmp    $0x1f,%ebx
  1057fd:	7e 05                	jle    105804 <vprintfmt+0x203>
  1057ff:	83 fb 7e             	cmp    $0x7e,%ebx
  105802:	7e 15                	jle    105819 <vprintfmt+0x218>
                    putch('?', putdat);
  105804:	8b 45 0c             	mov    0xc(%ebp),%eax
  105807:	89 44 24 04          	mov    %eax,0x4(%esp)
  10580b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105812:	8b 45 08             	mov    0x8(%ebp),%eax
  105815:	ff d0                	call   *%eax
  105817:	eb 0f                	jmp    105828 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105819:	8b 45 0c             	mov    0xc(%ebp),%eax
  10581c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105820:	89 1c 24             	mov    %ebx,(%esp)
  105823:	8b 45 08             	mov    0x8(%ebp),%eax
  105826:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105828:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10582c:	89 f0                	mov    %esi,%eax
  10582e:	8d 70 01             	lea    0x1(%eax),%esi
  105831:	0f b6 00             	movzbl (%eax),%eax
  105834:	0f be d8             	movsbl %al,%ebx
  105837:	85 db                	test   %ebx,%ebx
  105839:	74 10                	je     10584b <vprintfmt+0x24a>
  10583b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10583f:	78 b3                	js     1057f4 <vprintfmt+0x1f3>
  105841:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105845:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105849:	79 a9                	jns    1057f4 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10584b:	eb 17                	jmp    105864 <vprintfmt+0x263>
                putch(' ', putdat);
  10584d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105850:	89 44 24 04          	mov    %eax,0x4(%esp)
  105854:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10585b:	8b 45 08             	mov    0x8(%ebp),%eax
  10585e:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105860:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105864:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105868:	7f e3                	jg     10584d <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  10586a:	e9 70 01 00 00       	jmp    1059df <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10586f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105872:	89 44 24 04          	mov    %eax,0x4(%esp)
  105876:	8d 45 14             	lea    0x14(%ebp),%eax
  105879:	89 04 24             	mov    %eax,(%esp)
  10587c:	e8 0b fd ff ff       	call   10558c <getint>
  105881:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105884:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10588a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10588d:	85 d2                	test   %edx,%edx
  10588f:	79 26                	jns    1058b7 <vprintfmt+0x2b6>
                putch('-', putdat);
  105891:	8b 45 0c             	mov    0xc(%ebp),%eax
  105894:	89 44 24 04          	mov    %eax,0x4(%esp)
  105898:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10589f:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a2:	ff d0                	call   *%eax
                num = -(long long)num;
  1058a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058aa:	f7 d8                	neg    %eax
  1058ac:	83 d2 00             	adc    $0x0,%edx
  1058af:	f7 da                	neg    %edx
  1058b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058b4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1058b7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058be:	e9 a8 00 00 00       	jmp    10596b <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1058c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058ca:	8d 45 14             	lea    0x14(%ebp),%eax
  1058cd:	89 04 24             	mov    %eax,(%esp)
  1058d0:	e8 68 fc ff ff       	call   10553d <getuint>
  1058d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1058db:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058e2:	e9 84 00 00 00       	jmp    10596b <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1058e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058ee:	8d 45 14             	lea    0x14(%ebp),%eax
  1058f1:	89 04 24             	mov    %eax,(%esp)
  1058f4:	e8 44 fc ff ff       	call   10553d <getuint>
  1058f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1058ff:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105906:	eb 63                	jmp    10596b <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105908:	8b 45 0c             	mov    0xc(%ebp),%eax
  10590b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10590f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105916:	8b 45 08             	mov    0x8(%ebp),%eax
  105919:	ff d0                	call   *%eax
            putch('x', putdat);
  10591b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10591e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105922:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105929:	8b 45 08             	mov    0x8(%ebp),%eax
  10592c:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  10592e:	8b 45 14             	mov    0x14(%ebp),%eax
  105931:	8d 50 04             	lea    0x4(%eax),%edx
  105934:	89 55 14             	mov    %edx,0x14(%ebp)
  105937:	8b 00                	mov    (%eax),%eax
  105939:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10593c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105943:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  10594a:	eb 1f                	jmp    10596b <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10594c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10594f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105953:	8d 45 14             	lea    0x14(%ebp),%eax
  105956:	89 04 24             	mov    %eax,(%esp)
  105959:	e8 df fb ff ff       	call   10553d <getuint>
  10595e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105961:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105964:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10596b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  10596f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105972:	89 54 24 18          	mov    %edx,0x18(%esp)
  105976:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105979:	89 54 24 14          	mov    %edx,0x14(%esp)
  10597d:	89 44 24 10          	mov    %eax,0x10(%esp)
  105981:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105984:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105987:	89 44 24 08          	mov    %eax,0x8(%esp)
  10598b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10598f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105992:	89 44 24 04          	mov    %eax,0x4(%esp)
  105996:	8b 45 08             	mov    0x8(%ebp),%eax
  105999:	89 04 24             	mov    %eax,(%esp)
  10599c:	e8 97 fa ff ff       	call   105438 <printnum>
            break;
  1059a1:	eb 3c                	jmp    1059df <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1059a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059aa:	89 1c 24             	mov    %ebx,(%esp)
  1059ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b0:	ff d0                	call   *%eax
            break;
  1059b2:	eb 2b                	jmp    1059df <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1059b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059bb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1059c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1059c5:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1059c7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1059cb:	eb 04                	jmp    1059d1 <vprintfmt+0x3d0>
  1059cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1059d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1059d4:	83 e8 01             	sub    $0x1,%eax
  1059d7:	0f b6 00             	movzbl (%eax),%eax
  1059da:	3c 25                	cmp    $0x25,%al
  1059dc:	75 ef                	jne    1059cd <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  1059de:	90                   	nop
        }
    }
  1059df:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059e0:	e9 3e fc ff ff       	jmp    105623 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1059e5:	83 c4 40             	add    $0x40,%esp
  1059e8:	5b                   	pop    %ebx
  1059e9:	5e                   	pop    %esi
  1059ea:	5d                   	pop    %ebp
  1059eb:	c3                   	ret    

001059ec <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1059ec:	55                   	push   %ebp
  1059ed:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1059ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059f2:	8b 40 08             	mov    0x8(%eax),%eax
  1059f5:	8d 50 01             	lea    0x1(%eax),%edx
  1059f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059fb:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1059fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a01:	8b 10                	mov    (%eax),%edx
  105a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a06:	8b 40 04             	mov    0x4(%eax),%eax
  105a09:	39 c2                	cmp    %eax,%edx
  105a0b:	73 12                	jae    105a1f <sprintputch+0x33>
        *b->buf ++ = ch;
  105a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a10:	8b 00                	mov    (%eax),%eax
  105a12:	8d 48 01             	lea    0x1(%eax),%ecx
  105a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a18:	89 0a                	mov    %ecx,(%edx)
  105a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  105a1d:	88 10                	mov    %dl,(%eax)
    }
}
  105a1f:	5d                   	pop    %ebp
  105a20:	c3                   	ret    

00105a21 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105a21:	55                   	push   %ebp
  105a22:	89 e5                	mov    %esp,%ebp
  105a24:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105a27:	8d 45 14             	lea    0x14(%ebp),%eax
  105a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a34:	8b 45 10             	mov    0x10(%ebp),%eax
  105a37:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a42:	8b 45 08             	mov    0x8(%ebp),%eax
  105a45:	89 04 24             	mov    %eax,(%esp)
  105a48:	e8 08 00 00 00       	call   105a55 <vsnprintf>
  105a4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105a53:	c9                   	leave  
  105a54:	c3                   	ret    

00105a55 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105a55:	55                   	push   %ebp
  105a56:	89 e5                	mov    %esp,%ebp
  105a58:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a64:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a67:	8b 45 08             	mov    0x8(%ebp),%eax
  105a6a:	01 d0                	add    %edx,%eax
  105a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105a76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105a7a:	74 0a                	je     105a86 <vsnprintf+0x31>
  105a7c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a82:	39 c2                	cmp    %eax,%edx
  105a84:	76 07                	jbe    105a8d <vsnprintf+0x38>
        return -E_INVAL;
  105a86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105a8b:	eb 2a                	jmp    105ab7 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  105a90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a94:	8b 45 10             	mov    0x10(%ebp),%eax
  105a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa2:	c7 04 24 ec 59 10 00 	movl   $0x1059ec,(%esp)
  105aa9:	e8 53 fb ff ff       	call   105601 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105aae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ab1:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ab7:	c9                   	leave  
  105ab8:	c3                   	ret    

00105ab9 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105ab9:	55                   	push   %ebp
  105aba:	89 e5                	mov    %esp,%ebp
  105abc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105abf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105ac6:	eb 04                	jmp    105acc <strlen+0x13>
        cnt ++;
  105ac8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105acc:	8b 45 08             	mov    0x8(%ebp),%eax
  105acf:	8d 50 01             	lea    0x1(%eax),%edx
  105ad2:	89 55 08             	mov    %edx,0x8(%ebp)
  105ad5:	0f b6 00             	movzbl (%eax),%eax
  105ad8:	84 c0                	test   %al,%al
  105ada:	75 ec                	jne    105ac8 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105adc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105adf:	c9                   	leave  
  105ae0:	c3                   	ret    

00105ae1 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105ae1:	55                   	push   %ebp
  105ae2:	89 e5                	mov    %esp,%ebp
  105ae4:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105ae7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105aee:	eb 04                	jmp    105af4 <strnlen+0x13>
        cnt ++;
  105af0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105af4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105af7:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105afa:	73 10                	jae    105b0c <strnlen+0x2b>
  105afc:	8b 45 08             	mov    0x8(%ebp),%eax
  105aff:	8d 50 01             	lea    0x1(%eax),%edx
  105b02:	89 55 08             	mov    %edx,0x8(%ebp)
  105b05:	0f b6 00             	movzbl (%eax),%eax
  105b08:	84 c0                	test   %al,%al
  105b0a:	75 e4                	jne    105af0 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105b0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b0f:	c9                   	leave  
  105b10:	c3                   	ret    

00105b11 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105b11:	55                   	push   %ebp
  105b12:	89 e5                	mov    %esp,%ebp
  105b14:	57                   	push   %edi
  105b15:	56                   	push   %esi
  105b16:	83 ec 20             	sub    $0x20,%esp
  105b19:	8b 45 08             	mov    0x8(%ebp),%eax
  105b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105b25:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b2b:	89 d1                	mov    %edx,%ecx
  105b2d:	89 c2                	mov    %eax,%edx
  105b2f:	89 ce                	mov    %ecx,%esi
  105b31:	89 d7                	mov    %edx,%edi
  105b33:	ac                   	lods   %ds:(%esi),%al
  105b34:	aa                   	stos   %al,%es:(%edi)
  105b35:	84 c0                	test   %al,%al
  105b37:	75 fa                	jne    105b33 <strcpy+0x22>
  105b39:	89 fa                	mov    %edi,%edx
  105b3b:	89 f1                	mov    %esi,%ecx
  105b3d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105b40:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105b43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105b49:	83 c4 20             	add    $0x20,%esp
  105b4c:	5e                   	pop    %esi
  105b4d:	5f                   	pop    %edi
  105b4e:	5d                   	pop    %ebp
  105b4f:	c3                   	ret    

00105b50 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105b50:	55                   	push   %ebp
  105b51:	89 e5                	mov    %esp,%ebp
  105b53:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105b56:	8b 45 08             	mov    0x8(%ebp),%eax
  105b59:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105b5c:	eb 21                	jmp    105b7f <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b61:	0f b6 10             	movzbl (%eax),%edx
  105b64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b67:	88 10                	mov    %dl,(%eax)
  105b69:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b6c:	0f b6 00             	movzbl (%eax),%eax
  105b6f:	84 c0                	test   %al,%al
  105b71:	74 04                	je     105b77 <strncpy+0x27>
            src ++;
  105b73:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105b77:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105b7b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105b7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b83:	75 d9                	jne    105b5e <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105b85:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105b88:	c9                   	leave  
  105b89:	c3                   	ret    

00105b8a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105b8a:	55                   	push   %ebp
  105b8b:	89 e5                	mov    %esp,%ebp
  105b8d:	57                   	push   %edi
  105b8e:	56                   	push   %esi
  105b8f:	83 ec 20             	sub    $0x20,%esp
  105b92:	8b 45 08             	mov    0x8(%ebp),%eax
  105b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105b9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ba4:	89 d1                	mov    %edx,%ecx
  105ba6:	89 c2                	mov    %eax,%edx
  105ba8:	89 ce                	mov    %ecx,%esi
  105baa:	89 d7                	mov    %edx,%edi
  105bac:	ac                   	lods   %ds:(%esi),%al
  105bad:	ae                   	scas   %es:(%edi),%al
  105bae:	75 08                	jne    105bb8 <strcmp+0x2e>
  105bb0:	84 c0                	test   %al,%al
  105bb2:	75 f8                	jne    105bac <strcmp+0x22>
  105bb4:	31 c0                	xor    %eax,%eax
  105bb6:	eb 04                	jmp    105bbc <strcmp+0x32>
  105bb8:	19 c0                	sbb    %eax,%eax
  105bba:	0c 01                	or     $0x1,%al
  105bbc:	89 fa                	mov    %edi,%edx
  105bbe:	89 f1                	mov    %esi,%ecx
  105bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105bc3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105bc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105bcc:	83 c4 20             	add    $0x20,%esp
  105bcf:	5e                   	pop    %esi
  105bd0:	5f                   	pop    %edi
  105bd1:	5d                   	pop    %ebp
  105bd2:	c3                   	ret    

00105bd3 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105bd3:	55                   	push   %ebp
  105bd4:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bd6:	eb 0c                	jmp    105be4 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105bd8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105bdc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105be0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105be4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105be8:	74 1a                	je     105c04 <strncmp+0x31>
  105bea:	8b 45 08             	mov    0x8(%ebp),%eax
  105bed:	0f b6 00             	movzbl (%eax),%eax
  105bf0:	84 c0                	test   %al,%al
  105bf2:	74 10                	je     105c04 <strncmp+0x31>
  105bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf7:	0f b6 10             	movzbl (%eax),%edx
  105bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bfd:	0f b6 00             	movzbl (%eax),%eax
  105c00:	38 c2                	cmp    %al,%dl
  105c02:	74 d4                	je     105bd8 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105c04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c08:	74 18                	je     105c22 <strncmp+0x4f>
  105c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c0d:	0f b6 00             	movzbl (%eax),%eax
  105c10:	0f b6 d0             	movzbl %al,%edx
  105c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c16:	0f b6 00             	movzbl (%eax),%eax
  105c19:	0f b6 c0             	movzbl %al,%eax
  105c1c:	29 c2                	sub    %eax,%edx
  105c1e:	89 d0                	mov    %edx,%eax
  105c20:	eb 05                	jmp    105c27 <strncmp+0x54>
  105c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c27:	5d                   	pop    %ebp
  105c28:	c3                   	ret    

00105c29 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105c29:	55                   	push   %ebp
  105c2a:	89 e5                	mov    %esp,%ebp
  105c2c:	83 ec 04             	sub    $0x4,%esp
  105c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c32:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c35:	eb 14                	jmp    105c4b <strchr+0x22>
        if (*s == c) {
  105c37:	8b 45 08             	mov    0x8(%ebp),%eax
  105c3a:	0f b6 00             	movzbl (%eax),%eax
  105c3d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105c40:	75 05                	jne    105c47 <strchr+0x1e>
            return (char *)s;
  105c42:	8b 45 08             	mov    0x8(%ebp),%eax
  105c45:	eb 13                	jmp    105c5a <strchr+0x31>
        }
        s ++;
  105c47:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105c4e:	0f b6 00             	movzbl (%eax),%eax
  105c51:	84 c0                	test   %al,%al
  105c53:	75 e2                	jne    105c37 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105c55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c5a:	c9                   	leave  
  105c5b:	c3                   	ret    

00105c5c <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105c5c:	55                   	push   %ebp
  105c5d:	89 e5                	mov    %esp,%ebp
  105c5f:	83 ec 04             	sub    $0x4,%esp
  105c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c65:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c68:	eb 11                	jmp    105c7b <strfind+0x1f>
        if (*s == c) {
  105c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c6d:	0f b6 00             	movzbl (%eax),%eax
  105c70:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105c73:	75 02                	jne    105c77 <strfind+0x1b>
            break;
  105c75:	eb 0e                	jmp    105c85 <strfind+0x29>
        }
        s ++;
  105c77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7e:	0f b6 00             	movzbl (%eax),%eax
  105c81:	84 c0                	test   %al,%al
  105c83:	75 e5                	jne    105c6a <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105c85:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105c88:	c9                   	leave  
  105c89:	c3                   	ret    

00105c8a <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105c8a:	55                   	push   %ebp
  105c8b:	89 e5                	mov    %esp,%ebp
  105c8d:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105c90:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105c97:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105c9e:	eb 04                	jmp    105ca4 <strtol+0x1a>
        s ++;
  105ca0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  105ca7:	0f b6 00             	movzbl (%eax),%eax
  105caa:	3c 20                	cmp    $0x20,%al
  105cac:	74 f2                	je     105ca0 <strtol+0x16>
  105cae:	8b 45 08             	mov    0x8(%ebp),%eax
  105cb1:	0f b6 00             	movzbl (%eax),%eax
  105cb4:	3c 09                	cmp    $0x9,%al
  105cb6:	74 e8                	je     105ca0 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  105cbb:	0f b6 00             	movzbl (%eax),%eax
  105cbe:	3c 2b                	cmp    $0x2b,%al
  105cc0:	75 06                	jne    105cc8 <strtol+0x3e>
        s ++;
  105cc2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105cc6:	eb 15                	jmp    105cdd <strtol+0x53>
    }
    else if (*s == '-') {
  105cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccb:	0f b6 00             	movzbl (%eax),%eax
  105cce:	3c 2d                	cmp    $0x2d,%al
  105cd0:	75 0b                	jne    105cdd <strtol+0x53>
        s ++, neg = 1;
  105cd2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105cd6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105cdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105ce1:	74 06                	je     105ce9 <strtol+0x5f>
  105ce3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105ce7:	75 24                	jne    105d0d <strtol+0x83>
  105ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  105cec:	0f b6 00             	movzbl (%eax),%eax
  105cef:	3c 30                	cmp    $0x30,%al
  105cf1:	75 1a                	jne    105d0d <strtol+0x83>
  105cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  105cf6:	83 c0 01             	add    $0x1,%eax
  105cf9:	0f b6 00             	movzbl (%eax),%eax
  105cfc:	3c 78                	cmp    $0x78,%al
  105cfe:	75 0d                	jne    105d0d <strtol+0x83>
        s += 2, base = 16;
  105d00:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105d04:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105d0b:	eb 2a                	jmp    105d37 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105d0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d11:	75 17                	jne    105d2a <strtol+0xa0>
  105d13:	8b 45 08             	mov    0x8(%ebp),%eax
  105d16:	0f b6 00             	movzbl (%eax),%eax
  105d19:	3c 30                	cmp    $0x30,%al
  105d1b:	75 0d                	jne    105d2a <strtol+0xa0>
        s ++, base = 8;
  105d1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d21:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105d28:	eb 0d                	jmp    105d37 <strtol+0xad>
    }
    else if (base == 0) {
  105d2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d2e:	75 07                	jne    105d37 <strtol+0xad>
        base = 10;
  105d30:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105d37:	8b 45 08             	mov    0x8(%ebp),%eax
  105d3a:	0f b6 00             	movzbl (%eax),%eax
  105d3d:	3c 2f                	cmp    $0x2f,%al
  105d3f:	7e 1b                	jle    105d5c <strtol+0xd2>
  105d41:	8b 45 08             	mov    0x8(%ebp),%eax
  105d44:	0f b6 00             	movzbl (%eax),%eax
  105d47:	3c 39                	cmp    $0x39,%al
  105d49:	7f 11                	jg     105d5c <strtol+0xd2>
            dig = *s - '0';
  105d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4e:	0f b6 00             	movzbl (%eax),%eax
  105d51:	0f be c0             	movsbl %al,%eax
  105d54:	83 e8 30             	sub    $0x30,%eax
  105d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d5a:	eb 48                	jmp    105da4 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5f:	0f b6 00             	movzbl (%eax),%eax
  105d62:	3c 60                	cmp    $0x60,%al
  105d64:	7e 1b                	jle    105d81 <strtol+0xf7>
  105d66:	8b 45 08             	mov    0x8(%ebp),%eax
  105d69:	0f b6 00             	movzbl (%eax),%eax
  105d6c:	3c 7a                	cmp    $0x7a,%al
  105d6e:	7f 11                	jg     105d81 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105d70:	8b 45 08             	mov    0x8(%ebp),%eax
  105d73:	0f b6 00             	movzbl (%eax),%eax
  105d76:	0f be c0             	movsbl %al,%eax
  105d79:	83 e8 57             	sub    $0x57,%eax
  105d7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d7f:	eb 23                	jmp    105da4 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105d81:	8b 45 08             	mov    0x8(%ebp),%eax
  105d84:	0f b6 00             	movzbl (%eax),%eax
  105d87:	3c 40                	cmp    $0x40,%al
  105d89:	7e 3d                	jle    105dc8 <strtol+0x13e>
  105d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8e:	0f b6 00             	movzbl (%eax),%eax
  105d91:	3c 5a                	cmp    $0x5a,%al
  105d93:	7f 33                	jg     105dc8 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105d95:	8b 45 08             	mov    0x8(%ebp),%eax
  105d98:	0f b6 00             	movzbl (%eax),%eax
  105d9b:	0f be c0             	movsbl %al,%eax
  105d9e:	83 e8 37             	sub    $0x37,%eax
  105da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105da7:	3b 45 10             	cmp    0x10(%ebp),%eax
  105daa:	7c 02                	jl     105dae <strtol+0x124>
            break;
  105dac:	eb 1a                	jmp    105dc8 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105dae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105db2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105db5:	0f af 45 10          	imul   0x10(%ebp),%eax
  105db9:	89 c2                	mov    %eax,%edx
  105dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dbe:	01 d0                	add    %edx,%eax
  105dc0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105dc3:	e9 6f ff ff ff       	jmp    105d37 <strtol+0xad>

    if (endptr) {
  105dc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105dcc:	74 08                	je     105dd6 <strtol+0x14c>
        *endptr = (char *) s;
  105dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  105dd4:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105dd6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105dda:	74 07                	je     105de3 <strtol+0x159>
  105ddc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105ddf:	f7 d8                	neg    %eax
  105de1:	eb 03                	jmp    105de6 <strtol+0x15c>
  105de3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105de6:	c9                   	leave  
  105de7:	c3                   	ret    

00105de8 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105de8:	55                   	push   %ebp
  105de9:	89 e5                	mov    %esp,%ebp
  105deb:	57                   	push   %edi
  105dec:	83 ec 24             	sub    $0x24,%esp
  105def:	8b 45 0c             	mov    0xc(%ebp),%eax
  105df2:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105df5:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105df9:	8b 55 08             	mov    0x8(%ebp),%edx
  105dfc:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105dff:	88 45 f7             	mov    %al,-0x9(%ebp)
  105e02:	8b 45 10             	mov    0x10(%ebp),%eax
  105e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105e08:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105e0b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105e0f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105e12:	89 d7                	mov    %edx,%edi
  105e14:	f3 aa                	rep stos %al,%es:(%edi)
  105e16:	89 fa                	mov    %edi,%edx
  105e18:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105e1b:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105e1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105e21:	83 c4 24             	add    $0x24,%esp
  105e24:	5f                   	pop    %edi
  105e25:	5d                   	pop    %ebp
  105e26:	c3                   	ret    

00105e27 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105e27:	55                   	push   %ebp
  105e28:	89 e5                	mov    %esp,%ebp
  105e2a:	57                   	push   %edi
  105e2b:	56                   	push   %esi
  105e2c:	53                   	push   %ebx
  105e2d:	83 ec 30             	sub    $0x30,%esp
  105e30:	8b 45 08             	mov    0x8(%ebp),%eax
  105e33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e3c:	8b 45 10             	mov    0x10(%ebp),%eax
  105e3f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e45:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105e48:	73 42                	jae    105e8c <memmove+0x65>
  105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105e50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e56:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e59:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105e5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e5f:	c1 e8 02             	shr    $0x2,%eax
  105e62:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105e64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e6a:	89 d7                	mov    %edx,%edi
  105e6c:	89 c6                	mov    %eax,%esi
  105e6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105e70:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105e73:	83 e1 03             	and    $0x3,%ecx
  105e76:	74 02                	je     105e7a <memmove+0x53>
  105e78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105e7a:	89 f0                	mov    %esi,%eax
  105e7c:	89 fa                	mov    %edi,%edx
  105e7e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105e81:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105e84:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105e8a:	eb 36                	jmp    105ec2 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105e8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e8f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e95:	01 c2                	add    %eax,%edx
  105e97:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e9a:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ea0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105ea3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ea6:	89 c1                	mov    %eax,%ecx
  105ea8:	89 d8                	mov    %ebx,%eax
  105eaa:	89 d6                	mov    %edx,%esi
  105eac:	89 c7                	mov    %eax,%edi
  105eae:	fd                   	std    
  105eaf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105eb1:	fc                   	cld    
  105eb2:	89 f8                	mov    %edi,%eax
  105eb4:	89 f2                	mov    %esi,%edx
  105eb6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105eb9:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105ebc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105ec2:	83 c4 30             	add    $0x30,%esp
  105ec5:	5b                   	pop    %ebx
  105ec6:	5e                   	pop    %esi
  105ec7:	5f                   	pop    %edi
  105ec8:	5d                   	pop    %ebp
  105ec9:	c3                   	ret    

00105eca <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105eca:	55                   	push   %ebp
  105ecb:	89 e5                	mov    %esp,%ebp
  105ecd:	57                   	push   %edi
  105ece:	56                   	push   %esi
  105ecf:	83 ec 20             	sub    $0x20,%esp
  105ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ede:	8b 45 10             	mov    0x10(%ebp),%eax
  105ee1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ee7:	c1 e8 02             	shr    $0x2,%eax
  105eea:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105eec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ef2:	89 d7                	mov    %edx,%edi
  105ef4:	89 c6                	mov    %eax,%esi
  105ef6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105ef8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105efb:	83 e1 03             	and    $0x3,%ecx
  105efe:	74 02                	je     105f02 <memcpy+0x38>
  105f00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f02:	89 f0                	mov    %esi,%eax
  105f04:	89 fa                	mov    %edi,%edx
  105f06:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105f09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105f0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105f12:	83 c4 20             	add    $0x20,%esp
  105f15:	5e                   	pop    %esi
  105f16:	5f                   	pop    %edi
  105f17:	5d                   	pop    %ebp
  105f18:	c3                   	ret    

00105f19 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105f19:	55                   	push   %ebp
  105f1a:	89 e5                	mov    %esp,%ebp
  105f1c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  105f22:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f28:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105f2b:	eb 30                	jmp    105f5d <memcmp+0x44>
        if (*s1 != *s2) {
  105f2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f30:	0f b6 10             	movzbl (%eax),%edx
  105f33:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f36:	0f b6 00             	movzbl (%eax),%eax
  105f39:	38 c2                	cmp    %al,%dl
  105f3b:	74 18                	je     105f55 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f40:	0f b6 00             	movzbl (%eax),%eax
  105f43:	0f b6 d0             	movzbl %al,%edx
  105f46:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f49:	0f b6 00             	movzbl (%eax),%eax
  105f4c:	0f b6 c0             	movzbl %al,%eax
  105f4f:	29 c2                	sub    %eax,%edx
  105f51:	89 d0                	mov    %edx,%eax
  105f53:	eb 1a                	jmp    105f6f <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105f55:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105f59:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105f5d:	8b 45 10             	mov    0x10(%ebp),%eax
  105f60:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f63:	89 55 10             	mov    %edx,0x10(%ebp)
  105f66:	85 c0                	test   %eax,%eax
  105f68:	75 c3                	jne    105f2d <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105f6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105f6f:	c9                   	leave  
  105f70:	c3                   	ret    
