
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 cc 32 00 00       	call   1032f8 <memset>

    cons_init();                // init the console
  10002c:	e8 43 15 00 00       	call   101574 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 a0 34 10 00 	movl   $0x1034a0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 bc 34 10 00 	movl   $0x1034bc,(%esp)
  100046:	e8 c7 02 00 00       	call   100312 <cprintf>

    print_kerninfo();
  10004b:	e8 f6 07 00 00       	call   100846 <print_kerninfo>

    grade_backtrace();
  100050:	e8 86 00 00 00       	call   1000db <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 e4 28 00 00       	call   10293e <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 58 16 00 00       	call   1016b7 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 aa 17 00 00       	call   10180e <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 fe 0c 00 00       	call   100d67 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 b7 15 00 00       	call   101625 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  10006e:	eb fe                	jmp    10006e <kern_init+0x6e>

00100070 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  100073:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  100076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10007d:	00 
  10007e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100085:	00 
  100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10008d:	e8 f6 0b 00 00       	call   100c88 <mon_backtrace>
}
  100092:	c9                   	leave  
  100093:	c3                   	ret    

00100094 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100094:	55                   	push   %ebp
  100095:	89 e5                	mov    %esp,%ebp
  100097:	53                   	push   %ebx
  100098:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  10009b:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  10009e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000a1:	8d 55 08             	lea    0x8(%ebp),%edx
  1000a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1000a7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000af:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000b3:	89 04 24             	mov    %eax,(%esp)
  1000b6:	e8 b5 ff ff ff       	call   100070 <grade_backtrace2>
}
  1000bb:	83 c4 14             	add    $0x14,%esp
  1000be:	5b                   	pop    %ebx
  1000bf:	5d                   	pop    %ebp
  1000c0:	c3                   	ret    

001000c1 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c1:	55                   	push   %ebp
  1000c2:	89 e5                	mov    %esp,%ebp
  1000c4:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000c7:	8b 45 10             	mov    0x10(%ebp),%eax
  1000ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d1:	89 04 24             	mov    %eax,(%esp)
  1000d4:	e8 bb ff ff ff       	call   100094 <grade_backtrace1>
}
  1000d9:	c9                   	leave  
  1000da:	c3                   	ret    

001000db <grade_backtrace>:

void
grade_backtrace(void) {
  1000db:	55                   	push   %ebp
  1000dc:	89 e5                	mov    %esp,%ebp
  1000de:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e1:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000e6:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000ed:	ff 
  1000ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000f9:	e8 c3 ff ff ff       	call   1000c1 <grade_backtrace0>
}
  1000fe:	c9                   	leave  
  1000ff:	c3                   	ret    

00100100 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100100:	55                   	push   %ebp
  100101:	89 e5                	mov    %esp,%ebp
  100103:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100106:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100109:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10010c:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10010f:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100112:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100116:	0f b7 c0             	movzwl %ax,%eax
  100119:	83 e0 03             	and    $0x3,%eax
  10011c:	89 c2                	mov    %eax,%edx
  10011e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100123:	89 54 24 08          	mov    %edx,0x8(%esp)
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 c1 34 10 00 	movl   $0x1034c1,(%esp)
  100132:	e8 db 01 00 00       	call   100312 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100137:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10013b:	0f b7 d0             	movzwl %ax,%edx
  10013e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100143:	89 54 24 08          	mov    %edx,0x8(%esp)
  100147:	89 44 24 04          	mov    %eax,0x4(%esp)
  10014b:	c7 04 24 cf 34 10 00 	movl   $0x1034cf,(%esp)
  100152:	e8 bb 01 00 00       	call   100312 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100157:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  10015b:	0f b7 d0             	movzwl %ax,%edx
  10015e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100163:	89 54 24 08          	mov    %edx,0x8(%esp)
  100167:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016b:	c7 04 24 dd 34 10 00 	movl   $0x1034dd,(%esp)
  100172:	e8 9b 01 00 00       	call   100312 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  100177:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017b:	0f b7 d0             	movzwl %ax,%edx
  10017e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100183:	89 54 24 08          	mov    %edx,0x8(%esp)
  100187:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018b:	c7 04 24 eb 34 10 00 	movl   $0x1034eb,(%esp)
  100192:	e8 7b 01 00 00       	call   100312 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  100197:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019b:	0f b7 d0             	movzwl %ax,%edx
  10019e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a3:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ab:	c7 04 24 f9 34 10 00 	movl   $0x1034f9,(%esp)
  1001b2:	e8 5b 01 00 00       	call   100312 <cprintf>
    round ++;
  1001b7:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001bc:	83 c0 01             	add    $0x1,%eax
  1001bf:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c4:	c9                   	leave  
  1001c5:	c3                   	ret    

001001c6 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c6:	55                   	push   %ebp
  1001c7:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001c9:	5d                   	pop    %ebp
  1001ca:	c3                   	ret    

001001cb <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001cb:	55                   	push   %ebp
  1001cc:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  1001ce:	5d                   	pop    %ebp
  1001cf:	c3                   	ret    

001001d0 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001d0:	55                   	push   %ebp
  1001d1:	89 e5                	mov    %esp,%ebp
  1001d3:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001d6:	e8 25 ff ff ff       	call   100100 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001db:	c7 04 24 08 35 10 00 	movl   $0x103508,(%esp)
  1001e2:	e8 2b 01 00 00       	call   100312 <cprintf>
    lab1_switch_to_user();
  1001e7:	e8 da ff ff ff       	call   1001c6 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001ec:	e8 0f ff ff ff       	call   100100 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001f1:	c7 04 24 28 35 10 00 	movl   $0x103528,(%esp)
  1001f8:	e8 15 01 00 00       	call   100312 <cprintf>
    lab1_switch_to_kernel();
  1001fd:	e8 c9 ff ff ff       	call   1001cb <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100202:	e8 f9 fe ff ff       	call   100100 <lab1_print_cur_status>
}
  100207:	c9                   	leave  
  100208:	c3                   	ret    

00100209 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100209:	55                   	push   %ebp
  10020a:	89 e5                	mov    %esp,%ebp
  10020c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10020f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100213:	74 13                	je     100228 <readline+0x1f>
        cprintf("%s", prompt);
  100215:	8b 45 08             	mov    0x8(%ebp),%eax
  100218:	89 44 24 04          	mov    %eax,0x4(%esp)
  10021c:	c7 04 24 47 35 10 00 	movl   $0x103547,(%esp)
  100223:	e8 ea 00 00 00       	call   100312 <cprintf>
    }
    int i = 0, c;
  100228:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10022f:	e8 66 01 00 00       	call   10039a <getchar>
  100234:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100237:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10023b:	79 07                	jns    100244 <readline+0x3b>
            return NULL;
  10023d:	b8 00 00 00 00       	mov    $0x0,%eax
  100242:	eb 79                	jmp    1002bd <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100244:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100248:	7e 28                	jle    100272 <readline+0x69>
  10024a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100251:	7f 1f                	jg     100272 <readline+0x69>
            cputchar(c);
  100253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100256:	89 04 24             	mov    %eax,(%esp)
  100259:	e8 da 00 00 00       	call   100338 <cputchar>
            buf[i ++] = c;
  10025e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100261:	8d 50 01             	lea    0x1(%eax),%edx
  100264:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100267:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10026a:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100270:	eb 46                	jmp    1002b8 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  100272:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100276:	75 17                	jne    10028f <readline+0x86>
  100278:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10027c:	7e 11                	jle    10028f <readline+0x86>
            cputchar(c);
  10027e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100281:	89 04 24             	mov    %eax,(%esp)
  100284:	e8 af 00 00 00       	call   100338 <cputchar>
            i --;
  100289:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10028d:	eb 29                	jmp    1002b8 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  10028f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100293:	74 06                	je     10029b <readline+0x92>
  100295:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  100299:	75 1d                	jne    1002b8 <readline+0xaf>
            cputchar(c);
  10029b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10029e:	89 04 24             	mov    %eax,(%esp)
  1002a1:	e8 92 00 00 00       	call   100338 <cputchar>
            buf[i] = '\0';
  1002a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002a9:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1002ae:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002b1:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1002b6:	eb 05                	jmp    1002bd <readline+0xb4>
        }
    }
  1002b8:	e9 72 ff ff ff       	jmp    10022f <readline+0x26>
}
  1002bd:	c9                   	leave  
  1002be:	c3                   	ret    

001002bf <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002bf:	55                   	push   %ebp
  1002c0:	89 e5                	mov    %esp,%ebp
  1002c2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c8:	89 04 24             	mov    %eax,(%esp)
  1002cb:	e8 d0 12 00 00       	call   1015a0 <cons_putc>
    (*cnt) ++;
  1002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002d3:	8b 00                	mov    (%eax),%eax
  1002d5:	8d 50 01             	lea    0x1(%eax),%edx
  1002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002db:	89 10                	mov    %edx,(%eax)
}
  1002dd:	c9                   	leave  
  1002de:	c3                   	ret    

001002df <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  1002df:	55                   	push   %ebp
  1002e0:	89 e5                	mov    %esp,%ebp
  1002e2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1002fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1002fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100301:	c7 04 24 bf 02 10 00 	movl   $0x1002bf,(%esp)
  100308:	e8 04 28 00 00       	call   102b11 <vprintfmt>
    return cnt;
  10030d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100310:	c9                   	leave  
  100311:	c3                   	ret    

00100312 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100312:	55                   	push   %ebp
  100313:	89 e5                	mov    %esp,%ebp
  100315:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100318:	8d 45 0c             	lea    0xc(%ebp),%eax
  10031b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10031e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100321:	89 44 24 04          	mov    %eax,0x4(%esp)
  100325:	8b 45 08             	mov    0x8(%ebp),%eax
  100328:	89 04 24             	mov    %eax,(%esp)
  10032b:	e8 af ff ff ff       	call   1002df <vcprintf>
  100330:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100333:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100336:	c9                   	leave  
  100337:	c3                   	ret    

00100338 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100338:	55                   	push   %ebp
  100339:	89 e5                	mov    %esp,%ebp
  10033b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10033e:	8b 45 08             	mov    0x8(%ebp),%eax
  100341:	89 04 24             	mov    %eax,(%esp)
  100344:	e8 57 12 00 00       	call   1015a0 <cons_putc>
}
  100349:	c9                   	leave  
  10034a:	c3                   	ret    

0010034b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10034b:	55                   	push   %ebp
  10034c:	89 e5                	mov    %esp,%ebp
  10034e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100351:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100358:	eb 13                	jmp    10036d <cputs+0x22>
        cputch(c, &cnt);
  10035a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10035e:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100361:	89 54 24 04          	mov    %edx,0x4(%esp)
  100365:	89 04 24             	mov    %eax,(%esp)
  100368:	e8 52 ff ff ff       	call   1002bf <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  10036d:	8b 45 08             	mov    0x8(%ebp),%eax
  100370:	8d 50 01             	lea    0x1(%eax),%edx
  100373:	89 55 08             	mov    %edx,0x8(%ebp)
  100376:	0f b6 00             	movzbl (%eax),%eax
  100379:	88 45 f7             	mov    %al,-0x9(%ebp)
  10037c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100380:	75 d8                	jne    10035a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100382:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100385:	89 44 24 04          	mov    %eax,0x4(%esp)
  100389:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100390:	e8 2a ff ff ff       	call   1002bf <cputch>
    return cnt;
  100395:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100398:	c9                   	leave  
  100399:	c3                   	ret    

0010039a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10039a:	55                   	push   %ebp
  10039b:	89 e5                	mov    %esp,%ebp
  10039d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003a0:	e8 24 12 00 00       	call   1015c9 <cons_getc>
  1003a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003ac:	74 f2                	je     1003a0 <getchar+0x6>
        /* do nothing */;
    return c;
  1003ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003b1:	c9                   	leave  
  1003b2:	c3                   	ret    

001003b3 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003b3:	55                   	push   %ebp
  1003b4:	89 e5                	mov    %esp,%ebp
  1003b6:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003bc:	8b 00                	mov    (%eax),%eax
  1003be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  1003c4:	8b 00                	mov    (%eax),%eax
  1003c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1003d0:	e9 d2 00 00 00       	jmp    1004a7 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1003d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1003d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1003db:	01 d0                	add    %edx,%eax
  1003dd:	89 c2                	mov    %eax,%edx
  1003df:	c1 ea 1f             	shr    $0x1f,%edx
  1003e2:	01 d0                	add    %edx,%eax
  1003e4:	d1 f8                	sar    %eax
  1003e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1003e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003ec:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1003ef:	eb 04                	jmp    1003f5 <stab_binsearch+0x42>
            m --;
  1003f1:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1003f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1003fb:	7c 1f                	jl     10041c <stab_binsearch+0x69>
  1003fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100400:	89 d0                	mov    %edx,%eax
  100402:	01 c0                	add    %eax,%eax
  100404:	01 d0                	add    %edx,%eax
  100406:	c1 e0 02             	shl    $0x2,%eax
  100409:	89 c2                	mov    %eax,%edx
  10040b:	8b 45 08             	mov    0x8(%ebp),%eax
  10040e:	01 d0                	add    %edx,%eax
  100410:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100414:	0f b6 c0             	movzbl %al,%eax
  100417:	3b 45 14             	cmp    0x14(%ebp),%eax
  10041a:	75 d5                	jne    1003f1 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10041c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10041f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100422:	7d 0b                	jge    10042f <stab_binsearch+0x7c>
            l = true_m + 1;
  100424:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100427:	83 c0 01             	add    $0x1,%eax
  10042a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10042d:	eb 78                	jmp    1004a7 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  10042f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100436:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100439:	89 d0                	mov    %edx,%eax
  10043b:	01 c0                	add    %eax,%eax
  10043d:	01 d0                	add    %edx,%eax
  10043f:	c1 e0 02             	shl    $0x2,%eax
  100442:	89 c2                	mov    %eax,%edx
  100444:	8b 45 08             	mov    0x8(%ebp),%eax
  100447:	01 d0                	add    %edx,%eax
  100449:	8b 40 08             	mov    0x8(%eax),%eax
  10044c:	3b 45 18             	cmp    0x18(%ebp),%eax
  10044f:	73 13                	jae    100464 <stab_binsearch+0xb1>
            *region_left = m;
  100451:	8b 45 0c             	mov    0xc(%ebp),%eax
  100454:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100457:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100459:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10045c:	83 c0 01             	add    $0x1,%eax
  10045f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100462:	eb 43                	jmp    1004a7 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100464:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100467:	89 d0                	mov    %edx,%eax
  100469:	01 c0                	add    %eax,%eax
  10046b:	01 d0                	add    %edx,%eax
  10046d:	c1 e0 02             	shl    $0x2,%eax
  100470:	89 c2                	mov    %eax,%edx
  100472:	8b 45 08             	mov    0x8(%ebp),%eax
  100475:	01 d0                	add    %edx,%eax
  100477:	8b 40 08             	mov    0x8(%eax),%eax
  10047a:	3b 45 18             	cmp    0x18(%ebp),%eax
  10047d:	76 16                	jbe    100495 <stab_binsearch+0xe2>
            *region_right = m - 1;
  10047f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100482:	8d 50 ff             	lea    -0x1(%eax),%edx
  100485:	8b 45 10             	mov    0x10(%ebp),%eax
  100488:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10048a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10048d:	83 e8 01             	sub    $0x1,%eax
  100490:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100493:	eb 12                	jmp    1004a7 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100495:	8b 45 0c             	mov    0xc(%ebp),%eax
  100498:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049b:	89 10                	mov    %edx,(%eax)
            l = m;
  10049d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004a3:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004ad:	0f 8e 22 ff ff ff    	jle    1003d5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004b7:	75 0f                	jne    1004c8 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004bc:	8b 00                	mov    (%eax),%eax
  1004be:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004c1:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c4:	89 10                	mov    %edx,(%eax)
  1004c6:	eb 3f                	jmp    100507 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004c8:	8b 45 10             	mov    0x10(%ebp),%eax
  1004cb:	8b 00                	mov    (%eax),%eax
  1004cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1004d0:	eb 04                	jmp    1004d6 <stab_binsearch+0x123>
  1004d2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d9:	8b 00                	mov    (%eax),%eax
  1004db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004de:	7d 1f                	jge    1004ff <stab_binsearch+0x14c>
  1004e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004e3:	89 d0                	mov    %edx,%eax
  1004e5:	01 c0                	add    %eax,%eax
  1004e7:	01 d0                	add    %edx,%eax
  1004e9:	c1 e0 02             	shl    $0x2,%eax
  1004ec:	89 c2                	mov    %eax,%edx
  1004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1004f1:	01 d0                	add    %edx,%eax
  1004f3:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004f7:	0f b6 c0             	movzbl %al,%eax
  1004fa:	3b 45 14             	cmp    0x14(%ebp),%eax
  1004fd:	75 d3                	jne    1004d2 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100505:	89 10                	mov    %edx,(%eax)
    }
}
  100507:	c9                   	leave  
  100508:	c3                   	ret    

00100509 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100509:	55                   	push   %ebp
  10050a:	89 e5                	mov    %esp,%ebp
  10050c:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100512:	c7 00 4c 35 10 00    	movl   $0x10354c,(%eax)
    info->eip_line = 0;
  100518:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100522:	8b 45 0c             	mov    0xc(%ebp),%eax
  100525:	c7 40 08 4c 35 10 00 	movl   $0x10354c,0x8(%eax)
    info->eip_fn_namelen = 9;
  10052c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052f:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100536:	8b 45 0c             	mov    0xc(%ebp),%eax
  100539:	8b 55 08             	mov    0x8(%ebp),%edx
  10053c:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10053f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100542:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100549:	c7 45 f4 cc 3d 10 00 	movl   $0x103dcc,-0xc(%ebp)
    stab_end = __STAB_END__;
  100550:	c7 45 f0 d0 b4 10 00 	movl   $0x10b4d0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100557:	c7 45 ec d1 b4 10 00 	movl   $0x10b4d1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10055e:	c7 45 e8 c1 d4 10 00 	movl   $0x10d4c1,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100565:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100568:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10056b:	76 0d                	jbe    10057a <debuginfo_eip+0x71>
  10056d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100570:	83 e8 01             	sub    $0x1,%eax
  100573:	0f b6 00             	movzbl (%eax),%eax
  100576:	84 c0                	test   %al,%al
  100578:	74 0a                	je     100584 <debuginfo_eip+0x7b>
        return -1;
  10057a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10057f:	e9 c0 02 00 00       	jmp    100844 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100584:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10058b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10058e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100591:	29 c2                	sub    %eax,%edx
  100593:	89 d0                	mov    %edx,%eax
  100595:	c1 f8 02             	sar    $0x2,%eax
  100598:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  10059e:	83 e8 01             	sub    $0x1,%eax
  1005a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005ab:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005b2:	00 
  1005b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005c4:	89 04 24             	mov    %eax,(%esp)
  1005c7:	e8 e7 fd ff ff       	call   1003b3 <stab_binsearch>
    if (lfile == 0)
  1005cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005cf:	85 c0                	test   %eax,%eax
  1005d1:	75 0a                	jne    1005dd <debuginfo_eip+0xd4>
        return -1;
  1005d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005d8:	e9 67 02 00 00       	jmp    100844 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1005dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1005e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005f0:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1005f7:	00 
  1005f8:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005ff:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100602:	89 44 24 04          	mov    %eax,0x4(%esp)
  100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100609:	89 04 24             	mov    %eax,(%esp)
  10060c:	e8 a2 fd ff ff       	call   1003b3 <stab_binsearch>

    if (lfun <= rfun) {
  100611:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100614:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100617:	39 c2                	cmp    %eax,%edx
  100619:	7f 7c                	jg     100697 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10061b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10061e:	89 c2                	mov    %eax,%edx
  100620:	89 d0                	mov    %edx,%eax
  100622:	01 c0                	add    %eax,%eax
  100624:	01 d0                	add    %edx,%eax
  100626:	c1 e0 02             	shl    $0x2,%eax
  100629:	89 c2                	mov    %eax,%edx
  10062b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10062e:	01 d0                	add    %edx,%eax
  100630:	8b 10                	mov    (%eax),%edx
  100632:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100635:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100638:	29 c1                	sub    %eax,%ecx
  10063a:	89 c8                	mov    %ecx,%eax
  10063c:	39 c2                	cmp    %eax,%edx
  10063e:	73 22                	jae    100662 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100640:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100643:	89 c2                	mov    %eax,%edx
  100645:	89 d0                	mov    %edx,%eax
  100647:	01 c0                	add    %eax,%eax
  100649:	01 d0                	add    %edx,%eax
  10064b:	c1 e0 02             	shl    $0x2,%eax
  10064e:	89 c2                	mov    %eax,%edx
  100650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100653:	01 d0                	add    %edx,%eax
  100655:	8b 10                	mov    (%eax),%edx
  100657:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10065a:	01 c2                	add    %eax,%edx
  10065c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10065f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100662:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100665:	89 c2                	mov    %eax,%edx
  100667:	89 d0                	mov    %edx,%eax
  100669:	01 c0                	add    %eax,%eax
  10066b:	01 d0                	add    %edx,%eax
  10066d:	c1 e0 02             	shl    $0x2,%eax
  100670:	89 c2                	mov    %eax,%edx
  100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100675:	01 d0                	add    %edx,%eax
  100677:	8b 50 08             	mov    0x8(%eax),%edx
  10067a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10067d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100680:	8b 45 0c             	mov    0xc(%ebp),%eax
  100683:	8b 40 10             	mov    0x10(%eax),%eax
  100686:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100689:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10068c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10068f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100692:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100695:	eb 15                	jmp    1006ac <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100697:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069a:	8b 55 08             	mov    0x8(%ebp),%edx
  10069d:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006af:	8b 40 08             	mov    0x8(%eax),%eax
  1006b2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006b9:	00 
  1006ba:	89 04 24             	mov    %eax,(%esp)
  1006bd:	e8 aa 2a 00 00       	call   10316c <strfind>
  1006c2:	89 c2                	mov    %eax,%edx
  1006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c7:	8b 40 08             	mov    0x8(%eax),%eax
  1006ca:	29 c2                	sub    %eax,%edx
  1006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006cf:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006d9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1006e0:	00 
  1006e1:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1006e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006e8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006f2:	89 04 24             	mov    %eax,(%esp)
  1006f5:	e8 b9 fc ff ff       	call   1003b3 <stab_binsearch>
    if (lline <= rline) {
  1006fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1006fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100700:	39 c2                	cmp    %eax,%edx
  100702:	7f 24                	jg     100728 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100704:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100707:	89 c2                	mov    %eax,%edx
  100709:	89 d0                	mov    %edx,%eax
  10070b:	01 c0                	add    %eax,%eax
  10070d:	01 d0                	add    %edx,%eax
  10070f:	c1 e0 02             	shl    $0x2,%eax
  100712:	89 c2                	mov    %eax,%edx
  100714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100717:	01 d0                	add    %edx,%eax
  100719:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10071d:	0f b7 d0             	movzwl %ax,%edx
  100720:	8b 45 0c             	mov    0xc(%ebp),%eax
  100723:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100726:	eb 13                	jmp    10073b <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10072d:	e9 12 01 00 00       	jmp    100844 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100732:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100735:	83 e8 01             	sub    $0x1,%eax
  100738:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10073b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10073e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100741:	39 c2                	cmp    %eax,%edx
  100743:	7c 56                	jl     10079b <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100745:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	89 d0                	mov    %edx,%eax
  10074c:	01 c0                	add    %eax,%eax
  10074e:	01 d0                	add    %edx,%eax
  100750:	c1 e0 02             	shl    $0x2,%eax
  100753:	89 c2                	mov    %eax,%edx
  100755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100758:	01 d0                	add    %edx,%eax
  10075a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10075e:	3c 84                	cmp    $0x84,%al
  100760:	74 39                	je     10079b <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100762:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100765:	89 c2                	mov    %eax,%edx
  100767:	89 d0                	mov    %edx,%eax
  100769:	01 c0                	add    %eax,%eax
  10076b:	01 d0                	add    %edx,%eax
  10076d:	c1 e0 02             	shl    $0x2,%eax
  100770:	89 c2                	mov    %eax,%edx
  100772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100775:	01 d0                	add    %edx,%eax
  100777:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10077b:	3c 64                	cmp    $0x64,%al
  10077d:	75 b3                	jne    100732 <debuginfo_eip+0x229>
  10077f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100782:	89 c2                	mov    %eax,%edx
  100784:	89 d0                	mov    %edx,%eax
  100786:	01 c0                	add    %eax,%eax
  100788:	01 d0                	add    %edx,%eax
  10078a:	c1 e0 02             	shl    $0x2,%eax
  10078d:	89 c2                	mov    %eax,%edx
  10078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100792:	01 d0                	add    %edx,%eax
  100794:	8b 40 08             	mov    0x8(%eax),%eax
  100797:	85 c0                	test   %eax,%eax
  100799:	74 97                	je     100732 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10079b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10079e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007a1:	39 c2                	cmp    %eax,%edx
  1007a3:	7c 46                	jl     1007eb <debuginfo_eip+0x2e2>
  1007a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007a8:	89 c2                	mov    %eax,%edx
  1007aa:	89 d0                	mov    %edx,%eax
  1007ac:	01 c0                	add    %eax,%eax
  1007ae:	01 d0                	add    %edx,%eax
  1007b0:	c1 e0 02             	shl    $0x2,%eax
  1007b3:	89 c2                	mov    %eax,%edx
  1007b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007b8:	01 d0                	add    %edx,%eax
  1007ba:	8b 10                	mov    (%eax),%edx
  1007bc:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007c2:	29 c1                	sub    %eax,%ecx
  1007c4:	89 c8                	mov    %ecx,%eax
  1007c6:	39 c2                	cmp    %eax,%edx
  1007c8:	73 21                	jae    1007eb <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007cd:	89 c2                	mov    %eax,%edx
  1007cf:	89 d0                	mov    %edx,%eax
  1007d1:	01 c0                	add    %eax,%eax
  1007d3:	01 d0                	add    %edx,%eax
  1007d5:	c1 e0 02             	shl    $0x2,%eax
  1007d8:	89 c2                	mov    %eax,%edx
  1007da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007dd:	01 d0                	add    %edx,%eax
  1007df:	8b 10                	mov    (%eax),%edx
  1007e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007e4:	01 c2                	add    %eax,%edx
  1007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007e9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1007eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1007ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007f1:	39 c2                	cmp    %eax,%edx
  1007f3:	7d 4a                	jge    10083f <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  1007f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007f8:	83 c0 01             	add    $0x1,%eax
  1007fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1007fe:	eb 18                	jmp    100818 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100800:	8b 45 0c             	mov    0xc(%ebp),%eax
  100803:	8b 40 14             	mov    0x14(%eax),%eax
  100806:	8d 50 01             	lea    0x1(%eax),%edx
  100809:	8b 45 0c             	mov    0xc(%ebp),%eax
  10080c:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  10080f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100812:	83 c0 01             	add    $0x1,%eax
  100815:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100818:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10081b:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10081e:	39 c2                	cmp    %eax,%edx
  100820:	7d 1d                	jge    10083f <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100822:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100825:	89 c2                	mov    %eax,%edx
  100827:	89 d0                	mov    %edx,%eax
  100829:	01 c0                	add    %eax,%eax
  10082b:	01 d0                	add    %edx,%eax
  10082d:	c1 e0 02             	shl    $0x2,%eax
  100830:	89 c2                	mov    %eax,%edx
  100832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100835:	01 d0                	add    %edx,%eax
  100837:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10083b:	3c a0                	cmp    $0xa0,%al
  10083d:	74 c1                	je     100800 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10083f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100844:	c9                   	leave  
  100845:	c3                   	ret    

00100846 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100846:	55                   	push   %ebp
  100847:	89 e5                	mov    %esp,%ebp
  100849:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10084c:	c7 04 24 56 35 10 00 	movl   $0x103556,(%esp)
  100853:	e8 ba fa ff ff       	call   100312 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100858:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10085f:	00 
  100860:	c7 04 24 6f 35 10 00 	movl   $0x10356f,(%esp)
  100867:	e8 a6 fa ff ff       	call   100312 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10086c:	c7 44 24 04 81 34 10 	movl   $0x103481,0x4(%esp)
  100873:	00 
  100874:	c7 04 24 87 35 10 00 	movl   $0x103587,(%esp)
  10087b:	e8 92 fa ff ff       	call   100312 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100880:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100887:	00 
  100888:	c7 04 24 9f 35 10 00 	movl   $0x10359f,(%esp)
  10088f:	e8 7e fa ff ff       	call   100312 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100894:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  10089b:	00 
  10089c:	c7 04 24 b7 35 10 00 	movl   $0x1035b7,(%esp)
  1008a3:	e8 6a fa ff ff       	call   100312 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008a8:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  1008ad:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008b3:	b8 00 00 10 00       	mov    $0x100000,%eax
  1008b8:	29 c2                	sub    %eax,%edx
  1008ba:	89 d0                	mov    %edx,%eax
  1008bc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008c2:	85 c0                	test   %eax,%eax
  1008c4:	0f 48 c2             	cmovs  %edx,%eax
  1008c7:	c1 f8 0a             	sar    $0xa,%eax
  1008ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008ce:	c7 04 24 d0 35 10 00 	movl   $0x1035d0,(%esp)
  1008d5:	e8 38 fa ff ff       	call   100312 <cprintf>
}
  1008da:	c9                   	leave  
  1008db:	c3                   	ret    

001008dc <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1008dc:	55                   	push   %ebp
  1008dd:	89 e5                	mov    %esp,%ebp
  1008df:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1008e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1008ef:	89 04 24             	mov    %eax,(%esp)
  1008f2:	e8 12 fc ff ff       	call   100509 <debuginfo_eip>
  1008f7:	85 c0                	test   %eax,%eax
  1008f9:	74 15                	je     100910 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100902:	c7 04 24 fa 35 10 00 	movl   $0x1035fa,(%esp)
  100909:	e8 04 fa ff ff       	call   100312 <cprintf>
  10090e:	eb 6d                	jmp    10097d <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100910:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100917:	eb 1c                	jmp    100935 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  100919:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10091c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10091f:	01 d0                	add    %edx,%eax
  100921:	0f b6 00             	movzbl (%eax),%eax
  100924:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10092a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10092d:	01 ca                	add    %ecx,%edx
  10092f:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100935:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100938:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10093b:	7f dc                	jg     100919 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  10093d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100946:	01 d0                	add    %edx,%eax
  100948:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  10094b:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10094e:	8b 55 08             	mov    0x8(%ebp),%edx
  100951:	89 d1                	mov    %edx,%ecx
  100953:	29 c1                	sub    %eax,%ecx
  100955:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100958:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10095b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10095f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100965:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100969:	89 54 24 08          	mov    %edx,0x8(%esp)
  10096d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100971:	c7 04 24 16 36 10 00 	movl   $0x103616,(%esp)
  100978:	e8 95 f9 ff ff       	call   100312 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  10097d:	c9                   	leave  
  10097e:	c3                   	ret    

0010097f <read_eip>:

static __noinline uint32_t
read_eip(void) {
  10097f:	55                   	push   %ebp
  100980:	89 e5                	mov    %esp,%ebp
  100982:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100985:	8b 45 04             	mov    0x4(%ebp),%eax
  100988:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  10098b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10098e:	c9                   	leave  
  10098f:	c3                   	ret    

00100990 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100990:	55                   	push   %ebp
  100991:	89 e5                	mov    %esp,%ebp
  100993:	53                   	push   %ebx
  100994:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100997:	89 e8                	mov    %ebp,%eax
  100999:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  10099c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */

    uint32_t ebp = read_ebp();
  10099f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  1009a2:	e8 d8 ff ff ff       	call   10097f <read_eip>
  1009a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    for(i = 0;ebp != 0&&i < STACKFRAME_DEPTH;i++) {
  1009aa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009b1:	e9 81 00 00 00       	jmp    100a37 <print_stackframe+0xa7>
        // 参数位置定位
        uint32_t *arguments = (uint32_t*)ebp + 2;
  1009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009b9:	83 c0 08             	add    $0x8,%eax
  1009bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // 显示传入的参数
        cprintf("ebp:0x%08x eip:0x%08x args:0x%08x 0x%08x 0x%08x 0x%08x",ebp,eip,arguments[0],arguments[1],arguments[2],arguments[3]);
  1009bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009c2:	83 c0 0c             	add    $0xc,%eax
  1009c5:	8b 18                	mov    (%eax),%ebx
  1009c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009ca:	83 c0 08             	add    $0x8,%eax
  1009cd:	8b 08                	mov    (%eax),%ecx
  1009cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009d2:	83 c0 04             	add    $0x4,%eax
  1009d5:	8b 10                	mov    (%eax),%edx
  1009d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009da:	8b 00                	mov    (%eax),%eax
  1009dc:	89 5c 24 18          	mov    %ebx,0x18(%esp)
  1009e0:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1009e4:	89 54 24 10          	mov    %edx,0x10(%esp)
  1009e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1009ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009fa:	c7 04 24 28 36 10 00 	movl   $0x103628,(%esp)
  100a01:	e8 0c f9 ff ff       	call   100312 <cprintf>
        cprintf("\n");
  100a06:	c7 04 24 5f 36 10 00 	movl   $0x10365f,(%esp)
  100a0d:	e8 00 f9 ff ff       	call   100312 <cprintf>
        print_debuginfo(eip - 1);
  100a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a15:	83 e8 01             	sub    $0x1,%eax
  100a18:	89 04 24             	mov    %eax,(%esp)
  100a1b:	e8 bc fe ff ff       	call   1008dc <print_debuginfo>
        // 寻找上一个调用者栈低位置，即模拟函数返回的过程
        eip = ((uint32_t*)ebp)[1];
  100a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a23:	83 c0 04             	add    $0x4,%eax
  100a26:	8b 00                	mov    (%eax),%eax
  100a28:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t*)ebp)[0];
  100a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a2e:	8b 00                	mov    (%eax),%eax
  100a30:	89 45 f4             	mov    %eax,-0xc(%ebp)
      */

    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    int i;
    for(i = 0;ebp != 0&&i < STACKFRAME_DEPTH;i++) {
  100a33:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a3b:	74 0a                	je     100a47 <print_stackframe+0xb7>
  100a3d:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a41:	0f 8e 6f ff ff ff    	jle    1009b6 <print_stackframe+0x26>
        // 寻找上一个调用者栈低位置，即模拟函数返回的过程
        eip = ((uint32_t*)ebp)[1];
        ebp = ((uint32_t*)ebp)[0];
    }

}
  100a47:	83 c4 44             	add    $0x44,%esp
  100a4a:	5b                   	pop    %ebx
  100a4b:	5d                   	pop    %ebp
  100a4c:	c3                   	ret    

00100a4d <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a4d:	55                   	push   %ebp
  100a4e:	89 e5                	mov    %esp,%ebp
  100a50:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a5a:	eb 0c                	jmp    100a68 <parse+0x1b>
            *buf ++ = '\0';
  100a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  100a5f:	8d 50 01             	lea    0x1(%eax),%edx
  100a62:	89 55 08             	mov    %edx,0x8(%ebp)
  100a65:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a68:	8b 45 08             	mov    0x8(%ebp),%eax
  100a6b:	0f b6 00             	movzbl (%eax),%eax
  100a6e:	84 c0                	test   %al,%al
  100a70:	74 1d                	je     100a8f <parse+0x42>
  100a72:	8b 45 08             	mov    0x8(%ebp),%eax
  100a75:	0f b6 00             	movzbl (%eax),%eax
  100a78:	0f be c0             	movsbl %al,%eax
  100a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a7f:	c7 04 24 e4 36 10 00 	movl   $0x1036e4,(%esp)
  100a86:	e8 ae 26 00 00       	call   103139 <strchr>
  100a8b:	85 c0                	test   %eax,%eax
  100a8d:	75 cd                	jne    100a5c <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  100a92:	0f b6 00             	movzbl (%eax),%eax
  100a95:	84 c0                	test   %al,%al
  100a97:	75 02                	jne    100a9b <parse+0x4e>
            break;
  100a99:	eb 67                	jmp    100b02 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100a9b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100a9f:	75 14                	jne    100ab5 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100aa1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100aa8:	00 
  100aa9:	c7 04 24 e9 36 10 00 	movl   $0x1036e9,(%esp)
  100ab0:	e8 5d f8 ff ff       	call   100312 <cprintf>
        }
        argv[argc ++] = buf;
  100ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab8:	8d 50 01             	lea    0x1(%eax),%edx
  100abb:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100abe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ac8:	01 c2                	add    %eax,%edx
  100aca:	8b 45 08             	mov    0x8(%ebp),%eax
  100acd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100acf:	eb 04                	jmp    100ad5 <parse+0x88>
            buf ++;
  100ad1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  100ad8:	0f b6 00             	movzbl (%eax),%eax
  100adb:	84 c0                	test   %al,%al
  100add:	74 1d                	je     100afc <parse+0xaf>
  100adf:	8b 45 08             	mov    0x8(%ebp),%eax
  100ae2:	0f b6 00             	movzbl (%eax),%eax
  100ae5:	0f be c0             	movsbl %al,%eax
  100ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aec:	c7 04 24 e4 36 10 00 	movl   $0x1036e4,(%esp)
  100af3:	e8 41 26 00 00       	call   103139 <strchr>
  100af8:	85 c0                	test   %eax,%eax
  100afa:	74 d5                	je     100ad1 <parse+0x84>
            buf ++;
        }
    }
  100afc:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100afd:	e9 66 ff ff ff       	jmp    100a68 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b05:	c9                   	leave  
  100b06:	c3                   	ret    

00100b07 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b07:	55                   	push   %ebp
  100b08:	89 e5                	mov    %esp,%ebp
  100b0a:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b0d:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b14:	8b 45 08             	mov    0x8(%ebp),%eax
  100b17:	89 04 24             	mov    %eax,(%esp)
  100b1a:	e8 2e ff ff ff       	call   100a4d <parse>
  100b1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b26:	75 0a                	jne    100b32 <runcmd+0x2b>
        return 0;
  100b28:	b8 00 00 00 00       	mov    $0x0,%eax
  100b2d:	e9 85 00 00 00       	jmp    100bb7 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b39:	eb 5c                	jmp    100b97 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b3b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b41:	89 d0                	mov    %edx,%eax
  100b43:	01 c0                	add    %eax,%eax
  100b45:	01 d0                	add    %edx,%eax
  100b47:	c1 e0 02             	shl    $0x2,%eax
  100b4a:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b4f:	8b 00                	mov    (%eax),%eax
  100b51:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b55:	89 04 24             	mov    %eax,(%esp)
  100b58:	e8 3d 25 00 00       	call   10309a <strcmp>
  100b5d:	85 c0                	test   %eax,%eax
  100b5f:	75 32                	jne    100b93 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b64:	89 d0                	mov    %edx,%eax
  100b66:	01 c0                	add    %eax,%eax
  100b68:	01 d0                	add    %edx,%eax
  100b6a:	c1 e0 02             	shl    $0x2,%eax
  100b6d:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b72:	8b 40 08             	mov    0x8(%eax),%eax
  100b75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100b78:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  100b7e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b82:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100b85:	83 c2 04             	add    $0x4,%edx
  100b88:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b8c:	89 0c 24             	mov    %ecx,(%esp)
  100b8f:	ff d0                	call   *%eax
  100b91:	eb 24                	jmp    100bb7 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b9a:	83 f8 02             	cmp    $0x2,%eax
  100b9d:	76 9c                	jbe    100b3b <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100b9f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ba6:	c7 04 24 07 37 10 00 	movl   $0x103707,(%esp)
  100bad:	e8 60 f7 ff ff       	call   100312 <cprintf>
    return 0;
  100bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bb7:	c9                   	leave  
  100bb8:	c3                   	ret    

00100bb9 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bb9:	55                   	push   %ebp
  100bba:	89 e5                	mov    %esp,%ebp
  100bbc:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bbf:	c7 04 24 20 37 10 00 	movl   $0x103720,(%esp)
  100bc6:	e8 47 f7 ff ff       	call   100312 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100bcb:	c7 04 24 48 37 10 00 	movl   $0x103748,(%esp)
  100bd2:	e8 3b f7 ff ff       	call   100312 <cprintf>

    if (tf != NULL) {
  100bd7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100bdb:	74 0b                	je     100be8 <kmonitor+0x2f>
        print_trapframe(tf);
  100bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  100be0:	89 04 24             	mov    %eax,(%esp)
  100be3:	e8 dd 0d 00 00       	call   1019c5 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100be8:	c7 04 24 6d 37 10 00 	movl   $0x10376d,(%esp)
  100bef:	e8 15 f6 ff ff       	call   100209 <readline>
  100bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100bf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100bfb:	74 18                	je     100c15 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c07:	89 04 24             	mov    %eax,(%esp)
  100c0a:	e8 f8 fe ff ff       	call   100b07 <runcmd>
  100c0f:	85 c0                	test   %eax,%eax
  100c11:	79 02                	jns    100c15 <kmonitor+0x5c>
                break;
  100c13:	eb 02                	jmp    100c17 <kmonitor+0x5e>
            }
        }
    }
  100c15:	eb d1                	jmp    100be8 <kmonitor+0x2f>
}
  100c17:	c9                   	leave  
  100c18:	c3                   	ret    

00100c19 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c19:	55                   	push   %ebp
  100c1a:	89 e5                	mov    %esp,%ebp
  100c1c:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c26:	eb 3f                	jmp    100c67 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c2b:	89 d0                	mov    %edx,%eax
  100c2d:	01 c0                	add    %eax,%eax
  100c2f:	01 d0                	add    %edx,%eax
  100c31:	c1 e0 02             	shl    $0x2,%eax
  100c34:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c39:	8b 48 04             	mov    0x4(%eax),%ecx
  100c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c3f:	89 d0                	mov    %edx,%eax
  100c41:	01 c0                	add    %eax,%eax
  100c43:	01 d0                	add    %edx,%eax
  100c45:	c1 e0 02             	shl    $0x2,%eax
  100c48:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c4d:	8b 00                	mov    (%eax),%eax
  100c4f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c57:	c7 04 24 71 37 10 00 	movl   $0x103771,(%esp)
  100c5e:	e8 af f6 ff ff       	call   100312 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c6a:	83 f8 02             	cmp    $0x2,%eax
  100c6d:	76 b9                	jbe    100c28 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c74:	c9                   	leave  
  100c75:	c3                   	ret    

00100c76 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100c76:	55                   	push   %ebp
  100c77:	89 e5                	mov    %esp,%ebp
  100c79:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100c7c:	e8 c5 fb ff ff       	call   100846 <print_kerninfo>
    return 0;
  100c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c86:	c9                   	leave  
  100c87:	c3                   	ret    

00100c88 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100c88:	55                   	push   %ebp
  100c89:	89 e5                	mov    %esp,%ebp
  100c8b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100c8e:	e8 fd fc ff ff       	call   100990 <print_stackframe>
    return 0;
  100c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c98:	c9                   	leave  
  100c99:	c3                   	ret    

00100c9a <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100c9a:	55                   	push   %ebp
  100c9b:	89 e5                	mov    %esp,%ebp
  100c9d:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ca0:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  100ca5:	85 c0                	test   %eax,%eax
  100ca7:	74 02                	je     100cab <__panic+0x11>
        goto panic_dead;
  100ca9:	eb 59                	jmp    100d04 <__panic+0x6a>
    }
    is_panic = 1;
  100cab:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  100cb2:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cb5:	8d 45 14             	lea    0x14(%ebp),%eax
  100cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  100cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cc9:	c7 04 24 7a 37 10 00 	movl   $0x10377a,(%esp)
  100cd0:	e8 3d f6 ff ff       	call   100312 <cprintf>
    vcprintf(fmt, ap);
  100cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  100cdf:	89 04 24             	mov    %eax,(%esp)
  100ce2:	e8 f8 f5 ff ff       	call   1002df <vcprintf>
    cprintf("\n");
  100ce7:	c7 04 24 96 37 10 00 	movl   $0x103796,(%esp)
  100cee:	e8 1f f6 ff ff       	call   100312 <cprintf>
    
    cprintf("stack trackback:\n");
  100cf3:	c7 04 24 98 37 10 00 	movl   $0x103798,(%esp)
  100cfa:	e8 13 f6 ff ff       	call   100312 <cprintf>
    print_stackframe();
  100cff:	e8 8c fc ff ff       	call   100990 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d04:	e8 22 09 00 00       	call   10162b <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d10:	e8 a4 fe ff ff       	call   100bb9 <kmonitor>
    }
  100d15:	eb f2                	jmp    100d09 <__panic+0x6f>

00100d17 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d17:	55                   	push   %ebp
  100d18:	89 e5                	mov    %esp,%ebp
  100d1a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d1d:	8d 45 14             	lea    0x14(%ebp),%eax
  100d20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d26:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  100d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d31:	c7 04 24 aa 37 10 00 	movl   $0x1037aa,(%esp)
  100d38:	e8 d5 f5 ff ff       	call   100312 <cprintf>
    vcprintf(fmt, ap);
  100d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d44:	8b 45 10             	mov    0x10(%ebp),%eax
  100d47:	89 04 24             	mov    %eax,(%esp)
  100d4a:	e8 90 f5 ff ff       	call   1002df <vcprintf>
    cprintf("\n");
  100d4f:	c7 04 24 96 37 10 00 	movl   $0x103796,(%esp)
  100d56:	e8 b7 f5 ff ff       	call   100312 <cprintf>
    va_end(ap);
}
  100d5b:	c9                   	leave  
  100d5c:	c3                   	ret    

00100d5d <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d5d:	55                   	push   %ebp
  100d5e:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d60:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100d65:	5d                   	pop    %ebp
  100d66:	c3                   	ret    

00100d67 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d67:	55                   	push   %ebp
  100d68:	89 e5                	mov    %esp,%ebp
  100d6a:	83 ec 28             	sub    $0x28,%esp
  100d6d:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d73:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d77:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d7b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d7f:	ee                   	out    %al,(%dx)
  100d80:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d86:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d8a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d8e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d92:	ee                   	out    %al,(%dx)
  100d93:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100d99:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100d9d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100da1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100da5:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100da6:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100dad:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100db0:	c7 04 24 c8 37 10 00 	movl   $0x1037c8,(%esp)
  100db7:	e8 56 f5 ff ff       	call   100312 <cprintf>
    pic_enable(IRQ_TIMER);
  100dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dc3:	e8 c1 08 00 00       	call   101689 <pic_enable>
}
  100dc8:	c9                   	leave  
  100dc9:	c3                   	ret    

00100dca <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100dca:	55                   	push   %ebp
  100dcb:	89 e5                	mov    %esp,%ebp
  100dcd:	83 ec 10             	sub    $0x10,%esp
  100dd0:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dd6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100dda:	89 c2                	mov    %eax,%edx
  100ddc:	ec                   	in     (%dx),%al
  100ddd:	88 45 fd             	mov    %al,-0x3(%ebp)
  100de0:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100de6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100dea:	89 c2                	mov    %eax,%edx
  100dec:	ec                   	in     (%dx),%al
  100ded:	88 45 f9             	mov    %al,-0x7(%ebp)
  100df0:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100df6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100dfa:	89 c2                	mov    %eax,%edx
  100dfc:	ec                   	in     (%dx),%al
  100dfd:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e00:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e06:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e0a:	89 c2                	mov    %eax,%edx
  100e0c:	ec                   	in     (%dx),%al
  100e0d:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e10:	c9                   	leave  
  100e11:	c3                   	ret    

00100e12 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e12:	55                   	push   %ebp
  100e13:	89 e5                	mov    %esp,%ebp
  100e15:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e18:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e22:	0f b7 00             	movzwl (%eax),%eax
  100e25:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e29:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e2c:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e34:	0f b7 00             	movzwl (%eax),%eax
  100e37:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e3b:	74 12                	je     100e4f <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e3d:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e44:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e4b:	b4 03 
  100e4d:	eb 13                	jmp    100e62 <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e52:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e56:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e59:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e60:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e62:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e69:	0f b7 c0             	movzwl %ax,%eax
  100e6c:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e70:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e74:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e78:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e7c:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e7d:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e84:	83 c0 01             	add    $0x1,%eax
  100e87:	0f b7 c0             	movzwl %ax,%eax
  100e8a:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e8e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100e92:	89 c2                	mov    %eax,%edx
  100e94:	ec                   	in     (%dx),%al
  100e95:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100e98:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e9c:	0f b6 c0             	movzbl %al,%eax
  100e9f:	c1 e0 08             	shl    $0x8,%eax
  100ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ea5:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100eac:	0f b7 c0             	movzwl %ax,%eax
  100eaf:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100eb3:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eb7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ebb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100ebf:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ec0:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ec7:	83 c0 01             	add    $0x1,%eax
  100eca:	0f b7 c0             	movzwl %ax,%eax
  100ecd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ed1:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100ed5:	89 c2                	mov    %eax,%edx
  100ed7:	ec                   	in     (%dx),%al
  100ed8:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100edb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100edf:	0f b6 c0             	movzbl %al,%eax
  100ee2:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee8:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ef0:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100ef6:	c9                   	leave  
  100ef7:	c3                   	ret    

00100ef8 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100ef8:	55                   	push   %ebp
  100ef9:	89 e5                	mov    %esp,%ebp
  100efb:	83 ec 48             	sub    $0x48,%esp
  100efe:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f04:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f08:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f0c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f10:	ee                   	out    %al,(%dx)
  100f11:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f17:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f1b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f1f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f23:	ee                   	out    %al,(%dx)
  100f24:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f2a:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f2e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f32:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f36:	ee                   	out    %al,(%dx)
  100f37:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f3d:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100f41:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f45:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f49:	ee                   	out    %al,(%dx)
  100f4a:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f50:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f54:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f58:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f5c:	ee                   	out    %al,(%dx)
  100f5d:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f63:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f67:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f6b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f6f:	ee                   	out    %al,(%dx)
  100f70:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f76:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f7a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f7e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f82:	ee                   	out    %al,(%dx)
  100f83:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f89:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100f8d:	89 c2                	mov    %eax,%edx
  100f8f:	ec                   	in     (%dx),%al
  100f90:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100f93:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f97:	3c ff                	cmp    $0xff,%al
  100f99:	0f 95 c0             	setne  %al
  100f9c:	0f b6 c0             	movzbl %al,%eax
  100f9f:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fa4:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100faa:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100fae:	89 c2                	mov    %eax,%edx
  100fb0:	ec                   	in     (%dx),%al
  100fb1:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100fb4:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100fba:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100fbe:	89 c2                	mov    %eax,%edx
  100fc0:	ec                   	in     (%dx),%al
  100fc1:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fc4:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fc9:	85 c0                	test   %eax,%eax
  100fcb:	74 0c                	je     100fd9 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fcd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fd4:	e8 b0 06 00 00       	call   101689 <pic_enable>
    }
}
  100fd9:	c9                   	leave  
  100fda:	c3                   	ret    

00100fdb <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fdb:	55                   	push   %ebp
  100fdc:	89 e5                	mov    %esp,%ebp
  100fde:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fe1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fe8:	eb 09                	jmp    100ff3 <lpt_putc_sub+0x18>
        delay();
  100fea:	e8 db fd ff ff       	call   100dca <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100ff3:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  100ff9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100ffd:	89 c2                	mov    %eax,%edx
  100fff:	ec                   	in     (%dx),%al
  101000:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101003:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101007:	84 c0                	test   %al,%al
  101009:	78 09                	js     101014 <lpt_putc_sub+0x39>
  10100b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101012:	7e d6                	jle    100fea <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101014:	8b 45 08             	mov    0x8(%ebp),%eax
  101017:	0f b6 c0             	movzbl %al,%eax
  10101a:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101020:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101023:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101027:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10102b:	ee                   	out    %al,(%dx)
  10102c:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101032:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101036:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10103a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10103e:	ee                   	out    %al,(%dx)
  10103f:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  101045:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  101049:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10104d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101051:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101052:	c9                   	leave  
  101053:	c3                   	ret    

00101054 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101054:	55                   	push   %ebp
  101055:	89 e5                	mov    %esp,%ebp
  101057:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10105a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10105e:	74 0d                	je     10106d <lpt_putc+0x19>
        lpt_putc_sub(c);
  101060:	8b 45 08             	mov    0x8(%ebp),%eax
  101063:	89 04 24             	mov    %eax,(%esp)
  101066:	e8 70 ff ff ff       	call   100fdb <lpt_putc_sub>
  10106b:	eb 24                	jmp    101091 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  10106d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101074:	e8 62 ff ff ff       	call   100fdb <lpt_putc_sub>
        lpt_putc_sub(' ');
  101079:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101080:	e8 56 ff ff ff       	call   100fdb <lpt_putc_sub>
        lpt_putc_sub('\b');
  101085:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10108c:	e8 4a ff ff ff       	call   100fdb <lpt_putc_sub>
    }
}
  101091:	c9                   	leave  
  101092:	c3                   	ret    

00101093 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101093:	55                   	push   %ebp
  101094:	89 e5                	mov    %esp,%ebp
  101096:	53                   	push   %ebx
  101097:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10109a:	8b 45 08             	mov    0x8(%ebp),%eax
  10109d:	b0 00                	mov    $0x0,%al
  10109f:	85 c0                	test   %eax,%eax
  1010a1:	75 07                	jne    1010aa <cga_putc+0x17>
        c |= 0x0700;
  1010a3:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ad:	0f b6 c0             	movzbl %al,%eax
  1010b0:	83 f8 0a             	cmp    $0xa,%eax
  1010b3:	74 4c                	je     101101 <cga_putc+0x6e>
  1010b5:	83 f8 0d             	cmp    $0xd,%eax
  1010b8:	74 57                	je     101111 <cga_putc+0x7e>
  1010ba:	83 f8 08             	cmp    $0x8,%eax
  1010bd:	0f 85 88 00 00 00    	jne    10114b <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  1010c3:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010ca:	66 85 c0             	test   %ax,%ax
  1010cd:	74 30                	je     1010ff <cga_putc+0x6c>
            crt_pos --;
  1010cf:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010d6:	83 e8 01             	sub    $0x1,%eax
  1010d9:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010df:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010e4:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010eb:	0f b7 d2             	movzwl %dx,%edx
  1010ee:	01 d2                	add    %edx,%edx
  1010f0:	01 c2                	add    %eax,%edx
  1010f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f5:	b0 00                	mov    $0x0,%al
  1010f7:	83 c8 20             	or     $0x20,%eax
  1010fa:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1010fd:	eb 72                	jmp    101171 <cga_putc+0xde>
  1010ff:	eb 70                	jmp    101171 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101101:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101108:	83 c0 50             	add    $0x50,%eax
  10110b:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101111:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101118:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  10111f:	0f b7 c1             	movzwl %cx,%eax
  101122:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101128:	c1 e8 10             	shr    $0x10,%eax
  10112b:	89 c2                	mov    %eax,%edx
  10112d:	66 c1 ea 06          	shr    $0x6,%dx
  101131:	89 d0                	mov    %edx,%eax
  101133:	c1 e0 02             	shl    $0x2,%eax
  101136:	01 d0                	add    %edx,%eax
  101138:	c1 e0 04             	shl    $0x4,%eax
  10113b:	29 c1                	sub    %eax,%ecx
  10113d:	89 ca                	mov    %ecx,%edx
  10113f:	89 d8                	mov    %ebx,%eax
  101141:	29 d0                	sub    %edx,%eax
  101143:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  101149:	eb 26                	jmp    101171 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10114b:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101151:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101158:	8d 50 01             	lea    0x1(%eax),%edx
  10115b:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101162:	0f b7 c0             	movzwl %ax,%eax
  101165:	01 c0                	add    %eax,%eax
  101167:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10116a:	8b 45 08             	mov    0x8(%ebp),%eax
  10116d:	66 89 02             	mov    %ax,(%edx)
        break;
  101170:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101171:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101178:	66 3d cf 07          	cmp    $0x7cf,%ax
  10117c:	76 5b                	jbe    1011d9 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10117e:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101183:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101189:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10118e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101195:	00 
  101196:	89 54 24 04          	mov    %edx,0x4(%esp)
  10119a:	89 04 24             	mov    %eax,(%esp)
  10119d:	e8 95 21 00 00       	call   103337 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011a2:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011a9:	eb 15                	jmp    1011c0 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  1011ab:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011b3:	01 d2                	add    %edx,%edx
  1011b5:	01 d0                	add    %edx,%eax
  1011b7:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011c0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011c7:	7e e2                	jle    1011ab <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011c9:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011d0:	83 e8 50             	sub    $0x50,%eax
  1011d3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011d9:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011e0:	0f b7 c0             	movzwl %ax,%eax
  1011e3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011e7:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  1011eb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1011ef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011f3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011f4:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011fb:	66 c1 e8 08          	shr    $0x8,%ax
  1011ff:	0f b6 c0             	movzbl %al,%eax
  101202:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101209:	83 c2 01             	add    $0x1,%edx
  10120c:	0f b7 d2             	movzwl %dx,%edx
  10120f:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101213:	88 45 ed             	mov    %al,-0x13(%ebp)
  101216:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10121a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10121e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10121f:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101226:	0f b7 c0             	movzwl %ax,%eax
  101229:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  10122d:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  101231:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101235:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101239:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10123a:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101241:	0f b6 c0             	movzbl %al,%eax
  101244:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10124b:	83 c2 01             	add    $0x1,%edx
  10124e:	0f b7 d2             	movzwl %dx,%edx
  101251:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  101255:	88 45 e5             	mov    %al,-0x1b(%ebp)
  101258:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10125c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101260:	ee                   	out    %al,(%dx)
}
  101261:	83 c4 34             	add    $0x34,%esp
  101264:	5b                   	pop    %ebx
  101265:	5d                   	pop    %ebp
  101266:	c3                   	ret    

00101267 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101267:	55                   	push   %ebp
  101268:	89 e5                	mov    %esp,%ebp
  10126a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10126d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101274:	eb 09                	jmp    10127f <serial_putc_sub+0x18>
        delay();
  101276:	e8 4f fb ff ff       	call   100dca <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10127b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10127f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101285:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101289:	89 c2                	mov    %eax,%edx
  10128b:	ec                   	in     (%dx),%al
  10128c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10128f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101293:	0f b6 c0             	movzbl %al,%eax
  101296:	83 e0 20             	and    $0x20,%eax
  101299:	85 c0                	test   %eax,%eax
  10129b:	75 09                	jne    1012a6 <serial_putc_sub+0x3f>
  10129d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012a4:	7e d0                	jle    101276 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1012a9:	0f b6 c0             	movzbl %al,%eax
  1012ac:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012b2:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012b5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012b9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012bd:	ee                   	out    %al,(%dx)
}
  1012be:	c9                   	leave  
  1012bf:	c3                   	ret    

001012c0 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012c0:	55                   	push   %ebp
  1012c1:	89 e5                	mov    %esp,%ebp
  1012c3:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012c6:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012ca:	74 0d                	je     1012d9 <serial_putc+0x19>
        serial_putc_sub(c);
  1012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1012cf:	89 04 24             	mov    %eax,(%esp)
  1012d2:	e8 90 ff ff ff       	call   101267 <serial_putc_sub>
  1012d7:	eb 24                	jmp    1012fd <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  1012d9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012e0:	e8 82 ff ff ff       	call   101267 <serial_putc_sub>
        serial_putc_sub(' ');
  1012e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012ec:	e8 76 ff ff ff       	call   101267 <serial_putc_sub>
        serial_putc_sub('\b');
  1012f1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012f8:	e8 6a ff ff ff       	call   101267 <serial_putc_sub>
    }
}
  1012fd:	c9                   	leave  
  1012fe:	c3                   	ret    

001012ff <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012ff:	55                   	push   %ebp
  101300:	89 e5                	mov    %esp,%ebp
  101302:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101305:	eb 33                	jmp    10133a <cons_intr+0x3b>
        if (c != 0) {
  101307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10130b:	74 2d                	je     10133a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10130d:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101312:	8d 50 01             	lea    0x1(%eax),%edx
  101315:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  10131b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10131e:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101324:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101329:	3d 00 02 00 00       	cmp    $0x200,%eax
  10132e:	75 0a                	jne    10133a <cons_intr+0x3b>
                cons.wpos = 0;
  101330:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101337:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  10133a:	8b 45 08             	mov    0x8(%ebp),%eax
  10133d:	ff d0                	call   *%eax
  10133f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101342:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101346:	75 bf                	jne    101307 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101348:	c9                   	leave  
  101349:	c3                   	ret    

0010134a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10134a:	55                   	push   %ebp
  10134b:	89 e5                	mov    %esp,%ebp
  10134d:	83 ec 10             	sub    $0x10,%esp
  101350:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101356:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10135a:	89 c2                	mov    %eax,%edx
  10135c:	ec                   	in     (%dx),%al
  10135d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101360:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101364:	0f b6 c0             	movzbl %al,%eax
  101367:	83 e0 01             	and    $0x1,%eax
  10136a:	85 c0                	test   %eax,%eax
  10136c:	75 07                	jne    101375 <serial_proc_data+0x2b>
        return -1;
  10136e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101373:	eb 2a                	jmp    10139f <serial_proc_data+0x55>
  101375:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10137b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10137f:	89 c2                	mov    %eax,%edx
  101381:	ec                   	in     (%dx),%al
  101382:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101385:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101389:	0f b6 c0             	movzbl %al,%eax
  10138c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10138f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101393:	75 07                	jne    10139c <serial_proc_data+0x52>
        c = '\b';
  101395:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10139c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10139f:	c9                   	leave  
  1013a0:	c3                   	ret    

001013a1 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013a1:	55                   	push   %ebp
  1013a2:	89 e5                	mov    %esp,%ebp
  1013a4:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013a7:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013ac:	85 c0                	test   %eax,%eax
  1013ae:	74 0c                	je     1013bc <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013b0:	c7 04 24 4a 13 10 00 	movl   $0x10134a,(%esp)
  1013b7:	e8 43 ff ff ff       	call   1012ff <cons_intr>
    }
}
  1013bc:	c9                   	leave  
  1013bd:	c3                   	ret    

001013be <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013be:	55                   	push   %ebp
  1013bf:	89 e5                	mov    %esp,%ebp
  1013c1:	83 ec 38             	sub    $0x38,%esp
  1013c4:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013ca:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013ce:	89 c2                	mov    %eax,%edx
  1013d0:	ec                   	in     (%dx),%al
  1013d1:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013d8:	0f b6 c0             	movzbl %al,%eax
  1013db:	83 e0 01             	and    $0x1,%eax
  1013de:	85 c0                	test   %eax,%eax
  1013e0:	75 0a                	jne    1013ec <kbd_proc_data+0x2e>
        return -1;
  1013e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e7:	e9 59 01 00 00       	jmp    101545 <kbd_proc_data+0x187>
  1013ec:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013f2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1013f6:	89 c2                	mov    %eax,%edx
  1013f8:	ec                   	in     (%dx),%al
  1013f9:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013fc:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101400:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101403:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101407:	75 17                	jne    101420 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101409:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10140e:	83 c8 40             	or     $0x40,%eax
  101411:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101416:	b8 00 00 00 00       	mov    $0x0,%eax
  10141b:	e9 25 01 00 00       	jmp    101545 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101420:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101424:	84 c0                	test   %al,%al
  101426:	79 47                	jns    10146f <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101428:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10142d:	83 e0 40             	and    $0x40,%eax
  101430:	85 c0                	test   %eax,%eax
  101432:	75 09                	jne    10143d <kbd_proc_data+0x7f>
  101434:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101438:	83 e0 7f             	and    $0x7f,%eax
  10143b:	eb 04                	jmp    101441 <kbd_proc_data+0x83>
  10143d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101441:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101444:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101448:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10144f:	83 c8 40             	or     $0x40,%eax
  101452:	0f b6 c0             	movzbl %al,%eax
  101455:	f7 d0                	not    %eax
  101457:	89 c2                	mov    %eax,%edx
  101459:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10145e:	21 d0                	and    %edx,%eax
  101460:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101465:	b8 00 00 00 00       	mov    $0x0,%eax
  10146a:	e9 d6 00 00 00       	jmp    101545 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  10146f:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101474:	83 e0 40             	and    $0x40,%eax
  101477:	85 c0                	test   %eax,%eax
  101479:	74 11                	je     10148c <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10147b:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10147f:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101484:	83 e0 bf             	and    $0xffffffbf,%eax
  101487:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  10148c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101490:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101497:	0f b6 d0             	movzbl %al,%edx
  10149a:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10149f:	09 d0                	or     %edx,%eax
  1014a1:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014a6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014aa:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014b1:	0f b6 d0             	movzbl %al,%edx
  1014b4:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014b9:	31 d0                	xor    %edx,%eax
  1014bb:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014c0:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014c5:	83 e0 03             	and    $0x3,%eax
  1014c8:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014cf:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d3:	01 d0                	add    %edx,%eax
  1014d5:	0f b6 00             	movzbl (%eax),%eax
  1014d8:	0f b6 c0             	movzbl %al,%eax
  1014db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014de:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014e3:	83 e0 08             	and    $0x8,%eax
  1014e6:	85 c0                	test   %eax,%eax
  1014e8:	74 22                	je     10150c <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014ea:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014ee:	7e 0c                	jle    1014fc <kbd_proc_data+0x13e>
  1014f0:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014f4:	7f 06                	jg     1014fc <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1014f6:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014fa:	eb 10                	jmp    10150c <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1014fc:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101500:	7e 0a                	jle    10150c <kbd_proc_data+0x14e>
  101502:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101506:	7f 04                	jg     10150c <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101508:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10150c:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101511:	f7 d0                	not    %eax
  101513:	83 e0 06             	and    $0x6,%eax
  101516:	85 c0                	test   %eax,%eax
  101518:	75 28                	jne    101542 <kbd_proc_data+0x184>
  10151a:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101521:	75 1f                	jne    101542 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101523:	c7 04 24 e3 37 10 00 	movl   $0x1037e3,(%esp)
  10152a:	e8 e3 ed ff ff       	call   100312 <cprintf>
  10152f:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101535:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101539:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10153d:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101541:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101542:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101545:	c9                   	leave  
  101546:	c3                   	ret    

00101547 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101547:	55                   	push   %ebp
  101548:	89 e5                	mov    %esp,%ebp
  10154a:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10154d:	c7 04 24 be 13 10 00 	movl   $0x1013be,(%esp)
  101554:	e8 a6 fd ff ff       	call   1012ff <cons_intr>
}
  101559:	c9                   	leave  
  10155a:	c3                   	ret    

0010155b <kbd_init>:

static void
kbd_init(void) {
  10155b:	55                   	push   %ebp
  10155c:	89 e5                	mov    %esp,%ebp
  10155e:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101561:	e8 e1 ff ff ff       	call   101547 <kbd_intr>
    pic_enable(IRQ_KBD);
  101566:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10156d:	e8 17 01 00 00       	call   101689 <pic_enable>
}
  101572:	c9                   	leave  
  101573:	c3                   	ret    

00101574 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101574:	55                   	push   %ebp
  101575:	89 e5                	mov    %esp,%ebp
  101577:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  10157a:	e8 93 f8 ff ff       	call   100e12 <cga_init>
    serial_init();
  10157f:	e8 74 f9 ff ff       	call   100ef8 <serial_init>
    kbd_init();
  101584:	e8 d2 ff ff ff       	call   10155b <kbd_init>
    if (!serial_exists) {
  101589:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  10158e:	85 c0                	test   %eax,%eax
  101590:	75 0c                	jne    10159e <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101592:	c7 04 24 ef 37 10 00 	movl   $0x1037ef,(%esp)
  101599:	e8 74 ed ff ff       	call   100312 <cprintf>
    }
}
  10159e:	c9                   	leave  
  10159f:	c3                   	ret    

001015a0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015a0:	55                   	push   %ebp
  1015a1:	89 e5                	mov    %esp,%ebp
  1015a3:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1015a9:	89 04 24             	mov    %eax,(%esp)
  1015ac:	e8 a3 fa ff ff       	call   101054 <lpt_putc>
    cga_putc(c);
  1015b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1015b4:	89 04 24             	mov    %eax,(%esp)
  1015b7:	e8 d7 fa ff ff       	call   101093 <cga_putc>
    serial_putc(c);
  1015bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1015bf:	89 04 24             	mov    %eax,(%esp)
  1015c2:	e8 f9 fc ff ff       	call   1012c0 <serial_putc>
}
  1015c7:	c9                   	leave  
  1015c8:	c3                   	ret    

001015c9 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015c9:	55                   	push   %ebp
  1015ca:	89 e5                	mov    %esp,%ebp
  1015cc:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015cf:	e8 cd fd ff ff       	call   1013a1 <serial_intr>
    kbd_intr();
  1015d4:	e8 6e ff ff ff       	call   101547 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015d9:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015df:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015e4:	39 c2                	cmp    %eax,%edx
  1015e6:	74 36                	je     10161e <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015e8:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015ed:	8d 50 01             	lea    0x1(%eax),%edx
  1015f0:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  1015f6:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  1015fd:	0f b6 c0             	movzbl %al,%eax
  101600:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101603:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101608:	3d 00 02 00 00       	cmp    $0x200,%eax
  10160d:	75 0a                	jne    101619 <cons_getc+0x50>
            cons.rpos = 0;
  10160f:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  101616:	00 00 00 
        }
        return c;
  101619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10161c:	eb 05                	jmp    101623 <cons_getc+0x5a>
    }
    return 0;
  10161e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101623:	c9                   	leave  
  101624:	c3                   	ret    

00101625 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101625:	55                   	push   %ebp
  101626:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101628:	fb                   	sti    
    sti();
}
  101629:	5d                   	pop    %ebp
  10162a:	c3                   	ret    

0010162b <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10162b:	55                   	push   %ebp
  10162c:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  10162e:	fa                   	cli    
    cli();
}
  10162f:	5d                   	pop    %ebp
  101630:	c3                   	ret    

00101631 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101631:	55                   	push   %ebp
  101632:	89 e5                	mov    %esp,%ebp
  101634:	83 ec 14             	sub    $0x14,%esp
  101637:	8b 45 08             	mov    0x8(%ebp),%eax
  10163a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10163e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101642:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101648:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  10164d:	85 c0                	test   %eax,%eax
  10164f:	74 36                	je     101687 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101651:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101655:	0f b6 c0             	movzbl %al,%eax
  101658:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10165e:	88 45 fd             	mov    %al,-0x3(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101661:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101665:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101669:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10166a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10166e:	66 c1 e8 08          	shr    $0x8,%ax
  101672:	0f b6 c0             	movzbl %al,%eax
  101675:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10167b:	88 45 f9             	mov    %al,-0x7(%ebp)
  10167e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101682:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101686:	ee                   	out    %al,(%dx)
    }
}
  101687:	c9                   	leave  
  101688:	c3                   	ret    

00101689 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101689:	55                   	push   %ebp
  10168a:	89 e5                	mov    %esp,%ebp
  10168c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10168f:	8b 45 08             	mov    0x8(%ebp),%eax
  101692:	ba 01 00 00 00       	mov    $0x1,%edx
  101697:	89 c1                	mov    %eax,%ecx
  101699:	d3 e2                	shl    %cl,%edx
  10169b:	89 d0                	mov    %edx,%eax
  10169d:	f7 d0                	not    %eax
  10169f:	89 c2                	mov    %eax,%edx
  1016a1:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016a8:	21 d0                	and    %edx,%eax
  1016aa:	0f b7 c0             	movzwl %ax,%eax
  1016ad:	89 04 24             	mov    %eax,(%esp)
  1016b0:	e8 7c ff ff ff       	call   101631 <pic_setmask>
}
  1016b5:	c9                   	leave  
  1016b6:	c3                   	ret    

001016b7 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016b7:	55                   	push   %ebp
  1016b8:	89 e5                	mov    %esp,%ebp
  1016ba:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016bd:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016c4:	00 00 00 
  1016c7:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016cd:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016d1:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016d5:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016d9:	ee                   	out    %al,(%dx)
  1016da:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016e0:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  1016e4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016e8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016ec:	ee                   	out    %al,(%dx)
  1016ed:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1016f3:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  1016f7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1016fb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1016ff:	ee                   	out    %al,(%dx)
  101700:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  101706:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  10170a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10170e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101712:	ee                   	out    %al,(%dx)
  101713:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  101719:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  10171d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101721:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101725:	ee                   	out    %al,(%dx)
  101726:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  10172c:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  101730:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101734:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101738:	ee                   	out    %al,(%dx)
  101739:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  10173f:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  101743:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101747:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10174b:	ee                   	out    %al,(%dx)
  10174c:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101752:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101756:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10175a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10175e:	ee                   	out    %al,(%dx)
  10175f:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101765:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101769:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10176d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101771:	ee                   	out    %al,(%dx)
  101772:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101778:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  10177c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101780:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101784:	ee                   	out    %al,(%dx)
  101785:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  10178b:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10178f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101793:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101797:	ee                   	out    %al,(%dx)
  101798:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10179e:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  1017a2:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017a6:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017aa:	ee                   	out    %al,(%dx)
  1017ab:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  1017b1:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  1017b5:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017b9:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017bd:	ee                   	out    %al,(%dx)
  1017be:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017c4:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017c8:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017cc:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017d0:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017d1:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017d8:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017dc:	74 12                	je     1017f0 <pic_init+0x139>
        pic_setmask(irq_mask);
  1017de:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017e5:	0f b7 c0             	movzwl %ax,%eax
  1017e8:	89 04 24             	mov    %eax,(%esp)
  1017eb:	e8 41 fe ff ff       	call   101631 <pic_setmask>
    }
}
  1017f0:	c9                   	leave  
  1017f1:	c3                   	ret    

001017f2 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1017f2:	55                   	push   %ebp
  1017f3:	89 e5                	mov    %esp,%ebp
  1017f5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1017f8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1017ff:	00 
  101800:	c7 04 24 20 38 10 00 	movl   $0x103820,(%esp)
  101807:	e8 06 eb ff ff       	call   100312 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  10180c:	c9                   	leave  
  10180d:	c3                   	ret    

0010180e <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10180e:	55                   	push   %ebp
  10180f:	89 e5                	mov    %esp,%ebp
  101811:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
extern uintptr_t __vectors[];
int i; 
for(i=0; i<256; i++)
  101814:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10181b:	e9 c3 00 00 00       	jmp    1018e3 <idt_init+0xd5>
 {
 SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  101820:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101823:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  10182a:	89 c2                	mov    %eax,%edx
  10182c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10182f:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  101836:	00 
  101837:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10183a:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  101841:	00 08 00 
  101844:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101847:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10184e:	00 
  10184f:	83 e2 e0             	and    $0xffffffe0,%edx
  101852:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101859:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10185c:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101863:	00 
  101864:	83 e2 1f             	and    $0x1f,%edx
  101867:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  10186e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101871:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101878:	00 
  101879:	83 e2 f0             	and    $0xfffffff0,%edx
  10187c:	83 ca 0e             	or     $0xe,%edx
  10187f:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  101886:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101889:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101890:	00 
  101891:	83 e2 ef             	and    $0xffffffef,%edx
  101894:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  10189b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10189e:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018a5:	00 
  1018a6:	83 e2 9f             	and    $0xffffff9f,%edx
  1018a9:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b3:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018ba:	00 
  1018bb:	83 ca 80             	or     $0xffffff80,%edx
  1018be:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c8:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018cf:	c1 e8 10             	shr    $0x10,%eax
  1018d2:	89 c2                	mov    %eax,%edx
  1018d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d7:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018de:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
extern uintptr_t __vectors[];
int i; 
for(i=0; i<256; i++)
  1018df:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1018e3:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  1018ea:	0f 8e 30 ff ff ff    	jle    101820 <idt_init+0x12>
 {
 SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
 
 }
 SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK],
  1018f0:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1018f5:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  1018fb:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  101902:	08 00 
  101904:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10190b:	83 e0 e0             	and    $0xffffffe0,%eax
  10190e:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101913:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10191a:	83 e0 1f             	and    $0x1f,%eax
  10191d:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101922:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101929:	83 e0 f0             	and    $0xfffffff0,%eax
  10192c:	83 c8 0e             	or     $0xe,%eax
  10192f:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101934:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10193b:	83 e0 ef             	and    $0xffffffef,%eax
  10193e:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101943:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10194a:	83 c8 60             	or     $0x60,%eax
  10194d:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101952:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101959:	83 c8 80             	or     $0xffffff80,%eax
  10195c:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101961:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101966:	c1 e8 10             	shr    $0x10,%eax
  101969:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  10196f:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  101976:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101979:	0f 01 18             	lidtl  (%eax)
DPL_USER);
 
 lidt(&idt_pd);
 
}
  10197c:	c9                   	leave  
  10197d:	c3                   	ret    

0010197e <trapname>:

static const char *
trapname(int trapno) {
  10197e:	55                   	push   %ebp
  10197f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101981:	8b 45 08             	mov    0x8(%ebp),%eax
  101984:	83 f8 13             	cmp    $0x13,%eax
  101987:	77 0c                	ja     101995 <trapname+0x17>
        return excnames[trapno];
  101989:	8b 45 08             	mov    0x8(%ebp),%eax
  10198c:	8b 04 85 80 3b 10 00 	mov    0x103b80(,%eax,4),%eax
  101993:	eb 18                	jmp    1019ad <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101995:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101999:	7e 0d                	jle    1019a8 <trapname+0x2a>
  10199b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  10199f:	7f 07                	jg     1019a8 <trapname+0x2a>
        return "Hardware Interrupt";
  1019a1:	b8 2a 38 10 00       	mov    $0x10382a,%eax
  1019a6:	eb 05                	jmp    1019ad <trapname+0x2f>
    }
    return "(unknown trap)";
  1019a8:	b8 3d 38 10 00       	mov    $0x10383d,%eax
}
  1019ad:	5d                   	pop    %ebp
  1019ae:	c3                   	ret    

001019af <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019af:	55                   	push   %ebp
  1019b0:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1019b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019b9:	66 83 f8 08          	cmp    $0x8,%ax
  1019bd:	0f 94 c0             	sete   %al
  1019c0:	0f b6 c0             	movzbl %al,%eax
}
  1019c3:	5d                   	pop    %ebp
  1019c4:	c3                   	ret    

001019c5 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019c5:	55                   	push   %ebp
  1019c6:	89 e5                	mov    %esp,%ebp
  1019c8:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019d2:	c7 04 24 7e 38 10 00 	movl   $0x10387e,(%esp)
  1019d9:	e8 34 e9 ff ff       	call   100312 <cprintf>
    print_regs(&tf->tf_regs);
  1019de:	8b 45 08             	mov    0x8(%ebp),%eax
  1019e1:	89 04 24             	mov    %eax,(%esp)
  1019e4:	e8 a1 01 00 00       	call   101b8a <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ec:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1019f0:	0f b7 c0             	movzwl %ax,%eax
  1019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019f7:	c7 04 24 8f 38 10 00 	movl   $0x10388f,(%esp)
  1019fe:	e8 0f e9 ff ff       	call   100312 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a03:	8b 45 08             	mov    0x8(%ebp),%eax
  101a06:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a0a:	0f b7 c0             	movzwl %ax,%eax
  101a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a11:	c7 04 24 a2 38 10 00 	movl   $0x1038a2,(%esp)
  101a18:	e8 f5 e8 ff ff       	call   100312 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a20:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a24:	0f b7 c0             	movzwl %ax,%eax
  101a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a2b:	c7 04 24 b5 38 10 00 	movl   $0x1038b5,(%esp)
  101a32:	e8 db e8 ff ff       	call   100312 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a37:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3a:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a3e:	0f b7 c0             	movzwl %ax,%eax
  101a41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a45:	c7 04 24 c8 38 10 00 	movl   $0x1038c8,(%esp)
  101a4c:	e8 c1 e8 ff ff       	call   100312 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a51:	8b 45 08             	mov    0x8(%ebp),%eax
  101a54:	8b 40 30             	mov    0x30(%eax),%eax
  101a57:	89 04 24             	mov    %eax,(%esp)
  101a5a:	e8 1f ff ff ff       	call   10197e <trapname>
  101a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  101a62:	8b 52 30             	mov    0x30(%edx),%edx
  101a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  101a69:	89 54 24 04          	mov    %edx,0x4(%esp)
  101a6d:	c7 04 24 db 38 10 00 	movl   $0x1038db,(%esp)
  101a74:	e8 99 e8 ff ff       	call   100312 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a79:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7c:	8b 40 34             	mov    0x34(%eax),%eax
  101a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a83:	c7 04 24 ed 38 10 00 	movl   $0x1038ed,(%esp)
  101a8a:	e8 83 e8 ff ff       	call   100312 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a92:	8b 40 38             	mov    0x38(%eax),%eax
  101a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a99:	c7 04 24 fc 38 10 00 	movl   $0x1038fc,(%esp)
  101aa0:	e8 6d e8 ff ff       	call   100312 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aac:	0f b7 c0             	movzwl %ax,%eax
  101aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab3:	c7 04 24 0b 39 10 00 	movl   $0x10390b,(%esp)
  101aba:	e8 53 e8 ff ff       	call   100312 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101abf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac2:	8b 40 40             	mov    0x40(%eax),%eax
  101ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac9:	c7 04 24 1e 39 10 00 	movl   $0x10391e,(%esp)
  101ad0:	e8 3d e8 ff ff       	call   100312 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ad5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101adc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ae3:	eb 3e                	jmp    101b23 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae8:	8b 50 40             	mov    0x40(%eax),%edx
  101aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101aee:	21 d0                	and    %edx,%eax
  101af0:	85 c0                	test   %eax,%eax
  101af2:	74 28                	je     101b1c <print_trapframe+0x157>
  101af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101af7:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101afe:	85 c0                	test   %eax,%eax
  101b00:	74 1a                	je     101b1c <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b05:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b10:	c7 04 24 2d 39 10 00 	movl   $0x10392d,(%esp)
  101b17:	e8 f6 e7 ff ff       	call   100312 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b20:	d1 65 f0             	shll   -0x10(%ebp)
  101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b26:	83 f8 17             	cmp    $0x17,%eax
  101b29:	76 ba                	jbe    101ae5 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2e:	8b 40 40             	mov    0x40(%eax),%eax
  101b31:	25 00 30 00 00       	and    $0x3000,%eax
  101b36:	c1 e8 0c             	shr    $0xc,%eax
  101b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3d:	c7 04 24 31 39 10 00 	movl   $0x103931,(%esp)
  101b44:	e8 c9 e7 ff ff       	call   100312 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b49:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4c:	89 04 24             	mov    %eax,(%esp)
  101b4f:	e8 5b fe ff ff       	call   1019af <trap_in_kernel>
  101b54:	85 c0                	test   %eax,%eax
  101b56:	75 30                	jne    101b88 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	8b 40 44             	mov    0x44(%eax),%eax
  101b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b62:	c7 04 24 3a 39 10 00 	movl   $0x10393a,(%esp)
  101b69:	e8 a4 e7 ff ff       	call   100312 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b71:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b75:	0f b7 c0             	movzwl %ax,%eax
  101b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7c:	c7 04 24 49 39 10 00 	movl   $0x103949,(%esp)
  101b83:	e8 8a e7 ff ff       	call   100312 <cprintf>
    }
}
  101b88:	c9                   	leave  
  101b89:	c3                   	ret    

00101b8a <print_regs>:

void
print_regs(struct pushregs *regs) {
  101b8a:	55                   	push   %ebp
  101b8b:	89 e5                	mov    %esp,%ebp
  101b8d:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101b90:	8b 45 08             	mov    0x8(%ebp),%eax
  101b93:	8b 00                	mov    (%eax),%eax
  101b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b99:	c7 04 24 5c 39 10 00 	movl   $0x10395c,(%esp)
  101ba0:	e8 6d e7 ff ff       	call   100312 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba8:	8b 40 04             	mov    0x4(%eax),%eax
  101bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101baf:	c7 04 24 6b 39 10 00 	movl   $0x10396b,(%esp)
  101bb6:	e8 57 e7 ff ff       	call   100312 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbe:	8b 40 08             	mov    0x8(%eax),%eax
  101bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc5:	c7 04 24 7a 39 10 00 	movl   $0x10397a,(%esp)
  101bcc:	e8 41 e7 ff ff       	call   100312 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd4:	8b 40 0c             	mov    0xc(%eax),%eax
  101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdb:	c7 04 24 89 39 10 00 	movl   $0x103989,(%esp)
  101be2:	e8 2b e7 ff ff       	call   100312 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101be7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bea:	8b 40 10             	mov    0x10(%eax),%eax
  101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf1:	c7 04 24 98 39 10 00 	movl   $0x103998,(%esp)
  101bf8:	e8 15 e7 ff ff       	call   100312 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  101c00:	8b 40 14             	mov    0x14(%eax),%eax
  101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c07:	c7 04 24 a7 39 10 00 	movl   $0x1039a7,(%esp)
  101c0e:	e8 ff e6 ff ff       	call   100312 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c13:	8b 45 08             	mov    0x8(%ebp),%eax
  101c16:	8b 40 18             	mov    0x18(%eax),%eax
  101c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1d:	c7 04 24 b6 39 10 00 	movl   $0x1039b6,(%esp)
  101c24:	e8 e9 e6 ff ff       	call   100312 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c29:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2c:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c33:	c7 04 24 c5 39 10 00 	movl   $0x1039c5,(%esp)
  101c3a:	e8 d3 e6 ff ff       	call   100312 <cprintf>
}
  101c3f:	c9                   	leave  
  101c40:	c3                   	ret    

00101c41 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c41:	55                   	push   %ebp
  101c42:	89 e5                	mov    %esp,%ebp
  101c44:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c47:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4a:	8b 40 30             	mov    0x30(%eax),%eax
  101c4d:	83 f8 2f             	cmp    $0x2f,%eax
  101c50:	77 21                	ja     101c73 <trap_dispatch+0x32>
  101c52:	83 f8 2e             	cmp    $0x2e,%eax
  101c55:	0f 83 04 01 00 00    	jae    101d5f <trap_dispatch+0x11e>
  101c5b:	83 f8 21             	cmp    $0x21,%eax
  101c5e:	0f 84 81 00 00 00    	je     101ce5 <trap_dispatch+0xa4>
  101c64:	83 f8 24             	cmp    $0x24,%eax
  101c67:	74 56                	je     101cbf <trap_dispatch+0x7e>
  101c69:	83 f8 20             	cmp    $0x20,%eax
  101c6c:	74 16                	je     101c84 <trap_dispatch+0x43>
  101c6e:	e9 b4 00 00 00       	jmp    101d27 <trap_dispatch+0xe6>
  101c73:	83 e8 78             	sub    $0x78,%eax
  101c76:	83 f8 01             	cmp    $0x1,%eax
  101c79:	0f 87 a8 00 00 00    	ja     101d27 <trap_dispatch+0xe6>
  101c7f:	e9 87 00 00 00       	jmp    101d0b <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks ++;
  101c84:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101c89:	83 c0 01             	add    $0x1,%eax
  101c8c:	a3 08 f9 10 00       	mov    %eax,0x10f908
 	if (ticks % TICK_NUM == 0)
  101c91:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101c97:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101c9c:	89 c8                	mov    %ecx,%eax
  101c9e:	f7 e2                	mul    %edx
  101ca0:	89 d0                	mov    %edx,%eax
  101ca2:	c1 e8 05             	shr    $0x5,%eax
  101ca5:	6b c0 64             	imul   $0x64,%eax,%eax
  101ca8:	29 c1                	sub    %eax,%ecx
  101caa:	89 c8                	mov    %ecx,%eax
  101cac:	85 c0                	test   %eax,%eax
  101cae:	75 0a                	jne    101cba <trap_dispatch+0x79>
 	{
	print_ticks();
  101cb0:	e8 3d fb ff ff       	call   1017f2 <print_ticks>
 	}
        break;
  101cb5:	e9 a6 00 00 00       	jmp    101d60 <trap_dispatch+0x11f>
  101cba:	e9 a1 00 00 00       	jmp    101d60 <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cbf:	e8 05 f9 ff ff       	call   1015c9 <cons_getc>
  101cc4:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cc7:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ccb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101ccf:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd7:	c7 04 24 d4 39 10 00 	movl   $0x1039d4,(%esp)
  101cde:	e8 2f e6 ff ff       	call   100312 <cprintf>
        break;
  101ce3:	eb 7b                	jmp    101d60 <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101ce5:	e8 df f8 ff ff       	call   1015c9 <cons_getc>
  101cea:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101ced:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cf1:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cf5:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cfd:	c7 04 24 e6 39 10 00 	movl   $0x1039e6,(%esp)
  101d04:	e8 09 e6 ff ff       	call   100312 <cprintf>
        break;
  101d09:	eb 55                	jmp    101d60 <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d0b:	c7 44 24 08 f5 39 10 	movl   $0x1039f5,0x8(%esp)
  101d12:	00 
  101d13:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
  101d1a:	00 
  101d1b:	c7 04 24 05 3a 10 00 	movl   $0x103a05,(%esp)
  101d22:	e8 73 ef ff ff       	call   100c9a <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d27:	8b 45 08             	mov    0x8(%ebp),%eax
  101d2a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d2e:	0f b7 c0             	movzwl %ax,%eax
  101d31:	83 e0 03             	and    $0x3,%eax
  101d34:	85 c0                	test   %eax,%eax
  101d36:	75 28                	jne    101d60 <trap_dispatch+0x11f>
            print_trapframe(tf);
  101d38:	8b 45 08             	mov    0x8(%ebp),%eax
  101d3b:	89 04 24             	mov    %eax,(%esp)
  101d3e:	e8 82 fc ff ff       	call   1019c5 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d43:	c7 44 24 08 16 3a 10 	movl   $0x103a16,0x8(%esp)
  101d4a:	00 
  101d4b:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
  101d52:	00 
  101d53:	c7 04 24 05 3a 10 00 	movl   $0x103a05,(%esp)
  101d5a:	e8 3b ef ff ff       	call   100c9a <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101d5f:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101d60:	c9                   	leave  
  101d61:	c3                   	ret    

00101d62 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d62:	55                   	push   %ebp
  101d63:	89 e5                	mov    %esp,%ebp
  101d65:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d68:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6b:	89 04 24             	mov    %eax,(%esp)
  101d6e:	e8 ce fe ff ff       	call   101c41 <trap_dispatch>
}
  101d73:	c9                   	leave  
  101d74:	c3                   	ret    

00101d75 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101d75:	1e                   	push   %ds
    pushl %es
  101d76:	06                   	push   %es
    pushl %fs
  101d77:	0f a0                	push   %fs
    pushl %gs
  101d79:	0f a8                	push   %gs
    pushal
  101d7b:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101d7c:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101d81:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101d83:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101d85:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101d86:	e8 d7 ff ff ff       	call   101d62 <trap>

    # pop the pushed stack pointer
    popl %esp
  101d8b:	5c                   	pop    %esp

00101d8c <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101d8c:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101d8d:	0f a9                	pop    %gs
    popl %fs
  101d8f:	0f a1                	pop    %fs
    popl %es
  101d91:	07                   	pop    %es
    popl %ds
  101d92:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101d93:	83 c4 08             	add    $0x8,%esp
    iret
  101d96:	cf                   	iret   

00101d97 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101d97:	6a 00                	push   $0x0
  pushl $0
  101d99:	6a 00                	push   $0x0
  jmp __alltraps
  101d9b:	e9 d5 ff ff ff       	jmp    101d75 <__alltraps>

00101da0 <vector1>:
.globl vector1
vector1:
  pushl $0
  101da0:	6a 00                	push   $0x0
  pushl $1
  101da2:	6a 01                	push   $0x1
  jmp __alltraps
  101da4:	e9 cc ff ff ff       	jmp    101d75 <__alltraps>

00101da9 <vector2>:
.globl vector2
vector2:
  pushl $0
  101da9:	6a 00                	push   $0x0
  pushl $2
  101dab:	6a 02                	push   $0x2
  jmp __alltraps
  101dad:	e9 c3 ff ff ff       	jmp    101d75 <__alltraps>

00101db2 <vector3>:
.globl vector3
vector3:
  pushl $0
  101db2:	6a 00                	push   $0x0
  pushl $3
  101db4:	6a 03                	push   $0x3
  jmp __alltraps
  101db6:	e9 ba ff ff ff       	jmp    101d75 <__alltraps>

00101dbb <vector4>:
.globl vector4
vector4:
  pushl $0
  101dbb:	6a 00                	push   $0x0
  pushl $4
  101dbd:	6a 04                	push   $0x4
  jmp __alltraps
  101dbf:	e9 b1 ff ff ff       	jmp    101d75 <__alltraps>

00101dc4 <vector5>:
.globl vector5
vector5:
  pushl $0
  101dc4:	6a 00                	push   $0x0
  pushl $5
  101dc6:	6a 05                	push   $0x5
  jmp __alltraps
  101dc8:	e9 a8 ff ff ff       	jmp    101d75 <__alltraps>

00101dcd <vector6>:
.globl vector6
vector6:
  pushl $0
  101dcd:	6a 00                	push   $0x0
  pushl $6
  101dcf:	6a 06                	push   $0x6
  jmp __alltraps
  101dd1:	e9 9f ff ff ff       	jmp    101d75 <__alltraps>

00101dd6 <vector7>:
.globl vector7
vector7:
  pushl $0
  101dd6:	6a 00                	push   $0x0
  pushl $7
  101dd8:	6a 07                	push   $0x7
  jmp __alltraps
  101dda:	e9 96 ff ff ff       	jmp    101d75 <__alltraps>

00101ddf <vector8>:
.globl vector8
vector8:
  pushl $8
  101ddf:	6a 08                	push   $0x8
  jmp __alltraps
  101de1:	e9 8f ff ff ff       	jmp    101d75 <__alltraps>

00101de6 <vector9>:
.globl vector9
vector9:
  pushl $0
  101de6:	6a 00                	push   $0x0
  pushl $9
  101de8:	6a 09                	push   $0x9
  jmp __alltraps
  101dea:	e9 86 ff ff ff       	jmp    101d75 <__alltraps>

00101def <vector10>:
.globl vector10
vector10:
  pushl $10
  101def:	6a 0a                	push   $0xa
  jmp __alltraps
  101df1:	e9 7f ff ff ff       	jmp    101d75 <__alltraps>

00101df6 <vector11>:
.globl vector11
vector11:
  pushl $11
  101df6:	6a 0b                	push   $0xb
  jmp __alltraps
  101df8:	e9 78 ff ff ff       	jmp    101d75 <__alltraps>

00101dfd <vector12>:
.globl vector12
vector12:
  pushl $12
  101dfd:	6a 0c                	push   $0xc
  jmp __alltraps
  101dff:	e9 71 ff ff ff       	jmp    101d75 <__alltraps>

00101e04 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e04:	6a 0d                	push   $0xd
  jmp __alltraps
  101e06:	e9 6a ff ff ff       	jmp    101d75 <__alltraps>

00101e0b <vector14>:
.globl vector14
vector14:
  pushl $14
  101e0b:	6a 0e                	push   $0xe
  jmp __alltraps
  101e0d:	e9 63 ff ff ff       	jmp    101d75 <__alltraps>

00101e12 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e12:	6a 00                	push   $0x0
  pushl $15
  101e14:	6a 0f                	push   $0xf
  jmp __alltraps
  101e16:	e9 5a ff ff ff       	jmp    101d75 <__alltraps>

00101e1b <vector16>:
.globl vector16
vector16:
  pushl $0
  101e1b:	6a 00                	push   $0x0
  pushl $16
  101e1d:	6a 10                	push   $0x10
  jmp __alltraps
  101e1f:	e9 51 ff ff ff       	jmp    101d75 <__alltraps>

00101e24 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e24:	6a 11                	push   $0x11
  jmp __alltraps
  101e26:	e9 4a ff ff ff       	jmp    101d75 <__alltraps>

00101e2b <vector18>:
.globl vector18
vector18:
  pushl $0
  101e2b:	6a 00                	push   $0x0
  pushl $18
  101e2d:	6a 12                	push   $0x12
  jmp __alltraps
  101e2f:	e9 41 ff ff ff       	jmp    101d75 <__alltraps>

00101e34 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e34:	6a 00                	push   $0x0
  pushl $19
  101e36:	6a 13                	push   $0x13
  jmp __alltraps
  101e38:	e9 38 ff ff ff       	jmp    101d75 <__alltraps>

00101e3d <vector20>:
.globl vector20
vector20:
  pushl $0
  101e3d:	6a 00                	push   $0x0
  pushl $20
  101e3f:	6a 14                	push   $0x14
  jmp __alltraps
  101e41:	e9 2f ff ff ff       	jmp    101d75 <__alltraps>

00101e46 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e46:	6a 00                	push   $0x0
  pushl $21
  101e48:	6a 15                	push   $0x15
  jmp __alltraps
  101e4a:	e9 26 ff ff ff       	jmp    101d75 <__alltraps>

00101e4f <vector22>:
.globl vector22
vector22:
  pushl $0
  101e4f:	6a 00                	push   $0x0
  pushl $22
  101e51:	6a 16                	push   $0x16
  jmp __alltraps
  101e53:	e9 1d ff ff ff       	jmp    101d75 <__alltraps>

00101e58 <vector23>:
.globl vector23
vector23:
  pushl $0
  101e58:	6a 00                	push   $0x0
  pushl $23
  101e5a:	6a 17                	push   $0x17
  jmp __alltraps
  101e5c:	e9 14 ff ff ff       	jmp    101d75 <__alltraps>

00101e61 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e61:	6a 00                	push   $0x0
  pushl $24
  101e63:	6a 18                	push   $0x18
  jmp __alltraps
  101e65:	e9 0b ff ff ff       	jmp    101d75 <__alltraps>

00101e6a <vector25>:
.globl vector25
vector25:
  pushl $0
  101e6a:	6a 00                	push   $0x0
  pushl $25
  101e6c:	6a 19                	push   $0x19
  jmp __alltraps
  101e6e:	e9 02 ff ff ff       	jmp    101d75 <__alltraps>

00101e73 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e73:	6a 00                	push   $0x0
  pushl $26
  101e75:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e77:	e9 f9 fe ff ff       	jmp    101d75 <__alltraps>

00101e7c <vector27>:
.globl vector27
vector27:
  pushl $0
  101e7c:	6a 00                	push   $0x0
  pushl $27
  101e7e:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e80:	e9 f0 fe ff ff       	jmp    101d75 <__alltraps>

00101e85 <vector28>:
.globl vector28
vector28:
  pushl $0
  101e85:	6a 00                	push   $0x0
  pushl $28
  101e87:	6a 1c                	push   $0x1c
  jmp __alltraps
  101e89:	e9 e7 fe ff ff       	jmp    101d75 <__alltraps>

00101e8e <vector29>:
.globl vector29
vector29:
  pushl $0
  101e8e:	6a 00                	push   $0x0
  pushl $29
  101e90:	6a 1d                	push   $0x1d
  jmp __alltraps
  101e92:	e9 de fe ff ff       	jmp    101d75 <__alltraps>

00101e97 <vector30>:
.globl vector30
vector30:
  pushl $0
  101e97:	6a 00                	push   $0x0
  pushl $30
  101e99:	6a 1e                	push   $0x1e
  jmp __alltraps
  101e9b:	e9 d5 fe ff ff       	jmp    101d75 <__alltraps>

00101ea0 <vector31>:
.globl vector31
vector31:
  pushl $0
  101ea0:	6a 00                	push   $0x0
  pushl $31
  101ea2:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ea4:	e9 cc fe ff ff       	jmp    101d75 <__alltraps>

00101ea9 <vector32>:
.globl vector32
vector32:
  pushl $0
  101ea9:	6a 00                	push   $0x0
  pushl $32
  101eab:	6a 20                	push   $0x20
  jmp __alltraps
  101ead:	e9 c3 fe ff ff       	jmp    101d75 <__alltraps>

00101eb2 <vector33>:
.globl vector33
vector33:
  pushl $0
  101eb2:	6a 00                	push   $0x0
  pushl $33
  101eb4:	6a 21                	push   $0x21
  jmp __alltraps
  101eb6:	e9 ba fe ff ff       	jmp    101d75 <__alltraps>

00101ebb <vector34>:
.globl vector34
vector34:
  pushl $0
  101ebb:	6a 00                	push   $0x0
  pushl $34
  101ebd:	6a 22                	push   $0x22
  jmp __alltraps
  101ebf:	e9 b1 fe ff ff       	jmp    101d75 <__alltraps>

00101ec4 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ec4:	6a 00                	push   $0x0
  pushl $35
  101ec6:	6a 23                	push   $0x23
  jmp __alltraps
  101ec8:	e9 a8 fe ff ff       	jmp    101d75 <__alltraps>

00101ecd <vector36>:
.globl vector36
vector36:
  pushl $0
  101ecd:	6a 00                	push   $0x0
  pushl $36
  101ecf:	6a 24                	push   $0x24
  jmp __alltraps
  101ed1:	e9 9f fe ff ff       	jmp    101d75 <__alltraps>

00101ed6 <vector37>:
.globl vector37
vector37:
  pushl $0
  101ed6:	6a 00                	push   $0x0
  pushl $37
  101ed8:	6a 25                	push   $0x25
  jmp __alltraps
  101eda:	e9 96 fe ff ff       	jmp    101d75 <__alltraps>

00101edf <vector38>:
.globl vector38
vector38:
  pushl $0
  101edf:	6a 00                	push   $0x0
  pushl $38
  101ee1:	6a 26                	push   $0x26
  jmp __alltraps
  101ee3:	e9 8d fe ff ff       	jmp    101d75 <__alltraps>

00101ee8 <vector39>:
.globl vector39
vector39:
  pushl $0
  101ee8:	6a 00                	push   $0x0
  pushl $39
  101eea:	6a 27                	push   $0x27
  jmp __alltraps
  101eec:	e9 84 fe ff ff       	jmp    101d75 <__alltraps>

00101ef1 <vector40>:
.globl vector40
vector40:
  pushl $0
  101ef1:	6a 00                	push   $0x0
  pushl $40
  101ef3:	6a 28                	push   $0x28
  jmp __alltraps
  101ef5:	e9 7b fe ff ff       	jmp    101d75 <__alltraps>

00101efa <vector41>:
.globl vector41
vector41:
  pushl $0
  101efa:	6a 00                	push   $0x0
  pushl $41
  101efc:	6a 29                	push   $0x29
  jmp __alltraps
  101efe:	e9 72 fe ff ff       	jmp    101d75 <__alltraps>

00101f03 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f03:	6a 00                	push   $0x0
  pushl $42
  101f05:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f07:	e9 69 fe ff ff       	jmp    101d75 <__alltraps>

00101f0c <vector43>:
.globl vector43
vector43:
  pushl $0
  101f0c:	6a 00                	push   $0x0
  pushl $43
  101f0e:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f10:	e9 60 fe ff ff       	jmp    101d75 <__alltraps>

00101f15 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f15:	6a 00                	push   $0x0
  pushl $44
  101f17:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f19:	e9 57 fe ff ff       	jmp    101d75 <__alltraps>

00101f1e <vector45>:
.globl vector45
vector45:
  pushl $0
  101f1e:	6a 00                	push   $0x0
  pushl $45
  101f20:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f22:	e9 4e fe ff ff       	jmp    101d75 <__alltraps>

00101f27 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f27:	6a 00                	push   $0x0
  pushl $46
  101f29:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f2b:	e9 45 fe ff ff       	jmp    101d75 <__alltraps>

00101f30 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f30:	6a 00                	push   $0x0
  pushl $47
  101f32:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f34:	e9 3c fe ff ff       	jmp    101d75 <__alltraps>

00101f39 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f39:	6a 00                	push   $0x0
  pushl $48
  101f3b:	6a 30                	push   $0x30
  jmp __alltraps
  101f3d:	e9 33 fe ff ff       	jmp    101d75 <__alltraps>

00101f42 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f42:	6a 00                	push   $0x0
  pushl $49
  101f44:	6a 31                	push   $0x31
  jmp __alltraps
  101f46:	e9 2a fe ff ff       	jmp    101d75 <__alltraps>

00101f4b <vector50>:
.globl vector50
vector50:
  pushl $0
  101f4b:	6a 00                	push   $0x0
  pushl $50
  101f4d:	6a 32                	push   $0x32
  jmp __alltraps
  101f4f:	e9 21 fe ff ff       	jmp    101d75 <__alltraps>

00101f54 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f54:	6a 00                	push   $0x0
  pushl $51
  101f56:	6a 33                	push   $0x33
  jmp __alltraps
  101f58:	e9 18 fe ff ff       	jmp    101d75 <__alltraps>

00101f5d <vector52>:
.globl vector52
vector52:
  pushl $0
  101f5d:	6a 00                	push   $0x0
  pushl $52
  101f5f:	6a 34                	push   $0x34
  jmp __alltraps
  101f61:	e9 0f fe ff ff       	jmp    101d75 <__alltraps>

00101f66 <vector53>:
.globl vector53
vector53:
  pushl $0
  101f66:	6a 00                	push   $0x0
  pushl $53
  101f68:	6a 35                	push   $0x35
  jmp __alltraps
  101f6a:	e9 06 fe ff ff       	jmp    101d75 <__alltraps>

00101f6f <vector54>:
.globl vector54
vector54:
  pushl $0
  101f6f:	6a 00                	push   $0x0
  pushl $54
  101f71:	6a 36                	push   $0x36
  jmp __alltraps
  101f73:	e9 fd fd ff ff       	jmp    101d75 <__alltraps>

00101f78 <vector55>:
.globl vector55
vector55:
  pushl $0
  101f78:	6a 00                	push   $0x0
  pushl $55
  101f7a:	6a 37                	push   $0x37
  jmp __alltraps
  101f7c:	e9 f4 fd ff ff       	jmp    101d75 <__alltraps>

00101f81 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f81:	6a 00                	push   $0x0
  pushl $56
  101f83:	6a 38                	push   $0x38
  jmp __alltraps
  101f85:	e9 eb fd ff ff       	jmp    101d75 <__alltraps>

00101f8a <vector57>:
.globl vector57
vector57:
  pushl $0
  101f8a:	6a 00                	push   $0x0
  pushl $57
  101f8c:	6a 39                	push   $0x39
  jmp __alltraps
  101f8e:	e9 e2 fd ff ff       	jmp    101d75 <__alltraps>

00101f93 <vector58>:
.globl vector58
vector58:
  pushl $0
  101f93:	6a 00                	push   $0x0
  pushl $58
  101f95:	6a 3a                	push   $0x3a
  jmp __alltraps
  101f97:	e9 d9 fd ff ff       	jmp    101d75 <__alltraps>

00101f9c <vector59>:
.globl vector59
vector59:
  pushl $0
  101f9c:	6a 00                	push   $0x0
  pushl $59
  101f9e:	6a 3b                	push   $0x3b
  jmp __alltraps
  101fa0:	e9 d0 fd ff ff       	jmp    101d75 <__alltraps>

00101fa5 <vector60>:
.globl vector60
vector60:
  pushl $0
  101fa5:	6a 00                	push   $0x0
  pushl $60
  101fa7:	6a 3c                	push   $0x3c
  jmp __alltraps
  101fa9:	e9 c7 fd ff ff       	jmp    101d75 <__alltraps>

00101fae <vector61>:
.globl vector61
vector61:
  pushl $0
  101fae:	6a 00                	push   $0x0
  pushl $61
  101fb0:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fb2:	e9 be fd ff ff       	jmp    101d75 <__alltraps>

00101fb7 <vector62>:
.globl vector62
vector62:
  pushl $0
  101fb7:	6a 00                	push   $0x0
  pushl $62
  101fb9:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fbb:	e9 b5 fd ff ff       	jmp    101d75 <__alltraps>

00101fc0 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fc0:	6a 00                	push   $0x0
  pushl $63
  101fc2:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fc4:	e9 ac fd ff ff       	jmp    101d75 <__alltraps>

00101fc9 <vector64>:
.globl vector64
vector64:
  pushl $0
  101fc9:	6a 00                	push   $0x0
  pushl $64
  101fcb:	6a 40                	push   $0x40
  jmp __alltraps
  101fcd:	e9 a3 fd ff ff       	jmp    101d75 <__alltraps>

00101fd2 <vector65>:
.globl vector65
vector65:
  pushl $0
  101fd2:	6a 00                	push   $0x0
  pushl $65
  101fd4:	6a 41                	push   $0x41
  jmp __alltraps
  101fd6:	e9 9a fd ff ff       	jmp    101d75 <__alltraps>

00101fdb <vector66>:
.globl vector66
vector66:
  pushl $0
  101fdb:	6a 00                	push   $0x0
  pushl $66
  101fdd:	6a 42                	push   $0x42
  jmp __alltraps
  101fdf:	e9 91 fd ff ff       	jmp    101d75 <__alltraps>

00101fe4 <vector67>:
.globl vector67
vector67:
  pushl $0
  101fe4:	6a 00                	push   $0x0
  pushl $67
  101fe6:	6a 43                	push   $0x43
  jmp __alltraps
  101fe8:	e9 88 fd ff ff       	jmp    101d75 <__alltraps>

00101fed <vector68>:
.globl vector68
vector68:
  pushl $0
  101fed:	6a 00                	push   $0x0
  pushl $68
  101fef:	6a 44                	push   $0x44
  jmp __alltraps
  101ff1:	e9 7f fd ff ff       	jmp    101d75 <__alltraps>

00101ff6 <vector69>:
.globl vector69
vector69:
  pushl $0
  101ff6:	6a 00                	push   $0x0
  pushl $69
  101ff8:	6a 45                	push   $0x45
  jmp __alltraps
  101ffa:	e9 76 fd ff ff       	jmp    101d75 <__alltraps>

00101fff <vector70>:
.globl vector70
vector70:
  pushl $0
  101fff:	6a 00                	push   $0x0
  pushl $70
  102001:	6a 46                	push   $0x46
  jmp __alltraps
  102003:	e9 6d fd ff ff       	jmp    101d75 <__alltraps>

00102008 <vector71>:
.globl vector71
vector71:
  pushl $0
  102008:	6a 00                	push   $0x0
  pushl $71
  10200a:	6a 47                	push   $0x47
  jmp __alltraps
  10200c:	e9 64 fd ff ff       	jmp    101d75 <__alltraps>

00102011 <vector72>:
.globl vector72
vector72:
  pushl $0
  102011:	6a 00                	push   $0x0
  pushl $72
  102013:	6a 48                	push   $0x48
  jmp __alltraps
  102015:	e9 5b fd ff ff       	jmp    101d75 <__alltraps>

0010201a <vector73>:
.globl vector73
vector73:
  pushl $0
  10201a:	6a 00                	push   $0x0
  pushl $73
  10201c:	6a 49                	push   $0x49
  jmp __alltraps
  10201e:	e9 52 fd ff ff       	jmp    101d75 <__alltraps>

00102023 <vector74>:
.globl vector74
vector74:
  pushl $0
  102023:	6a 00                	push   $0x0
  pushl $74
  102025:	6a 4a                	push   $0x4a
  jmp __alltraps
  102027:	e9 49 fd ff ff       	jmp    101d75 <__alltraps>

0010202c <vector75>:
.globl vector75
vector75:
  pushl $0
  10202c:	6a 00                	push   $0x0
  pushl $75
  10202e:	6a 4b                	push   $0x4b
  jmp __alltraps
  102030:	e9 40 fd ff ff       	jmp    101d75 <__alltraps>

00102035 <vector76>:
.globl vector76
vector76:
  pushl $0
  102035:	6a 00                	push   $0x0
  pushl $76
  102037:	6a 4c                	push   $0x4c
  jmp __alltraps
  102039:	e9 37 fd ff ff       	jmp    101d75 <__alltraps>

0010203e <vector77>:
.globl vector77
vector77:
  pushl $0
  10203e:	6a 00                	push   $0x0
  pushl $77
  102040:	6a 4d                	push   $0x4d
  jmp __alltraps
  102042:	e9 2e fd ff ff       	jmp    101d75 <__alltraps>

00102047 <vector78>:
.globl vector78
vector78:
  pushl $0
  102047:	6a 00                	push   $0x0
  pushl $78
  102049:	6a 4e                	push   $0x4e
  jmp __alltraps
  10204b:	e9 25 fd ff ff       	jmp    101d75 <__alltraps>

00102050 <vector79>:
.globl vector79
vector79:
  pushl $0
  102050:	6a 00                	push   $0x0
  pushl $79
  102052:	6a 4f                	push   $0x4f
  jmp __alltraps
  102054:	e9 1c fd ff ff       	jmp    101d75 <__alltraps>

00102059 <vector80>:
.globl vector80
vector80:
  pushl $0
  102059:	6a 00                	push   $0x0
  pushl $80
  10205b:	6a 50                	push   $0x50
  jmp __alltraps
  10205d:	e9 13 fd ff ff       	jmp    101d75 <__alltraps>

00102062 <vector81>:
.globl vector81
vector81:
  pushl $0
  102062:	6a 00                	push   $0x0
  pushl $81
  102064:	6a 51                	push   $0x51
  jmp __alltraps
  102066:	e9 0a fd ff ff       	jmp    101d75 <__alltraps>

0010206b <vector82>:
.globl vector82
vector82:
  pushl $0
  10206b:	6a 00                	push   $0x0
  pushl $82
  10206d:	6a 52                	push   $0x52
  jmp __alltraps
  10206f:	e9 01 fd ff ff       	jmp    101d75 <__alltraps>

00102074 <vector83>:
.globl vector83
vector83:
  pushl $0
  102074:	6a 00                	push   $0x0
  pushl $83
  102076:	6a 53                	push   $0x53
  jmp __alltraps
  102078:	e9 f8 fc ff ff       	jmp    101d75 <__alltraps>

0010207d <vector84>:
.globl vector84
vector84:
  pushl $0
  10207d:	6a 00                	push   $0x0
  pushl $84
  10207f:	6a 54                	push   $0x54
  jmp __alltraps
  102081:	e9 ef fc ff ff       	jmp    101d75 <__alltraps>

00102086 <vector85>:
.globl vector85
vector85:
  pushl $0
  102086:	6a 00                	push   $0x0
  pushl $85
  102088:	6a 55                	push   $0x55
  jmp __alltraps
  10208a:	e9 e6 fc ff ff       	jmp    101d75 <__alltraps>

0010208f <vector86>:
.globl vector86
vector86:
  pushl $0
  10208f:	6a 00                	push   $0x0
  pushl $86
  102091:	6a 56                	push   $0x56
  jmp __alltraps
  102093:	e9 dd fc ff ff       	jmp    101d75 <__alltraps>

00102098 <vector87>:
.globl vector87
vector87:
  pushl $0
  102098:	6a 00                	push   $0x0
  pushl $87
  10209a:	6a 57                	push   $0x57
  jmp __alltraps
  10209c:	e9 d4 fc ff ff       	jmp    101d75 <__alltraps>

001020a1 <vector88>:
.globl vector88
vector88:
  pushl $0
  1020a1:	6a 00                	push   $0x0
  pushl $88
  1020a3:	6a 58                	push   $0x58
  jmp __alltraps
  1020a5:	e9 cb fc ff ff       	jmp    101d75 <__alltraps>

001020aa <vector89>:
.globl vector89
vector89:
  pushl $0
  1020aa:	6a 00                	push   $0x0
  pushl $89
  1020ac:	6a 59                	push   $0x59
  jmp __alltraps
  1020ae:	e9 c2 fc ff ff       	jmp    101d75 <__alltraps>

001020b3 <vector90>:
.globl vector90
vector90:
  pushl $0
  1020b3:	6a 00                	push   $0x0
  pushl $90
  1020b5:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020b7:	e9 b9 fc ff ff       	jmp    101d75 <__alltraps>

001020bc <vector91>:
.globl vector91
vector91:
  pushl $0
  1020bc:	6a 00                	push   $0x0
  pushl $91
  1020be:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020c0:	e9 b0 fc ff ff       	jmp    101d75 <__alltraps>

001020c5 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020c5:	6a 00                	push   $0x0
  pushl $92
  1020c7:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020c9:	e9 a7 fc ff ff       	jmp    101d75 <__alltraps>

001020ce <vector93>:
.globl vector93
vector93:
  pushl $0
  1020ce:	6a 00                	push   $0x0
  pushl $93
  1020d0:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020d2:	e9 9e fc ff ff       	jmp    101d75 <__alltraps>

001020d7 <vector94>:
.globl vector94
vector94:
  pushl $0
  1020d7:	6a 00                	push   $0x0
  pushl $94
  1020d9:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020db:	e9 95 fc ff ff       	jmp    101d75 <__alltraps>

001020e0 <vector95>:
.globl vector95
vector95:
  pushl $0
  1020e0:	6a 00                	push   $0x0
  pushl $95
  1020e2:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020e4:	e9 8c fc ff ff       	jmp    101d75 <__alltraps>

001020e9 <vector96>:
.globl vector96
vector96:
  pushl $0
  1020e9:	6a 00                	push   $0x0
  pushl $96
  1020eb:	6a 60                	push   $0x60
  jmp __alltraps
  1020ed:	e9 83 fc ff ff       	jmp    101d75 <__alltraps>

001020f2 <vector97>:
.globl vector97
vector97:
  pushl $0
  1020f2:	6a 00                	push   $0x0
  pushl $97
  1020f4:	6a 61                	push   $0x61
  jmp __alltraps
  1020f6:	e9 7a fc ff ff       	jmp    101d75 <__alltraps>

001020fb <vector98>:
.globl vector98
vector98:
  pushl $0
  1020fb:	6a 00                	push   $0x0
  pushl $98
  1020fd:	6a 62                	push   $0x62
  jmp __alltraps
  1020ff:	e9 71 fc ff ff       	jmp    101d75 <__alltraps>

00102104 <vector99>:
.globl vector99
vector99:
  pushl $0
  102104:	6a 00                	push   $0x0
  pushl $99
  102106:	6a 63                	push   $0x63
  jmp __alltraps
  102108:	e9 68 fc ff ff       	jmp    101d75 <__alltraps>

0010210d <vector100>:
.globl vector100
vector100:
  pushl $0
  10210d:	6a 00                	push   $0x0
  pushl $100
  10210f:	6a 64                	push   $0x64
  jmp __alltraps
  102111:	e9 5f fc ff ff       	jmp    101d75 <__alltraps>

00102116 <vector101>:
.globl vector101
vector101:
  pushl $0
  102116:	6a 00                	push   $0x0
  pushl $101
  102118:	6a 65                	push   $0x65
  jmp __alltraps
  10211a:	e9 56 fc ff ff       	jmp    101d75 <__alltraps>

0010211f <vector102>:
.globl vector102
vector102:
  pushl $0
  10211f:	6a 00                	push   $0x0
  pushl $102
  102121:	6a 66                	push   $0x66
  jmp __alltraps
  102123:	e9 4d fc ff ff       	jmp    101d75 <__alltraps>

00102128 <vector103>:
.globl vector103
vector103:
  pushl $0
  102128:	6a 00                	push   $0x0
  pushl $103
  10212a:	6a 67                	push   $0x67
  jmp __alltraps
  10212c:	e9 44 fc ff ff       	jmp    101d75 <__alltraps>

00102131 <vector104>:
.globl vector104
vector104:
  pushl $0
  102131:	6a 00                	push   $0x0
  pushl $104
  102133:	6a 68                	push   $0x68
  jmp __alltraps
  102135:	e9 3b fc ff ff       	jmp    101d75 <__alltraps>

0010213a <vector105>:
.globl vector105
vector105:
  pushl $0
  10213a:	6a 00                	push   $0x0
  pushl $105
  10213c:	6a 69                	push   $0x69
  jmp __alltraps
  10213e:	e9 32 fc ff ff       	jmp    101d75 <__alltraps>

00102143 <vector106>:
.globl vector106
vector106:
  pushl $0
  102143:	6a 00                	push   $0x0
  pushl $106
  102145:	6a 6a                	push   $0x6a
  jmp __alltraps
  102147:	e9 29 fc ff ff       	jmp    101d75 <__alltraps>

0010214c <vector107>:
.globl vector107
vector107:
  pushl $0
  10214c:	6a 00                	push   $0x0
  pushl $107
  10214e:	6a 6b                	push   $0x6b
  jmp __alltraps
  102150:	e9 20 fc ff ff       	jmp    101d75 <__alltraps>

00102155 <vector108>:
.globl vector108
vector108:
  pushl $0
  102155:	6a 00                	push   $0x0
  pushl $108
  102157:	6a 6c                	push   $0x6c
  jmp __alltraps
  102159:	e9 17 fc ff ff       	jmp    101d75 <__alltraps>

0010215e <vector109>:
.globl vector109
vector109:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $109
  102160:	6a 6d                	push   $0x6d
  jmp __alltraps
  102162:	e9 0e fc ff ff       	jmp    101d75 <__alltraps>

00102167 <vector110>:
.globl vector110
vector110:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $110
  102169:	6a 6e                	push   $0x6e
  jmp __alltraps
  10216b:	e9 05 fc ff ff       	jmp    101d75 <__alltraps>

00102170 <vector111>:
.globl vector111
vector111:
  pushl $0
  102170:	6a 00                	push   $0x0
  pushl $111
  102172:	6a 6f                	push   $0x6f
  jmp __alltraps
  102174:	e9 fc fb ff ff       	jmp    101d75 <__alltraps>

00102179 <vector112>:
.globl vector112
vector112:
  pushl $0
  102179:	6a 00                	push   $0x0
  pushl $112
  10217b:	6a 70                	push   $0x70
  jmp __alltraps
  10217d:	e9 f3 fb ff ff       	jmp    101d75 <__alltraps>

00102182 <vector113>:
.globl vector113
vector113:
  pushl $0
  102182:	6a 00                	push   $0x0
  pushl $113
  102184:	6a 71                	push   $0x71
  jmp __alltraps
  102186:	e9 ea fb ff ff       	jmp    101d75 <__alltraps>

0010218b <vector114>:
.globl vector114
vector114:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $114
  10218d:	6a 72                	push   $0x72
  jmp __alltraps
  10218f:	e9 e1 fb ff ff       	jmp    101d75 <__alltraps>

00102194 <vector115>:
.globl vector115
vector115:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $115
  102196:	6a 73                	push   $0x73
  jmp __alltraps
  102198:	e9 d8 fb ff ff       	jmp    101d75 <__alltraps>

0010219d <vector116>:
.globl vector116
vector116:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $116
  10219f:	6a 74                	push   $0x74
  jmp __alltraps
  1021a1:	e9 cf fb ff ff       	jmp    101d75 <__alltraps>

001021a6 <vector117>:
.globl vector117
vector117:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $117
  1021a8:	6a 75                	push   $0x75
  jmp __alltraps
  1021aa:	e9 c6 fb ff ff       	jmp    101d75 <__alltraps>

001021af <vector118>:
.globl vector118
vector118:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $118
  1021b1:	6a 76                	push   $0x76
  jmp __alltraps
  1021b3:	e9 bd fb ff ff       	jmp    101d75 <__alltraps>

001021b8 <vector119>:
.globl vector119
vector119:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $119
  1021ba:	6a 77                	push   $0x77
  jmp __alltraps
  1021bc:	e9 b4 fb ff ff       	jmp    101d75 <__alltraps>

001021c1 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $120
  1021c3:	6a 78                	push   $0x78
  jmp __alltraps
  1021c5:	e9 ab fb ff ff       	jmp    101d75 <__alltraps>

001021ca <vector121>:
.globl vector121
vector121:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $121
  1021cc:	6a 79                	push   $0x79
  jmp __alltraps
  1021ce:	e9 a2 fb ff ff       	jmp    101d75 <__alltraps>

001021d3 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021d3:	6a 00                	push   $0x0
  pushl $122
  1021d5:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021d7:	e9 99 fb ff ff       	jmp    101d75 <__alltraps>

001021dc <vector123>:
.globl vector123
vector123:
  pushl $0
  1021dc:	6a 00                	push   $0x0
  pushl $123
  1021de:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021e0:	e9 90 fb ff ff       	jmp    101d75 <__alltraps>

001021e5 <vector124>:
.globl vector124
vector124:
  pushl $0
  1021e5:	6a 00                	push   $0x0
  pushl $124
  1021e7:	6a 7c                	push   $0x7c
  jmp __alltraps
  1021e9:	e9 87 fb ff ff       	jmp    101d75 <__alltraps>

001021ee <vector125>:
.globl vector125
vector125:
  pushl $0
  1021ee:	6a 00                	push   $0x0
  pushl $125
  1021f0:	6a 7d                	push   $0x7d
  jmp __alltraps
  1021f2:	e9 7e fb ff ff       	jmp    101d75 <__alltraps>

001021f7 <vector126>:
.globl vector126
vector126:
  pushl $0
  1021f7:	6a 00                	push   $0x0
  pushl $126
  1021f9:	6a 7e                	push   $0x7e
  jmp __alltraps
  1021fb:	e9 75 fb ff ff       	jmp    101d75 <__alltraps>

00102200 <vector127>:
.globl vector127
vector127:
  pushl $0
  102200:	6a 00                	push   $0x0
  pushl $127
  102202:	6a 7f                	push   $0x7f
  jmp __alltraps
  102204:	e9 6c fb ff ff       	jmp    101d75 <__alltraps>

00102209 <vector128>:
.globl vector128
vector128:
  pushl $0
  102209:	6a 00                	push   $0x0
  pushl $128
  10220b:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102210:	e9 60 fb ff ff       	jmp    101d75 <__alltraps>

00102215 <vector129>:
.globl vector129
vector129:
  pushl $0
  102215:	6a 00                	push   $0x0
  pushl $129
  102217:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10221c:	e9 54 fb ff ff       	jmp    101d75 <__alltraps>

00102221 <vector130>:
.globl vector130
vector130:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $130
  102223:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102228:	e9 48 fb ff ff       	jmp    101d75 <__alltraps>

0010222d <vector131>:
.globl vector131
vector131:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $131
  10222f:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102234:	e9 3c fb ff ff       	jmp    101d75 <__alltraps>

00102239 <vector132>:
.globl vector132
vector132:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $132
  10223b:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102240:	e9 30 fb ff ff       	jmp    101d75 <__alltraps>

00102245 <vector133>:
.globl vector133
vector133:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $133
  102247:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10224c:	e9 24 fb ff ff       	jmp    101d75 <__alltraps>

00102251 <vector134>:
.globl vector134
vector134:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $134
  102253:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102258:	e9 18 fb ff ff       	jmp    101d75 <__alltraps>

0010225d <vector135>:
.globl vector135
vector135:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $135
  10225f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102264:	e9 0c fb ff ff       	jmp    101d75 <__alltraps>

00102269 <vector136>:
.globl vector136
vector136:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $136
  10226b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102270:	e9 00 fb ff ff       	jmp    101d75 <__alltraps>

00102275 <vector137>:
.globl vector137
vector137:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $137
  102277:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10227c:	e9 f4 fa ff ff       	jmp    101d75 <__alltraps>

00102281 <vector138>:
.globl vector138
vector138:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $138
  102283:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102288:	e9 e8 fa ff ff       	jmp    101d75 <__alltraps>

0010228d <vector139>:
.globl vector139
vector139:
  pushl $0
  10228d:	6a 00                	push   $0x0
  pushl $139
  10228f:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102294:	e9 dc fa ff ff       	jmp    101d75 <__alltraps>

00102299 <vector140>:
.globl vector140
vector140:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $140
  10229b:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022a0:	e9 d0 fa ff ff       	jmp    101d75 <__alltraps>

001022a5 <vector141>:
.globl vector141
vector141:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $141
  1022a7:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022ac:	e9 c4 fa ff ff       	jmp    101d75 <__alltraps>

001022b1 <vector142>:
.globl vector142
vector142:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $142
  1022b3:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022b8:	e9 b8 fa ff ff       	jmp    101d75 <__alltraps>

001022bd <vector143>:
.globl vector143
vector143:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $143
  1022bf:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022c4:	e9 ac fa ff ff       	jmp    101d75 <__alltraps>

001022c9 <vector144>:
.globl vector144
vector144:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $144
  1022cb:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022d0:	e9 a0 fa ff ff       	jmp    101d75 <__alltraps>

001022d5 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $145
  1022d7:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022dc:	e9 94 fa ff ff       	jmp    101d75 <__alltraps>

001022e1 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $146
  1022e3:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1022e8:	e9 88 fa ff ff       	jmp    101d75 <__alltraps>

001022ed <vector147>:
.globl vector147
vector147:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $147
  1022ef:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1022f4:	e9 7c fa ff ff       	jmp    101d75 <__alltraps>

001022f9 <vector148>:
.globl vector148
vector148:
  pushl $0
  1022f9:	6a 00                	push   $0x0
  pushl $148
  1022fb:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102300:	e9 70 fa ff ff       	jmp    101d75 <__alltraps>

00102305 <vector149>:
.globl vector149
vector149:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $149
  102307:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10230c:	e9 64 fa ff ff       	jmp    101d75 <__alltraps>

00102311 <vector150>:
.globl vector150
vector150:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $150
  102313:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102318:	e9 58 fa ff ff       	jmp    101d75 <__alltraps>

0010231d <vector151>:
.globl vector151
vector151:
  pushl $0
  10231d:	6a 00                	push   $0x0
  pushl $151
  10231f:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102324:	e9 4c fa ff ff       	jmp    101d75 <__alltraps>

00102329 <vector152>:
.globl vector152
vector152:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $152
  10232b:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102330:	e9 40 fa ff ff       	jmp    101d75 <__alltraps>

00102335 <vector153>:
.globl vector153
vector153:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $153
  102337:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10233c:	e9 34 fa ff ff       	jmp    101d75 <__alltraps>

00102341 <vector154>:
.globl vector154
vector154:
  pushl $0
  102341:	6a 00                	push   $0x0
  pushl $154
  102343:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102348:	e9 28 fa ff ff       	jmp    101d75 <__alltraps>

0010234d <vector155>:
.globl vector155
vector155:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $155
  10234f:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102354:	e9 1c fa ff ff       	jmp    101d75 <__alltraps>

00102359 <vector156>:
.globl vector156
vector156:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $156
  10235b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102360:	e9 10 fa ff ff       	jmp    101d75 <__alltraps>

00102365 <vector157>:
.globl vector157
vector157:
  pushl $0
  102365:	6a 00                	push   $0x0
  pushl $157
  102367:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10236c:	e9 04 fa ff ff       	jmp    101d75 <__alltraps>

00102371 <vector158>:
.globl vector158
vector158:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $158
  102373:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102378:	e9 f8 f9 ff ff       	jmp    101d75 <__alltraps>

0010237d <vector159>:
.globl vector159
vector159:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $159
  10237f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102384:	e9 ec f9 ff ff       	jmp    101d75 <__alltraps>

00102389 <vector160>:
.globl vector160
vector160:
  pushl $0
  102389:	6a 00                	push   $0x0
  pushl $160
  10238b:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102390:	e9 e0 f9 ff ff       	jmp    101d75 <__alltraps>

00102395 <vector161>:
.globl vector161
vector161:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $161
  102397:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10239c:	e9 d4 f9 ff ff       	jmp    101d75 <__alltraps>

001023a1 <vector162>:
.globl vector162
vector162:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $162
  1023a3:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023a8:	e9 c8 f9 ff ff       	jmp    101d75 <__alltraps>

001023ad <vector163>:
.globl vector163
vector163:
  pushl $0
  1023ad:	6a 00                	push   $0x0
  pushl $163
  1023af:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023b4:	e9 bc f9 ff ff       	jmp    101d75 <__alltraps>

001023b9 <vector164>:
.globl vector164
vector164:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $164
  1023bb:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023c0:	e9 b0 f9 ff ff       	jmp    101d75 <__alltraps>

001023c5 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $165
  1023c7:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023cc:	e9 a4 f9 ff ff       	jmp    101d75 <__alltraps>

001023d1 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023d1:	6a 00                	push   $0x0
  pushl $166
  1023d3:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023d8:	e9 98 f9 ff ff       	jmp    101d75 <__alltraps>

001023dd <vector167>:
.globl vector167
vector167:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $167
  1023df:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023e4:	e9 8c f9 ff ff       	jmp    101d75 <__alltraps>

001023e9 <vector168>:
.globl vector168
vector168:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $168
  1023eb:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1023f0:	e9 80 f9 ff ff       	jmp    101d75 <__alltraps>

001023f5 <vector169>:
.globl vector169
vector169:
  pushl $0
  1023f5:	6a 00                	push   $0x0
  pushl $169
  1023f7:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1023fc:	e9 74 f9 ff ff       	jmp    101d75 <__alltraps>

00102401 <vector170>:
.globl vector170
vector170:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $170
  102403:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102408:	e9 68 f9 ff ff       	jmp    101d75 <__alltraps>

0010240d <vector171>:
.globl vector171
vector171:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $171
  10240f:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102414:	e9 5c f9 ff ff       	jmp    101d75 <__alltraps>

00102419 <vector172>:
.globl vector172
vector172:
  pushl $0
  102419:	6a 00                	push   $0x0
  pushl $172
  10241b:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102420:	e9 50 f9 ff ff       	jmp    101d75 <__alltraps>

00102425 <vector173>:
.globl vector173
vector173:
  pushl $0
  102425:	6a 00                	push   $0x0
  pushl $173
  102427:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10242c:	e9 44 f9 ff ff       	jmp    101d75 <__alltraps>

00102431 <vector174>:
.globl vector174
vector174:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $174
  102433:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102438:	e9 38 f9 ff ff       	jmp    101d75 <__alltraps>

0010243d <vector175>:
.globl vector175
vector175:
  pushl $0
  10243d:	6a 00                	push   $0x0
  pushl $175
  10243f:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102444:	e9 2c f9 ff ff       	jmp    101d75 <__alltraps>

00102449 <vector176>:
.globl vector176
vector176:
  pushl $0
  102449:	6a 00                	push   $0x0
  pushl $176
  10244b:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102450:	e9 20 f9 ff ff       	jmp    101d75 <__alltraps>

00102455 <vector177>:
.globl vector177
vector177:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $177
  102457:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10245c:	e9 14 f9 ff ff       	jmp    101d75 <__alltraps>

00102461 <vector178>:
.globl vector178
vector178:
  pushl $0
  102461:	6a 00                	push   $0x0
  pushl $178
  102463:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102468:	e9 08 f9 ff ff       	jmp    101d75 <__alltraps>

0010246d <vector179>:
.globl vector179
vector179:
  pushl $0
  10246d:	6a 00                	push   $0x0
  pushl $179
  10246f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102474:	e9 fc f8 ff ff       	jmp    101d75 <__alltraps>

00102479 <vector180>:
.globl vector180
vector180:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $180
  10247b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102480:	e9 f0 f8 ff ff       	jmp    101d75 <__alltraps>

00102485 <vector181>:
.globl vector181
vector181:
  pushl $0
  102485:	6a 00                	push   $0x0
  pushl $181
  102487:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10248c:	e9 e4 f8 ff ff       	jmp    101d75 <__alltraps>

00102491 <vector182>:
.globl vector182
vector182:
  pushl $0
  102491:	6a 00                	push   $0x0
  pushl $182
  102493:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102498:	e9 d8 f8 ff ff       	jmp    101d75 <__alltraps>

0010249d <vector183>:
.globl vector183
vector183:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $183
  10249f:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024a4:	e9 cc f8 ff ff       	jmp    101d75 <__alltraps>

001024a9 <vector184>:
.globl vector184
vector184:
  pushl $0
  1024a9:	6a 00                	push   $0x0
  pushl $184
  1024ab:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024b0:	e9 c0 f8 ff ff       	jmp    101d75 <__alltraps>

001024b5 <vector185>:
.globl vector185
vector185:
  pushl $0
  1024b5:	6a 00                	push   $0x0
  pushl $185
  1024b7:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024bc:	e9 b4 f8 ff ff       	jmp    101d75 <__alltraps>

001024c1 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $186
  1024c3:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024c8:	e9 a8 f8 ff ff       	jmp    101d75 <__alltraps>

001024cd <vector187>:
.globl vector187
vector187:
  pushl $0
  1024cd:	6a 00                	push   $0x0
  pushl $187
  1024cf:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024d4:	e9 9c f8 ff ff       	jmp    101d75 <__alltraps>

001024d9 <vector188>:
.globl vector188
vector188:
  pushl $0
  1024d9:	6a 00                	push   $0x0
  pushl $188
  1024db:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024e0:	e9 90 f8 ff ff       	jmp    101d75 <__alltraps>

001024e5 <vector189>:
.globl vector189
vector189:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $189
  1024e7:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1024ec:	e9 84 f8 ff ff       	jmp    101d75 <__alltraps>

001024f1 <vector190>:
.globl vector190
vector190:
  pushl $0
  1024f1:	6a 00                	push   $0x0
  pushl $190
  1024f3:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1024f8:	e9 78 f8 ff ff       	jmp    101d75 <__alltraps>

001024fd <vector191>:
.globl vector191
vector191:
  pushl $0
  1024fd:	6a 00                	push   $0x0
  pushl $191
  1024ff:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102504:	e9 6c f8 ff ff       	jmp    101d75 <__alltraps>

00102509 <vector192>:
.globl vector192
vector192:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $192
  10250b:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102510:	e9 60 f8 ff ff       	jmp    101d75 <__alltraps>

00102515 <vector193>:
.globl vector193
vector193:
  pushl $0
  102515:	6a 00                	push   $0x0
  pushl $193
  102517:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10251c:	e9 54 f8 ff ff       	jmp    101d75 <__alltraps>

00102521 <vector194>:
.globl vector194
vector194:
  pushl $0
  102521:	6a 00                	push   $0x0
  pushl $194
  102523:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102528:	e9 48 f8 ff ff       	jmp    101d75 <__alltraps>

0010252d <vector195>:
.globl vector195
vector195:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $195
  10252f:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102534:	e9 3c f8 ff ff       	jmp    101d75 <__alltraps>

00102539 <vector196>:
.globl vector196
vector196:
  pushl $0
  102539:	6a 00                	push   $0x0
  pushl $196
  10253b:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102540:	e9 30 f8 ff ff       	jmp    101d75 <__alltraps>

00102545 <vector197>:
.globl vector197
vector197:
  pushl $0
  102545:	6a 00                	push   $0x0
  pushl $197
  102547:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10254c:	e9 24 f8 ff ff       	jmp    101d75 <__alltraps>

00102551 <vector198>:
.globl vector198
vector198:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $198
  102553:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102558:	e9 18 f8 ff ff       	jmp    101d75 <__alltraps>

0010255d <vector199>:
.globl vector199
vector199:
  pushl $0
  10255d:	6a 00                	push   $0x0
  pushl $199
  10255f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102564:	e9 0c f8 ff ff       	jmp    101d75 <__alltraps>

00102569 <vector200>:
.globl vector200
vector200:
  pushl $0
  102569:	6a 00                	push   $0x0
  pushl $200
  10256b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102570:	e9 00 f8 ff ff       	jmp    101d75 <__alltraps>

00102575 <vector201>:
.globl vector201
vector201:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $201
  102577:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10257c:	e9 f4 f7 ff ff       	jmp    101d75 <__alltraps>

00102581 <vector202>:
.globl vector202
vector202:
  pushl $0
  102581:	6a 00                	push   $0x0
  pushl $202
  102583:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102588:	e9 e8 f7 ff ff       	jmp    101d75 <__alltraps>

0010258d <vector203>:
.globl vector203
vector203:
  pushl $0
  10258d:	6a 00                	push   $0x0
  pushl $203
  10258f:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102594:	e9 dc f7 ff ff       	jmp    101d75 <__alltraps>

00102599 <vector204>:
.globl vector204
vector204:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $204
  10259b:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025a0:	e9 d0 f7 ff ff       	jmp    101d75 <__alltraps>

001025a5 <vector205>:
.globl vector205
vector205:
  pushl $0
  1025a5:	6a 00                	push   $0x0
  pushl $205
  1025a7:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025ac:	e9 c4 f7 ff ff       	jmp    101d75 <__alltraps>

001025b1 <vector206>:
.globl vector206
vector206:
  pushl $0
  1025b1:	6a 00                	push   $0x0
  pushl $206
  1025b3:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025b8:	e9 b8 f7 ff ff       	jmp    101d75 <__alltraps>

001025bd <vector207>:
.globl vector207
vector207:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $207
  1025bf:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025c4:	e9 ac f7 ff ff       	jmp    101d75 <__alltraps>

001025c9 <vector208>:
.globl vector208
vector208:
  pushl $0
  1025c9:	6a 00                	push   $0x0
  pushl $208
  1025cb:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025d0:	e9 a0 f7 ff ff       	jmp    101d75 <__alltraps>

001025d5 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025d5:	6a 00                	push   $0x0
  pushl $209
  1025d7:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025dc:	e9 94 f7 ff ff       	jmp    101d75 <__alltraps>

001025e1 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $210
  1025e3:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1025e8:	e9 88 f7 ff ff       	jmp    101d75 <__alltraps>

001025ed <vector211>:
.globl vector211
vector211:
  pushl $0
  1025ed:	6a 00                	push   $0x0
  pushl $211
  1025ef:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1025f4:	e9 7c f7 ff ff       	jmp    101d75 <__alltraps>

001025f9 <vector212>:
.globl vector212
vector212:
  pushl $0
  1025f9:	6a 00                	push   $0x0
  pushl $212
  1025fb:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102600:	e9 70 f7 ff ff       	jmp    101d75 <__alltraps>

00102605 <vector213>:
.globl vector213
vector213:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $213
  102607:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10260c:	e9 64 f7 ff ff       	jmp    101d75 <__alltraps>

00102611 <vector214>:
.globl vector214
vector214:
  pushl $0
  102611:	6a 00                	push   $0x0
  pushl $214
  102613:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102618:	e9 58 f7 ff ff       	jmp    101d75 <__alltraps>

0010261d <vector215>:
.globl vector215
vector215:
  pushl $0
  10261d:	6a 00                	push   $0x0
  pushl $215
  10261f:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102624:	e9 4c f7 ff ff       	jmp    101d75 <__alltraps>

00102629 <vector216>:
.globl vector216
vector216:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $216
  10262b:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102630:	e9 40 f7 ff ff       	jmp    101d75 <__alltraps>

00102635 <vector217>:
.globl vector217
vector217:
  pushl $0
  102635:	6a 00                	push   $0x0
  pushl $217
  102637:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10263c:	e9 34 f7 ff ff       	jmp    101d75 <__alltraps>

00102641 <vector218>:
.globl vector218
vector218:
  pushl $0
  102641:	6a 00                	push   $0x0
  pushl $218
  102643:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102648:	e9 28 f7 ff ff       	jmp    101d75 <__alltraps>

0010264d <vector219>:
.globl vector219
vector219:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $219
  10264f:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102654:	e9 1c f7 ff ff       	jmp    101d75 <__alltraps>

00102659 <vector220>:
.globl vector220
vector220:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $220
  10265b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102660:	e9 10 f7 ff ff       	jmp    101d75 <__alltraps>

00102665 <vector221>:
.globl vector221
vector221:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $221
  102667:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10266c:	e9 04 f7 ff ff       	jmp    101d75 <__alltraps>

00102671 <vector222>:
.globl vector222
vector222:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $222
  102673:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102678:	e9 f8 f6 ff ff       	jmp    101d75 <__alltraps>

0010267d <vector223>:
.globl vector223
vector223:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $223
  10267f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102684:	e9 ec f6 ff ff       	jmp    101d75 <__alltraps>

00102689 <vector224>:
.globl vector224
vector224:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $224
  10268b:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102690:	e9 e0 f6 ff ff       	jmp    101d75 <__alltraps>

00102695 <vector225>:
.globl vector225
vector225:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $225
  102697:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10269c:	e9 d4 f6 ff ff       	jmp    101d75 <__alltraps>

001026a1 <vector226>:
.globl vector226
vector226:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $226
  1026a3:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026a8:	e9 c8 f6 ff ff       	jmp    101d75 <__alltraps>

001026ad <vector227>:
.globl vector227
vector227:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $227
  1026af:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026b4:	e9 bc f6 ff ff       	jmp    101d75 <__alltraps>

001026b9 <vector228>:
.globl vector228
vector228:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $228
  1026bb:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026c0:	e9 b0 f6 ff ff       	jmp    101d75 <__alltraps>

001026c5 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $229
  1026c7:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026cc:	e9 a4 f6 ff ff       	jmp    101d75 <__alltraps>

001026d1 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $230
  1026d3:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026d8:	e9 98 f6 ff ff       	jmp    101d75 <__alltraps>

001026dd <vector231>:
.globl vector231
vector231:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $231
  1026df:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026e4:	e9 8c f6 ff ff       	jmp    101d75 <__alltraps>

001026e9 <vector232>:
.globl vector232
vector232:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $232
  1026eb:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1026f0:	e9 80 f6 ff ff       	jmp    101d75 <__alltraps>

001026f5 <vector233>:
.globl vector233
vector233:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $233
  1026f7:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1026fc:	e9 74 f6 ff ff       	jmp    101d75 <__alltraps>

00102701 <vector234>:
.globl vector234
vector234:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $234
  102703:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102708:	e9 68 f6 ff ff       	jmp    101d75 <__alltraps>

0010270d <vector235>:
.globl vector235
vector235:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $235
  10270f:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102714:	e9 5c f6 ff ff       	jmp    101d75 <__alltraps>

00102719 <vector236>:
.globl vector236
vector236:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $236
  10271b:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102720:	e9 50 f6 ff ff       	jmp    101d75 <__alltraps>

00102725 <vector237>:
.globl vector237
vector237:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $237
  102727:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10272c:	e9 44 f6 ff ff       	jmp    101d75 <__alltraps>

00102731 <vector238>:
.globl vector238
vector238:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $238
  102733:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102738:	e9 38 f6 ff ff       	jmp    101d75 <__alltraps>

0010273d <vector239>:
.globl vector239
vector239:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $239
  10273f:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102744:	e9 2c f6 ff ff       	jmp    101d75 <__alltraps>

00102749 <vector240>:
.globl vector240
vector240:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $240
  10274b:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102750:	e9 20 f6 ff ff       	jmp    101d75 <__alltraps>

00102755 <vector241>:
.globl vector241
vector241:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $241
  102757:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10275c:	e9 14 f6 ff ff       	jmp    101d75 <__alltraps>

00102761 <vector242>:
.globl vector242
vector242:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $242
  102763:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102768:	e9 08 f6 ff ff       	jmp    101d75 <__alltraps>

0010276d <vector243>:
.globl vector243
vector243:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $243
  10276f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102774:	e9 fc f5 ff ff       	jmp    101d75 <__alltraps>

00102779 <vector244>:
.globl vector244
vector244:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $244
  10277b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102780:	e9 f0 f5 ff ff       	jmp    101d75 <__alltraps>

00102785 <vector245>:
.globl vector245
vector245:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $245
  102787:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10278c:	e9 e4 f5 ff ff       	jmp    101d75 <__alltraps>

00102791 <vector246>:
.globl vector246
vector246:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $246
  102793:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102798:	e9 d8 f5 ff ff       	jmp    101d75 <__alltraps>

0010279d <vector247>:
.globl vector247
vector247:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $247
  10279f:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027a4:	e9 cc f5 ff ff       	jmp    101d75 <__alltraps>

001027a9 <vector248>:
.globl vector248
vector248:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $248
  1027ab:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027b0:	e9 c0 f5 ff ff       	jmp    101d75 <__alltraps>

001027b5 <vector249>:
.globl vector249
vector249:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $249
  1027b7:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027bc:	e9 b4 f5 ff ff       	jmp    101d75 <__alltraps>

001027c1 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $250
  1027c3:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027c8:	e9 a8 f5 ff ff       	jmp    101d75 <__alltraps>

001027cd <vector251>:
.globl vector251
vector251:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $251
  1027cf:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027d4:	e9 9c f5 ff ff       	jmp    101d75 <__alltraps>

001027d9 <vector252>:
.globl vector252
vector252:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $252
  1027db:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027e0:	e9 90 f5 ff ff       	jmp    101d75 <__alltraps>

001027e5 <vector253>:
.globl vector253
vector253:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $253
  1027e7:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1027ec:	e9 84 f5 ff ff       	jmp    101d75 <__alltraps>

001027f1 <vector254>:
.globl vector254
vector254:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $254
  1027f3:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1027f8:	e9 78 f5 ff ff       	jmp    101d75 <__alltraps>

001027fd <vector255>:
.globl vector255
vector255:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $255
  1027ff:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102804:	e9 6c f5 ff ff       	jmp    101d75 <__alltraps>

00102809 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102809:	55                   	push   %ebp
  10280a:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  10280c:	8b 45 08             	mov    0x8(%ebp),%eax
  10280f:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102812:	b8 23 00 00 00       	mov    $0x23,%eax
  102817:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102819:	b8 23 00 00 00       	mov    $0x23,%eax
  10281e:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102820:	b8 10 00 00 00       	mov    $0x10,%eax
  102825:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102827:	b8 10 00 00 00       	mov    $0x10,%eax
  10282c:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  10282e:	b8 10 00 00 00       	mov    $0x10,%eax
  102833:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102835:	ea 3c 28 10 00 08 00 	ljmp   $0x8,$0x10283c
}
  10283c:	5d                   	pop    %ebp
  10283d:	c3                   	ret    

0010283e <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  10283e:	55                   	push   %ebp
  10283f:	89 e5                	mov    %esp,%ebp
  102841:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102844:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  102849:	05 00 04 00 00       	add    $0x400,%eax
  10284e:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102853:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  10285a:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  10285c:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  102863:	68 00 
  102865:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10286a:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  102870:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102875:	c1 e8 10             	shr    $0x10,%eax
  102878:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  10287d:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102884:	83 e0 f0             	and    $0xfffffff0,%eax
  102887:	83 c8 09             	or     $0x9,%eax
  10288a:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  10288f:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102896:	83 c8 10             	or     $0x10,%eax
  102899:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  10289e:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028a5:	83 e0 9f             	and    $0xffffff9f,%eax
  1028a8:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028ad:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028b4:	83 c8 80             	or     $0xffffff80,%eax
  1028b7:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028bc:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028c3:	83 e0 f0             	and    $0xfffffff0,%eax
  1028c6:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028cb:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028d2:	83 e0 ef             	and    $0xffffffef,%eax
  1028d5:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028da:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028e1:	83 e0 df             	and    $0xffffffdf,%eax
  1028e4:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028e9:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028f0:	83 c8 40             	or     $0x40,%eax
  1028f3:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028f8:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028ff:	83 e0 7f             	and    $0x7f,%eax
  102902:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102907:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10290c:	c1 e8 18             	shr    $0x18,%eax
  10290f:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102914:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10291b:	83 e0 ef             	and    $0xffffffef,%eax
  10291e:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102923:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  10292a:	e8 da fe ff ff       	call   102809 <lgdt>
  10292f:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102935:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102939:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  10293c:	c9                   	leave  
  10293d:	c3                   	ret    

0010293e <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  10293e:	55                   	push   %ebp
  10293f:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102941:	e8 f8 fe ff ff       	call   10283e <gdt_init>
}
  102946:	5d                   	pop    %ebp
  102947:	c3                   	ret    

00102948 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102948:	55                   	push   %ebp
  102949:	89 e5                	mov    %esp,%ebp
  10294b:	83 ec 58             	sub    $0x58,%esp
  10294e:	8b 45 10             	mov    0x10(%ebp),%eax
  102951:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102954:	8b 45 14             	mov    0x14(%ebp),%eax
  102957:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10295a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10295d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102960:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102963:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102966:	8b 45 18             	mov    0x18(%ebp),%eax
  102969:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10296c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10296f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102972:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102975:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102978:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10297b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10297e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102982:	74 1c                	je     1029a0 <printnum+0x58>
  102984:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102987:	ba 00 00 00 00       	mov    $0x0,%edx
  10298c:	f7 75 e4             	divl   -0x1c(%ebp)
  10298f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102992:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102995:	ba 00 00 00 00       	mov    $0x0,%edx
  10299a:	f7 75 e4             	divl   -0x1c(%ebp)
  10299d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1029a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1029a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1029a6:	f7 75 e4             	divl   -0x1c(%ebp)
  1029a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1029ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1029af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1029b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1029b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1029b8:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1029bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1029be:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1029c1:	8b 45 18             	mov    0x18(%ebp),%eax
  1029c4:	ba 00 00 00 00       	mov    $0x0,%edx
  1029c9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1029cc:	77 56                	ja     102a24 <printnum+0xdc>
  1029ce:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1029d1:	72 05                	jb     1029d8 <printnum+0x90>
  1029d3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1029d6:	77 4c                	ja     102a24 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1029d8:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1029db:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029de:	8b 45 20             	mov    0x20(%ebp),%eax
  1029e1:	89 44 24 18          	mov    %eax,0x18(%esp)
  1029e5:	89 54 24 14          	mov    %edx,0x14(%esp)
  1029e9:	8b 45 18             	mov    0x18(%ebp),%eax
  1029ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  1029f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1029f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1029f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1029fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1029fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a05:	8b 45 08             	mov    0x8(%ebp),%eax
  102a08:	89 04 24             	mov    %eax,(%esp)
  102a0b:	e8 38 ff ff ff       	call   102948 <printnum>
  102a10:	eb 1c                	jmp    102a2e <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a19:	8b 45 20             	mov    0x20(%ebp),%eax
  102a1c:	89 04 24             	mov    %eax,(%esp)
  102a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102a22:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  102a24:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102a28:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102a2c:	7f e4                	jg     102a12 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102a2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102a31:	05 50 3c 10 00       	add    $0x103c50,%eax
  102a36:	0f b6 00             	movzbl (%eax),%eax
  102a39:	0f be c0             	movsbl %al,%eax
  102a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  102a43:	89 04 24             	mov    %eax,(%esp)
  102a46:	8b 45 08             	mov    0x8(%ebp),%eax
  102a49:	ff d0                	call   *%eax
}
  102a4b:	c9                   	leave  
  102a4c:	c3                   	ret    

00102a4d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102a4d:	55                   	push   %ebp
  102a4e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102a50:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102a54:	7e 14                	jle    102a6a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102a56:	8b 45 08             	mov    0x8(%ebp),%eax
  102a59:	8b 00                	mov    (%eax),%eax
  102a5b:	8d 48 08             	lea    0x8(%eax),%ecx
  102a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  102a61:	89 0a                	mov    %ecx,(%edx)
  102a63:	8b 50 04             	mov    0x4(%eax),%edx
  102a66:	8b 00                	mov    (%eax),%eax
  102a68:	eb 30                	jmp    102a9a <getuint+0x4d>
    }
    else if (lflag) {
  102a6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102a6e:	74 16                	je     102a86 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102a70:	8b 45 08             	mov    0x8(%ebp),%eax
  102a73:	8b 00                	mov    (%eax),%eax
  102a75:	8d 48 04             	lea    0x4(%eax),%ecx
  102a78:	8b 55 08             	mov    0x8(%ebp),%edx
  102a7b:	89 0a                	mov    %ecx,(%edx)
  102a7d:	8b 00                	mov    (%eax),%eax
  102a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  102a84:	eb 14                	jmp    102a9a <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102a86:	8b 45 08             	mov    0x8(%ebp),%eax
  102a89:	8b 00                	mov    (%eax),%eax
  102a8b:	8d 48 04             	lea    0x4(%eax),%ecx
  102a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  102a91:	89 0a                	mov    %ecx,(%edx)
  102a93:	8b 00                	mov    (%eax),%eax
  102a95:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102a9a:	5d                   	pop    %ebp
  102a9b:	c3                   	ret    

00102a9c <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102a9c:	55                   	push   %ebp
  102a9d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102a9f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102aa3:	7e 14                	jle    102ab9 <getint+0x1d>
        return va_arg(*ap, long long);
  102aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  102aa8:	8b 00                	mov    (%eax),%eax
  102aaa:	8d 48 08             	lea    0x8(%eax),%ecx
  102aad:	8b 55 08             	mov    0x8(%ebp),%edx
  102ab0:	89 0a                	mov    %ecx,(%edx)
  102ab2:	8b 50 04             	mov    0x4(%eax),%edx
  102ab5:	8b 00                	mov    (%eax),%eax
  102ab7:	eb 28                	jmp    102ae1 <getint+0x45>
    }
    else if (lflag) {
  102ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102abd:	74 12                	je     102ad1 <getint+0x35>
        return va_arg(*ap, long);
  102abf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ac2:	8b 00                	mov    (%eax),%eax
  102ac4:	8d 48 04             	lea    0x4(%eax),%ecx
  102ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  102aca:	89 0a                	mov    %ecx,(%edx)
  102acc:	8b 00                	mov    (%eax),%eax
  102ace:	99                   	cltd   
  102acf:	eb 10                	jmp    102ae1 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ad4:	8b 00                	mov    (%eax),%eax
  102ad6:	8d 48 04             	lea    0x4(%eax),%ecx
  102ad9:	8b 55 08             	mov    0x8(%ebp),%edx
  102adc:	89 0a                	mov    %ecx,(%edx)
  102ade:	8b 00                	mov    (%eax),%eax
  102ae0:	99                   	cltd   
    }
}
  102ae1:	5d                   	pop    %ebp
  102ae2:	c3                   	ret    

00102ae3 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102ae3:	55                   	push   %ebp
  102ae4:	89 e5                	mov    %esp,%ebp
  102ae6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102ae9:	8d 45 14             	lea    0x14(%ebp),%eax
  102aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102af2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102af6:	8b 45 10             	mov    0x10(%ebp),%eax
  102af9:	89 44 24 08          	mov    %eax,0x8(%esp)
  102afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b04:	8b 45 08             	mov    0x8(%ebp),%eax
  102b07:	89 04 24             	mov    %eax,(%esp)
  102b0a:	e8 02 00 00 00       	call   102b11 <vprintfmt>
    va_end(ap);
}
  102b0f:	c9                   	leave  
  102b10:	c3                   	ret    

00102b11 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102b11:	55                   	push   %ebp
  102b12:	89 e5                	mov    %esp,%ebp
  102b14:	56                   	push   %esi
  102b15:	53                   	push   %ebx
  102b16:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102b19:	eb 18                	jmp    102b33 <vprintfmt+0x22>
            if (ch == '\0') {
  102b1b:	85 db                	test   %ebx,%ebx
  102b1d:	75 05                	jne    102b24 <vprintfmt+0x13>
                return;
  102b1f:	e9 d1 03 00 00       	jmp    102ef5 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  102b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b2b:	89 1c 24             	mov    %ebx,(%esp)
  102b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b31:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102b33:	8b 45 10             	mov    0x10(%ebp),%eax
  102b36:	8d 50 01             	lea    0x1(%eax),%edx
  102b39:	89 55 10             	mov    %edx,0x10(%ebp)
  102b3c:	0f b6 00             	movzbl (%eax),%eax
  102b3f:	0f b6 d8             	movzbl %al,%ebx
  102b42:	83 fb 25             	cmp    $0x25,%ebx
  102b45:	75 d4                	jne    102b1b <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  102b47:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102b4b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102b52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102b55:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102b58:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102b5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b62:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102b65:	8b 45 10             	mov    0x10(%ebp),%eax
  102b68:	8d 50 01             	lea    0x1(%eax),%edx
  102b6b:	89 55 10             	mov    %edx,0x10(%ebp)
  102b6e:	0f b6 00             	movzbl (%eax),%eax
  102b71:	0f b6 d8             	movzbl %al,%ebx
  102b74:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102b77:	83 f8 55             	cmp    $0x55,%eax
  102b7a:	0f 87 44 03 00 00    	ja     102ec4 <vprintfmt+0x3b3>
  102b80:	8b 04 85 74 3c 10 00 	mov    0x103c74(,%eax,4),%eax
  102b87:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102b89:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102b8d:	eb d6                	jmp    102b65 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102b8f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102b93:	eb d0                	jmp    102b65 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102b95:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102b9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102b9f:	89 d0                	mov    %edx,%eax
  102ba1:	c1 e0 02             	shl    $0x2,%eax
  102ba4:	01 d0                	add    %edx,%eax
  102ba6:	01 c0                	add    %eax,%eax
  102ba8:	01 d8                	add    %ebx,%eax
  102baa:	83 e8 30             	sub    $0x30,%eax
  102bad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  102bb3:	0f b6 00             	movzbl (%eax),%eax
  102bb6:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102bb9:	83 fb 2f             	cmp    $0x2f,%ebx
  102bbc:	7e 0b                	jle    102bc9 <vprintfmt+0xb8>
  102bbe:	83 fb 39             	cmp    $0x39,%ebx
  102bc1:	7f 06                	jg     102bc9 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102bc3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  102bc7:	eb d3                	jmp    102b9c <vprintfmt+0x8b>
            goto process_precision;
  102bc9:	eb 33                	jmp    102bfe <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  102bcb:	8b 45 14             	mov    0x14(%ebp),%eax
  102bce:	8d 50 04             	lea    0x4(%eax),%edx
  102bd1:	89 55 14             	mov    %edx,0x14(%ebp)
  102bd4:	8b 00                	mov    (%eax),%eax
  102bd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102bd9:	eb 23                	jmp    102bfe <vprintfmt+0xed>

        case '.':
            if (width < 0)
  102bdb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102bdf:	79 0c                	jns    102bed <vprintfmt+0xdc>
                width = 0;
  102be1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102be8:	e9 78 ff ff ff       	jmp    102b65 <vprintfmt+0x54>
  102bed:	e9 73 ff ff ff       	jmp    102b65 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  102bf2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102bf9:	e9 67 ff ff ff       	jmp    102b65 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  102bfe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102c02:	79 12                	jns    102c16 <vprintfmt+0x105>
                width = precision, precision = -1;
  102c04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c07:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102c0a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102c11:	e9 4f ff ff ff       	jmp    102b65 <vprintfmt+0x54>
  102c16:	e9 4a ff ff ff       	jmp    102b65 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102c1b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  102c1f:	e9 41 ff ff ff       	jmp    102b65 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102c24:	8b 45 14             	mov    0x14(%ebp),%eax
  102c27:	8d 50 04             	lea    0x4(%eax),%edx
  102c2a:	89 55 14             	mov    %edx,0x14(%ebp)
  102c2d:	8b 00                	mov    (%eax),%eax
  102c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c32:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c36:	89 04 24             	mov    %eax,(%esp)
  102c39:	8b 45 08             	mov    0x8(%ebp),%eax
  102c3c:	ff d0                	call   *%eax
            break;
  102c3e:	e9 ac 02 00 00       	jmp    102eef <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102c43:	8b 45 14             	mov    0x14(%ebp),%eax
  102c46:	8d 50 04             	lea    0x4(%eax),%edx
  102c49:	89 55 14             	mov    %edx,0x14(%ebp)
  102c4c:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102c4e:	85 db                	test   %ebx,%ebx
  102c50:	79 02                	jns    102c54 <vprintfmt+0x143>
                err = -err;
  102c52:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102c54:	83 fb 06             	cmp    $0x6,%ebx
  102c57:	7f 0b                	jg     102c64 <vprintfmt+0x153>
  102c59:	8b 34 9d 34 3c 10 00 	mov    0x103c34(,%ebx,4),%esi
  102c60:	85 f6                	test   %esi,%esi
  102c62:	75 23                	jne    102c87 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  102c64:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102c68:	c7 44 24 08 61 3c 10 	movl   $0x103c61,0x8(%esp)
  102c6f:	00 
  102c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c77:	8b 45 08             	mov    0x8(%ebp),%eax
  102c7a:	89 04 24             	mov    %eax,(%esp)
  102c7d:	e8 61 fe ff ff       	call   102ae3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102c82:	e9 68 02 00 00       	jmp    102eef <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  102c87:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102c8b:	c7 44 24 08 6a 3c 10 	movl   $0x103c6a,0x8(%esp)
  102c92:	00 
  102c93:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9d:	89 04 24             	mov    %eax,(%esp)
  102ca0:	e8 3e fe ff ff       	call   102ae3 <printfmt>
            }
            break;
  102ca5:	e9 45 02 00 00       	jmp    102eef <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102caa:	8b 45 14             	mov    0x14(%ebp),%eax
  102cad:	8d 50 04             	lea    0x4(%eax),%edx
  102cb0:	89 55 14             	mov    %edx,0x14(%ebp)
  102cb3:	8b 30                	mov    (%eax),%esi
  102cb5:	85 f6                	test   %esi,%esi
  102cb7:	75 05                	jne    102cbe <vprintfmt+0x1ad>
                p = "(null)";
  102cb9:	be 6d 3c 10 00       	mov    $0x103c6d,%esi
            }
            if (width > 0 && padc != '-') {
  102cbe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102cc2:	7e 3e                	jle    102d02 <vprintfmt+0x1f1>
  102cc4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102cc8:	74 38                	je     102d02 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102cca:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  102ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  102cd4:	89 34 24             	mov    %esi,(%esp)
  102cd7:	e8 15 03 00 00       	call   102ff1 <strnlen>
  102cdc:	29 c3                	sub    %eax,%ebx
  102cde:	89 d8                	mov    %ebx,%eax
  102ce0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102ce3:	eb 17                	jmp    102cfc <vprintfmt+0x1eb>
                    putch(padc, putdat);
  102ce5:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102ce9:	8b 55 0c             	mov    0xc(%ebp),%edx
  102cec:	89 54 24 04          	mov    %edx,0x4(%esp)
  102cf0:	89 04 24             	mov    %eax,(%esp)
  102cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf6:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  102cf8:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102cfc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d00:	7f e3                	jg     102ce5 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102d02:	eb 38                	jmp    102d3c <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  102d04:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102d08:	74 1f                	je     102d29 <vprintfmt+0x218>
  102d0a:	83 fb 1f             	cmp    $0x1f,%ebx
  102d0d:	7e 05                	jle    102d14 <vprintfmt+0x203>
  102d0f:	83 fb 7e             	cmp    $0x7e,%ebx
  102d12:	7e 15                	jle    102d29 <vprintfmt+0x218>
                    putch('?', putdat);
  102d14:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d1b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102d22:	8b 45 08             	mov    0x8(%ebp),%eax
  102d25:	ff d0                	call   *%eax
  102d27:	eb 0f                	jmp    102d38 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  102d29:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d30:	89 1c 24             	mov    %ebx,(%esp)
  102d33:	8b 45 08             	mov    0x8(%ebp),%eax
  102d36:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102d38:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102d3c:	89 f0                	mov    %esi,%eax
  102d3e:	8d 70 01             	lea    0x1(%eax),%esi
  102d41:	0f b6 00             	movzbl (%eax),%eax
  102d44:	0f be d8             	movsbl %al,%ebx
  102d47:	85 db                	test   %ebx,%ebx
  102d49:	74 10                	je     102d5b <vprintfmt+0x24a>
  102d4b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d4f:	78 b3                	js     102d04 <vprintfmt+0x1f3>
  102d51:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  102d55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d59:	79 a9                	jns    102d04 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102d5b:	eb 17                	jmp    102d74 <vprintfmt+0x263>
                putch(' ', putdat);
  102d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d64:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6e:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102d70:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102d74:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d78:	7f e3                	jg     102d5d <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  102d7a:	e9 70 01 00 00       	jmp    102eef <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d86:	8d 45 14             	lea    0x14(%ebp),%eax
  102d89:	89 04 24             	mov    %eax,(%esp)
  102d8c:	e8 0b fd ff ff       	call   102a9c <getint>
  102d91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d94:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d9d:	85 d2                	test   %edx,%edx
  102d9f:	79 26                	jns    102dc7 <vprintfmt+0x2b6>
                putch('-', putdat);
  102da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  102da8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  102daf:	8b 45 08             	mov    0x8(%ebp),%eax
  102db2:	ff d0                	call   *%eax
                num = -(long long)num;
  102db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102db7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102dba:	f7 d8                	neg    %eax
  102dbc:	83 d2 00             	adc    $0x0,%edx
  102dbf:	f7 da                	neg    %edx
  102dc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102dc4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  102dc7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102dce:	e9 a8 00 00 00       	jmp    102e7b <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  102dd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dda:	8d 45 14             	lea    0x14(%ebp),%eax
  102ddd:	89 04 24             	mov    %eax,(%esp)
  102de0:	e8 68 fc ff ff       	call   102a4d <getuint>
  102de5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102de8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  102deb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102df2:	e9 84 00 00 00       	jmp    102e7b <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  102df7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dfe:	8d 45 14             	lea    0x14(%ebp),%eax
  102e01:	89 04 24             	mov    %eax,(%esp)
  102e04:	e8 44 fc ff ff       	call   102a4d <getuint>
  102e09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  102e0f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  102e16:	eb 63                	jmp    102e7b <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  102e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e1f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  102e26:	8b 45 08             	mov    0x8(%ebp),%eax
  102e29:	ff d0                	call   *%eax
            putch('x', putdat);
  102e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e32:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  102e39:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3c:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  102e3e:	8b 45 14             	mov    0x14(%ebp),%eax
  102e41:	8d 50 04             	lea    0x4(%eax),%edx
  102e44:	89 55 14             	mov    %edx,0x14(%ebp)
  102e47:	8b 00                	mov    (%eax),%eax
  102e49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  102e53:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  102e5a:	eb 1f                	jmp    102e7b <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  102e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e63:	8d 45 14             	lea    0x14(%ebp),%eax
  102e66:	89 04 24             	mov    %eax,(%esp)
  102e69:	e8 df fb ff ff       	call   102a4d <getuint>
  102e6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e71:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  102e74:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  102e7b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  102e7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e82:	89 54 24 18          	mov    %edx,0x18(%esp)
  102e86:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102e89:	89 54 24 14          	mov    %edx,0x14(%esp)
  102e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  102e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e97:	89 44 24 08          	mov    %eax,0x8(%esp)
  102e9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea9:	89 04 24             	mov    %eax,(%esp)
  102eac:	e8 97 fa ff ff       	call   102948 <printnum>
            break;
  102eb1:	eb 3c                	jmp    102eef <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  102eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eba:	89 1c 24             	mov    %ebx,(%esp)
  102ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec0:	ff d0                	call   *%eax
            break;
  102ec2:	eb 2b                	jmp    102eef <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  102ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ecb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  102ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed5:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  102ed7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102edb:	eb 04                	jmp    102ee1 <vprintfmt+0x3d0>
  102edd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102ee1:	8b 45 10             	mov    0x10(%ebp),%eax
  102ee4:	83 e8 01             	sub    $0x1,%eax
  102ee7:	0f b6 00             	movzbl (%eax),%eax
  102eea:	3c 25                	cmp    $0x25,%al
  102eec:	75 ef                	jne    102edd <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  102eee:	90                   	nop
        }
    }
  102eef:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102ef0:	e9 3e fc ff ff       	jmp    102b33 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  102ef5:	83 c4 40             	add    $0x40,%esp
  102ef8:	5b                   	pop    %ebx
  102ef9:	5e                   	pop    %esi
  102efa:	5d                   	pop    %ebp
  102efb:	c3                   	ret    

00102efc <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  102efc:	55                   	push   %ebp
  102efd:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  102eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f02:	8b 40 08             	mov    0x8(%eax),%eax
  102f05:	8d 50 01             	lea    0x1(%eax),%edx
  102f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f0b:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  102f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f11:	8b 10                	mov    (%eax),%edx
  102f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f16:	8b 40 04             	mov    0x4(%eax),%eax
  102f19:	39 c2                	cmp    %eax,%edx
  102f1b:	73 12                	jae    102f2f <sprintputch+0x33>
        *b->buf ++ = ch;
  102f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f20:	8b 00                	mov    (%eax),%eax
  102f22:	8d 48 01             	lea    0x1(%eax),%ecx
  102f25:	8b 55 0c             	mov    0xc(%ebp),%edx
  102f28:	89 0a                	mov    %ecx,(%edx)
  102f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  102f2d:	88 10                	mov    %dl,(%eax)
    }
}
  102f2f:	5d                   	pop    %ebp
  102f30:	c3                   	ret    

00102f31 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  102f31:	55                   	push   %ebp
  102f32:	89 e5                	mov    %esp,%ebp
  102f34:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  102f37:	8d 45 14             	lea    0x14(%ebp),%eax
  102f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  102f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102f44:	8b 45 10             	mov    0x10(%ebp),%eax
  102f47:	89 44 24 08          	mov    %eax,0x8(%esp)
  102f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f52:	8b 45 08             	mov    0x8(%ebp),%eax
  102f55:	89 04 24             	mov    %eax,(%esp)
  102f58:	e8 08 00 00 00       	call   102f65 <vsnprintf>
  102f5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  102f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102f63:	c9                   	leave  
  102f64:	c3                   	ret    

00102f65 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  102f65:	55                   	push   %ebp
  102f66:	89 e5                	mov    %esp,%ebp
  102f68:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  102f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  102f6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f74:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f77:	8b 45 08             	mov    0x8(%ebp),%eax
  102f7a:	01 d0                	add    %edx,%eax
  102f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  102f86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102f8a:	74 0a                	je     102f96 <vsnprintf+0x31>
  102f8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f92:	39 c2                	cmp    %eax,%edx
  102f94:	76 07                	jbe    102f9d <vsnprintf+0x38>
        return -E_INVAL;
  102f96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  102f9b:	eb 2a                	jmp    102fc7 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  102f9d:	8b 45 14             	mov    0x14(%ebp),%eax
  102fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  102fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  102fab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  102fae:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fb2:	c7 04 24 fc 2e 10 00 	movl   $0x102efc,(%esp)
  102fb9:	e8 53 fb ff ff       	call   102b11 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  102fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fc1:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  102fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102fc7:	c9                   	leave  
  102fc8:	c3                   	ret    

00102fc9 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102fc9:	55                   	push   %ebp
  102fca:	89 e5                	mov    %esp,%ebp
  102fcc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102fcf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102fd6:	eb 04                	jmp    102fdc <strlen+0x13>
        cnt ++;
  102fd8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  102fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  102fdf:	8d 50 01             	lea    0x1(%eax),%edx
  102fe2:	89 55 08             	mov    %edx,0x8(%ebp)
  102fe5:	0f b6 00             	movzbl (%eax),%eax
  102fe8:	84 c0                	test   %al,%al
  102fea:	75 ec                	jne    102fd8 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  102fec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102fef:	c9                   	leave  
  102ff0:	c3                   	ret    

00102ff1 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102ff1:	55                   	push   %ebp
  102ff2:	89 e5                	mov    %esp,%ebp
  102ff4:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102ff7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102ffe:	eb 04                	jmp    103004 <strnlen+0x13>
        cnt ++;
  103000:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  103004:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103007:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10300a:	73 10                	jae    10301c <strnlen+0x2b>
  10300c:	8b 45 08             	mov    0x8(%ebp),%eax
  10300f:	8d 50 01             	lea    0x1(%eax),%edx
  103012:	89 55 08             	mov    %edx,0x8(%ebp)
  103015:	0f b6 00             	movzbl (%eax),%eax
  103018:	84 c0                	test   %al,%al
  10301a:	75 e4                	jne    103000 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  10301c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10301f:	c9                   	leave  
  103020:	c3                   	ret    

00103021 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  103021:	55                   	push   %ebp
  103022:	89 e5                	mov    %esp,%ebp
  103024:	57                   	push   %edi
  103025:	56                   	push   %esi
  103026:	83 ec 20             	sub    $0x20,%esp
  103029:	8b 45 08             	mov    0x8(%ebp),%eax
  10302c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10302f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103032:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  103035:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10303b:	89 d1                	mov    %edx,%ecx
  10303d:	89 c2                	mov    %eax,%edx
  10303f:	89 ce                	mov    %ecx,%esi
  103041:	89 d7                	mov    %edx,%edi
  103043:	ac                   	lods   %ds:(%esi),%al
  103044:	aa                   	stos   %al,%es:(%edi)
  103045:	84 c0                	test   %al,%al
  103047:	75 fa                	jne    103043 <strcpy+0x22>
  103049:	89 fa                	mov    %edi,%edx
  10304b:	89 f1                	mov    %esi,%ecx
  10304d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  103050:	89 55 e8             	mov    %edx,-0x18(%ebp)
  103053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  103056:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  103059:	83 c4 20             	add    $0x20,%esp
  10305c:	5e                   	pop    %esi
  10305d:	5f                   	pop    %edi
  10305e:	5d                   	pop    %ebp
  10305f:	c3                   	ret    

00103060 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  103060:	55                   	push   %ebp
  103061:	89 e5                	mov    %esp,%ebp
  103063:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  103066:	8b 45 08             	mov    0x8(%ebp),%eax
  103069:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10306c:	eb 21                	jmp    10308f <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  10306e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103071:	0f b6 10             	movzbl (%eax),%edx
  103074:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103077:	88 10                	mov    %dl,(%eax)
  103079:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10307c:	0f b6 00             	movzbl (%eax),%eax
  10307f:	84 c0                	test   %al,%al
  103081:	74 04                	je     103087 <strncpy+0x27>
            src ++;
  103083:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  103087:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10308b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  10308f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103093:	75 d9                	jne    10306e <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  103095:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103098:	c9                   	leave  
  103099:	c3                   	ret    

0010309a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10309a:	55                   	push   %ebp
  10309b:	89 e5                	mov    %esp,%ebp
  10309d:	57                   	push   %edi
  10309e:	56                   	push   %esi
  10309f:	83 ec 20             	sub    $0x20,%esp
  1030a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1030a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1030a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  1030ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1030b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030b4:	89 d1                	mov    %edx,%ecx
  1030b6:	89 c2                	mov    %eax,%edx
  1030b8:	89 ce                	mov    %ecx,%esi
  1030ba:	89 d7                	mov    %edx,%edi
  1030bc:	ac                   	lods   %ds:(%esi),%al
  1030bd:	ae                   	scas   %es:(%edi),%al
  1030be:	75 08                	jne    1030c8 <strcmp+0x2e>
  1030c0:	84 c0                	test   %al,%al
  1030c2:	75 f8                	jne    1030bc <strcmp+0x22>
  1030c4:	31 c0                	xor    %eax,%eax
  1030c6:	eb 04                	jmp    1030cc <strcmp+0x32>
  1030c8:	19 c0                	sbb    %eax,%eax
  1030ca:	0c 01                	or     $0x1,%al
  1030cc:	89 fa                	mov    %edi,%edx
  1030ce:	89 f1                	mov    %esi,%ecx
  1030d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030d3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1030d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  1030d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1030dc:	83 c4 20             	add    $0x20,%esp
  1030df:	5e                   	pop    %esi
  1030e0:	5f                   	pop    %edi
  1030e1:	5d                   	pop    %ebp
  1030e2:	c3                   	ret    

001030e3 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1030e3:	55                   	push   %ebp
  1030e4:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1030e6:	eb 0c                	jmp    1030f4 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  1030e8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1030ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1030f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1030f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1030f8:	74 1a                	je     103114 <strncmp+0x31>
  1030fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1030fd:	0f b6 00             	movzbl (%eax),%eax
  103100:	84 c0                	test   %al,%al
  103102:	74 10                	je     103114 <strncmp+0x31>
  103104:	8b 45 08             	mov    0x8(%ebp),%eax
  103107:	0f b6 10             	movzbl (%eax),%edx
  10310a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10310d:	0f b6 00             	movzbl (%eax),%eax
  103110:	38 c2                	cmp    %al,%dl
  103112:	74 d4                	je     1030e8 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  103114:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103118:	74 18                	je     103132 <strncmp+0x4f>
  10311a:	8b 45 08             	mov    0x8(%ebp),%eax
  10311d:	0f b6 00             	movzbl (%eax),%eax
  103120:	0f b6 d0             	movzbl %al,%edx
  103123:	8b 45 0c             	mov    0xc(%ebp),%eax
  103126:	0f b6 00             	movzbl (%eax),%eax
  103129:	0f b6 c0             	movzbl %al,%eax
  10312c:	29 c2                	sub    %eax,%edx
  10312e:	89 d0                	mov    %edx,%eax
  103130:	eb 05                	jmp    103137 <strncmp+0x54>
  103132:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103137:	5d                   	pop    %ebp
  103138:	c3                   	ret    

00103139 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  103139:	55                   	push   %ebp
  10313a:	89 e5                	mov    %esp,%ebp
  10313c:	83 ec 04             	sub    $0x4,%esp
  10313f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103142:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103145:	eb 14                	jmp    10315b <strchr+0x22>
        if (*s == c) {
  103147:	8b 45 08             	mov    0x8(%ebp),%eax
  10314a:	0f b6 00             	movzbl (%eax),%eax
  10314d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  103150:	75 05                	jne    103157 <strchr+0x1e>
            return (char *)s;
  103152:	8b 45 08             	mov    0x8(%ebp),%eax
  103155:	eb 13                	jmp    10316a <strchr+0x31>
        }
        s ++;
  103157:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  10315b:	8b 45 08             	mov    0x8(%ebp),%eax
  10315e:	0f b6 00             	movzbl (%eax),%eax
  103161:	84 c0                	test   %al,%al
  103163:	75 e2                	jne    103147 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  103165:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10316a:	c9                   	leave  
  10316b:	c3                   	ret    

0010316c <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10316c:	55                   	push   %ebp
  10316d:	89 e5                	mov    %esp,%ebp
  10316f:	83 ec 04             	sub    $0x4,%esp
  103172:	8b 45 0c             	mov    0xc(%ebp),%eax
  103175:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103178:	eb 11                	jmp    10318b <strfind+0x1f>
        if (*s == c) {
  10317a:	8b 45 08             	mov    0x8(%ebp),%eax
  10317d:	0f b6 00             	movzbl (%eax),%eax
  103180:	3a 45 fc             	cmp    -0x4(%ebp),%al
  103183:	75 02                	jne    103187 <strfind+0x1b>
            break;
  103185:	eb 0e                	jmp    103195 <strfind+0x29>
        }
        s ++;
  103187:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  10318b:	8b 45 08             	mov    0x8(%ebp),%eax
  10318e:	0f b6 00             	movzbl (%eax),%eax
  103191:	84 c0                	test   %al,%al
  103193:	75 e5                	jne    10317a <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  103195:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103198:	c9                   	leave  
  103199:	c3                   	ret    

0010319a <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10319a:	55                   	push   %ebp
  10319b:	89 e5                	mov    %esp,%ebp
  10319d:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1031a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1031a7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1031ae:	eb 04                	jmp    1031b4 <strtol+0x1a>
        s ++;
  1031b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1031b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1031b7:	0f b6 00             	movzbl (%eax),%eax
  1031ba:	3c 20                	cmp    $0x20,%al
  1031bc:	74 f2                	je     1031b0 <strtol+0x16>
  1031be:	8b 45 08             	mov    0x8(%ebp),%eax
  1031c1:	0f b6 00             	movzbl (%eax),%eax
  1031c4:	3c 09                	cmp    $0x9,%al
  1031c6:	74 e8                	je     1031b0 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  1031c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1031cb:	0f b6 00             	movzbl (%eax),%eax
  1031ce:	3c 2b                	cmp    $0x2b,%al
  1031d0:	75 06                	jne    1031d8 <strtol+0x3e>
        s ++;
  1031d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1031d6:	eb 15                	jmp    1031ed <strtol+0x53>
    }
    else if (*s == '-') {
  1031d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1031db:	0f b6 00             	movzbl (%eax),%eax
  1031de:	3c 2d                	cmp    $0x2d,%al
  1031e0:	75 0b                	jne    1031ed <strtol+0x53>
        s ++, neg = 1;
  1031e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1031e6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1031ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1031f1:	74 06                	je     1031f9 <strtol+0x5f>
  1031f3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1031f7:	75 24                	jne    10321d <strtol+0x83>
  1031f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1031fc:	0f b6 00             	movzbl (%eax),%eax
  1031ff:	3c 30                	cmp    $0x30,%al
  103201:	75 1a                	jne    10321d <strtol+0x83>
  103203:	8b 45 08             	mov    0x8(%ebp),%eax
  103206:	83 c0 01             	add    $0x1,%eax
  103209:	0f b6 00             	movzbl (%eax),%eax
  10320c:	3c 78                	cmp    $0x78,%al
  10320e:	75 0d                	jne    10321d <strtol+0x83>
        s += 2, base = 16;
  103210:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  103214:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  10321b:	eb 2a                	jmp    103247 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  10321d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103221:	75 17                	jne    10323a <strtol+0xa0>
  103223:	8b 45 08             	mov    0x8(%ebp),%eax
  103226:	0f b6 00             	movzbl (%eax),%eax
  103229:	3c 30                	cmp    $0x30,%al
  10322b:	75 0d                	jne    10323a <strtol+0xa0>
        s ++, base = 8;
  10322d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103231:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  103238:	eb 0d                	jmp    103247 <strtol+0xad>
    }
    else if (base == 0) {
  10323a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10323e:	75 07                	jne    103247 <strtol+0xad>
        base = 10;
  103240:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  103247:	8b 45 08             	mov    0x8(%ebp),%eax
  10324a:	0f b6 00             	movzbl (%eax),%eax
  10324d:	3c 2f                	cmp    $0x2f,%al
  10324f:	7e 1b                	jle    10326c <strtol+0xd2>
  103251:	8b 45 08             	mov    0x8(%ebp),%eax
  103254:	0f b6 00             	movzbl (%eax),%eax
  103257:	3c 39                	cmp    $0x39,%al
  103259:	7f 11                	jg     10326c <strtol+0xd2>
            dig = *s - '0';
  10325b:	8b 45 08             	mov    0x8(%ebp),%eax
  10325e:	0f b6 00             	movzbl (%eax),%eax
  103261:	0f be c0             	movsbl %al,%eax
  103264:	83 e8 30             	sub    $0x30,%eax
  103267:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10326a:	eb 48                	jmp    1032b4 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10326c:	8b 45 08             	mov    0x8(%ebp),%eax
  10326f:	0f b6 00             	movzbl (%eax),%eax
  103272:	3c 60                	cmp    $0x60,%al
  103274:	7e 1b                	jle    103291 <strtol+0xf7>
  103276:	8b 45 08             	mov    0x8(%ebp),%eax
  103279:	0f b6 00             	movzbl (%eax),%eax
  10327c:	3c 7a                	cmp    $0x7a,%al
  10327e:	7f 11                	jg     103291 <strtol+0xf7>
            dig = *s - 'a' + 10;
  103280:	8b 45 08             	mov    0x8(%ebp),%eax
  103283:	0f b6 00             	movzbl (%eax),%eax
  103286:	0f be c0             	movsbl %al,%eax
  103289:	83 e8 57             	sub    $0x57,%eax
  10328c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10328f:	eb 23                	jmp    1032b4 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  103291:	8b 45 08             	mov    0x8(%ebp),%eax
  103294:	0f b6 00             	movzbl (%eax),%eax
  103297:	3c 40                	cmp    $0x40,%al
  103299:	7e 3d                	jle    1032d8 <strtol+0x13e>
  10329b:	8b 45 08             	mov    0x8(%ebp),%eax
  10329e:	0f b6 00             	movzbl (%eax),%eax
  1032a1:	3c 5a                	cmp    $0x5a,%al
  1032a3:	7f 33                	jg     1032d8 <strtol+0x13e>
            dig = *s - 'A' + 10;
  1032a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1032a8:	0f b6 00             	movzbl (%eax),%eax
  1032ab:	0f be c0             	movsbl %al,%eax
  1032ae:	83 e8 37             	sub    $0x37,%eax
  1032b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1032b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032b7:	3b 45 10             	cmp    0x10(%ebp),%eax
  1032ba:	7c 02                	jl     1032be <strtol+0x124>
            break;
  1032bc:	eb 1a                	jmp    1032d8 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  1032be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1032c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1032c5:	0f af 45 10          	imul   0x10(%ebp),%eax
  1032c9:	89 c2                	mov    %eax,%edx
  1032cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032ce:	01 d0                	add    %edx,%eax
  1032d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  1032d3:	e9 6f ff ff ff       	jmp    103247 <strtol+0xad>

    if (endptr) {
  1032d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1032dc:	74 08                	je     1032e6 <strtol+0x14c>
        *endptr = (char *) s;
  1032de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e1:	8b 55 08             	mov    0x8(%ebp),%edx
  1032e4:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1032e6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1032ea:	74 07                	je     1032f3 <strtol+0x159>
  1032ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1032ef:	f7 d8                	neg    %eax
  1032f1:	eb 03                	jmp    1032f6 <strtol+0x15c>
  1032f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1032f6:	c9                   	leave  
  1032f7:	c3                   	ret    

001032f8 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1032f8:	55                   	push   %ebp
  1032f9:	89 e5                	mov    %esp,%ebp
  1032fb:	57                   	push   %edi
  1032fc:	83 ec 24             	sub    $0x24,%esp
  1032ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  103302:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  103305:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  103309:	8b 55 08             	mov    0x8(%ebp),%edx
  10330c:	89 55 f8             	mov    %edx,-0x8(%ebp)
  10330f:	88 45 f7             	mov    %al,-0x9(%ebp)
  103312:	8b 45 10             	mov    0x10(%ebp),%eax
  103315:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  103318:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10331b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10331f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  103322:	89 d7                	mov    %edx,%edi
  103324:	f3 aa                	rep stos %al,%es:(%edi)
  103326:	89 fa                	mov    %edi,%edx
  103328:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10332b:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  10332e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  103331:	83 c4 24             	add    $0x24,%esp
  103334:	5f                   	pop    %edi
  103335:	5d                   	pop    %ebp
  103336:	c3                   	ret    

00103337 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  103337:	55                   	push   %ebp
  103338:	89 e5                	mov    %esp,%ebp
  10333a:	57                   	push   %edi
  10333b:	56                   	push   %esi
  10333c:	53                   	push   %ebx
  10333d:	83 ec 30             	sub    $0x30,%esp
  103340:	8b 45 08             	mov    0x8(%ebp),%eax
  103343:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103346:	8b 45 0c             	mov    0xc(%ebp),%eax
  103349:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10334c:	8b 45 10             	mov    0x10(%ebp),%eax
  10334f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  103352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103355:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103358:	73 42                	jae    10339c <memmove+0x65>
  10335a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10335d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103360:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103363:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103366:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103369:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10336c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10336f:	c1 e8 02             	shr    $0x2,%eax
  103372:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  103374:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103377:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10337a:	89 d7                	mov    %edx,%edi
  10337c:	89 c6                	mov    %eax,%esi
  10337e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103380:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  103383:	83 e1 03             	and    $0x3,%ecx
  103386:	74 02                	je     10338a <memmove+0x53>
  103388:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10338a:	89 f0                	mov    %esi,%eax
  10338c:	89 fa                	mov    %edi,%edx
  10338e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  103391:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103394:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  103397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10339a:	eb 36                	jmp    1033d2 <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10339c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10339f:	8d 50 ff             	lea    -0x1(%eax),%edx
  1033a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033a5:	01 c2                	add    %eax,%edx
  1033a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033aa:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1033ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033b0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  1033b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033b6:	89 c1                	mov    %eax,%ecx
  1033b8:	89 d8                	mov    %ebx,%eax
  1033ba:	89 d6                	mov    %edx,%esi
  1033bc:	89 c7                	mov    %eax,%edi
  1033be:	fd                   	std    
  1033bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1033c1:	fc                   	cld    
  1033c2:	89 f8                	mov    %edi,%eax
  1033c4:	89 f2                	mov    %esi,%edx
  1033c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1033c9:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1033cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  1033cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1033d2:	83 c4 30             	add    $0x30,%esp
  1033d5:	5b                   	pop    %ebx
  1033d6:	5e                   	pop    %esi
  1033d7:	5f                   	pop    %edi
  1033d8:	5d                   	pop    %ebp
  1033d9:	c3                   	ret    

001033da <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1033da:	55                   	push   %ebp
  1033db:	89 e5                	mov    %esp,%ebp
  1033dd:	57                   	push   %edi
  1033de:	56                   	push   %esi
  1033df:	83 ec 20             	sub    $0x20,%esp
  1033e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1033e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033ee:	8b 45 10             	mov    0x10(%ebp),%eax
  1033f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1033f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033f7:	c1 e8 02             	shr    $0x2,%eax
  1033fa:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1033fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1033ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103402:	89 d7                	mov    %edx,%edi
  103404:	89 c6                	mov    %eax,%esi
  103406:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103408:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10340b:	83 e1 03             	and    $0x3,%ecx
  10340e:	74 02                	je     103412 <memcpy+0x38>
  103410:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103412:	89 f0                	mov    %esi,%eax
  103414:	89 fa                	mov    %edi,%edx
  103416:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  103419:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10341c:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  10341f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  103422:	83 c4 20             	add    $0x20,%esp
  103425:	5e                   	pop    %esi
  103426:	5f                   	pop    %edi
  103427:	5d                   	pop    %ebp
  103428:	c3                   	ret    

00103429 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  103429:	55                   	push   %ebp
  10342a:	89 e5                	mov    %esp,%ebp
  10342c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  10342f:	8b 45 08             	mov    0x8(%ebp),%eax
  103432:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  103435:	8b 45 0c             	mov    0xc(%ebp),%eax
  103438:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10343b:	eb 30                	jmp    10346d <memcmp+0x44>
        if (*s1 != *s2) {
  10343d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103440:	0f b6 10             	movzbl (%eax),%edx
  103443:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103446:	0f b6 00             	movzbl (%eax),%eax
  103449:	38 c2                	cmp    %al,%dl
  10344b:	74 18                	je     103465 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  10344d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103450:	0f b6 00             	movzbl (%eax),%eax
  103453:	0f b6 d0             	movzbl %al,%edx
  103456:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103459:	0f b6 00             	movzbl (%eax),%eax
  10345c:	0f b6 c0             	movzbl %al,%eax
  10345f:	29 c2                	sub    %eax,%edx
  103461:	89 d0                	mov    %edx,%eax
  103463:	eb 1a                	jmp    10347f <memcmp+0x56>
        }
        s1 ++, s2 ++;
  103465:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  103469:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  10346d:	8b 45 10             	mov    0x10(%ebp),%eax
  103470:	8d 50 ff             	lea    -0x1(%eax),%edx
  103473:	89 55 10             	mov    %edx,0x10(%ebp)
  103476:	85 c0                	test   %eax,%eax
  103478:	75 c3                	jne    10343d <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  10347a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10347f:	c9                   	leave  
  103480:	c3                   	ret    
