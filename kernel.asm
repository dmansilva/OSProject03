
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 a6 37 10 80       	mov    $0x801037a6,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 0c 84 10 	movl   $0x8010840c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 74 4e 00 00       	call   80104ec2 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 ac 0d 11 80 5c 	movl   $0x80110d5c,0x80110dac
80100055:	0d 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 b0 0d 11 80 5c 	movl   $0x80110d5c,0x80110db0
8010005f:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 b0 0d 11 80    	mov    0x80110db0,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 5c 0d 11 80 	movl   $0x80110d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 13 84 10 	movl   $0x80108413,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 ed 4c 00 00       	call   80104d84 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 b0 0d 11 80       	mov    0x80110db0,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 b0 0d 11 80       	mov    %eax,0x80110db0

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 5c 0d 11 80 	cmpl   $0x80110d5c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000c9:	e8 15 4e 00 00       	call   80104ee3 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 b0 0d 11 80       	mov    0x80110db0,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 41 4e 00 00       	call   80104f4a <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 a7 4c 00 00       	call   80104dbe <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 5c 0d 11 80 	cmpl   $0x80110d5c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle some unused buffer and clean buffer
  // "clean" because B_DIRTY and not locked means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 ac 0d 11 80       	mov    0x80110dac,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017d:	e8 c8 4d 00 00       	call   80104f4a <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 2e 4c 00 00       	call   80104dbe <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle some unused buffer and clean buffer
  // "clean" because B_DIRTY and not locked means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 5c 0d 11 80 	cmpl   $0x80110d5c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 1a 84 10 80 	movl   $0x8010841a,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 46 26 00 00       	call   8010282d <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 5c 4c 00 00       	call   80104e5c <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 2b 84 10 80 	movl   $0x8010842b,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 03 26 00 00       	call   8010282d <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 1c 4c 00 00       	call   80104e5c <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 32 84 10 80 	movl   $0x80108432,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 bc 4b 00 00       	call   80104e1a <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100265:	e8 79 4c 00 00       	call   80104ee3 <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 b0 0d 11 80    	mov    0x80110db0,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 5c 0d 11 80 	movl   $0x80110d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 b0 0d 11 80       	mov    0x80110db0,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 b0 0d 11 80       	mov    %eax,0x80110db0
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002d1:	e8 74 4c 00 00       	call   80104f4a <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 04 90 10 80    	mov    -0x7fef6ffc(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 bd 03 00 00       	call   8010076e <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003dc:	e8 02 4b 00 00       	call   80104ee3 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 39 84 10 80 	movl   $0x80108439,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 57 03 00 00       	call   8010076e <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec 42 84 10 80 	movl   $0x80108442,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 84 02 00 00       	call   8010076e <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 6a 02 00 00       	call   8010076e <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 5c 02 00 00       	call   8010076e <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 51 02 00 00       	call   8010076e <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010054d:	e8 f8 49 00 00       	call   80104f4a <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100566:	00 00 00 
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
80100569:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010056f:	8a 00                	mov    (%eax),%al
80100571:	0f b6 c0             	movzbl %al,%eax
80100574:	89 44 24 04          	mov    %eax,0x4(%esp)
80100578:	c7 04 24 49 84 10 80 	movl   $0x80108449,(%esp)
8010057f:	e8 3d fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
80100584:	8b 45 08             	mov    0x8(%ebp),%eax
80100587:	89 04 24             	mov    %eax,(%esp)
8010058a:	e8 32 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
8010058f:	c7 04 24 65 84 10 80 	movl   $0x80108465,(%esp)
80100596:	e8 26 fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
8010059b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010059e:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a2:	8d 45 08             	lea    0x8(%ebp),%eax
801005a5:	89 04 24             	mov    %eax,(%esp)
801005a8:	e8 ea 49 00 00       	call   80104f97 <getcallerpcs>
  for(i=0; i<10; i++)
801005ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005b4:	eb 1a                	jmp    801005d0 <panic+0x7c>
    cprintf(" %p", pcs[i]);
801005b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b9:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801005c1:	c7 04 24 67 84 10 80 	movl   $0x80108467,(%esp)
801005c8:	e8 f4 fd ff ff       	call   801003c1 <cprintf>
  cons.locking = 0;
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005cd:	ff 45 f4             	incl   -0xc(%ebp)
801005d0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005d4:	7e e0                	jle    801005b6 <panic+0x62>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d6:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005dd:	00 00 00 
  for(;;)
    ;
801005e0:	eb fe                	jmp    801005e0 <panic+0x8c>

801005e2 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005e2:	55                   	push   %ebp
801005e3:	89 e5                	mov    %esp,%ebp
801005e5:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e8:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005ef:	00 
801005f0:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f7:	e8 f7 fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005fc:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100603:	e8 d0 fc ff ff       	call   801002d8 <inb>
80100608:	0f b6 c0             	movzbl %al,%eax
8010060b:	c1 e0 08             	shl    $0x8,%eax
8010060e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100611:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100618:	00 
80100619:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100620:	e8 ce fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
80100625:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010062c:	e8 a7 fc ff ff       	call   801002d8 <inb>
80100631:	0f b6 c0             	movzbl %al,%eax
80100634:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100637:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010063b:	75 1b                	jne    80100658 <cgaputc+0x76>
    pos += 80 - pos%80;
8010063d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100640:	b9 50 00 00 00       	mov    $0x50,%ecx
80100645:	99                   	cltd   
80100646:	f7 f9                	idiv   %ecx
80100648:	89 d0                	mov    %edx,%eax
8010064a:	ba 50 00 00 00       	mov    $0x50,%edx
8010064f:	29 c2                	sub    %eax,%edx
80100651:	89 d0                	mov    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 34                	jmp    8010068c <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0b                	jne    8010066c <cgaputc+0x8a>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 25                	jle    8010068c <cgaputc+0xaa>
80100667:	ff 4d f4             	decl   -0xc(%ebp)
8010066a:	eb 20                	jmp    8010068c <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066c:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8d 50 01             	lea    0x1(%eax),%edx
80100678:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010067b:	01 c0                	add    %eax,%eax
8010067d:	8d 14 01             	lea    (%ecx,%eax,1),%edx
80100680:	8b 45 08             	mov    0x8(%ebp),%eax
80100683:	0f b6 c0             	movzbl %al,%eax
80100686:	80 cc 07             	or     $0x7,%ah
80100689:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100690:	78 09                	js     8010069b <cgaputc+0xb9>
80100692:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100699:	7e 0c                	jle    801006a7 <cgaputc+0xc5>
    panic("pos under/overflow");
8010069b:	c7 04 24 6b 84 10 80 	movl   $0x8010846b,(%esp)
801006a2:	e8 ad fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a7:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ae:	7e 53                	jle    80100703 <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006b0:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006bb:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c0:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c7:	00 
801006c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801006cc:	89 04 24             	mov    %eax,(%esp)
801006cf:	e8 3b 4b 00 00       	call   8010520f <memmove>
    pos -= 80;
801006d4:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d8:	b8 80 07 00 00       	mov    $0x780,%eax
801006dd:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006e0:	01 c0                	add    %eax,%eax
801006e2:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006eb:	01 d2                	add    %edx,%edx
801006ed:	01 ca                	add    %ecx,%edx
801006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801006f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006fa:	00 
801006fb:	89 14 24             	mov    %edx,(%esp)
801006fe:	e8 43 4a 00 00       	call   80105146 <memset>
  }

  outb(CRTPORT, 14);
80100703:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
8010070a:	00 
8010070b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100712:	e8 dc fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010071a:	c1 f8 08             	sar    $0x8,%eax
8010071d:	0f b6 c0             	movzbl %al,%eax
80100720:	89 44 24 04          	mov    %eax,0x4(%esp)
80100724:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010072b:	e8 c3 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
80100730:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100737:	00 
80100738:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073f:	e8 af fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
80100744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100747:	0f b6 c0             	movzbl %al,%eax
8010074a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100755:	e8 99 fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
8010075a:	8b 15 00 90 10 80    	mov    0x80109000,%edx
80100760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100763:	01 c0                	add    %eax,%eax
80100765:	01 d0                	add    %edx,%eax
80100767:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010076c:	c9                   	leave  
8010076d:	c3                   	ret    

8010076e <consputc>:

void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100774:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 07                	je     80100784 <consputc+0x16>
    cli();
8010077d:	e8 8d fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
80100782:	eb fe                	jmp    80100782 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100784:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078b:	75 26                	jne    801007b3 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100794:	e8 03 63 00 00       	call   80106a9c <uartputc>
80100799:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007a0:	e8 f7 62 00 00       	call   80106a9c <uartputc>
801007a5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007ac:	e8 eb 62 00 00       	call   80106a9c <uartputc>
801007b1:	eb 0b                	jmp    801007be <consputc+0x50>
  } else
    uartputc(c);
801007b3:	8b 45 08             	mov    0x8(%ebp),%eax
801007b6:	89 04 24             	mov    %eax,(%esp)
801007b9:	e8 de 62 00 00       	call   80106a9c <uartputc>
  cgaputc(c);
801007be:	8b 45 08             	mov    0x8(%ebp),%eax
801007c1:	89 04 24             	mov    %eax,(%esp)
801007c4:	e8 19 fe ff ff       	call   801005e2 <cgaputc>
}
801007c9:	c9                   	leave  
801007ca:	c3                   	ret    

801007cb <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007cb:	55                   	push   %ebp
801007cc:	89 e5                	mov    %esp,%ebp
801007ce:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d8:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801007df:	e8 ff 46 00 00       	call   80104ee3 <acquire>
  while((c = getc()) >= 0){
801007e4:	e9 2f 01 00 00       	jmp    80100918 <consoleintr+0x14d>
    switch(c){
801007e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007ec:	83 f8 10             	cmp    $0x10,%eax
801007ef:	74 1b                	je     8010080c <consoleintr+0x41>
801007f1:	83 f8 10             	cmp    $0x10,%eax
801007f4:	7f 0a                	jg     80100800 <consoleintr+0x35>
801007f6:	83 f8 08             	cmp    $0x8,%eax
801007f9:	74 5e                	je     80100859 <consoleintr+0x8e>
801007fb:	e9 89 00 00 00       	jmp    80100889 <consoleintr+0xbe>
80100800:	83 f8 15             	cmp    $0x15,%eax
80100803:	74 2c                	je     80100831 <consoleintr+0x66>
80100805:	83 f8 7f             	cmp    $0x7f,%eax
80100808:	74 4f                	je     80100859 <consoleintr+0x8e>
8010080a:	eb 7d                	jmp    80100889 <consoleintr+0xbe>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 00 01 00 00       	jmp    80100918 <consoleintr+0x14d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 48 10 11 80       	mov    0x80111048,%eax
8010081d:	48                   	dec    %eax
8010081e:	a3 48 10 11 80       	mov    %eax,0x80111048
        consputc(BACKSPACE);
80100823:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082a:	e8 3f ff ff ff       	call   8010076e <consputc>
8010082f:	eb 01                	jmp    80100832 <consoleintr+0x67>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	90                   	nop
80100832:	8b 15 48 10 11 80    	mov    0x80111048,%edx
80100838:	a1 44 10 11 80       	mov    0x80111044,%eax
8010083d:	39 c2                	cmp    %eax,%edx
8010083f:	74 13                	je     80100854 <consoleintr+0x89>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100841:	a1 48 10 11 80       	mov    0x80111048,%eax
80100846:	48                   	dec    %eax
80100847:	83 e0 7f             	and    $0x7f,%eax
8010084a:	8a 80 c0 0f 11 80    	mov    -0x7feef040(%eax),%al
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100850:	3c 0a                	cmp    $0xa,%al
80100852:	75 c4                	jne    80100818 <consoleintr+0x4d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100854:	e9 bf 00 00 00       	jmp    80100918 <consoleintr+0x14d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100859:	8b 15 48 10 11 80    	mov    0x80111048,%edx
8010085f:	a1 44 10 11 80       	mov    0x80111044,%eax
80100864:	39 c2                	cmp    %eax,%edx
80100866:	74 1c                	je     80100884 <consoleintr+0xb9>
        input.e--;
80100868:	a1 48 10 11 80       	mov    0x80111048,%eax
8010086d:	48                   	dec    %eax
8010086e:	a3 48 10 11 80       	mov    %eax,0x80111048
        consputc(BACKSPACE);
80100873:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010087a:	e8 ef fe ff ff       	call   8010076e <consputc>
      }
      break;
8010087f:	e9 94 00 00 00       	jmp    80100918 <consoleintr+0x14d>
80100884:	e9 8f 00 00 00       	jmp    80100918 <consoleintr+0x14d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100889:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010088d:	0f 84 84 00 00 00    	je     80100917 <consoleintr+0x14c>
80100893:	8b 15 48 10 11 80    	mov    0x80111048,%edx
80100899:	a1 40 10 11 80       	mov    0x80111040,%eax
8010089e:	29 c2                	sub    %eax,%edx
801008a0:	89 d0                	mov    %edx,%eax
801008a2:	83 f8 7f             	cmp    $0x7f,%eax
801008a5:	77 70                	ja     80100917 <consoleintr+0x14c>
        c = (c == '\r') ? '\n' : c;
801008a7:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ab:	74 05                	je     801008b2 <consoleintr+0xe7>
801008ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b0:	eb 05                	jmp    801008b7 <consoleintr+0xec>
801008b2:	b8 0a 00 00 00       	mov    $0xa,%eax
801008b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ba:	a1 48 10 11 80       	mov    0x80111048,%eax
801008bf:	8d 50 01             	lea    0x1(%eax),%edx
801008c2:	89 15 48 10 11 80    	mov    %edx,0x80111048
801008c8:	83 e0 7f             	and    $0x7f,%eax
801008cb:	89 c2                	mov    %eax,%edx
801008cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d0:	88 82 c0 0f 11 80    	mov    %al,-0x7feef040(%edx)
        consputc(c);
801008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d9:	89 04 24             	mov    %eax,(%esp)
801008dc:	e8 8d fe ff ff       	call   8010076e <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e1:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008e5:	74 18                	je     801008ff <consoleintr+0x134>
801008e7:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008eb:	74 12                	je     801008ff <consoleintr+0x134>
801008ed:	a1 48 10 11 80       	mov    0x80111048,%eax
801008f2:	8b 15 40 10 11 80    	mov    0x80111040,%edx
801008f8:	83 ea 80             	sub    $0xffffff80,%edx
801008fb:	39 d0                	cmp    %edx,%eax
801008fd:	75 18                	jne    80100917 <consoleintr+0x14c>
          input.w = input.e;
801008ff:	a1 48 10 11 80       	mov    0x80111048,%eax
80100904:	a3 44 10 11 80       	mov    %eax,0x80111044
          wakeup(&input.r);
80100909:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100910:	e8 d6 42 00 00       	call   80104beb <wakeup>
        }
      }
      break;
80100915:	eb 00                	jmp    80100917 <consoleintr+0x14c>
80100917:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100918:	8b 45 08             	mov    0x8(%ebp),%eax
8010091b:	ff d0                	call   *%eax
8010091d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100920:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100924:	0f 89 bf fe ff ff    	jns    801007e9 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
8010092a:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100931:	e8 14 46 00 00       	call   80104f4a <release>
  if(doprocdump) {
80100936:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010093a:	74 05                	je     80100941 <consoleintr+0x176>
    procdump();  // now call procdump() wo. cons.lock held
8010093c:	e8 4d 43 00 00       	call   80104c8e <procdump>
  }
}
80100941:	c9                   	leave  
80100942:	c3                   	ret    

80100943 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100943:	55                   	push   %ebp
80100944:	89 e5                	mov    %esp,%ebp
80100946:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100949:	8b 45 08             	mov    0x8(%ebp),%eax
8010094c:	89 04 24             	mov    %eax,(%esp)
8010094f:	e8 de 10 00 00       	call   80101a32 <iunlock>
  target = n;
80100954:	8b 45 10             	mov    0x10(%ebp),%eax
80100957:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010095a:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100961:	e8 7d 45 00 00       	call   80104ee3 <acquire>
  while(n > 0){
80100966:	e9 a6 00 00 00       	jmp    80100a11 <consoleread+0xce>
    while(input.r == input.w){
8010096b:	eb 42                	jmp    801009af <consoleread+0x6c>
      if(proc->killed){
8010096d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100973:	8b 40 24             	mov    0x24(%eax),%eax
80100976:	85 c0                	test   %eax,%eax
80100978:	74 21                	je     8010099b <consoleread+0x58>
        release(&cons.lock);
8010097a:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100981:	e8 c4 45 00 00       	call   80104f4a <release>
        ilock(ip);
80100986:	8b 45 08             	mov    0x8(%ebp),%eax
80100989:	89 04 24             	mov    %eax,(%esp)
8010098c:	e8 8d 0f 00 00       	call   8010191e <ilock>
        return -1;
80100991:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100996:	e9 a1 00 00 00       	jmp    80100a3c <consoleread+0xf9>
      }
      sleep(&input.r, &cons.lock);
8010099b:	c7 44 24 04 c0 b5 10 	movl   $0x8010b5c0,0x4(%esp)
801009a2:	80 
801009a3:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
801009aa:	e8 63 41 00 00       	call   80104b12 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009af:	8b 15 40 10 11 80    	mov    0x80111040,%edx
801009b5:	a1 44 10 11 80       	mov    0x80111044,%eax
801009ba:	39 c2                	cmp    %eax,%edx
801009bc:	74 af                	je     8010096d <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009be:	a1 40 10 11 80       	mov    0x80111040,%eax
801009c3:	8d 50 01             	lea    0x1(%eax),%edx
801009c6:	89 15 40 10 11 80    	mov    %edx,0x80111040
801009cc:	83 e0 7f             	and    $0x7f,%eax
801009cf:	8a 80 c0 0f 11 80    	mov    -0x7feef040(%eax),%al
801009d5:	0f be c0             	movsbl %al,%eax
801009d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009db:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009df:	75 17                	jne    801009f8 <consoleread+0xb5>
      if(n < target){
801009e1:	8b 45 10             	mov    0x10(%ebp),%eax
801009e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009e7:	73 0d                	jae    801009f6 <consoleread+0xb3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009e9:	a1 40 10 11 80       	mov    0x80111040,%eax
801009ee:	48                   	dec    %eax
801009ef:	a3 40 10 11 80       	mov    %eax,0x80111040
      }
      break;
801009f4:	eb 25                	jmp    80100a1b <consoleread+0xd8>
801009f6:	eb 23                	jmp    80100a1b <consoleread+0xd8>
    }
    *dst++ = c;
801009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801009fb:	8d 50 01             	lea    0x1(%eax),%edx
801009fe:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a01:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a04:	88 10                	mov    %dl,(%eax)
    --n;
80100a06:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100a09:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a0d:	75 02                	jne    80100a11 <consoleread+0xce>
      break;
80100a0f:	eb 0a                	jmp    80100a1b <consoleread+0xd8>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a15:	0f 8f 50 ff ff ff    	jg     8010096b <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a1b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a22:	e8 23 45 00 00       	call   80104f4a <release>
  ilock(ip);
80100a27:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2a:	89 04 24             	mov    %eax,(%esp)
80100a2d:	e8 ec 0e 00 00       	call   8010191e <ilock>

  return target - n;
80100a32:	8b 45 10             	mov    0x10(%ebp),%eax
80100a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a38:	29 c2                	sub    %eax,%edx
80100a3a:	89 d0                	mov    %edx,%eax
}
80100a3c:	c9                   	leave  
80100a3d:	c3                   	ret    

80100a3e <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a3e:	55                   	push   %ebp
80100a3f:	89 e5                	mov    %esp,%ebp
80100a41:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a44:	8b 45 08             	mov    0x8(%ebp),%eax
80100a47:	89 04 24             	mov    %eax,(%esp)
80100a4a:	e8 e3 0f 00 00       	call   80101a32 <iunlock>
  acquire(&cons.lock);
80100a4f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a56:	e8 88 44 00 00       	call   80104ee3 <acquire>
  for(i = 0; i < n; i++)
80100a5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a62:	eb 1b                	jmp    80100a7f <consolewrite+0x41>
    consputc(buf[i] & 0xff);
80100a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a6a:	01 d0                	add    %edx,%eax
80100a6c:	8a 00                	mov    (%eax),%al
80100a6e:	0f be c0             	movsbl %al,%eax
80100a71:	0f b6 c0             	movzbl %al,%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 f2 fc ff ff       	call   8010076e <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a7c:	ff 45 f4             	incl   -0xc(%ebp)
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a85:	7c dd                	jl     80100a64 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a87:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a8e:	e8 b7 44 00 00       	call   80104f4a <release>
  ilock(ip);
80100a93:	8b 45 08             	mov    0x8(%ebp),%eax
80100a96:	89 04 24             	mov    %eax,(%esp)
80100a99:	e8 80 0e 00 00       	call   8010191e <ilock>

  return n;
80100a9e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aa1:	c9                   	leave  
80100aa2:	c3                   	ret    

80100aa3 <consoleinit>:

void
consoleinit(void)
{
80100aa3:	55                   	push   %ebp
80100aa4:	89 e5                	mov    %esp,%ebp
80100aa6:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100aa9:	c7 44 24 04 7e 84 10 	movl   $0x8010847e,0x4(%esp)
80100ab0:	80 
80100ab1:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100ab8:	e8 05 44 00 00       	call   80104ec2 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abd:	c7 05 0c 1a 11 80 3e 	movl   $0x80100a3e,0x80111a0c
80100ac4:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac7:	c7 05 08 1a 11 80 43 	movl   $0x80100943,0x80111a08
80100ace:	09 10 80 
  cons.locking = 1;
80100ad1:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100ad8:	00 00 00 

  picenable(IRQ_KBD);
80100adb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae2:	e8 9d 32 00 00       	call   80103d84 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aee:	00 
80100aef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af6:	e8 f2 1e 00 00       	call   801029ed <ioapicenable>
}
80100afb:	c9                   	leave  
80100afc:	c3                   	ret    
80100afd:	00 00                	add    %al,(%eax)
	...

80100b00 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b00:	55                   	push   %ebp
80100b01:	89 e5                	mov    %esp,%ebp
80100b03:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b09:	e8 b5 29 00 00       	call   801034c3 <begin_op>

  if((ip = namei(path)) == 0){
80100b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b11:	89 04 24             	mov    %eax,(%esp)
80100b14:	e8 18 19 00 00       	call   80102431 <namei>
80100b19:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b1c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b20:	75 0f                	jne    80100b31 <exec+0x31>
    end_op();
80100b22:	e8 1e 2a 00 00       	call   80103545 <end_op>
    return -1;
80100b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b2c:	e9 0b 04 00 00       	jmp    80100f3c <exec+0x43c>
  }
  ilock(ip);
80100b31:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b34:	89 04 24             	mov    %eax,(%esp)
80100b37:	e8 e2 0d 00 00       	call   8010191e <ilock>
  pgdir = 0;
80100b3c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b43:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b4a:	00 
80100b4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b52:	00 
80100b53:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b59:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b60:	89 04 24             	mov    %eax,(%esp)
80100b63:	e8 3a 12 00 00       	call   80101da2 <readi>
80100b68:	83 f8 33             	cmp    $0x33,%eax
80100b6b:	77 05                	ja     80100b72 <exec+0x72>
    goto bad;
80100b6d:	e9 9e 03 00 00       	jmp    80100f10 <exec+0x410>
  if(elf.magic != ELF_MAGIC)
80100b72:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b78:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b7d:	74 05                	je     80100b84 <exec+0x84>
    goto bad;
80100b7f:	e9 8c 03 00 00       	jmp    80100f10 <exec+0x410>

  if((pgdir = setupkvm()) == 0)
80100b84:	e8 23 70 00 00       	call   80107bac <setupkvm>
80100b89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b8c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b90:	75 05                	jne    80100b97 <exec+0x97>
    goto bad;
80100b92:	e9 79 03 00 00       	jmp    80100f10 <exec+0x410>

  // Load program into memory.
  sz = 0;
80100b97:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b9e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ba5:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bab:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bae:	e9 fb 00 00 00       	jmp    80100cae <exec+0x1ae>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bb6:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bbd:	00 
80100bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bc2:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bcc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bcf:	89 04 24             	mov    %eax,(%esp)
80100bd2:	e8 cb 11 00 00       	call   80101da2 <readi>
80100bd7:	83 f8 20             	cmp    $0x20,%eax
80100bda:	74 05                	je     80100be1 <exec+0xe1>
      goto bad;
80100bdc:	e9 2f 03 00 00       	jmp    80100f10 <exec+0x410>
    if(ph.type != ELF_PROG_LOAD)
80100be1:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100be7:	83 f8 01             	cmp    $0x1,%eax
80100bea:	74 05                	je     80100bf1 <exec+0xf1>
      continue;
80100bec:	e9 b1 00 00 00       	jmp    80100ca2 <exec+0x1a2>
    if(ph.memsz < ph.filesz)
80100bf1:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bf7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bfd:	39 c2                	cmp    %eax,%edx
80100bff:	73 05                	jae    80100c06 <exec+0x106>
      goto bad;
80100c01:	e9 0a 03 00 00       	jmp    80100f10 <exec+0x410>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c06:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c0c:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c12:	01 c2                	add    %eax,%edx
80100c14:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c1a:	39 c2                	cmp    %eax,%edx
80100c1c:	73 05                	jae    80100c23 <exec+0x123>
      goto bad;
80100c1e:	e9 ed 02 00 00       	jmp    80100f10 <exec+0x410>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c23:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c29:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c2f:	01 d0                	add    %edx,%eax
80100c31:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c3f:	89 04 24             	mov    %eax,(%esp)
80100c42:	e8 00 73 00 00       	call   80107f47 <allocuvm>
80100c47:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c4a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c4e:	75 05                	jne    80100c55 <exec+0x155>
      goto bad;
80100c50:	e9 bb 02 00 00       	jmp    80100f10 <exec+0x410>
    if(ph.vaddr % PGSIZE != 0)
80100c55:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c5b:	25 ff 0f 00 00       	and    $0xfff,%eax
80100c60:	85 c0                	test   %eax,%eax
80100c62:	74 05                	je     80100c69 <exec+0x169>
      goto bad;
80100c64:	e9 a7 02 00 00       	jmp    80100f10 <exec+0x410>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c69:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c6f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c7b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c83:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c86:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c91:	89 04 24             	mov    %eax,(%esp)
80100c94:	e8 cb 71 00 00       	call   80107e64 <loaduvm>
80100c99:	85 c0                	test   %eax,%eax
80100c9b:	79 05                	jns    80100ca2 <exec+0x1a2>
      goto bad;
80100c9d:	e9 6e 02 00 00       	jmp    80100f10 <exec+0x410>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ca2:	ff 45 ec             	incl   -0x14(%ebp)
80100ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca8:	83 c0 20             	add    $0x20,%eax
80100cab:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cae:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
80100cb4:	0f b7 c0             	movzwl %ax,%eax
80100cb7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cba:	0f 8f f3 fe ff ff    	jg     80100bb3 <exec+0xb3>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cc3:	89 04 24             	mov    %eax,(%esp)
80100cc6:	e8 3f 0e 00 00       	call   80101b0a <iunlockput>
  end_op();
80100ccb:	e8 75 28 00 00       	call   80103545 <end_op>
  ip = 0;
80100cd0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cda:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cea:	05 00 20 00 00       	add    $0x2000,%eax
80100cef:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cfd:	89 04 24             	mov    %eax,(%esp)
80100d00:	e8 42 72 00 00       	call   80107f47 <allocuvm>
80100d05:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d08:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d0c:	75 05                	jne    80100d13 <exec+0x213>
    goto bad;
80100d0e:	e9 fd 01 00 00       	jmp    80100f10 <exec+0x410>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d16:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d22:	89 04 24             	mov    %eax,(%esp)
80100d25:	e8 7f 74 00 00       	call   801081a9 <clearpteu>
  sp = sz;
80100d2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d37:	e9 95 00 00 00       	jmp    80100dd1 <exec+0x2d1>
    if(argc >= MAXARG)
80100d3c:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d40:	76 05                	jbe    80100d47 <exec+0x247>
      goto bad;
80100d42:	e9 c9 01 00 00       	jmp    80100f10 <exec+0x410>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d54:	01 d0                	add    %edx,%eax
80100d56:	8b 00                	mov    (%eax),%eax
80100d58:	89 04 24             	mov    %eax,(%esp)
80100d5b:	e8 39 46 00 00       	call   80105399 <strlen>
80100d60:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d63:	29 c2                	sub    %eax,%edx
80100d65:	89 d0                	mov    %edx,%eax
80100d67:	48                   	dec    %eax
80100d68:	83 e0 fc             	and    $0xfffffffc,%eax
80100d6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d78:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d7b:	01 d0                	add    %edx,%eax
80100d7d:	8b 00                	mov    (%eax),%eax
80100d7f:	89 04 24             	mov    %eax,(%esp)
80100d82:	e8 12 46 00 00       	call   80105399 <strlen>
80100d87:	40                   	inc    %eax
80100d88:	89 c2                	mov    %eax,%edx
80100d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d97:	01 c8                	add    %ecx,%eax
80100d99:	8b 00                	mov    (%eax),%eax
80100d9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d9f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100daa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dad:	89 04 24             	mov    %eax,(%esp)
80100db0:	e8 ac 75 00 00       	call   80108361 <copyout>
80100db5:	85 c0                	test   %eax,%eax
80100db7:	79 05                	jns    80100dbe <exec+0x2be>
      goto bad;
80100db9:	e9 52 01 00 00       	jmp    80100f10 <exec+0x410>
    ustack[3+argc] = sp;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 50 03             	lea    0x3(%eax),%edx
80100dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc7:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dce:	ff 45 e4             	incl   -0x1c(%ebp)
80100dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dde:	01 d0                	add    %edx,%eax
80100de0:	8b 00                	mov    (%eax),%eax
80100de2:	85 c0                	test   %eax,%eax
80100de4:	0f 85 52 ff ff ff    	jne    80100d3c <exec+0x23c>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ded:	83 c0 03             	add    $0x3,%eax
80100df0:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df7:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dfb:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e02:	ff ff ff 
  ustack[1] = argc;
80100e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e08:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e11:	40                   	inc    %eax
80100e12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e19:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1c:	29 d0                	sub    %edx,%eax
80100e1e:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	83 c0 04             	add    $0x4,%eax
80100e2a:	c1 e0 02             	shl    $0x2,%eax
80100e2d:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e33:	83 c0 04             	add    $0x4,%eax
80100e36:	c1 e0 02             	shl    $0x2,%eax
80100e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e3d:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e51:	89 04 24             	mov    %eax,(%esp)
80100e54:	e8 08 75 00 00       	call   80108361 <copyout>
80100e59:	85 c0                	test   %eax,%eax
80100e5b:	79 05                	jns    80100e62 <exec+0x362>
    goto bad;
80100e5d:	e9 ae 00 00 00       	jmp    80100f10 <exec+0x410>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e62:	8b 45 08             	mov    0x8(%ebp),%eax
80100e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e6e:	eb 13                	jmp    80100e83 <exec+0x383>
    if(*s == '/')
80100e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e73:	8a 00                	mov    (%eax),%al
80100e75:	3c 2f                	cmp    $0x2f,%al
80100e77:	75 07                	jne    80100e80 <exec+0x380>
      last = s+1;
80100e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7c:	40                   	inc    %eax
80100e7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e80:	ff 45 f4             	incl   -0xc(%ebp)
80100e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e86:	8a 00                	mov    (%eax),%al
80100e88:	84 c0                	test   %al,%al
80100e8a:	75 e4                	jne    80100e70 <exec+0x370>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e92:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e95:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e9c:	00 
80100e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ea4:	89 14 24             	mov    %edx,(%esp)
80100ea7:	e8 a6 44 00 00       	call   80105352 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb2:	8b 40 04             	mov    0x4(%eax),%eax
80100eb5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ec1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ec4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eca:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ecd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 40 18             	mov    0x18(%eax),%eax
80100ed8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ede:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee7:	8b 40 18             	mov    0x18(%eax),%eax
80100eea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eed:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef6:	89 04 24             	mov    %eax,(%esp)
80100ef9:	e8 7a 6d 00 00       	call   80107c78 <switchuvm>
  freevm(oldpgdir);
80100efe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f01:	89 04 24             	mov    %eax,(%esp)
80100f04:	e8 0a 72 00 00       	call   80108113 <freevm>
  return 0;
80100f09:	b8 00 00 00 00       	mov    $0x0,%eax
80100f0e:	eb 2c                	jmp    80100f3c <exec+0x43c>

 bad:
  if(pgdir)
80100f10:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f14:	74 0b                	je     80100f21 <exec+0x421>
    freevm(pgdir);
80100f16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f19:	89 04 24             	mov    %eax,(%esp)
80100f1c:	e8 f2 71 00 00       	call   80108113 <freevm>
  if(ip){
80100f21:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f25:	74 10                	je     80100f37 <exec+0x437>
    iunlockput(ip);
80100f27:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f2a:	89 04 24             	mov    %eax,(%esp)
80100f2d:	e8 d8 0b 00 00       	call   80101b0a <iunlockput>
    end_op();
80100f32:	e8 0e 26 00 00       	call   80103545 <end_op>
  }
  return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f3c:	c9                   	leave  
80100f3d:	c3                   	ret    
	...

80100f40 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f40:	55                   	push   %ebp
80100f41:	89 e5                	mov    %esp,%ebp
80100f43:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f46:	c7 44 24 04 86 84 10 	movl   $0x80108486,0x4(%esp)
80100f4d:	80 
80100f4e:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100f55:	e8 68 3f 00 00       	call   80104ec2 <initlock>
}
80100f5a:	c9                   	leave  
80100f5b:	c3                   	ret    

80100f5c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f5c:	55                   	push   %ebp
80100f5d:	89 e5                	mov    %esp,%ebp
80100f5f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f62:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100f69:	e8 75 3f 00 00       	call   80104ee3 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f6e:	c7 45 f4 94 10 11 80 	movl   $0x80111094,-0xc(%ebp)
80100f75:	eb 29                	jmp    80100fa0 <filealloc+0x44>
    if(f->ref == 0){
80100f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7a:	8b 40 04             	mov    0x4(%eax),%eax
80100f7d:	85 c0                	test   %eax,%eax
80100f7f:	75 1b                	jne    80100f9c <filealloc+0x40>
      f->ref = 1;
80100f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f84:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f8b:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100f92:	e8 b3 3f 00 00       	call   80104f4a <release>
      return f;
80100f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f9a:	eb 1e                	jmp    80100fba <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f9c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fa0:	81 7d f4 f4 19 11 80 	cmpl   $0x801119f4,-0xc(%ebp)
80100fa7:	72 ce                	jb     80100f77 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fa9:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100fb0:	e8 95 3f 00 00       	call   80104f4a <release>
  return 0;
80100fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fba:	c9                   	leave  
80100fbb:	c3                   	ret    

80100fbc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fbc:	55                   	push   %ebp
80100fbd:	89 e5                	mov    %esp,%ebp
80100fbf:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fc2:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100fc9:	e8 15 3f 00 00       	call   80104ee3 <acquire>
  if(f->ref < 1)
80100fce:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd1:	8b 40 04             	mov    0x4(%eax),%eax
80100fd4:	85 c0                	test   %eax,%eax
80100fd6:	7f 0c                	jg     80100fe4 <filedup+0x28>
    panic("filedup");
80100fd8:	c7 04 24 8d 84 10 80 	movl   $0x8010848d,(%esp)
80100fdf:	e8 70 f5 ff ff       	call   80100554 <panic>
  f->ref++;
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe7:	8b 40 04             	mov    0x4(%eax),%eax
80100fea:	8d 50 01             	lea    0x1(%eax),%edx
80100fed:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100ff3:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80100ffa:	e8 4b 3f 00 00       	call   80104f4a <release>
  return f;
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101002:	c9                   	leave  
80101003:	c3                   	ret    

80101004 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101004:	55                   	push   %ebp
80101005:	89 e5                	mov    %esp,%ebp
80101007:	57                   	push   %edi
80101008:	56                   	push   %esi
80101009:	53                   	push   %ebx
8010100a:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
8010100d:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80101014:	e8 ca 3e 00 00       	call   80104ee3 <acquire>
  if(f->ref < 1)
80101019:	8b 45 08             	mov    0x8(%ebp),%eax
8010101c:	8b 40 04             	mov    0x4(%eax),%eax
8010101f:	85 c0                	test   %eax,%eax
80101021:	7f 0c                	jg     8010102f <fileclose+0x2b>
    panic("fileclose");
80101023:	c7 04 24 95 84 10 80 	movl   $0x80108495,(%esp)
8010102a:	e8 25 f5 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
8010102f:	8b 45 08             	mov    0x8(%ebp),%eax
80101032:	8b 40 04             	mov    0x4(%eax),%eax
80101035:	8d 50 ff             	lea    -0x1(%eax),%edx
80101038:	8b 45 08             	mov    0x8(%ebp),%eax
8010103b:	89 50 04             	mov    %edx,0x4(%eax)
8010103e:	8b 45 08             	mov    0x8(%ebp),%eax
80101041:	8b 40 04             	mov    0x4(%eax),%eax
80101044:	85 c0                	test   %eax,%eax
80101046:	7e 0e                	jle    80101056 <fileclose+0x52>
    release(&ftable.lock);
80101048:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
8010104f:	e8 f6 3e 00 00       	call   80104f4a <release>
80101054:	eb 70                	jmp    801010c6 <fileclose+0xc2>
    return;
  }
  ff = *f;
80101056:	8b 45 08             	mov    0x8(%ebp),%eax
80101059:	8d 55 d0             	lea    -0x30(%ebp),%edx
8010105c:	89 c3                	mov    %eax,%ebx
8010105e:	b8 06 00 00 00       	mov    $0x6,%eax
80101063:	89 d7                	mov    %edx,%edi
80101065:	89 de                	mov    %ebx,%esi
80101067:	89 c1                	mov    %eax,%ecx
80101069:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101075:	8b 45 08             	mov    0x8(%ebp),%eax
80101078:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010107e:	c7 04 24 60 10 11 80 	movl   $0x80111060,(%esp)
80101085:	e8 c0 3e 00 00       	call   80104f4a <release>

  if(ff.type == FD_PIPE)
8010108a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010108d:	83 f8 01             	cmp    $0x1,%eax
80101090:	75 17                	jne    801010a9 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101092:	8a 45 d9             	mov    -0x27(%ebp),%al
80101095:	0f be d0             	movsbl %al,%edx
80101098:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010109b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010109f:	89 04 24             	mov    %eax,(%esp)
801010a2:	e8 8c 2f 00 00       	call   80104033 <pipeclose>
801010a7:	eb 1d                	jmp    801010c6 <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801010a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801010ac:	83 f8 02             	cmp    $0x2,%eax
801010af:	75 15                	jne    801010c6 <fileclose+0xc2>
    begin_op();
801010b1:	e8 0d 24 00 00       	call   801034c3 <begin_op>
    iput(ff.ip);
801010b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010b9:	89 04 24             	mov    %eax,(%esp)
801010bc:	e8 b5 09 00 00       	call   80101a76 <iput>
    end_op();
801010c1:	e8 7f 24 00 00       	call   80103545 <end_op>
  }
}
801010c6:	83 c4 3c             	add    $0x3c,%esp
801010c9:	5b                   	pop    %ebx
801010ca:	5e                   	pop    %esi
801010cb:	5f                   	pop    %edi
801010cc:	5d                   	pop    %ebp
801010cd:	c3                   	ret    

801010ce <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010ce:	55                   	push   %ebp
801010cf:	89 e5                	mov    %esp,%ebp
801010d1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010d4:	8b 45 08             	mov    0x8(%ebp),%eax
801010d7:	8b 00                	mov    (%eax),%eax
801010d9:	83 f8 02             	cmp    $0x2,%eax
801010dc:	75 38                	jne    80101116 <filestat+0x48>
    ilock(f->ip);
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 40 10             	mov    0x10(%eax),%eax
801010e4:	89 04 24             	mov    %eax,(%esp)
801010e7:	e8 32 08 00 00       	call   8010191e <ilock>
    stati(f->ip, st);
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 10             	mov    0x10(%eax),%eax
801010f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801010f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801010f9:	89 04 24             	mov    %eax,(%esp)
801010fc:	e8 5d 0c 00 00       	call   80101d5e <stati>
    iunlock(f->ip);
80101101:	8b 45 08             	mov    0x8(%ebp),%eax
80101104:	8b 40 10             	mov    0x10(%eax),%eax
80101107:	89 04 24             	mov    %eax,(%esp)
8010110a:	e8 23 09 00 00       	call   80101a32 <iunlock>
    return 0;
8010110f:	b8 00 00 00 00       	mov    $0x0,%eax
80101114:	eb 05                	jmp    8010111b <filestat+0x4d>
  }
  return -1;
80101116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010111b:	c9                   	leave  
8010111c:	c3                   	ret    

8010111d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010111d:	55                   	push   %ebp
8010111e:	89 e5                	mov    %esp,%ebp
80101120:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	8a 40 08             	mov    0x8(%eax),%al
80101129:	84 c0                	test   %al,%al
8010112b:	75 0a                	jne    80101137 <fileread+0x1a>
    return -1;
8010112d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101132:	e9 9f 00 00 00       	jmp    801011d6 <fileread+0xb9>
  if(f->type == FD_PIPE)
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 00                	mov    (%eax),%eax
8010113c:	83 f8 01             	cmp    $0x1,%eax
8010113f:	75 1e                	jne    8010115f <fileread+0x42>
    return piperead(f->pipe, addr, n);
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 40 0c             	mov    0xc(%eax),%eax
80101147:	8b 55 10             	mov    0x10(%ebp),%edx
8010114a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010114e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101151:	89 54 24 04          	mov    %edx,0x4(%esp)
80101155:	89 04 24             	mov    %eax,(%esp)
80101158:	e8 55 30 00 00       	call   801041b2 <piperead>
8010115d:	eb 77                	jmp    801011d6 <fileread+0xb9>
  if(f->type == FD_INODE){
8010115f:	8b 45 08             	mov    0x8(%ebp),%eax
80101162:	8b 00                	mov    (%eax),%eax
80101164:	83 f8 02             	cmp    $0x2,%eax
80101167:	75 61                	jne    801011ca <fileread+0xad>
    ilock(f->ip);
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	8b 40 10             	mov    0x10(%eax),%eax
8010116f:	89 04 24             	mov    %eax,(%esp)
80101172:	e8 a7 07 00 00       	call   8010191e <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101177:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 50 14             	mov    0x14(%eax),%edx
80101180:	8b 45 08             	mov    0x8(%ebp),%eax
80101183:	8b 40 10             	mov    0x10(%eax),%eax
80101186:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010118a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010118e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101191:	89 54 24 04          	mov    %edx,0x4(%esp)
80101195:	89 04 24             	mov    %eax,(%esp)
80101198:	e8 05 0c 00 00       	call   80101da2 <readi>
8010119d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011a4:	7e 11                	jle    801011b7 <fileread+0x9a>
      f->off += r;
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 50 14             	mov    0x14(%eax),%edx
801011ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011af:	01 c2                	add    %eax,%edx
801011b1:	8b 45 08             	mov    0x8(%ebp),%eax
801011b4:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 40 10             	mov    0x10(%eax),%eax
801011bd:	89 04 24             	mov    %eax,(%esp)
801011c0:	e8 6d 08 00 00       	call   80101a32 <iunlock>
    return r;
801011c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c8:	eb 0c                	jmp    801011d6 <fileread+0xb9>
  }
  panic("fileread");
801011ca:	c7 04 24 9f 84 10 80 	movl   $0x8010849f,(%esp)
801011d1:	e8 7e f3 ff ff       	call   80100554 <panic>
}
801011d6:	c9                   	leave  
801011d7:	c3                   	ret    

801011d8 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011d8:	55                   	push   %ebp
801011d9:	89 e5                	mov    %esp,%ebp
801011db:	53                   	push   %ebx
801011dc:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8a 40 09             	mov    0x9(%eax),%al
801011e5:	84 c0                	test   %al,%al
801011e7:	75 0a                	jne    801011f3 <filewrite+0x1b>
    return -1;
801011e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011ee:	e9 20 01 00 00       	jmp    80101313 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 00                	mov    (%eax),%eax
801011f8:	83 f8 01             	cmp    $0x1,%eax
801011fb:	75 21                	jne    8010121e <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
801011fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101200:	8b 40 0c             	mov    0xc(%eax),%eax
80101203:	8b 55 10             	mov    0x10(%ebp),%edx
80101206:	89 54 24 08          	mov    %edx,0x8(%esp)
8010120a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010120d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101211:	89 04 24             	mov    %eax,(%esp)
80101214:	e8 ac 2e 00 00       	call   801040c5 <pipewrite>
80101219:	e9 f5 00 00 00       	jmp    80101313 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010121e:	8b 45 08             	mov    0x8(%ebp),%eax
80101221:	8b 00                	mov    (%eax),%eax
80101223:	83 f8 02             	cmp    $0x2,%eax
80101226:	0f 85 db 00 00 00    	jne    80101307 <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010122c:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101233:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010123a:	e9 a8 00 00 00       	jmp    801012e7 <filewrite+0x10f>
      int n1 = n - i;
8010123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101242:	8b 55 10             	mov    0x10(%ebp),%edx
80101245:	29 c2                	sub    %eax,%edx
80101247:	89 d0                	mov    %edx,%eax
80101249:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010124f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101252:	7e 06                	jle    8010125a <filewrite+0x82>
        n1 = max;
80101254:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101257:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010125a:	e8 64 22 00 00       	call   801034c3 <begin_op>
      ilock(f->ip);
8010125f:	8b 45 08             	mov    0x8(%ebp),%eax
80101262:	8b 40 10             	mov    0x10(%eax),%eax
80101265:	89 04 24             	mov    %eax,(%esp)
80101268:	e8 b1 06 00 00       	call   8010191e <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010126d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 50 14             	mov    0x14(%eax),%edx
80101276:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010127c:	01 c3                	add    %eax,%ebx
8010127e:	8b 45 08             	mov    0x8(%ebp),%eax
80101281:	8b 40 10             	mov    0x10(%eax),%eax
80101284:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101288:	89 54 24 08          	mov    %edx,0x8(%esp)
8010128c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101290:	89 04 24             	mov    %eax,(%esp)
80101293:	e8 6e 0c 00 00       	call   80101f06 <writei>
80101298:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010129b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010129f:	7e 11                	jle    801012b2 <filewrite+0xda>
        f->off += r;
801012a1:	8b 45 08             	mov    0x8(%ebp),%eax
801012a4:	8b 50 14             	mov    0x14(%eax),%edx
801012a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012aa:	01 c2                	add    %eax,%edx
801012ac:	8b 45 08             	mov    0x8(%ebp),%eax
801012af:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 10             	mov    0x10(%eax),%eax
801012b8:	89 04 24             	mov    %eax,(%esp)
801012bb:	e8 72 07 00 00       	call   80101a32 <iunlock>
      end_op();
801012c0:	e8 80 22 00 00       	call   80103545 <end_op>

      if(r < 0)
801012c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012c9:	79 02                	jns    801012cd <filewrite+0xf5>
        break;
801012cb:	eb 26                	jmp    801012f3 <filewrite+0x11b>
      if(r != n1)
801012cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012d3:	74 0c                	je     801012e1 <filewrite+0x109>
        panic("short filewrite");
801012d5:	c7 04 24 a8 84 10 80 	movl   $0x801084a8,(%esp)
801012dc:	e8 73 f2 ff ff       	call   80100554 <panic>
      i += r;
801012e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e4:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ed:	0f 8c 4c ff ff ff    	jl     8010123f <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012f6:	3b 45 10             	cmp    0x10(%ebp),%eax
801012f9:	75 05                	jne    80101300 <filewrite+0x128>
801012fb:	8b 45 10             	mov    0x10(%ebp),%eax
801012fe:	eb 05                	jmp    80101305 <filewrite+0x12d>
80101300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101305:	eb 0c                	jmp    80101313 <filewrite+0x13b>
  }
  panic("filewrite");
80101307:	c7 04 24 b8 84 10 80 	movl   $0x801084b8,(%esp)
8010130e:	e8 41 f2 ff ff       	call   80100554 <panic>
}
80101313:	83 c4 24             	add    $0x24,%esp
80101316:	5b                   	pop    %ebx
80101317:	5d                   	pop    %ebp
80101318:	c3                   	ret    
80101319:	00 00                	add    %al,(%eax)
	...

8010131c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010131c:	55                   	push   %ebp
8010131d:	89 e5                	mov    %esp,%ebp
8010131f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010132c:	00 
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 80 ee ff ff       	call   801001b5 <bread>
80101335:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133b:	83 c0 5c             	add    $0x5c,%eax
8010133e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101345:	00 
80101346:	89 44 24 04          	mov    %eax,0x4(%esp)
8010134a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010134d:	89 04 24             	mov    %eax,(%esp)
80101350:	e8 ba 3e 00 00       	call   8010520f <memmove>
  brelse(bp);
80101355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101358:	89 04 24             	mov    %eax,(%esp)
8010135b:	e8 cc ee ff ff       	call   8010022c <brelse>
}
80101360:	c9                   	leave  
80101361:	c3                   	ret    

80101362 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101362:	55                   	push   %ebp
80101363:	89 e5                	mov    %esp,%ebp
80101365:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101368:	8b 55 0c             	mov    0xc(%ebp),%edx
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101372:	89 04 24             	mov    %eax,(%esp)
80101375:	e8 3b ee ff ff       	call   801001b5 <bread>
8010137a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101380:	83 c0 5c             	add    $0x5c,%eax
80101383:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010138a:	00 
8010138b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101392:	00 
80101393:	89 04 24             	mov    %eax,(%esp)
80101396:	e8 ab 3d 00 00       	call   80105146 <memset>
  log_write(bp);
8010139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139e:	89 04 24             	mov    %eax,(%esp)
801013a1:	e8 21 23 00 00       	call   801036c7 <log_write>
  brelse(bp);
801013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a9:	89 04 24             	mov    %eax,(%esp)
801013ac:	e8 7b ee ff ff       	call   8010022c <brelse>
}
801013b1:	c9                   	leave  
801013b2:	c3                   	ret    

801013b3 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013b3:	55                   	push   %ebp
801013b4:	89 e5                	mov    %esp,%ebp
801013b6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013c7:	e9 03 01 00 00       	jmp    801014cf <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
801013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013cf:	85 c0                	test   %eax,%eax
801013d1:	79 05                	jns    801013d8 <balloc+0x25>
801013d3:	05 ff 0f 00 00       	add    $0xfff,%eax
801013d8:	c1 f8 0c             	sar    $0xc,%eax
801013db:	89 c2                	mov    %eax,%edx
801013dd:	a1 78 1a 11 80       	mov    0x80111a78,%eax
801013e2:	01 d0                	add    %edx,%eax
801013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e8:	8b 45 08             	mov    0x8(%ebp),%eax
801013eb:	89 04 24             	mov    %eax,(%esp)
801013ee:	e8 c2 ed ff ff       	call   801001b5 <bread>
801013f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013fd:	e9 9b 00 00 00       	jmp    8010149d <balloc+0xea>
      m = 1 << (bi % 8);
80101402:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101405:	25 07 00 00 80       	and    $0x80000007,%eax
8010140a:	85 c0                	test   %eax,%eax
8010140c:	79 05                	jns    80101413 <balloc+0x60>
8010140e:	48                   	dec    %eax
8010140f:	83 c8 f8             	or     $0xfffffff8,%eax
80101412:	40                   	inc    %eax
80101413:	ba 01 00 00 00       	mov    $0x1,%edx
80101418:	88 c1                	mov    %al,%cl
8010141a:	d3 e2                	shl    %cl,%edx
8010141c:	89 d0                	mov    %edx,%eax
8010141e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101424:	85 c0                	test   %eax,%eax
80101426:	79 03                	jns    8010142b <balloc+0x78>
80101428:	83 c0 07             	add    $0x7,%eax
8010142b:	c1 f8 03             	sar    $0x3,%eax
8010142e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101431:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101435:	0f b6 c0             	movzbl %al,%eax
80101438:	23 45 e8             	and    -0x18(%ebp),%eax
8010143b:	85 c0                	test   %eax,%eax
8010143d:	75 5b                	jne    8010149a <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101442:	85 c0                	test   %eax,%eax
80101444:	79 03                	jns    80101449 <balloc+0x96>
80101446:	83 c0 07             	add    $0x7,%eax
80101449:	c1 f8 03             	sar    $0x3,%eax
8010144c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144f:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101453:	88 d1                	mov    %dl,%cl
80101455:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101458:	09 ca                	or     %ecx,%edx
8010145a:	88 d1                	mov    %dl,%cl
8010145c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010145f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101466:	89 04 24             	mov    %eax,(%esp)
80101469:	e8 59 22 00 00       	call   801036c7 <log_write>
        brelse(bp);
8010146e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101471:	89 04 24             	mov    %eax,(%esp)
80101474:	e8 b3 ed ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010147f:	01 c2                	add    %eax,%edx
80101481:	8b 45 08             	mov    0x8(%ebp),%eax
80101484:	89 54 24 04          	mov    %edx,0x4(%esp)
80101488:	89 04 24             	mov    %eax,(%esp)
8010148b:	e8 d2 fe ff ff       	call   80101362 <bzero>
        return b + bi;
80101490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101493:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101496:	01 d0                	add    %edx,%eax
80101498:	eb 51                	jmp    801014eb <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010149a:	ff 45 f0             	incl   -0x10(%ebp)
8010149d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014a4:	7f 17                	jg     801014bd <balloc+0x10a>
801014a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ac:	01 d0                	add    %edx,%eax
801014ae:	89 c2                	mov    %eax,%edx
801014b0:	a1 60 1a 11 80       	mov    0x80111a60,%eax
801014b5:	39 c2                	cmp    %eax,%edx
801014b7:	0f 82 45 ff ff ff    	jb     80101402 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c0:	89 04 24             	mov    %eax,(%esp)
801014c3:	e8 64 ed ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014c8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d2:	a1 60 1a 11 80       	mov    0x80111a60,%eax
801014d7:	39 c2                	cmp    %eax,%edx
801014d9:	0f 82 ed fe ff ff    	jb     801013cc <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014df:	c7 04 24 c4 84 10 80 	movl   $0x801084c4,(%esp)
801014e6:	e8 69 f0 ff ff       	call   80100554 <panic>
}
801014eb:	c9                   	leave  
801014ec:	c3                   	ret    

801014ed <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014ed:	55                   	push   %ebp
801014ee:	89 e5                	mov    %esp,%ebp
801014f0:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014f3:	c7 44 24 04 60 1a 11 	movl   $0x80111a60,0x4(%esp)
801014fa:	80 
801014fb:	8b 45 08             	mov    0x8(%ebp),%eax
801014fe:	89 04 24             	mov    %eax,(%esp)
80101501:	e8 16 fe ff ff       	call   8010131c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101506:	8b 45 0c             	mov    0xc(%ebp),%eax
80101509:	c1 e8 0c             	shr    $0xc,%eax
8010150c:	89 c2                	mov    %eax,%edx
8010150e:	a1 78 1a 11 80       	mov    0x80111a78,%eax
80101513:	01 c2                	add    %eax,%edx
80101515:	8b 45 08             	mov    0x8(%ebp),%eax
80101518:	89 54 24 04          	mov    %edx,0x4(%esp)
8010151c:	89 04 24             	mov    %eax,(%esp)
8010151f:	e8 91 ec ff ff       	call   801001b5 <bread>
80101524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101527:	8b 45 0c             	mov    0xc(%ebp),%eax
8010152a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010152f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101535:	25 07 00 00 80       	and    $0x80000007,%eax
8010153a:	85 c0                	test   %eax,%eax
8010153c:	79 05                	jns    80101543 <bfree+0x56>
8010153e:	48                   	dec    %eax
8010153f:	83 c8 f8             	or     $0xfffffff8,%eax
80101542:	40                   	inc    %eax
80101543:	ba 01 00 00 00       	mov    $0x1,%edx
80101548:	88 c1                	mov    %al,%cl
8010154a:	d3 e2                	shl    %cl,%edx
8010154c:	89 d0                	mov    %edx,%eax
8010154e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101554:	85 c0                	test   %eax,%eax
80101556:	79 03                	jns    8010155b <bfree+0x6e>
80101558:	83 c0 07             	add    $0x7,%eax
8010155b:	c1 f8 03             	sar    $0x3,%eax
8010155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101561:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101565:	0f b6 c0             	movzbl %al,%eax
80101568:	23 45 ec             	and    -0x14(%ebp),%eax
8010156b:	85 c0                	test   %eax,%eax
8010156d:	75 0c                	jne    8010157b <bfree+0x8e>
    panic("freeing free block");
8010156f:	c7 04 24 da 84 10 80 	movl   $0x801084da,(%esp)
80101576:	e8 d9 ef ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157e:	85 c0                	test   %eax,%eax
80101580:	79 03                	jns    80101585 <bfree+0x98>
80101582:	83 c0 07             	add    $0x7,%eax
80101585:	c1 f8 03             	sar    $0x3,%eax
80101588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158b:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010158f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101592:	f7 d1                	not    %ecx
80101594:	21 ca                	and    %ecx,%edx
80101596:	88 d1                	mov    %dl,%cl
80101598:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a2:	89 04 24             	mov    %eax,(%esp)
801015a5:	e8 1d 21 00 00       	call   801036c7 <log_write>
  brelse(bp);
801015aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ad:	89 04 24             	mov    %eax,(%esp)
801015b0:	e8 77 ec ff ff       	call   8010022c <brelse>
}
801015b5:	c9                   	leave  
801015b6:	c3                   	ret    

801015b7 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015b7:	55                   	push   %ebp
801015b8:	89 e5                	mov    %esp,%ebp
801015ba:	57                   	push   %edi
801015bb:	56                   	push   %esi
801015bc:	53                   	push   %ebx
801015bd:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801015c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801015c7:	c7 44 24 04 ed 84 10 	movl   $0x801084ed,0x4(%esp)
801015ce:	80 
801015cf:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
801015d6:	e8 e7 38 00 00       	call   80104ec2 <initlock>
  for(i = 0; i < NINODE; i++) {
801015db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801015e2:	eb 2b                	jmp    8010160f <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
801015e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015e7:	89 d0                	mov    %edx,%eax
801015e9:	c1 e0 03             	shl    $0x3,%eax
801015ec:	01 d0                	add    %edx,%eax
801015ee:	c1 e0 04             	shl    $0x4,%eax
801015f1:	83 c0 30             	add    $0x30,%eax
801015f4:	05 80 1a 11 80       	add    $0x80111a80,%eax
801015f9:	83 c0 10             	add    $0x10,%eax
801015fc:	c7 44 24 04 f4 84 10 	movl   $0x801084f4,0x4(%esp)
80101603:	80 
80101604:	89 04 24             	mov    %eax,(%esp)
80101607:	e8 78 37 00 00       	call   80104d84 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
8010160c:	ff 45 e4             	incl   -0x1c(%ebp)
8010160f:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101613:	7e cf                	jle    801015e4 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }
  
  readsb(dev, &sb);
80101615:	c7 44 24 04 60 1a 11 	movl   $0x80111a60,0x4(%esp)
8010161c:	80 
8010161d:	8b 45 08             	mov    0x8(%ebp),%eax
80101620:	89 04 24             	mov    %eax,(%esp)
80101623:	e8 f4 fc ff ff       	call   8010131c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101628:	a1 78 1a 11 80       	mov    0x80111a78,%eax
8010162d:	8b 3d 74 1a 11 80    	mov    0x80111a74,%edi
80101633:	8b 35 70 1a 11 80    	mov    0x80111a70,%esi
80101639:	8b 1d 6c 1a 11 80    	mov    0x80111a6c,%ebx
8010163f:	8b 0d 68 1a 11 80    	mov    0x80111a68,%ecx
80101645:	8b 15 64 1a 11 80    	mov    0x80111a64,%edx
8010164b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010164e:	8b 15 60 1a 11 80    	mov    0x80111a60,%edx
80101654:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101658:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010165c:	89 74 24 14          	mov    %esi,0x14(%esp)
80101660:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101664:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101668:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010166b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010166f:	89 d0                	mov    %edx,%eax
80101671:	89 44 24 04          	mov    %eax,0x4(%esp)
80101675:	c7 04 24 fc 84 10 80 	movl   $0x801084fc,(%esp)
8010167c:	e8 40 ed ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101681:	83 c4 4c             	add    $0x4c,%esp
80101684:	5b                   	pop    %ebx
80101685:	5e                   	pop    %esi
80101686:	5f                   	pop    %edi
80101687:	5d                   	pop    %ebp
80101688:	c3                   	ret    

80101689 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101689:	55                   	push   %ebp
8010168a:	89 e5                	mov    %esp,%ebp
8010168c:	83 ec 28             	sub    $0x28,%esp
8010168f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101692:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101696:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010169d:	e9 9b 00 00 00       	jmp    8010173d <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a5:	c1 e8 03             	shr    $0x3,%eax
801016a8:	89 c2                	mov    %eax,%edx
801016aa:	a1 74 1a 11 80       	mov    0x80111a74,%eax
801016af:	01 d0                	add    %edx,%eax
801016b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801016b5:	8b 45 08             	mov    0x8(%ebp),%eax
801016b8:	89 04 24             	mov    %eax,(%esp)
801016bb:	e8 f5 ea ff ff       	call   801001b5 <bread>
801016c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c6:	8d 50 5c             	lea    0x5c(%eax),%edx
801016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cc:	83 e0 07             	and    $0x7,%eax
801016cf:	c1 e0 06             	shl    $0x6,%eax
801016d2:	01 d0                	add    %edx,%eax
801016d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016da:	8b 00                	mov    (%eax),%eax
801016dc:	66 85 c0             	test   %ax,%ax
801016df:	75 4e                	jne    8010172f <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801016e1:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801016e8:	00 
801016e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016f0:	00 
801016f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016f4:	89 04 24             	mov    %eax,(%esp)
801016f7:	e8 4a 3a 00 00       	call   80105146 <memset>
      dip->type = type;
801016fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101702:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101708:	89 04 24             	mov    %eax,(%esp)
8010170b:	e8 b7 1f 00 00       	call   801036c7 <log_write>
      brelse(bp);
80101710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101713:	89 04 24             	mov    %eax,(%esp)
80101716:	e8 11 eb ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
8010171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101722:	8b 45 08             	mov    0x8(%ebp),%eax
80101725:	89 04 24             	mov    %eax,(%esp)
80101728:	e8 ea 00 00 00       	call   80101817 <iget>
8010172d:	eb 2a                	jmp    80101759 <ialloc+0xd0>
    }
    brelse(bp);
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	89 04 24             	mov    %eax,(%esp)
80101735:	e8 f2 ea ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010173a:	ff 45 f4             	incl   -0xc(%ebp)
8010173d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101740:	a1 68 1a 11 80       	mov    0x80111a68,%eax
80101745:	39 c2                	cmp    %eax,%edx
80101747:	0f 82 55 ff ff ff    	jb     801016a2 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010174d:	c7 04 24 4f 85 10 80 	movl   $0x8010854f,(%esp)
80101754:	e8 fb ed ff ff       	call   80100554 <panic>
}
80101759:	c9                   	leave  
8010175a:	c3                   	ret    

8010175b <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101761:	8b 45 08             	mov    0x8(%ebp),%eax
80101764:	8b 40 04             	mov    0x4(%eax),%eax
80101767:	c1 e8 03             	shr    $0x3,%eax
8010176a:	89 c2                	mov    %eax,%edx
8010176c:	a1 74 1a 11 80       	mov    0x80111a74,%eax
80101771:	01 c2                	add    %eax,%edx
80101773:	8b 45 08             	mov    0x8(%ebp),%eax
80101776:	8b 00                	mov    (%eax),%eax
80101778:	89 54 24 04          	mov    %edx,0x4(%esp)
8010177c:	89 04 24             	mov    %eax,(%esp)
8010177f:	e8 31 ea ff ff       	call   801001b5 <bread>
80101784:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010178a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010178d:	8b 45 08             	mov    0x8(%ebp),%eax
80101790:	8b 40 04             	mov    0x4(%eax),%eax
80101793:	83 e0 07             	and    $0x7,%eax
80101796:	c1 e0 06             	shl    $0x6,%eax
80101799:	01 d0                	add    %edx,%eax
8010179b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010179e:	8b 45 08             	mov    0x8(%ebp),%eax
801017a1:	8b 40 50             	mov    0x50(%eax),%eax
801017a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017a7:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801017aa:	8b 45 08             	mov    0x8(%ebp),%eax
801017ad:	66 8b 40 52          	mov    0x52(%eax),%ax
801017b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017b4:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801017b8:	8b 45 08             	mov    0x8(%ebp),%eax
801017bb:	8b 40 54             	mov    0x54(%eax),%eax
801017be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017c1:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801017c5:	8b 45 08             	mov    0x8(%ebp),%eax
801017c8:	66 8b 40 56          	mov    0x56(%eax),%ax
801017cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801017cf:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801017d3:	8b 45 08             	mov    0x8(%ebp),%eax
801017d6:	8b 50 58             	mov    0x58(%eax),%edx
801017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017dc:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017df:	8b 45 08             	mov    0x8(%ebp),%eax
801017e2:	8d 50 5c             	lea    0x5c(%eax),%edx
801017e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e8:	83 c0 0c             	add    $0xc,%eax
801017eb:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017f2:	00 
801017f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801017f7:	89 04 24             	mov    %eax,(%esp)
801017fa:	e8 10 3a 00 00       	call   8010520f <memmove>
  log_write(bp);
801017ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101802:	89 04 24             	mov    %eax,(%esp)
80101805:	e8 bd 1e 00 00       	call   801036c7 <log_write>
  brelse(bp);
8010180a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180d:	89 04 24             	mov    %eax,(%esp)
80101810:	e8 17 ea ff ff       	call   8010022c <brelse>
}
80101815:	c9                   	leave  
80101816:	c3                   	ret    

80101817 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101817:	55                   	push   %ebp
80101818:	89 e5                	mov    %esp,%ebp
8010181a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010181d:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
80101824:	e8 ba 36 00 00       	call   80104ee3 <acquire>

  // Is the inode already cached?
  empty = 0;
80101829:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101830:	c7 45 f4 b4 1a 11 80 	movl   $0x80111ab4,-0xc(%ebp)
80101837:	eb 5c                	jmp    80101895 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183c:	8b 40 08             	mov    0x8(%eax),%eax
8010183f:	85 c0                	test   %eax,%eax
80101841:	7e 35                	jle    80101878 <iget+0x61>
80101843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101846:	8b 00                	mov    (%eax),%eax
80101848:	3b 45 08             	cmp    0x8(%ebp),%eax
8010184b:	75 2b                	jne    80101878 <iget+0x61>
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	8b 40 04             	mov    0x4(%eax),%eax
80101853:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101856:	75 20                	jne    80101878 <iget+0x61>
      ip->ref++;
80101858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185b:	8b 40 08             	mov    0x8(%eax),%eax
8010185e:	8d 50 01             	lea    0x1(%eax),%edx
80101861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101864:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101867:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
8010186e:	e8 d7 36 00 00       	call   80104f4a <release>
      return ip;
80101873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101876:	eb 72                	jmp    801018ea <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101878:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010187c:	75 10                	jne    8010188e <iget+0x77>
8010187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101881:	8b 40 08             	mov    0x8(%eax),%eax
80101884:	85 c0                	test   %eax,%eax
80101886:	75 06                	jne    8010188e <iget+0x77>
      empty = ip;
80101888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010188e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101895:	81 7d f4 d4 36 11 80 	cmpl   $0x801136d4,-0xc(%ebp)
8010189c:	72 9b                	jb     80101839 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010189e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018a2:	75 0c                	jne    801018b0 <iget+0x99>
    panic("iget: no inodes");
801018a4:	c7 04 24 61 85 10 80 	movl   $0x80108561,(%esp)
801018ab:	e8 a4 ec ff ff       	call   80100554 <panic>

  ip = empty;
801018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	8b 55 08             	mov    0x8(%ebp),%edx
801018bc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801018c4:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d4:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801018db:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
801018e2:	e8 63 36 00 00       	call   80104f4a <release>

  return ip;
801018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018ea:	c9                   	leave  
801018eb:	c3                   	ret    

801018ec <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018ec:	55                   	push   %ebp
801018ed:	89 e5                	mov    %esp,%ebp
801018ef:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018f2:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
801018f9:	e8 e5 35 00 00       	call   80104ee3 <acquire>
  ip->ref++;
801018fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101901:	8b 40 08             	mov    0x8(%eax),%eax
80101904:	8d 50 01             	lea    0x1(%eax),%edx
80101907:	8b 45 08             	mov    0x8(%ebp),%eax
8010190a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010190d:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
80101914:	e8 31 36 00 00       	call   80104f4a <release>
  return ip;
80101919:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010191c:	c9                   	leave  
8010191d:	c3                   	ret    

8010191e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010191e:	55                   	push   %ebp
8010191f:	89 e5                	mov    %esp,%ebp
80101921:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101924:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101928:	74 0a                	je     80101934 <ilock+0x16>
8010192a:	8b 45 08             	mov    0x8(%ebp),%eax
8010192d:	8b 40 08             	mov    0x8(%eax),%eax
80101930:	85 c0                	test   %eax,%eax
80101932:	7f 0c                	jg     80101940 <ilock+0x22>
    panic("ilock");
80101934:	c7 04 24 71 85 10 80 	movl   $0x80108571,(%esp)
8010193b:	e8 14 ec ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	83 c0 0c             	add    $0xc,%eax
80101946:	89 04 24             	mov    %eax,(%esp)
80101949:	e8 70 34 00 00       	call   80104dbe <acquiresleep>

  if(!(ip->flags & I_VALID)){
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	8b 40 4c             	mov    0x4c(%eax),%eax
80101954:	83 e0 02             	and    $0x2,%eax
80101957:	85 c0                	test   %eax,%eax
80101959:	0f 85 d1 00 00 00    	jne    80101a30 <ilock+0x112>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010195f:	8b 45 08             	mov    0x8(%ebp),%eax
80101962:	8b 40 04             	mov    0x4(%eax),%eax
80101965:	c1 e8 03             	shr    $0x3,%eax
80101968:	89 c2                	mov    %eax,%edx
8010196a:	a1 74 1a 11 80       	mov    0x80111a74,%eax
8010196f:	01 c2                	add    %eax,%edx
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	8b 00                	mov    (%eax),%eax
80101976:	89 54 24 04          	mov    %edx,0x4(%esp)
8010197a:	89 04 24             	mov    %eax,(%esp)
8010197d:	e8 33 e8 ff ff       	call   801001b5 <bread>
80101982:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101988:	8d 50 5c             	lea    0x5c(%eax),%edx
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	8b 40 04             	mov    0x4(%eax),%eax
80101991:	83 e0 07             	and    $0x7,%eax
80101994:	c1 e0 06             	shl    $0x6,%eax
80101997:	01 d0                	add    %edx,%eax
80101999:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010199c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199f:	8b 00                	mov    (%eax),%eax
801019a1:	8b 55 08             	mov    0x8(%ebp),%edx
801019a4:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
801019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ab:	66 8b 40 02          	mov    0x2(%eax),%ax
801019af:	8b 55 08             	mov    0x8(%ebp),%edx
801019b2:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
801019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b9:	8b 40 04             	mov    0x4(%eax),%eax
801019bc:	8b 55 08             	mov    0x8(%ebp),%edx
801019bf:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
801019c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c6:	66 8b 40 06          	mov    0x6(%eax),%ax
801019ca:	8b 55 08             	mov    0x8(%ebp),%edx
801019cd:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
801019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d4:	8b 50 08             	mov    0x8(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e0:	8d 50 0c             	lea    0xc(%eax),%edx
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	83 c0 5c             	add    $0x5c,%eax
801019e9:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019f0:	00 
801019f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801019f5:	89 04 24             	mov    %eax,(%esp)
801019f8:	e8 12 38 00 00       	call   8010520f <memmove>
    brelse(bp);
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	89 04 24             	mov    %eax,(%esp)
80101a03:	e8 24 e8 ff ff       	call   8010022c <brelse>
    ip->flags |= I_VALID;
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a0e:	83 c8 02             	or     $0x2,%eax
80101a11:	89 c2                	mov    %eax,%edx
80101a13:	8b 45 08             	mov    0x8(%ebp),%eax
80101a16:	89 50 4c             	mov    %edx,0x4c(%eax)
    if(ip->type == 0)
80101a19:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1c:	8b 40 50             	mov    0x50(%eax),%eax
80101a1f:	66 85 c0             	test   %ax,%ax
80101a22:	75 0c                	jne    80101a30 <ilock+0x112>
      panic("ilock: no type");
80101a24:	c7 04 24 77 85 10 80 	movl   $0x80108577,(%esp)
80101a2b:	e8 24 eb ff ff       	call   80100554 <panic>
  }
}
80101a30:	c9                   	leave  
80101a31:	c3                   	ret    

80101a32 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a32:	55                   	push   %ebp
80101a33:	89 e5                	mov    %esp,%ebp
80101a35:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a3c:	74 1c                	je     80101a5a <iunlock+0x28>
80101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a41:	83 c0 0c             	add    $0xc,%eax
80101a44:	89 04 24             	mov    %eax,(%esp)
80101a47:	e8 10 34 00 00       	call   80104e5c <holdingsleep>
80101a4c:	85 c0                	test   %eax,%eax
80101a4e:	74 0a                	je     80101a5a <iunlock+0x28>
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	8b 40 08             	mov    0x8(%eax),%eax
80101a56:	85 c0                	test   %eax,%eax
80101a58:	7f 0c                	jg     80101a66 <iunlock+0x34>
    panic("iunlock");
80101a5a:	c7 04 24 86 85 10 80 	movl   $0x80108586,(%esp)
80101a61:	e8 ee ea ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101a66:	8b 45 08             	mov    0x8(%ebp),%eax
80101a69:	83 c0 0c             	add    $0xc,%eax
80101a6c:	89 04 24             	mov    %eax,(%esp)
80101a6f:	e8 a6 33 00 00       	call   80104e1a <releasesleep>
}
80101a74:	c9                   	leave  
80101a75:	c3                   	ret    

80101a76 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a76:	55                   	push   %ebp
80101a77:	89 e5                	mov    %esp,%ebp
80101a79:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a7c:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
80101a83:	e8 5b 34 00 00       	call   80104ee3 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	8b 40 08             	mov    0x8(%eax),%eax
80101a8e:	83 f8 01             	cmp    $0x1,%eax
80101a91:	75 5a                	jne    80101aed <iput+0x77>
80101a93:	8b 45 08             	mov    0x8(%ebp),%eax
80101a96:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a99:	83 e0 02             	and    $0x2,%eax
80101a9c:	85 c0                	test   %eax,%eax
80101a9e:	74 4d                	je     80101aed <iput+0x77>
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	66 8b 40 56          	mov    0x56(%eax),%ax
80101aa7:	66 85 c0             	test   %ax,%ax
80101aaa:	75 41                	jne    80101aed <iput+0x77>
    // inode has no links and no other references: truncate and free.
    release(&icache.lock);
80101aac:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
80101ab3:	e8 92 34 00 00       	call   80104f4a <release>
    itrunc(ip);
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	89 04 24             	mov    %eax,(%esp)
80101abe:	e8 78 01 00 00       	call   80101c3b <itrunc>
    ip->type = 0;
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
    iupdate(ip);
80101acc:	8b 45 08             	mov    0x8(%ebp),%eax
80101acf:	89 04 24             	mov    %eax,(%esp)
80101ad2:	e8 84 fc ff ff       	call   8010175b <iupdate>
    acquire(&icache.lock);
80101ad7:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
80101ade:	e8 00 34 00 00       	call   80104ee3 <acquire>
    ip->flags = 0;
80101ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae6:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }
  ip->ref--;
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	8b 40 08             	mov    0x8(%eax),%eax
80101af3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101afc:	c7 04 24 80 1a 11 80 	movl   $0x80111a80,(%esp)
80101b03:	e8 42 34 00 00       	call   80104f4a <release>
}
80101b08:	c9                   	leave  
80101b09:	c3                   	ret    

80101b0a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b0a:	55                   	push   %ebp
80101b0b:	89 e5                	mov    %esp,%ebp
80101b0d:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	89 04 24             	mov    %eax,(%esp)
80101b16:	e8 17 ff ff ff       	call   80101a32 <iunlock>
  iput(ip);
80101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1e:	89 04 24             	mov    %eax,(%esp)
80101b21:	e8 50 ff ff ff       	call   80101a76 <iput>
}
80101b26:	c9                   	leave  
80101b27:	c3                   	ret    

80101b28 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b28:	55                   	push   %ebp
80101b29:	89 e5                	mov    %esp,%ebp
80101b2b:	53                   	push   %ebx
80101b2c:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b2f:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b33:	77 3e                	ja     80101b73 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b3b:	83 c2 14             	add    $0x14,%edx
80101b3e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b49:	75 20                	jne    80101b6b <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 00                	mov    (%eax),%eax
80101b50:	89 04 24             	mov    %eax,(%esp)
80101b53:	e8 5b f8 ff ff       	call   801013b3 <balloc>
80101b58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b61:	8d 4a 14             	lea    0x14(%edx),%ecx
80101b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b67:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6e:	e9 c2 00 00 00       	jmp    80101c35 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101b73:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b77:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b7b:	0f 87 a8 00 00 00    	ja     80101c29 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b91:	75 1c                	jne    80101baf <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	8b 00                	mov    (%eax),%eax
80101b98:	89 04 24             	mov    %eax,(%esp)
80101b9b:	e8 13 f8 ff ff       	call   801013b3 <balloc>
80101ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 00                	mov    (%eax),%eax
80101bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bbb:	89 04 24             	mov    %eax,(%esp)
80101bbe:	e8 f2 e5 ff ff       	call   801001b5 <bread>
80101bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc9:	83 c0 5c             	add    $0x5c,%eax
80101bcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bdc:	01 d0                	add    %edx,%eax
80101bde:	8b 00                	mov    (%eax),%eax
80101be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be7:	75 30                	jne    80101c19 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101be9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bf6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 00                	mov    (%eax),%eax
80101bfe:	89 04 24             	mov    %eax,(%esp)
80101c01:	e8 ad f7 ff ff       	call   801013b3 <balloc>
80101c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0c:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c11:	89 04 24             	mov    %eax,(%esp)
80101c14:	e8 ae 1a 00 00       	call   801036c7 <log_write>
    }
    brelse(bp);
80101c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1c:	89 04 24             	mov    %eax,(%esp)
80101c1f:	e8 08 e6 ff ff       	call   8010022c <brelse>
    return addr;
80101c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c27:	eb 0c                	jmp    80101c35 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101c29:	c7 04 24 8e 85 10 80 	movl   $0x8010858e,(%esp)
80101c30:	e8 1f e9 ff ff       	call   80100554 <panic>
}
80101c35:	83 c4 24             	add    $0x24,%esp
80101c38:	5b                   	pop    %ebx
80101c39:	5d                   	pop    %ebp
80101c3a:	c3                   	ret    

80101c3b <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c3b:	55                   	push   %ebp
80101c3c:	89 e5                	mov    %esp,%ebp
80101c3e:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c48:	eb 43                	jmp    80101c8d <itrunc+0x52>
    if(ip->addrs[i]){
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c50:	83 c2 14             	add    $0x14,%edx
80101c53:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c57:	85 c0                	test   %eax,%eax
80101c59:	74 2f                	je     80101c8a <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c61:	83 c2 14             	add    $0x14,%edx
80101c64:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c68:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6b:	8b 00                	mov    (%eax),%eax
80101c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c71:	89 04 24             	mov    %eax,(%esp)
80101c74:	e8 74 f8 ff ff       	call   801014ed <bfree>
      ip->addrs[i] = 0;
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7f:	83 c2 14             	add    $0x14,%edx
80101c82:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c89:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c8a:	ff 45 f4             	incl   -0xc(%ebp)
80101c8d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c91:	7e b7                	jle    80101c4a <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c9c:	85 c0                	test   %eax,%eax
80101c9e:	0f 84 a3 00 00 00    	je     80101d47 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	8b 00                	mov    (%eax),%eax
80101cb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cb6:	89 04 24             	mov    %eax,(%esp)
80101cb9:	e8 f7 e4 ff ff       	call   801001b5 <bread>
80101cbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc4:	83 c0 5c             	add    $0x5c,%eax
80101cc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101cd1:	eb 3a                	jmp    80101d0d <itrunc+0xd2>
      if(a[j])
80101cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ce0:	01 d0                	add    %edx,%eax
80101ce2:	8b 00                	mov    (%eax),%eax
80101ce4:	85 c0                	test   %eax,%eax
80101ce6:	74 22                	je     80101d0a <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ceb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cf5:	01 d0                	add    %edx,%eax
80101cf7:	8b 10                	mov    (%eax),%edx
80101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfc:	8b 00                	mov    (%eax),%eax
80101cfe:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d02:	89 04 24             	mov    %eax,(%esp)
80101d05:	e8 e3 f7 ff ff       	call   801014ed <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d0a:	ff 45 f0             	incl   -0x10(%ebp)
80101d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d10:	83 f8 7f             	cmp    $0x7f,%eax
80101d13:	76 be                	jbe    80101cd3 <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d18:	89 04 24             	mov    %eax,(%esp)
80101d1b:	e8 0c e5 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	8b 00                	mov    (%eax),%eax
80101d2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d32:	89 04 24             	mov    %eax,(%esp)
80101d35:	e8 b3 f7 ff ff       	call   801014ed <bfree>
    ip->addrs[NDIRECT] = 0;
80101d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3d:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101d44:	00 00 00 
  }

  ip->size = 0;
80101d47:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4a:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101d51:	8b 45 08             	mov    0x8(%ebp),%eax
80101d54:	89 04 24             	mov    %eax,(%esp)
80101d57:	e8 ff f9 ff ff       	call   8010175b <iupdate>
}
80101d5c:	c9                   	leave  
80101d5d:	c3                   	ret    

80101d5e <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d5e:	55                   	push   %ebp
80101d5f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d61:	8b 45 08             	mov    0x8(%ebp),%eax
80101d64:	8b 00                	mov    (%eax),%eax
80101d66:	89 c2                	mov    %eax,%edx
80101d68:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d6b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	8b 50 04             	mov    0x4(%eax),%edx
80101d74:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d77:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7d:	8b 40 50             	mov    0x50(%eax),%eax
80101d80:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d83:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101d86:	8b 45 08             	mov    0x8(%ebp),%eax
80101d89:	66 8b 40 56          	mov    0x56(%eax),%ax
80101d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d90:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	8b 50 58             	mov    0x58(%eax),%edx
80101d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d9d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101da0:	5d                   	pop    %ebp
80101da1:	c3                   	ret    

80101da2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101da2:	55                   	push   %ebp
80101da3:	89 e5                	mov    %esp,%ebp
80101da5:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 40 50             	mov    0x50(%eax),%eax
80101dae:	66 83 f8 03          	cmp    $0x3,%ax
80101db2:	75 60                	jne    80101e14 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	66 8b 40 52          	mov    0x52(%eax),%ax
80101dbb:	66 85 c0             	test   %ax,%ax
80101dbe:	78 20                	js     80101de0 <readi+0x3e>
80101dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc3:	66 8b 40 52          	mov    0x52(%eax),%ax
80101dc7:	66 83 f8 09          	cmp    $0x9,%ax
80101dcb:	7f 13                	jg     80101de0 <readi+0x3e>
80101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd0:	66 8b 40 52          	mov    0x52(%eax),%ax
80101dd4:	98                   	cwtl   
80101dd5:	8b 04 c5 00 1a 11 80 	mov    -0x7feee600(,%eax,8),%eax
80101ddc:	85 c0                	test   %eax,%eax
80101dde:	75 0a                	jne    80101dea <readi+0x48>
      return -1;
80101de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101de5:	e9 1a 01 00 00       	jmp    80101f04 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ded:	66 8b 40 52          	mov    0x52(%eax),%ax
80101df1:	98                   	cwtl   
80101df2:	8b 04 c5 00 1a 11 80 	mov    -0x7feee600(,%eax,8),%eax
80101df9:	8b 55 14             	mov    0x14(%ebp),%edx
80101dfc:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e00:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e03:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e07:	8b 55 08             	mov    0x8(%ebp),%edx
80101e0a:	89 14 24             	mov    %edx,(%esp)
80101e0d:	ff d0                	call   *%eax
80101e0f:	e9 f0 00 00 00       	jmp    80101f04 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 40 58             	mov    0x58(%eax),%eax
80101e1a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e1d:	72 0d                	jb     80101e2c <readi+0x8a>
80101e1f:	8b 45 14             	mov    0x14(%ebp),%eax
80101e22:	8b 55 10             	mov    0x10(%ebp),%edx
80101e25:	01 d0                	add    %edx,%eax
80101e27:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e2a:	73 0a                	jae    80101e36 <readi+0x94>
    return -1;
80101e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e31:	e9 ce 00 00 00       	jmp    80101f04 <readi+0x162>
  if(off + n > ip->size)
80101e36:	8b 45 14             	mov    0x14(%ebp),%eax
80101e39:	8b 55 10             	mov    0x10(%ebp),%edx
80101e3c:	01 c2                	add    %eax,%edx
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	8b 40 58             	mov    0x58(%eax),%eax
80101e44:	39 c2                	cmp    %eax,%edx
80101e46:	76 0c                	jbe    80101e54 <readi+0xb2>
    n = ip->size - off;
80101e48:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4b:	8b 40 58             	mov    0x58(%eax),%eax
80101e4e:	2b 45 10             	sub    0x10(%ebp),%eax
80101e51:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e5b:	e9 95 00 00 00       	jmp    80101ef5 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e60:	8b 45 10             	mov    0x10(%ebp),%eax
80101e63:	c1 e8 09             	shr    $0x9,%eax
80101e66:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	89 04 24             	mov    %eax,(%esp)
80101e70:	e8 b3 fc ff ff       	call   80101b28 <bmap>
80101e75:	8b 55 08             	mov    0x8(%ebp),%edx
80101e78:	8b 12                	mov    (%edx),%edx
80101e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e7e:	89 14 24             	mov    %edx,(%esp)
80101e81:	e8 2f e3 ff ff       	call   801001b5 <bread>
80101e86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e89:	8b 45 10             	mov    0x10(%ebp),%eax
80101e8c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e91:	89 c2                	mov    %eax,%edx
80101e93:	b8 00 02 00 00       	mov    $0x200,%eax
80101e98:	29 d0                	sub    %edx,%eax
80101e9a:	89 c1                	mov    %eax,%ecx
80101e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9f:	8b 55 14             	mov    0x14(%ebp),%edx
80101ea2:	29 c2                	sub    %eax,%edx
80101ea4:	89 c8                	mov    %ecx,%eax
80101ea6:	39 d0                	cmp    %edx,%eax
80101ea8:	76 02                	jbe    80101eac <readi+0x10a>
80101eaa:	89 d0                	mov    %edx,%eax
80101eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for (int j = 0; j < min(m, 10); j++) {
      cprintf("%x ", bp->data[off%BSIZE+j]);
    }
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
80101eaf:	8b 45 10             	mov    0x10(%ebp),%eax
80101eb2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101eb7:	8d 50 50             	lea    0x50(%eax),%edx
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	01 d0                	add    %edx,%eax
80101ebf:	8d 50 0c             	lea    0xc(%eax),%edx
80101ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec5:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ec9:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 04 24             	mov    %eax,(%esp)
80101ed3:	e8 37 33 00 00       	call   8010520f <memmove>
    brelse(bp);
80101ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101edb:	89 04 24             	mov    %eax,(%esp)
80101ede:	e8 49 e3 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ee3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee6:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eec:	01 45 10             	add    %eax,0x10(%ebp)
80101eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ef2:	01 45 0c             	add    %eax,0xc(%ebp)
80101ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef8:	3b 45 14             	cmp    0x14(%ebp),%eax
80101efb:	0f 82 5f ff ff ff    	jb     80101e60 <readi+0xbe>
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f01:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f04:	c9                   	leave  
80101f05:	c3                   	ret    

80101f06 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0f:	8b 40 50             	mov    0x50(%eax),%eax
80101f12:	66 83 f8 03          	cmp    $0x3,%ax
80101f16:	75 60                	jne    80101f78 <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f18:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1b:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f1f:	66 85 c0             	test   %ax,%ax
80101f22:	78 20                	js     80101f44 <writei+0x3e>
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f2b:	66 83 f8 09          	cmp    $0x9,%ax
80101f2f:	7f 13                	jg     80101f44 <writei+0x3e>
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f38:	98                   	cwtl   
80101f39:	8b 04 c5 04 1a 11 80 	mov    -0x7feee5fc(,%eax,8),%eax
80101f40:	85 c0                	test   %eax,%eax
80101f42:	75 0a                	jne    80101f4e <writei+0x48>
      return -1;
80101f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f49:	e9 45 01 00 00       	jmp    80102093 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f55:	98                   	cwtl   
80101f56:	8b 04 c5 04 1a 11 80 	mov    -0x7feee5fc(,%eax,8),%eax
80101f5d:	8b 55 14             	mov    0x14(%ebp),%edx
80101f60:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f64:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f67:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f6e:	89 14 24             	mov    %edx,(%esp)
80101f71:	ff d0                	call   *%eax
80101f73:	e9 1b 01 00 00       	jmp    80102093 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f78:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7b:	8b 40 58             	mov    0x58(%eax),%eax
80101f7e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f81:	72 0d                	jb     80101f90 <writei+0x8a>
80101f83:	8b 45 14             	mov    0x14(%ebp),%eax
80101f86:	8b 55 10             	mov    0x10(%ebp),%edx
80101f89:	01 d0                	add    %edx,%eax
80101f8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f8e:	73 0a                	jae    80101f9a <writei+0x94>
    return -1;
80101f90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f95:	e9 f9 00 00 00       	jmp    80102093 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f9a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f9d:	8b 55 10             	mov    0x10(%ebp),%edx
80101fa0:	01 d0                	add    %edx,%eax
80101fa2:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fa7:	76 0a                	jbe    80101fb3 <writei+0xad>
    return -1;
80101fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fae:	e9 e0 00 00 00       	jmp    80102093 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fba:	e9 a0 00 00 00       	jmp    8010205f <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	c1 e8 09             	shr    $0x9,%eax
80101fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	89 04 24             	mov    %eax,(%esp)
80101fcf:	e8 54 fb ff ff       	call   80101b28 <bmap>
80101fd4:	8b 55 08             	mov    0x8(%ebp),%edx
80101fd7:	8b 12                	mov    (%edx),%edx
80101fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fdd:	89 14 24             	mov    %edx,(%esp)
80101fe0:	e8 d0 e1 ff ff       	call   801001b5 <bread>
80101fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fe8:	8b 45 10             	mov    0x10(%ebp),%eax
80101feb:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff0:	89 c2                	mov    %eax,%edx
80101ff2:	b8 00 02 00 00       	mov    $0x200,%eax
80101ff7:	29 d0                	sub    %edx,%eax
80101ff9:	89 c1                	mov    %eax,%ecx
80101ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ffe:	8b 55 14             	mov    0x14(%ebp),%edx
80102001:	29 c2                	sub    %eax,%edx
80102003:	89 c8                	mov    %ecx,%eax
80102005:	39 d0                	cmp    %edx,%eax
80102007:	76 02                	jbe    8010200b <writei+0x105>
80102009:	89 d0                	mov    %edx,%eax
8010200b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010200e:	8b 45 10             	mov    0x10(%ebp),%eax
80102011:	25 ff 01 00 00       	and    $0x1ff,%eax
80102016:	8d 50 50             	lea    0x50(%eax),%edx
80102019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201c:	01 d0                	add    %edx,%eax
8010201e:	8d 50 0c             	lea    0xc(%eax),%edx
80102021:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102024:	89 44 24 08          	mov    %eax,0x8(%esp)
80102028:	8b 45 0c             	mov    0xc(%ebp),%eax
8010202b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010202f:	89 14 24             	mov    %edx,(%esp)
80102032:	e8 d8 31 00 00       	call   8010520f <memmove>
    log_write(bp);
80102037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010203a:	89 04 24             	mov    %eax,(%esp)
8010203d:	e8 85 16 00 00       	call   801036c7 <log_write>
    brelse(bp);
80102042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102045:	89 04 24             	mov    %eax,(%esp)
80102048:	e8 df e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010204d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102050:	01 45 f4             	add    %eax,-0xc(%ebp)
80102053:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102056:	01 45 10             	add    %eax,0x10(%ebp)
80102059:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010205c:	01 45 0c             	add    %eax,0xc(%ebp)
8010205f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102062:	3b 45 14             	cmp    0x14(%ebp),%eax
80102065:	0f 82 54 ff ff ff    	jb     80101fbf <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010206b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010206f:	74 1f                	je     80102090 <writei+0x18a>
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	8b 40 58             	mov    0x58(%eax),%eax
80102077:	3b 45 10             	cmp    0x10(%ebp),%eax
8010207a:	73 14                	jae    80102090 <writei+0x18a>
    ip->size = off;
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	8b 55 10             	mov    0x10(%ebp),%edx
80102082:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102085:	8b 45 08             	mov    0x8(%ebp),%eax
80102088:	89 04 24             	mov    %eax,(%esp)
8010208b:	e8 cb f6 ff ff       	call   8010175b <iupdate>
  }
  return n;
80102090:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102093:	c9                   	leave  
80102094:	c3                   	ret    

80102095 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102095:	55                   	push   %ebp
80102096:	89 e5                	mov    %esp,%ebp
80102098:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010209b:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020a2:	00 
801020a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	89 04 24             	mov    %eax,(%esp)
801020b0:	e8 f9 31 00 00       	call   801052ae <strncmp>
}
801020b5:	c9                   	leave  
801020b6:	c3                   	ret    

801020b7 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020b7:	55                   	push   %ebp
801020b8:	89 e5                	mov    %esp,%ebp
801020ba:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020bd:	8b 45 08             	mov    0x8(%ebp),%eax
801020c0:	8b 40 50             	mov    0x50(%eax),%eax
801020c3:	66 83 f8 01          	cmp    $0x1,%ax
801020c7:	74 0c                	je     801020d5 <dirlookup+0x1e>
    panic("dirlookup not DIR");
801020c9:	c7 04 24 a1 85 10 80 	movl   $0x801085a1,(%esp)
801020d0:	e8 7f e4 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 86 00 00 00       	jmp    80102167 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020e1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020e8:	00 
801020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801020f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f7:	8b 45 08             	mov    0x8(%ebp),%eax
801020fa:	89 04 24             	mov    %eax,(%esp)
801020fd:	e8 a0 fc ff ff       	call   80101da2 <readi>
80102102:	83 f8 10             	cmp    $0x10,%eax
80102105:	74 0c                	je     80102113 <dirlookup+0x5c>
      panic("dirlink read");
80102107:	c7 04 24 b3 85 10 80 	movl   $0x801085b3,(%esp)
8010210e:	e8 41 e4 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102113:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102116:	66 85 c0             	test   %ax,%ax
80102119:	75 02                	jne    8010211d <dirlookup+0x66>
      continue;
8010211b:	eb 46                	jmp    80102163 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
8010211d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102120:	83 c0 02             	add    $0x2,%eax
80102123:	89 44 24 04          	mov    %eax,0x4(%esp)
80102127:	8b 45 0c             	mov    0xc(%ebp),%eax
8010212a:	89 04 24             	mov    %eax,(%esp)
8010212d:	e8 63 ff ff ff       	call   80102095 <namecmp>
80102132:	85 c0                	test   %eax,%eax
80102134:	75 2d                	jne    80102163 <dirlookup+0xac>
      // entry matches path element
      if(poff)
80102136:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010213a:	74 08                	je     80102144 <dirlookup+0x8d>
        *poff = off;
8010213c:	8b 45 10             	mov    0x10(%ebp),%eax
8010213f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102142:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102144:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102147:	0f b7 c0             	movzwl %ax,%eax
8010214a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010214d:	8b 45 08             	mov    0x8(%ebp),%eax
80102150:	8b 00                	mov    (%eax),%eax
80102152:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102155:	89 54 24 04          	mov    %edx,0x4(%esp)
80102159:	89 04 24             	mov    %eax,(%esp)
8010215c:	e8 b6 f6 ff ff       	call   80101817 <iget>
80102161:	eb 18                	jmp    8010217b <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102163:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	8b 40 58             	mov    0x58(%eax),%eax
8010216d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102170:	0f 87 6b ff ff ff    	ja     801020e1 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102176:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010217b:	c9                   	leave  
8010217c:	c3                   	ret    

8010217d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010217d:	55                   	push   %ebp
8010217e:	89 e5                	mov    %esp,%ebp
80102180:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102183:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010218a:	00 
8010218b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010218e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	89 04 24             	mov    %eax,(%esp)
80102198:	e8 1a ff ff ff       	call   801020b7 <dirlookup>
8010219d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021a4:	74 15                	je     801021bb <dirlink+0x3e>
    iput(ip);
801021a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021a9:	89 04 24             	mov    %eax,(%esp)
801021ac:	e8 c5 f8 ff ff       	call   80101a76 <iput>
    return -1;
801021b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021b6:	e9 b6 00 00 00       	jmp    80102271 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021c2:	eb 45                	jmp    80102209 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021ce:	00 
801021cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801021d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 bd fb ff ff       	call   80101da2 <readi>
801021e5:	83 f8 10             	cmp    $0x10,%eax
801021e8:	74 0c                	je     801021f6 <dirlink+0x79>
      panic("dirlink read");
801021ea:	c7 04 24 b3 85 10 80 	movl   $0x801085b3,(%esp)
801021f1:	e8 5e e3 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801021f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801021f9:	66 85 c0             	test   %ax,%ax
801021fc:	75 02                	jne    80102200 <dirlink+0x83>
      break;
801021fe:	eb 16                	jmp    80102216 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102203:	83 c0 10             	add    $0x10,%eax
80102206:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010220c:	8b 45 08             	mov    0x8(%ebp),%eax
8010220f:	8b 40 58             	mov    0x58(%eax),%eax
80102212:	39 c2                	cmp    %eax,%edx
80102214:	72 ae                	jb     801021c4 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102216:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010221d:	00 
8010221e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102221:	89 44 24 04          	mov    %eax,0x4(%esp)
80102225:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102228:	83 c0 02             	add    $0x2,%eax
8010222b:	89 04 24             	mov    %eax,(%esp)
8010222e:	e8 c9 30 00 00       	call   801052fc <strncpy>
  de.inum = inum;
80102233:	8b 45 10             	mov    0x10(%ebp),%eax
80102236:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010223d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102244:	00 
80102245:	89 44 24 08          	mov    %eax,0x8(%esp)
80102249:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010224c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	89 04 24             	mov    %eax,(%esp)
80102256:	e8 ab fc ff ff       	call   80101f06 <writei>
8010225b:	83 f8 10             	cmp    $0x10,%eax
8010225e:	74 0c                	je     8010226c <dirlink+0xef>
    panic("dirlink");
80102260:	c7 04 24 c0 85 10 80 	movl   $0x801085c0,(%esp)
80102267:	e8 e8 e2 ff ff       	call   80100554 <panic>

  return 0;
8010226c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102271:	c9                   	leave  
80102272:	c3                   	ret    

80102273 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102273:	55                   	push   %ebp
80102274:	89 e5                	mov    %esp,%ebp
80102276:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102279:	eb 03                	jmp    8010227e <skipelem+0xb>
    path++;
8010227b:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010227e:	8b 45 08             	mov    0x8(%ebp),%eax
80102281:	8a 00                	mov    (%eax),%al
80102283:	3c 2f                	cmp    $0x2f,%al
80102285:	74 f4                	je     8010227b <skipelem+0x8>
    path++;
  if(*path == 0)
80102287:	8b 45 08             	mov    0x8(%ebp),%eax
8010228a:	8a 00                	mov    (%eax),%al
8010228c:	84 c0                	test   %al,%al
8010228e:	75 0a                	jne    8010229a <skipelem+0x27>
    return 0;
80102290:	b8 00 00 00 00       	mov    $0x0,%eax
80102295:	e9 81 00 00 00       	jmp    8010231b <skipelem+0xa8>
  s = path;
8010229a:	8b 45 08             	mov    0x8(%ebp),%eax
8010229d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022a0:	eb 03                	jmp    801022a5 <skipelem+0x32>
    path++;
801022a2:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	8a 00                	mov    (%eax),%al
801022aa:	3c 2f                	cmp    $0x2f,%al
801022ac:	74 09                	je     801022b7 <skipelem+0x44>
801022ae:	8b 45 08             	mov    0x8(%ebp),%eax
801022b1:	8a 00                	mov    (%eax),%al
801022b3:	84 c0                	test   %al,%al
801022b5:	75 eb                	jne    801022a2 <skipelem+0x2f>
    path++;
  len = path - s;
801022b7:	8b 55 08             	mov    0x8(%ebp),%edx
801022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bd:	29 c2                	sub    %eax,%edx
801022bf:	89 d0                	mov    %edx,%eax
801022c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022c4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022c8:	7e 1c                	jle    801022e6 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801022ca:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022d1:	00 
801022d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022dc:	89 04 24             	mov    %eax,(%esp)
801022df:	e8 2b 2f 00 00       	call   8010520f <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e4:	eb 29                	jmp    8010230f <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022f7:	89 04 24             	mov    %eax,(%esp)
801022fa:	e8 10 2f 00 00       	call   8010520f <memmove>
    name[len] = 0;
801022ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102302:	8b 45 0c             	mov    0xc(%ebp),%eax
80102305:	01 d0                	add    %edx,%eax
80102307:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010230a:	eb 03                	jmp    8010230f <skipelem+0x9c>
    path++;
8010230c:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010230f:	8b 45 08             	mov    0x8(%ebp),%eax
80102312:	8a 00                	mov    (%eax),%al
80102314:	3c 2f                	cmp    $0x2f,%al
80102316:	74 f4                	je     8010230c <skipelem+0x99>
    path++;
  return path;
80102318:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010231b:	c9                   	leave  
8010231c:	c3                   	ret    

8010231d <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010231d:	55                   	push   %ebp
8010231e:	89 e5                	mov    %esp,%ebp
80102320:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102323:	8b 45 08             	mov    0x8(%ebp),%eax
80102326:	8a 00                	mov    (%eax),%al
80102328:	3c 2f                	cmp    $0x2f,%al
8010232a:	75 1c                	jne    80102348 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010232c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102333:	00 
80102334:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010233b:	e8 d7 f4 ff ff       	call   80101817 <iget>
80102340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102343:	e9 ad 00 00 00       	jmp    801023f5 <namex+0xd8>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102348:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010234e:	8b 40 68             	mov    0x68(%eax),%eax
80102351:	89 04 24             	mov    %eax,(%esp)
80102354:	e8 93 f5 ff ff       	call   801018ec <idup>
80102359:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010235c:	e9 94 00 00 00       	jmp    801023f5 <namex+0xd8>
    ilock(ip);
80102361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102364:	89 04 24             	mov    %eax,(%esp)
80102367:	e8 b2 f5 ff ff       	call   8010191e <ilock>
    if(ip->type != T_DIR){
8010236c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236f:	8b 40 50             	mov    0x50(%eax),%eax
80102372:	66 83 f8 01          	cmp    $0x1,%ax
80102376:	74 15                	je     8010238d <namex+0x70>
      iunlockput(ip);
80102378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237b:	89 04 24             	mov    %eax,(%esp)
8010237e:	e8 87 f7 ff ff       	call   80101b0a <iunlockput>
      return 0;
80102383:	b8 00 00 00 00       	mov    $0x0,%eax
80102388:	e9 a2 00 00 00       	jmp    8010242f <namex+0x112>
    }
    if(nameiparent && *path == '\0'){
8010238d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102391:	74 1c                	je     801023af <namex+0x92>
80102393:	8b 45 08             	mov    0x8(%ebp),%eax
80102396:	8a 00                	mov    (%eax),%al
80102398:	84 c0                	test   %al,%al
8010239a:	75 13                	jne    801023af <namex+0x92>
      // Stop one level early.
      iunlock(ip);
8010239c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239f:	89 04 24             	mov    %eax,(%esp)
801023a2:	e8 8b f6 ff ff       	call   80101a32 <iunlock>
      return ip;
801023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023aa:	e9 80 00 00 00       	jmp    8010242f <namex+0x112>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023b6:	00 
801023b7:	8b 45 10             	mov    0x10(%ebp),%eax
801023ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	89 04 24             	mov    %eax,(%esp)
801023c4:	e8 ee fc ff ff       	call   801020b7 <dirlookup>
801023c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023d0:	75 12                	jne    801023e4 <namex+0xc7>
      iunlockput(ip);
801023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d5:	89 04 24             	mov    %eax,(%esp)
801023d8:	e8 2d f7 ff ff       	call   80101b0a <iunlockput>
      return 0;
801023dd:	b8 00 00 00 00       	mov    $0x0,%eax
801023e2:	eb 4b                	jmp    8010242f <namex+0x112>
    }
    iunlockput(ip);
801023e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e7:	89 04 24             	mov    %eax,(%esp)
801023ea:	e8 1b f7 ff ff       	call   80101b0a <iunlockput>
    ip = next;
801023ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023f5:	8b 45 10             	mov    0x10(%ebp),%eax
801023f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	89 04 24             	mov    %eax,(%esp)
80102402:	e8 6c fe ff ff       	call   80102273 <skipelem>
80102407:	89 45 08             	mov    %eax,0x8(%ebp)
8010240a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010240e:	0f 85 4d ff ff ff    	jne    80102361 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102414:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102418:	74 12                	je     8010242c <namex+0x10f>
    iput(ip);
8010241a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241d:	89 04 24             	mov    %eax,(%esp)
80102420:	e8 51 f6 ff ff       	call   80101a76 <iput>
    return 0;
80102425:	b8 00 00 00 00       	mov    $0x0,%eax
8010242a:	eb 03                	jmp    8010242f <namex+0x112>
  }
  return ip;
8010242c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010242f:	c9                   	leave  
80102430:	c3                   	ret    

80102431 <namei>:

struct inode*
namei(char *path)
{
80102431:	55                   	push   %ebp
80102432:	89 e5                	mov    %esp,%ebp
80102434:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102437:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010243a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010243e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102445:	00 
80102446:	8b 45 08             	mov    0x8(%ebp),%eax
80102449:	89 04 24             	mov    %eax,(%esp)
8010244c:	e8 cc fe ff ff       	call   8010231d <namex>
}
80102451:	c9                   	leave  
80102452:	c3                   	ret    

80102453 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102453:	55                   	push   %ebp
80102454:	89 e5                	mov    %esp,%ebp
80102456:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102459:	8b 45 0c             	mov    0xc(%ebp),%eax
8010245c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102460:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102467:	00 
80102468:	8b 45 08             	mov    0x8(%ebp),%eax
8010246b:	89 04 24             	mov    %eax,(%esp)
8010246e:	e8 aa fe ff ff       	call   8010231d <namex>
}
80102473:	c9                   	leave  
80102474:	c3                   	ret    
80102475:	00 00                	add    %al,(%eax)
	...

80102478 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102478:	55                   	push   %ebp
80102479:	89 e5                	mov    %esp,%ebp
8010247b:	83 ec 14             	sub    $0x14,%esp
8010247e:	8b 45 08             	mov    0x8(%ebp),%eax
80102481:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102488:	89 c2                	mov    %eax,%edx
8010248a:	ec                   	in     (%dx),%al
8010248b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010248e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102491:	c9                   	leave  
80102492:	c3                   	ret    

80102493 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102493:	55                   	push   %ebp
80102494:	89 e5                	mov    %esp,%ebp
80102496:	57                   	push   %edi
80102497:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102498:	8b 55 08             	mov    0x8(%ebp),%edx
8010249b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010249e:	8b 45 10             	mov    0x10(%ebp),%eax
801024a1:	89 cb                	mov    %ecx,%ebx
801024a3:	89 df                	mov    %ebx,%edi
801024a5:	89 c1                	mov    %eax,%ecx
801024a7:	fc                   	cld    
801024a8:	f3 6d                	rep insl (%dx),%es:(%edi)
801024aa:	89 c8                	mov    %ecx,%eax
801024ac:	89 fb                	mov    %edi,%ebx
801024ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024b1:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024b4:	5b                   	pop    %ebx
801024b5:	5f                   	pop    %edi
801024b6:	5d                   	pop    %ebp
801024b7:	c3                   	ret    

801024b8 <outb>:

static inline void
outb(ushort port, uchar data)
{
801024b8:	55                   	push   %ebp
801024b9:	89 e5                	mov    %esp,%ebp
801024bb:	83 ec 08             	sub    $0x8,%esp
801024be:	8b 45 08             	mov    0x8(%ebp),%eax
801024c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801024c4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801024c8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024cb:	8a 45 f8             	mov    -0x8(%ebp),%al
801024ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801024d1:	ee                   	out    %al,(%dx)
}
801024d2:	c9                   	leave  
801024d3:	c3                   	ret    

801024d4 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024d4:	55                   	push   %ebp
801024d5:	89 e5                	mov    %esp,%ebp
801024d7:	56                   	push   %esi
801024d8:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024d9:	8b 55 08             	mov    0x8(%ebp),%edx
801024dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024df:	8b 45 10             	mov    0x10(%ebp),%eax
801024e2:	89 cb                	mov    %ecx,%ebx
801024e4:	89 de                	mov    %ebx,%esi
801024e6:	89 c1                	mov    %eax,%ecx
801024e8:	fc                   	cld    
801024e9:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024eb:	89 c8                	mov    %ecx,%eax
801024ed:	89 f3                	mov    %esi,%ebx
801024ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024f2:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024f5:	5b                   	pop    %ebx
801024f6:	5e                   	pop    %esi
801024f7:	5d                   	pop    %ebp
801024f8:	c3                   	ret    

801024f9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024f9:	55                   	push   %ebp
801024fa:	89 e5                	mov    %esp,%ebp
801024fc:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801024ff:	90                   	nop
80102500:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102507:	e8 6c ff ff ff       	call   80102478 <inb>
8010250c:	0f b6 c0             	movzbl %al,%eax
8010250f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102512:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102515:	25 c0 00 00 00       	and    $0xc0,%eax
8010251a:	83 f8 40             	cmp    $0x40,%eax
8010251d:	75 e1                	jne    80102500 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010251f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102523:	74 11                	je     80102536 <idewait+0x3d>
80102525:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102528:	83 e0 21             	and    $0x21,%eax
8010252b:	85 c0                	test   %eax,%eax
8010252d:	74 07                	je     80102536 <idewait+0x3d>
    return -1;
8010252f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102534:	eb 05                	jmp    8010253b <idewait+0x42>
  return 0;
80102536:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010253b:	c9                   	leave  
8010253c:	c3                   	ret    

8010253d <ideinit>:

void
ideinit(void)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102543:	c7 44 24 04 c8 85 10 	movl   $0x801085c8,0x4(%esp)
8010254a:	80 
8010254b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102552:	e8 6b 29 00 00       	call   80104ec2 <initlock>
  picenable(IRQ_IDE);
80102557:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010255e:	e8 21 18 00 00       	call   80103d84 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102563:	a1 00 3e 11 80       	mov    0x80113e00,%eax
80102568:	48                   	dec    %eax
80102569:	89 44 24 04          	mov    %eax,0x4(%esp)
8010256d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102574:	e8 74 04 00 00       	call   801029ed <ioapicenable>
  idewait(0);
80102579:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102580:	e8 74 ff ff ff       	call   801024f9 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102585:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010258c:	00 
8010258d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102594:	e8 1f ff ff ff       	call   801024b8 <outb>
  for(i=0; i<1000; i++){
80102599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025a0:	eb 1f                	jmp    801025c1 <ideinit+0x84>
    if(inb(0x1f7) != 0){
801025a2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025a9:	e8 ca fe ff ff       	call   80102478 <inb>
801025ae:	84 c0                	test   %al,%al
801025b0:	74 0c                	je     801025be <ideinit+0x81>
      havedisk1 = 1;
801025b2:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025b9:	00 00 00 
      break;
801025bc:	eb 0c                	jmp    801025ca <ideinit+0x8d>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025be:	ff 45 f4             	incl   -0xc(%ebp)
801025c1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025c8:	7e d8                	jle    801025a2 <ideinit+0x65>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025ca:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025d1:	00 
801025d2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d9:	e8 da fe ff ff       	call   801024b8 <outb>
}
801025de:	c9                   	leave  
801025df:	c3                   	ret    

801025e0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025e0:	55                   	push   %ebp
801025e1:	89 e5                	mov    %esp,%ebp
801025e3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801025e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ea:	75 0c                	jne    801025f8 <idestart+0x18>
    panic("idestart");
801025ec:	c7 04 24 cc 85 10 80 	movl   $0x801085cc,(%esp)
801025f3:	e8 5c df ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801025f8:	8b 45 08             	mov    0x8(%ebp),%eax
801025fb:	8b 40 08             	mov    0x8(%eax),%eax
801025fe:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102603:	76 0c                	jbe    80102611 <idestart+0x31>
    panic("incorrect blockno");
80102605:	c7 04 24 d5 85 10 80 	movl   $0x801085d5,(%esp)
8010260c:	e8 43 df ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102611:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102618:	8b 45 08             	mov    0x8(%ebp),%eax
8010261b:	8b 50 08             	mov    0x8(%eax),%edx
8010261e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102621:	0f af c2             	imul   %edx,%eax
80102624:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102627:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010262b:	75 07                	jne    80102634 <idestart+0x54>
8010262d:	b8 20 00 00 00       	mov    $0x20,%eax
80102632:	eb 05                	jmp    80102639 <idestart+0x59>
80102634:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102639:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010263c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102640:	75 07                	jne    80102649 <idestart+0x69>
80102642:	b8 30 00 00 00       	mov    $0x30,%eax
80102647:	eb 05                	jmp    8010264e <idestart+0x6e>
80102649:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010264e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102651:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102655:	7e 0c                	jle    80102663 <idestart+0x83>
80102657:	c7 04 24 cc 85 10 80 	movl   $0x801085cc,(%esp)
8010265e:	e8 f1 de ff ff       	call   80100554 <panic>

  idewait(0);
80102663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010266a:	e8 8a fe ff ff       	call   801024f9 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010266f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102676:	00 
80102677:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010267e:	e8 35 fe ff ff       	call   801024b8 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102686:	0f b6 c0             	movzbl %al,%eax
80102689:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102694:	e8 1f fe ff ff       	call   801024b8 <outb>
  outb(0x1f3, sector & 0xff);
80102699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010269c:	0f b6 c0             	movzbl %al,%eax
8010269f:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a3:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026aa:	e8 09 fe ff ff       	call   801024b8 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026b2:	c1 f8 08             	sar    $0x8,%eax
801026b5:	0f b6 c0             	movzbl %al,%eax
801026b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bc:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026c3:	e8 f0 fd ff ff       	call   801024b8 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801026c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026cb:	c1 f8 10             	sar    $0x10,%eax
801026ce:	0f b6 c0             	movzbl %al,%eax
801026d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801026dc:	e8 d7 fd ff ff       	call   801024b8 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801026e1:	8b 45 08             	mov    0x8(%ebp),%eax
801026e4:	8b 40 04             	mov    0x4(%eax),%eax
801026e7:	83 e0 01             	and    $0x1,%eax
801026ea:	c1 e0 04             	shl    $0x4,%eax
801026ed:	88 c2                	mov    %al,%dl
801026ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f2:	c1 f8 18             	sar    $0x18,%eax
801026f5:	83 e0 0f             	and    $0xf,%eax
801026f8:	09 d0                	or     %edx,%eax
801026fa:	83 c8 e0             	or     $0xffffffe0,%eax
801026fd:	0f b6 c0             	movzbl %al,%eax
80102700:	89 44 24 04          	mov    %eax,0x4(%esp)
80102704:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010270b:	e8 a8 fd ff ff       	call   801024b8 <outb>
  if(b->flags & B_DIRTY){
80102710:	8b 45 08             	mov    0x8(%ebp),%eax
80102713:	8b 00                	mov    (%eax),%eax
80102715:	83 e0 04             	and    $0x4,%eax
80102718:	85 c0                	test   %eax,%eax
8010271a:	74 36                	je     80102752 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010271c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010271f:	0f b6 c0             	movzbl %al,%eax
80102722:	89 44 24 04          	mov    %eax,0x4(%esp)
80102726:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010272d:	e8 86 fd ff ff       	call   801024b8 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102732:	8b 45 08             	mov    0x8(%ebp),%eax
80102735:	83 c0 5c             	add    $0x5c,%eax
80102738:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010273f:	00 
80102740:	89 44 24 04          	mov    %eax,0x4(%esp)
80102744:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010274b:	e8 84 fd ff ff       	call   801024d4 <outsl>
80102750:	eb 16                	jmp    80102768 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102752:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102755:	0f b6 c0             	movzbl %al,%eax
80102758:	89 44 24 04          	mov    %eax,0x4(%esp)
8010275c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102763:	e8 50 fd ff ff       	call   801024b8 <outb>
  }
}
80102768:	c9                   	leave  
80102769:	c3                   	ret    

8010276a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010276a:	55                   	push   %ebp
8010276b:	89 e5                	mov    %esp,%ebp
8010276d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102770:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102777:	e8 67 27 00 00       	call   80104ee3 <acquire>
  if((b = idequeue) == 0){
8010277c:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102781:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102784:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102788:	75 11                	jne    8010279b <ideintr+0x31>
    release(&idelock);
8010278a:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102791:	e8 b4 27 00 00       	call   80104f4a <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102796:	e9 90 00 00 00       	jmp    8010282b <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010279b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279e:	8b 40 58             	mov    0x58(%eax),%eax
801027a1:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a9:	8b 00                	mov    (%eax),%eax
801027ab:	83 e0 04             	and    $0x4,%eax
801027ae:	85 c0                	test   %eax,%eax
801027b0:	75 2e                	jne    801027e0 <ideintr+0x76>
801027b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027b9:	e8 3b fd ff ff       	call   801024f9 <idewait>
801027be:	85 c0                	test   %eax,%eax
801027c0:	78 1e                	js     801027e0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801027c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c5:	83 c0 5c             	add    $0x5c,%eax
801027c8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027cf:	00 
801027d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801027d4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027db:	e8 b3 fc ff ff       	call   80102493 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801027e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e3:	8b 00                	mov    (%eax),%eax
801027e5:	83 c8 02             	or     $0x2,%eax
801027e8:	89 c2                	mov    %eax,%edx
801027ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ed:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801027ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f2:	8b 00                	mov    (%eax),%eax
801027f4:	83 e0 fb             	and    $0xfffffffb,%eax
801027f7:	89 c2                	mov    %eax,%edx
801027f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027fc:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102801:	89 04 24             	mov    %eax,(%esp)
80102804:	e8 e2 23 00 00       	call   80104beb <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102809:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010280e:	85 c0                	test   %eax,%eax
80102810:	74 0d                	je     8010281f <ideintr+0xb5>
    idestart(idequeue);
80102812:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102817:	89 04 24             	mov    %eax,(%esp)
8010281a:	e8 c1 fd ff ff       	call   801025e0 <idestart>

  release(&idelock);
8010281f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102826:	e8 1f 27 00 00       	call   80104f4a <release>
}
8010282b:	c9                   	leave  
8010282c:	c3                   	ret    

8010282d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010282d:	55                   	push   %ebp
8010282e:	89 e5                	mov    %esp,%ebp
80102830:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102833:	8b 45 08             	mov    0x8(%ebp),%eax
80102836:	83 c0 0c             	add    $0xc,%eax
80102839:	89 04 24             	mov    %eax,(%esp)
8010283c:	e8 1b 26 00 00       	call   80104e5c <holdingsleep>
80102841:	85 c0                	test   %eax,%eax
80102843:	75 0c                	jne    80102851 <iderw+0x24>
    panic("iderw: buf not locked");
80102845:	c7 04 24 e7 85 10 80 	movl   $0x801085e7,(%esp)
8010284c:	e8 03 dd ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102851:	8b 45 08             	mov    0x8(%ebp),%eax
80102854:	8b 00                	mov    (%eax),%eax
80102856:	83 e0 06             	and    $0x6,%eax
80102859:	83 f8 02             	cmp    $0x2,%eax
8010285c:	75 0c                	jne    8010286a <iderw+0x3d>
    panic("iderw: nothing to do");
8010285e:	c7 04 24 fd 85 10 80 	movl   $0x801085fd,(%esp)
80102865:	e8 ea dc ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
8010286a:	8b 45 08             	mov    0x8(%ebp),%eax
8010286d:	8b 40 04             	mov    0x4(%eax),%eax
80102870:	85 c0                	test   %eax,%eax
80102872:	74 15                	je     80102889 <iderw+0x5c>
80102874:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102879:	85 c0                	test   %eax,%eax
8010287b:	75 0c                	jne    80102889 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
8010287d:	c7 04 24 12 86 10 80 	movl   $0x80108612,(%esp)
80102884:	e8 cb dc ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102889:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102890:	e8 4e 26 00 00       	call   80104ee3 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102895:	8b 45 08             	mov    0x8(%ebp),%eax
80102898:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010289f:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
801028a6:	eb 0b                	jmp    801028b3 <iderw+0x86>
801028a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ab:	8b 00                	mov    (%eax),%eax
801028ad:	83 c0 58             	add    $0x58,%eax
801028b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b6:	8b 00                	mov    (%eax),%eax
801028b8:	85 c0                	test   %eax,%eax
801028ba:	75 ec                	jne    801028a8 <iderw+0x7b>
    ;
  *pp = b;
801028bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bf:	8b 55 08             	mov    0x8(%ebp),%edx
801028c2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801028c4:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028c9:	3b 45 08             	cmp    0x8(%ebp),%eax
801028cc:	75 0d                	jne    801028db <iderw+0xae>
    idestart(b);
801028ce:	8b 45 08             	mov    0x8(%ebp),%eax
801028d1:	89 04 24             	mov    %eax,(%esp)
801028d4:	e8 07 fd ff ff       	call   801025e0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028d9:	eb 15                	jmp    801028f0 <iderw+0xc3>
801028db:	eb 13                	jmp    801028f0 <iderw+0xc3>
    sleep(b, &idelock);
801028dd:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
801028e4:	80 
801028e5:	8b 45 08             	mov    0x8(%ebp),%eax
801028e8:	89 04 24             	mov    %eax,(%esp)
801028eb:	e8 22 22 00 00       	call   80104b12 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028f0:	8b 45 08             	mov    0x8(%ebp),%eax
801028f3:	8b 00                	mov    (%eax),%eax
801028f5:	83 e0 06             	and    $0x6,%eax
801028f8:	83 f8 02             	cmp    $0x2,%eax
801028fb:	75 e0                	jne    801028dd <iderw+0xb0>
    sleep(b, &idelock);
  }

  release(&idelock);
801028fd:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102904:	e8 41 26 00 00       	call   80104f4a <release>
}
80102909:	c9                   	leave  
8010290a:	c3                   	ret    
	...

8010290c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010290f:	a1 d4 36 11 80       	mov    0x801136d4,%eax
80102914:	8b 55 08             	mov    0x8(%ebp),%edx
80102917:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102919:	a1 d4 36 11 80       	mov    0x801136d4,%eax
8010291e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102921:	5d                   	pop    %ebp
80102922:	c3                   	ret    

80102923 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102923:	55                   	push   %ebp
80102924:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102926:	a1 d4 36 11 80       	mov    0x801136d4,%eax
8010292b:	8b 55 08             	mov    0x8(%ebp),%edx
8010292e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102930:	a1 d4 36 11 80       	mov    0x801136d4,%eax
80102935:	8b 55 0c             	mov    0xc(%ebp),%edx
80102938:	89 50 10             	mov    %edx,0x10(%eax)
}
8010293b:	5d                   	pop    %ebp
8010293c:	c3                   	ret    

8010293d <ioapicinit>:

void
ioapicinit(void)
{
8010293d:	55                   	push   %ebp
8010293e:	89 e5                	mov    %esp,%ebp
80102940:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102943:	a1 04 38 11 80       	mov    0x80113804,%eax
80102948:	85 c0                	test   %eax,%eax
8010294a:	75 05                	jne    80102951 <ioapicinit+0x14>
    return;
8010294c:	e9 9a 00 00 00       	jmp    801029eb <ioapicinit+0xae>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102951:	c7 05 d4 36 11 80 00 	movl   $0xfec00000,0x801136d4
80102958:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010295b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102962:	e8 a5 ff ff ff       	call   8010290c <ioapicread>
80102967:	c1 e8 10             	shr    $0x10,%eax
8010296a:	25 ff 00 00 00       	and    $0xff,%eax
8010296f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102972:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102979:	e8 8e ff ff ff       	call   8010290c <ioapicread>
8010297e:	c1 e8 18             	shr    $0x18,%eax
80102981:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102984:	a0 00 38 11 80       	mov    0x80113800,%al
80102989:	0f b6 c0             	movzbl %al,%eax
8010298c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010298f:	74 0c                	je     8010299d <ioapicinit+0x60>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102991:	c7 04 24 30 86 10 80 	movl   $0x80108630,(%esp)
80102998:	e8 24 da ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010299d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029a4:	eb 3d                	jmp    801029e3 <ioapicinit+0xa6>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	83 c0 20             	add    $0x20,%eax
801029ac:	0d 00 00 01 00       	or     $0x10000,%eax
801029b1:	89 c2                	mov    %eax,%edx
801029b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b6:	83 c0 08             	add    $0x8,%eax
801029b9:	01 c0                	add    %eax,%eax
801029bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801029bf:	89 04 24             	mov    %eax,(%esp)
801029c2:	e8 5c ff ff ff       	call   80102923 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ca:	83 c0 08             	add    $0x8,%eax
801029cd:	01 c0                	add    %eax,%eax
801029cf:	40                   	inc    %eax
801029d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029d7:	00 
801029d8:	89 04 24             	mov    %eax,(%esp)
801029db:	e8 43 ff ff ff       	call   80102923 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029e0:	ff 45 f4             	incl   -0xc(%ebp)
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801029e9:	7e bb                	jle    801029a6 <ioapicinit+0x69>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801029eb:	c9                   	leave  
801029ec:	c3                   	ret    

801029ed <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801029ed:	55                   	push   %ebp
801029ee:	89 e5                	mov    %esp,%ebp
801029f0:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801029f3:	a1 04 38 11 80       	mov    0x80113804,%eax
801029f8:	85 c0                	test   %eax,%eax
801029fa:	75 02                	jne    801029fe <ioapicenable+0x11>
    return;
801029fc:	eb 37                	jmp    80102a35 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102a01:	83 c0 20             	add    $0x20,%eax
80102a04:	89 c2                	mov    %eax,%edx
80102a06:	8b 45 08             	mov    0x8(%ebp),%eax
80102a09:	83 c0 08             	add    $0x8,%eax
80102a0c:	01 c0                	add    %eax,%eax
80102a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102a12:	89 04 24             	mov    %eax,(%esp)
80102a15:	e8 09 ff ff ff       	call   80102923 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a1d:	c1 e0 18             	shl    $0x18,%eax
80102a20:	8b 55 08             	mov    0x8(%ebp),%edx
80102a23:	83 c2 08             	add    $0x8,%edx
80102a26:	01 d2                	add    %edx,%edx
80102a28:	42                   	inc    %edx
80102a29:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a2d:	89 14 24             	mov    %edx,(%esp)
80102a30:	e8 ee fe ff ff       	call   80102923 <ioapicwrite>
}
80102a35:	c9                   	leave  
80102a36:	c3                   	ret    
	...

80102a38 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
80102a3b:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a3e:	c7 44 24 04 62 86 10 	movl   $0x80108662,0x4(%esp)
80102a45:	80 
80102a46:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
80102a4d:	e8 70 24 00 00       	call   80104ec2 <initlock>
  kmem.use_lock = 0;
80102a52:	c7 05 14 37 11 80 00 	movl   $0x0,0x80113714
80102a59:	00 00 00 
  freerange(vstart, vend);
80102a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a63:	8b 45 08             	mov    0x8(%ebp),%eax
80102a66:	89 04 24             	mov    %eax,(%esp)
80102a69:	e8 26 00 00 00       	call   80102a94 <freerange>
}
80102a6e:	c9                   	leave  
80102a6f:	c3                   	ret    

80102a70 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a70:	55                   	push   %ebp
80102a71:	89 e5                	mov    %esp,%ebp
80102a73:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a76:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a79:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a80:	89 04 24             	mov    %eax,(%esp)
80102a83:	e8 0c 00 00 00       	call   80102a94 <freerange>
  kmem.use_lock = 1;
80102a88:	c7 05 14 37 11 80 01 	movl   $0x1,0x80113714
80102a8f:	00 00 00 
}
80102a92:	c9                   	leave  
80102a93:	c3                   	ret    

80102a94 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a94:	55                   	push   %ebp
80102a95:	89 e5                	mov    %esp,%ebp
80102a97:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102aa2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102aaa:	eb 12                	jmp    80102abe <freerange+0x2a>
    kfree(p);
80102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aaf:	89 04 24             	mov    %eax,(%esp)
80102ab2:	e8 16 00 00 00       	call   80102acd <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ab7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	05 00 10 00 00       	add    $0x1000,%eax
80102ac6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ac9:	76 e1                	jbe    80102aac <freerange+0x18>
    kfree(p);
}
80102acb:	c9                   	leave  
80102acc:	c3                   	ret    

80102acd <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102acd:	55                   	push   %ebp
80102ace:	89 e5                	mov    %esp,%ebp
80102ad0:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad6:	25 ff 0f 00 00       	and    $0xfff,%eax
80102adb:	85 c0                	test   %eax,%eax
80102add:	75 18                	jne    80102af7 <kfree+0x2a>
80102adf:	81 7d 08 a8 65 11 80 	cmpl   $0x801165a8,0x8(%ebp)
80102ae6:	72 0f                	jb     80102af7 <kfree+0x2a>
80102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80102aeb:	05 00 00 00 80       	add    $0x80000000,%eax
80102af0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102af5:	76 0c                	jbe    80102b03 <kfree+0x36>
    panic("kfree");
80102af7:	c7 04 24 67 86 10 80 	movl   $0x80108667,(%esp)
80102afe:	e8 51 da ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b03:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b0a:	00 
80102b0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b12:	00 
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	89 04 24             	mov    %eax,(%esp)
80102b19:	e8 28 26 00 00       	call   80105146 <memset>

  if(kmem.use_lock)
80102b1e:	a1 14 37 11 80       	mov    0x80113714,%eax
80102b23:	85 c0                	test   %eax,%eax
80102b25:	74 0c                	je     80102b33 <kfree+0x66>
    acquire(&kmem.lock);
80102b27:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
80102b2e:	e8 b0 23 00 00       	call   80104ee3 <acquire>
  r = (struct run*)v;
80102b33:	8b 45 08             	mov    0x8(%ebp),%eax
80102b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b39:	8b 15 18 37 11 80    	mov    0x80113718,%edx
80102b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b42:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b47:	a3 18 37 11 80       	mov    %eax,0x80113718
  if(kmem.use_lock)
80102b4c:	a1 14 37 11 80       	mov    0x80113714,%eax
80102b51:	85 c0                	test   %eax,%eax
80102b53:	74 0c                	je     80102b61 <kfree+0x94>
    release(&kmem.lock);
80102b55:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
80102b5c:	e8 e9 23 00 00       	call   80104f4a <release>
}
80102b61:	c9                   	leave  
80102b62:	c3                   	ret    

80102b63 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b63:	55                   	push   %ebp
80102b64:	89 e5                	mov    %esp,%ebp
80102b66:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b69:	a1 14 37 11 80       	mov    0x80113714,%eax
80102b6e:	85 c0                	test   %eax,%eax
80102b70:	74 0c                	je     80102b7e <kalloc+0x1b>
    acquire(&kmem.lock);
80102b72:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
80102b79:	e8 65 23 00 00       	call   80104ee3 <acquire>
  r = kmem.freelist;
80102b7e:	a1 18 37 11 80       	mov    0x80113718,%eax
80102b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b8a:	74 0a                	je     80102b96 <kalloc+0x33>
    kmem.freelist = r->next;
80102b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8f:	8b 00                	mov    (%eax),%eax
80102b91:	a3 18 37 11 80       	mov    %eax,0x80113718
  if(kmem.use_lock)
80102b96:	a1 14 37 11 80       	mov    0x80113714,%eax
80102b9b:	85 c0                	test   %eax,%eax
80102b9d:	74 0c                	je     80102bab <kalloc+0x48>
    release(&kmem.lock);
80102b9f:	c7 04 24 e0 36 11 80 	movl   $0x801136e0,(%esp)
80102ba6:	e8 9f 23 00 00       	call   80104f4a <release>
  return (char*)r;
80102bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bae:	c9                   	leave  
80102baf:	c3                   	ret    

80102bb0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bb0:	55                   	push   %ebp
80102bb1:	89 e5                	mov    %esp,%ebp
80102bb3:	83 ec 14             	sub    $0x14,%esp
80102bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102bc0:	89 c2                	mov    %eax,%edx
80102bc2:	ec                   	in     (%dx),%al
80102bc3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bc6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102bc9:	c9                   	leave  
80102bca:	c3                   	ret    

80102bcb <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bcb:	55                   	push   %ebp
80102bcc:	89 e5                	mov    %esp,%ebp
80102bce:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102bd1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102bd8:	e8 d3 ff ff ff       	call   80102bb0 <inb>
80102bdd:	0f b6 c0             	movzbl %al,%eax
80102be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be6:	83 e0 01             	and    $0x1,%eax
80102be9:	85 c0                	test   %eax,%eax
80102beb:	75 0a                	jne    80102bf7 <kbdgetc+0x2c>
    return -1;
80102bed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102bf2:	e9 21 01 00 00       	jmp    80102d18 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102bf7:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bfe:	e8 ad ff ff ff       	call   80102bb0 <inb>
80102c03:	0f b6 c0             	movzbl %al,%eax
80102c06:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c09:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c10:	75 17                	jne    80102c29 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c12:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c17:	83 c8 40             	or     $0x40,%eax
80102c1a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c1f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c24:	e9 ef 00 00 00       	jmp    80102d18 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c2c:	25 80 00 00 00       	and    $0x80,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 44                	je     80102c79 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c35:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c3a:	83 e0 40             	and    $0x40,%eax
80102c3d:	85 c0                	test   %eax,%eax
80102c3f:	75 08                	jne    80102c49 <kbdgetc+0x7e>
80102c41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c44:	83 e0 7f             	and    $0x7f,%eax
80102c47:	eb 03                	jmp    80102c4c <kbdgetc+0x81>
80102c49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c52:	05 20 90 10 80       	add    $0x80109020,%eax
80102c57:	8a 00                	mov    (%eax),%al
80102c59:	83 c8 40             	or     $0x40,%eax
80102c5c:	0f b6 c0             	movzbl %al,%eax
80102c5f:	f7 d0                	not    %eax
80102c61:	89 c2                	mov    %eax,%edx
80102c63:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c68:	21 d0                	and    %edx,%eax
80102c6a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c6f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c74:	e9 9f 00 00 00       	jmp    80102d18 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102c79:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c7e:	83 e0 40             	and    $0x40,%eax
80102c81:	85 c0                	test   %eax,%eax
80102c83:	74 14                	je     80102c99 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c85:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c8c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c91:	83 e0 bf             	and    $0xffffffbf,%eax
80102c94:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c9c:	05 20 90 10 80       	add    $0x80109020,%eax
80102ca1:	8a 00                	mov    (%eax),%al
80102ca3:	0f b6 d0             	movzbl %al,%edx
80102ca6:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cab:	09 d0                	or     %edx,%eax
80102cad:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102cb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb5:	05 20 91 10 80       	add    $0x80109120,%eax
80102cba:	8a 00                	mov    (%eax),%al
80102cbc:	0f b6 d0             	movzbl %al,%edx
80102cbf:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cc4:	31 d0                	xor    %edx,%eax
80102cc6:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ccb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cd0:	83 e0 03             	and    $0x3,%eax
80102cd3:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102cda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cdd:	01 d0                	add    %edx,%eax
80102cdf:	8a 00                	mov    (%eax),%al
80102ce1:	0f b6 c0             	movzbl %al,%eax
80102ce4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ce7:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cec:	83 e0 08             	and    $0x8,%eax
80102cef:	85 c0                	test   %eax,%eax
80102cf1:	74 22                	je     80102d15 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102cf3:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cf7:	76 0c                	jbe    80102d05 <kbdgetc+0x13a>
80102cf9:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cfd:	77 06                	ja     80102d05 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102cff:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d03:	eb 10                	jmp    80102d15 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d05:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d09:	76 0a                	jbe    80102d15 <kbdgetc+0x14a>
80102d0b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d0f:	77 04                	ja     80102d15 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d11:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d15:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d18:	c9                   	leave  
80102d19:	c3                   	ret    

80102d1a <kbdintr>:

void
kbdintr(void)
{
80102d1a:	55                   	push   %ebp
80102d1b:	89 e5                	mov    %esp,%ebp
80102d1d:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d20:	c7 04 24 cb 2b 10 80 	movl   $0x80102bcb,(%esp)
80102d27:	e8 9f da ff ff       	call   801007cb <consoleintr>
}
80102d2c:	c9                   	leave  
80102d2d:	c3                   	ret    
	...

80102d30 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	83 ec 14             	sub    $0x14,%esp
80102d36:	8b 45 08             	mov    0x8(%ebp),%eax
80102d39:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102d40:	89 c2                	mov    %eax,%edx
80102d42:	ec                   	in     (%dx),%al
80102d43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d46:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102d49:	c9                   	leave  
80102d4a:	c3                   	ret    

80102d4b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d4b:	55                   	push   %ebp
80102d4c:	89 e5                	mov    %esp,%ebp
80102d4e:	83 ec 08             	sub    $0x8,%esp
80102d51:	8b 45 08             	mov    0x8(%ebp),%eax
80102d54:	8b 55 0c             	mov    0xc(%ebp),%edx
80102d57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102d5b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d5e:	8a 45 f8             	mov    -0x8(%ebp),%al
80102d61:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102d64:	ee                   	out    %al,(%dx)
}
80102d65:	c9                   	leave  
80102d66:	c3                   	ret    

80102d67 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d67:	55                   	push   %ebp
80102d68:	89 e5                	mov    %esp,%ebp
80102d6a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d6d:	9c                   	pushf  
80102d6e:	58                   	pop    %eax
80102d6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102d72:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102d75:	c9                   	leave  
80102d76:	c3                   	ret    

80102d77 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d77:	55                   	push   %ebp
80102d78:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d7a:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102d7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d82:	c1 e2 02             	shl    $0x2,%edx
80102d85:	01 c2                	add    %eax,%edx
80102d87:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d8a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d8c:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102d91:	83 c0 20             	add    $0x20,%eax
80102d94:	8b 00                	mov    (%eax),%eax
}
80102d96:	5d                   	pop    %ebp
80102d97:	c3                   	ret    

80102d98 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
80102d9b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102d9e:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102da3:	85 c0                	test   %eax,%eax
80102da5:	75 05                	jne    80102dac <lapicinit+0x14>
    return;
80102da7:	e9 43 01 00 00       	jmp    80102eef <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dac:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102db3:	00 
80102db4:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102dbb:	e8 b7 ff ff ff       	call   80102d77 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dc0:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102dc7:	00 
80102dc8:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102dcf:	e8 a3 ff ff ff       	call   80102d77 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102dd4:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102ddb:	00 
80102ddc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102de3:	e8 8f ff ff ff       	call   80102d77 <lapicw>
  lapicw(TICR, 10000000);
80102de8:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102def:	00 
80102df0:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102df7:	e8 7b ff ff ff       	call   80102d77 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102dfc:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e03:	00 
80102e04:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e0b:	e8 67 ff ff ff       	call   80102d77 <lapicw>
  lapicw(LINT1, MASKED);
80102e10:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e17:	00 
80102e18:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e1f:	e8 53 ff ff ff       	call   80102d77 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e24:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102e29:	83 c0 30             	add    $0x30,%eax
80102e2c:	8b 00                	mov    (%eax),%eax
80102e2e:	c1 e8 10             	shr    $0x10,%eax
80102e31:	0f b6 c0             	movzbl %al,%eax
80102e34:	83 f8 03             	cmp    $0x3,%eax
80102e37:	76 14                	jbe    80102e4d <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e39:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e40:	00 
80102e41:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e48:	e8 2a ff ff ff       	call   80102d77 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e4d:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e54:	00 
80102e55:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e5c:	e8 16 ff ff ff       	call   80102d77 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e68:	00 
80102e69:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e70:	e8 02 ff ff ff       	call   80102d77 <lapicw>
  lapicw(ESR, 0);
80102e75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e7c:	00 
80102e7d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e84:	e8 ee fe ff ff       	call   80102d77 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e90:	00 
80102e91:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e98:	e8 da fe ff ff       	call   80102d77 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea4:	00 
80102ea5:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102eac:	e8 c6 fe ff ff       	call   80102d77 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eb1:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102eb8:	00 
80102eb9:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ec0:	e8 b2 fe ff ff       	call   80102d77 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102ec5:	90                   	nop
80102ec6:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102ecb:	05 00 03 00 00       	add    $0x300,%eax
80102ed0:	8b 00                	mov    (%eax),%eax
80102ed2:	25 00 10 00 00       	and    $0x1000,%eax
80102ed7:	85 c0                	test   %eax,%eax
80102ed9:	75 eb                	jne    80102ec6 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102edb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee2:	00 
80102ee3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102eea:	e8 88 fe ff ff       	call   80102d77 <lapicw>
}
80102eef:	c9                   	leave  
80102ef0:	c3                   	ret    

80102ef1 <cpunum>:

int
cpunum(void)
{
80102ef1:	55                   	push   %ebp
80102ef2:	89 e5                	mov    %esp,%ebp
80102ef4:	83 ec 28             	sub    $0x28,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ef7:	e8 6b fe ff ff       	call   80102d67 <readeflags>
80102efc:	25 00 02 00 00       	and    $0x200,%eax
80102f01:	85 c0                	test   %eax,%eax
80102f03:	74 25                	je     80102f2a <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102f05:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102f0a:	8d 50 01             	lea    0x1(%eax),%edx
80102f0d:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102f13:	85 c0                	test   %eax,%eax
80102f15:	75 13                	jne    80102f2a <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f17:	8b 45 04             	mov    0x4(%ebp),%eax
80102f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f1e:	c7 04 24 70 86 10 80 	movl   $0x80108670,(%esp)
80102f25:	e8 97 d4 ff ff       	call   801003c1 <cprintf>
        __builtin_return_address(0));
  }

  if (!lapic)
80102f2a:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102f2f:	85 c0                	test   %eax,%eax
80102f31:	75 07                	jne    80102f3a <cpunum+0x49>
    return 0;
80102f33:	b8 00 00 00 00       	mov    $0x0,%eax
80102f38:	eb 5d                	jmp    80102f97 <cpunum+0xa6>

  apicid = lapic[ID] >> 24;
80102f3a:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102f3f:	83 c0 20             	add    $0x20,%eax
80102f42:	8b 00                	mov    (%eax),%eax
80102f44:	c1 e8 18             	shr    $0x18,%eax
80102f47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i = 0; i < ncpu; ++i) {
80102f4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f51:	eb 2e                	jmp    80102f81 <cpunum+0x90>
    if (cpus[i].apicid == apicid)
80102f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f56:	89 d0                	mov    %edx,%eax
80102f58:	c1 e0 02             	shl    $0x2,%eax
80102f5b:	01 d0                	add    %edx,%eax
80102f5d:	01 c0                	add    %eax,%eax
80102f5f:	01 d0                	add    %edx,%eax
80102f61:	89 c1                	mov    %eax,%ecx
80102f63:	c1 e1 04             	shl    $0x4,%ecx
80102f66:	01 c8                	add    %ecx,%eax
80102f68:	01 d0                	add    %edx,%eax
80102f6a:	05 20 38 11 80       	add    $0x80113820,%eax
80102f6f:	8a 00                	mov    (%eax),%al
80102f71:	0f b6 c0             	movzbl %al,%eax
80102f74:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102f77:	75 05                	jne    80102f7e <cpunum+0x8d>
      return i;
80102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f7c:	eb 19                	jmp    80102f97 <cpunum+0xa6>

  if (!lapic)
    return 0;

  apicid = lapic[ID] >> 24;
  for (i = 0; i < ncpu; ++i) {
80102f7e:	ff 45 f4             	incl   -0xc(%ebp)
80102f81:	a1 00 3e 11 80       	mov    0x80113e00,%eax
80102f86:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f89:	7c c8                	jl     80102f53 <cpunum+0x62>
    if (cpus[i].apicid == apicid)
      return i;
  }
  panic("unknown apicid\n");
80102f8b:	c7 04 24 9c 86 10 80 	movl   $0x8010869c,(%esp)
80102f92:	e8 bd d5 ff ff       	call   80100554 <panic>
}
80102f97:	c9                   	leave  
80102f98:	c3                   	ret    

80102f99 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f9f:	a1 1c 37 11 80       	mov    0x8011371c,%eax
80102fa4:	85 c0                	test   %eax,%eax
80102fa6:	74 14                	je     80102fbc <lapiceoi+0x23>
    lapicw(EOI, 0);
80102fa8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102faf:	00 
80102fb0:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fb7:	e8 bb fd ff ff       	call   80102d77 <lapicw>
}
80102fbc:	c9                   	leave  
80102fbd:	c3                   	ret    

80102fbe <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fbe:	55                   	push   %ebp
80102fbf:	89 e5                	mov    %esp,%ebp
}
80102fc1:	5d                   	pop    %ebp
80102fc2:	c3                   	ret    

80102fc3 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fc3:	55                   	push   %ebp
80102fc4:	89 e5                	mov    %esp,%ebp
80102fc6:	83 ec 1c             	sub    $0x1c,%esp
80102fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fcc:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fcf:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fd6:	00 
80102fd7:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fde:	e8 68 fd ff ff       	call   80102d4b <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fe3:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fea:	00 
80102feb:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102ff2:	e8 54 fd ff ff       	call   80102d4b <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102ff7:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ffe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103001:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103006:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103009:	8d 50 02             	lea    0x2(%eax),%edx
8010300c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010300f:	c1 e8 04             	shr    $0x4,%eax
80103012:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103015:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103019:	c1 e0 18             	shl    $0x18,%eax
8010301c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103020:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103027:	e8 4b fd ff ff       	call   80102d77 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010302c:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103033:	00 
80103034:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010303b:	e8 37 fd ff ff       	call   80102d77 <lapicw>
  microdelay(200);
80103040:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103047:	e8 72 ff ff ff       	call   80102fbe <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010304c:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103053:	00 
80103054:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010305b:	e8 17 fd ff ff       	call   80102d77 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103060:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103067:	e8 52 ff ff ff       	call   80102fbe <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010306c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103073:	eb 3f                	jmp    801030b4 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103075:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103079:	c1 e0 18             	shl    $0x18,%eax
8010307c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103080:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103087:	e8 eb fc ff ff       	call   80102d77 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010308c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308f:	c1 e8 0c             	shr    $0xc,%eax
80103092:	80 cc 06             	or     $0x6,%ah
80103095:	89 44 24 04          	mov    %eax,0x4(%esp)
80103099:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030a0:	e8 d2 fc ff ff       	call   80102d77 <lapicw>
    microdelay(200);
801030a5:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030ac:	e8 0d ff ff ff       	call   80102fbe <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b1:	ff 45 fc             	incl   -0x4(%ebp)
801030b4:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030b8:	7e bb                	jle    80103075 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030ba:	c9                   	leave  
801030bb:	c3                   	ret    

801030bc <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030bc:	55                   	push   %ebp
801030bd:	89 e5                	mov    %esp,%ebp
801030bf:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030c2:	8b 45 08             	mov    0x8(%ebp),%eax
801030c5:	0f b6 c0             	movzbl %al,%eax
801030c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801030cc:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030d3:	e8 73 fc ff ff       	call   80102d4b <outb>
  microdelay(200);
801030d8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030df:	e8 da fe ff ff       	call   80102fbe <microdelay>

  return inb(CMOS_RETURN);
801030e4:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030eb:	e8 40 fc ff ff       	call   80102d30 <inb>
801030f0:	0f b6 c0             	movzbl %al,%eax
}
801030f3:	c9                   	leave  
801030f4:	c3                   	ret    

801030f5 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
801030f8:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103102:	e8 b5 ff ff ff       	call   801030bc <cmos_read>
80103107:	8b 55 08             	mov    0x8(%ebp),%edx
8010310a:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010310c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103113:	e8 a4 ff ff ff       	call   801030bc <cmos_read>
80103118:	8b 55 08             	mov    0x8(%ebp),%edx
8010311b:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010311e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103125:	e8 92 ff ff ff       	call   801030bc <cmos_read>
8010312a:	8b 55 08             	mov    0x8(%ebp),%edx
8010312d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103130:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103137:	e8 80 ff ff ff       	call   801030bc <cmos_read>
8010313c:	8b 55 08             	mov    0x8(%ebp),%edx
8010313f:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103142:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103149:	e8 6e ff ff ff       	call   801030bc <cmos_read>
8010314e:	8b 55 08             	mov    0x8(%ebp),%edx
80103151:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103154:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010315b:	e8 5c ff ff ff       	call   801030bc <cmos_read>
80103160:	8b 55 08             	mov    0x8(%ebp),%edx
80103163:	89 42 14             	mov    %eax,0x14(%edx)
}
80103166:	c9                   	leave  
80103167:	c3                   	ret    

80103168 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103168:	55                   	push   %ebp
80103169:	89 e5                	mov    %esp,%ebp
8010316b:	57                   	push   %edi
8010316c:	56                   	push   %esi
8010316d:	53                   	push   %ebx
8010316e:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103171:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103178:	e8 3f ff ff ff       	call   801030bc <cmos_read>
8010317d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103183:	83 e0 04             	and    $0x4,%eax
80103186:	85 c0                	test   %eax,%eax
80103188:	0f 94 c0             	sete   %al
8010318b:	0f b6 c0             	movzbl %al,%eax
8010318e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103191:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103194:	89 04 24             	mov    %eax,(%esp)
80103197:	e8 59 ff ff ff       	call   801030f5 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010319c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801031a3:	e8 14 ff ff ff       	call   801030bc <cmos_read>
801031a8:	25 80 00 00 00       	and    $0x80,%eax
801031ad:	85 c0                	test   %eax,%eax
801031af:	74 02                	je     801031b3 <cmostime+0x4b>
        continue;
801031b1:	eb 36                	jmp    801031e9 <cmostime+0x81>
    fill_rtcdate(&t2);
801031b3:	8d 45 b0             	lea    -0x50(%ebp),%eax
801031b6:	89 04 24             	mov    %eax,(%esp)
801031b9:	e8 37 ff ff ff       	call   801030f5 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031be:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031c5:	00 
801031c6:	8d 45 b0             	lea    -0x50(%ebp),%eax
801031c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801031cd:	8d 45 c8             	lea    -0x38(%ebp),%eax
801031d0:	89 04 24             	mov    %eax,(%esp)
801031d3:	e8 e5 1f 00 00       	call   801051bd <memcmp>
801031d8:	85 c0                	test   %eax,%eax
801031da:	75 0d                	jne    801031e9 <cmostime+0x81>
      break;
801031dc:	90                   	nop
  }

  // convert
  if(bcd) {
801031dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801031e1:	0f 84 ac 00 00 00    	je     80103293 <cmostime+0x12b>
801031e7:	eb 02                	jmp    801031eb <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031e9:	eb a6                	jmp    80103191 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031eb:	8b 45 c8             	mov    -0x38(%ebp),%eax
801031ee:	c1 e8 04             	shr    $0x4,%eax
801031f1:	89 c2                	mov    %eax,%edx
801031f3:	89 d0                	mov    %edx,%eax
801031f5:	c1 e0 02             	shl    $0x2,%eax
801031f8:	01 d0                	add    %edx,%eax
801031fa:	01 c0                	add    %eax,%eax
801031fc:	8b 55 c8             	mov    -0x38(%ebp),%edx
801031ff:	83 e2 0f             	and    $0xf,%edx
80103202:	01 d0                	add    %edx,%eax
80103204:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103207:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010320a:	c1 e8 04             	shr    $0x4,%eax
8010320d:	89 c2                	mov    %eax,%edx
8010320f:	89 d0                	mov    %edx,%eax
80103211:	c1 e0 02             	shl    $0x2,%eax
80103214:	01 d0                	add    %edx,%eax
80103216:	01 c0                	add    %eax,%eax
80103218:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010321b:	83 e2 0f             	and    $0xf,%edx
8010321e:	01 d0                	add    %edx,%eax
80103220:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103223:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103226:	c1 e8 04             	shr    $0x4,%eax
80103229:	89 c2                	mov    %eax,%edx
8010322b:	89 d0                	mov    %edx,%eax
8010322d:	c1 e0 02             	shl    $0x2,%eax
80103230:	01 d0                	add    %edx,%eax
80103232:	01 c0                	add    %eax,%eax
80103234:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103237:	83 e2 0f             	and    $0xf,%edx
8010323a:	01 d0                	add    %edx,%eax
8010323c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
8010323f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103242:	c1 e8 04             	shr    $0x4,%eax
80103245:	89 c2                	mov    %eax,%edx
80103247:	89 d0                	mov    %edx,%eax
80103249:	c1 e0 02             	shl    $0x2,%eax
8010324c:	01 d0                	add    %edx,%eax
8010324e:	01 c0                	add    %eax,%eax
80103250:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103253:	83 e2 0f             	and    $0xf,%edx
80103256:	01 d0                	add    %edx,%eax
80103258:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
8010325b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325e:	c1 e8 04             	shr    $0x4,%eax
80103261:	89 c2                	mov    %eax,%edx
80103263:	89 d0                	mov    %edx,%eax
80103265:	c1 e0 02             	shl    $0x2,%eax
80103268:	01 d0                	add    %edx,%eax
8010326a:	01 c0                	add    %eax,%eax
8010326c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010326f:	83 e2 0f             	and    $0xf,%edx
80103272:	01 d0                	add    %edx,%eax
80103274:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103277:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327a:	c1 e8 04             	shr    $0x4,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	89 d0                	mov    %edx,%eax
80103281:	c1 e0 02             	shl    $0x2,%eax
80103284:	01 d0                	add    %edx,%eax
80103286:	01 c0                	add    %eax,%eax
80103288:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010328b:	83 e2 0f             	and    $0xf,%edx
8010328e:	01 d0                	add    %edx,%eax
80103290:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103293:	8b 45 08             	mov    0x8(%ebp),%eax
80103296:	89 c2                	mov    %eax,%edx
80103298:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010329b:	b8 06 00 00 00       	mov    $0x6,%eax
801032a0:	89 d7                	mov    %edx,%edi
801032a2:	89 de                	mov    %ebx,%esi
801032a4:	89 c1                	mov    %eax,%ecx
801032a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801032a8:	8b 45 08             	mov    0x8(%ebp),%eax
801032ab:	8b 40 14             	mov    0x14(%eax),%eax
801032ae:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032b4:	8b 45 08             	mov    0x8(%ebp),%eax
801032b7:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ba:	83 c4 5c             	add    $0x5c,%esp
801032bd:	5b                   	pop    %ebx
801032be:	5e                   	pop    %esi
801032bf:	5f                   	pop    %edi
801032c0:	5d                   	pop    %ebp
801032c1:	c3                   	ret    
	...

801032c4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032c4:	55                   	push   %ebp
801032c5:	89 e5                	mov    %esp,%ebp
801032c7:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032ca:	c7 44 24 04 ac 86 10 	movl   $0x801086ac,0x4(%esp)
801032d1:	80 
801032d2:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801032d9:	e8 e4 1b 00 00       	call   80104ec2 <initlock>
  readsb(dev, &sb);
801032de:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801032e5:	8b 45 08             	mov    0x8(%ebp),%eax
801032e8:	89 04 24             	mov    %eax,(%esp)
801032eb:	e8 2c e0 ff ff       	call   8010131c <readsb>
  log.start = sb.logstart;
801032f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f3:	a3 54 37 11 80       	mov    %eax,0x80113754
  log.size = sb.nlog;
801032f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032fb:	a3 58 37 11 80       	mov    %eax,0x80113758
  log.dev = dev;
80103300:	8b 45 08             	mov    0x8(%ebp),%eax
80103303:	a3 64 37 11 80       	mov    %eax,0x80113764
  recover_from_log();
80103308:	e8 95 01 00 00       	call   801034a2 <recover_from_log>
}
8010330d:	c9                   	leave  
8010330e:	c3                   	ret    

8010330f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010330f:	55                   	push   %ebp
80103310:	89 e5                	mov    %esp,%ebp
80103312:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103315:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010331c:	e9 89 00 00 00       	jmp    801033aa <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103321:	8b 15 54 37 11 80    	mov    0x80113754,%edx
80103327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332a:	01 d0                	add    %edx,%eax
8010332c:	40                   	inc    %eax
8010332d:	89 c2                	mov    %eax,%edx
8010332f:	a1 64 37 11 80       	mov    0x80113764,%eax
80103334:	89 54 24 04          	mov    %edx,0x4(%esp)
80103338:	89 04 24             	mov    %eax,(%esp)
8010333b:	e8 75 ce ff ff       	call   801001b5 <bread>
80103340:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103346:	83 c0 10             	add    $0x10,%eax
80103349:	8b 04 85 2c 37 11 80 	mov    -0x7feec8d4(,%eax,4),%eax
80103350:	89 c2                	mov    %eax,%edx
80103352:	a1 64 37 11 80       	mov    0x80113764,%eax
80103357:	89 54 24 04          	mov    %edx,0x4(%esp)
8010335b:	89 04 24             	mov    %eax,(%esp)
8010335e:	e8 52 ce ff ff       	call   801001b5 <bread>
80103363:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103369:	8d 50 5c             	lea    0x5c(%eax),%edx
8010336c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010336f:	83 c0 5c             	add    $0x5c,%eax
80103372:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103379:	00 
8010337a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010337e:	89 04 24             	mov    %eax,(%esp)
80103381:	e8 89 1e 00 00       	call   8010520f <memmove>
    bwrite(dbuf);  // write dst to disk
80103386:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103389:	89 04 24             	mov    %eax,(%esp)
8010338c:	e8 5b ce ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103394:	89 04 24             	mov    %eax,(%esp)
80103397:	e8 90 ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010339c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010339f:	89 04 24             	mov    %eax,(%esp)
801033a2:	e8 85 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a7:	ff 45 f4             	incl   -0xc(%ebp)
801033aa:	a1 68 37 11 80       	mov    0x80113768,%eax
801033af:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b2:	0f 8f 69 ff ff ff    	jg     80103321 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801033b8:	c9                   	leave  
801033b9:	c3                   	ret    

801033ba <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033ba:	55                   	push   %ebp
801033bb:	89 e5                	mov    %esp,%ebp
801033bd:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033c0:	a1 54 37 11 80       	mov    0x80113754,%eax
801033c5:	89 c2                	mov    %eax,%edx
801033c7:	a1 64 37 11 80       	mov    0x80113764,%eax
801033cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801033d0:	89 04 24             	mov    %eax,(%esp)
801033d3:	e8 dd cd ff ff       	call   801001b5 <bread>
801033d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033de:	83 c0 5c             	add    $0x5c,%eax
801033e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e7:	8b 00                	mov    (%eax),%eax
801033e9:	a3 68 37 11 80       	mov    %eax,0x80113768
  for (i = 0; i < log.lh.n; i++) {
801033ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033f5:	eb 1a                	jmp    80103411 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801033f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033fd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103401:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103404:	83 c2 10             	add    $0x10,%edx
80103407:	89 04 95 2c 37 11 80 	mov    %eax,-0x7feec8d4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010340e:	ff 45 f4             	incl   -0xc(%ebp)
80103411:	a1 68 37 11 80       	mov    0x80113768,%eax
80103416:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103419:	7f dc                	jg     801033f7 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010341b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010341e:	89 04 24             	mov    %eax,(%esp)
80103421:	e8 06 ce ff ff       	call   8010022c <brelse>
}
80103426:	c9                   	leave  
80103427:	c3                   	ret    

80103428 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103428:	55                   	push   %ebp
80103429:	89 e5                	mov    %esp,%ebp
8010342b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010342e:	a1 54 37 11 80       	mov    0x80113754,%eax
80103433:	89 c2                	mov    %eax,%edx
80103435:	a1 64 37 11 80       	mov    0x80113764,%eax
8010343a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010343e:	89 04 24             	mov    %eax,(%esp)
80103441:	e8 6f cd ff ff       	call   801001b5 <bread>
80103446:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010344c:	83 c0 5c             	add    $0x5c,%eax
8010344f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103452:	8b 15 68 37 11 80    	mov    0x80113768,%edx
80103458:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010345d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103464:	eb 1a                	jmp    80103480 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103469:	83 c0 10             	add    $0x10,%eax
8010346c:	8b 0c 85 2c 37 11 80 	mov    -0x7feec8d4(,%eax,4),%ecx
80103473:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103479:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010347d:	ff 45 f4             	incl   -0xc(%ebp)
80103480:	a1 68 37 11 80       	mov    0x80113768,%eax
80103485:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103488:	7f dc                	jg     80103466 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010348a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348d:	89 04 24             	mov    %eax,(%esp)
80103490:	e8 57 cd ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103498:	89 04 24             	mov    %eax,(%esp)
8010349b:	e8 8c cd ff ff       	call   8010022c <brelse>
}
801034a0:	c9                   	leave  
801034a1:	c3                   	ret    

801034a2 <recover_from_log>:

static void
recover_from_log(void)
{
801034a2:	55                   	push   %ebp
801034a3:	89 e5                	mov    %esp,%ebp
801034a5:	83 ec 08             	sub    $0x8,%esp
  read_head();
801034a8:	e8 0d ff ff ff       	call   801033ba <read_head>
  install_trans(); // if committed, copy from log to disk
801034ad:	e8 5d fe ff ff       	call   8010330f <install_trans>
  log.lh.n = 0;
801034b2:	c7 05 68 37 11 80 00 	movl   $0x0,0x80113768
801034b9:	00 00 00 
  write_head(); // clear the log
801034bc:	e8 67 ff ff ff       	call   80103428 <write_head>
}
801034c1:	c9                   	leave  
801034c2:	c3                   	ret    

801034c3 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034c3:	55                   	push   %ebp
801034c4:	89 e5                	mov    %esp,%ebp
801034c6:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034c9:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801034d0:	e8 0e 1a 00 00       	call   80104ee3 <acquire>
  while(1){
    if(log.committing){
801034d5:	a1 60 37 11 80       	mov    0x80113760,%eax
801034da:	85 c0                	test   %eax,%eax
801034dc:	74 16                	je     801034f4 <begin_op+0x31>
      sleep(&log, &log.lock);
801034de:	c7 44 24 04 20 37 11 	movl   $0x80113720,0x4(%esp)
801034e5:	80 
801034e6:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801034ed:	e8 20 16 00 00       	call   80104b12 <sleep>
801034f2:	eb 4d                	jmp    80103541 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034f4:	8b 15 68 37 11 80    	mov    0x80113768,%edx
801034fa:	a1 5c 37 11 80       	mov    0x8011375c,%eax
801034ff:	8d 48 01             	lea    0x1(%eax),%ecx
80103502:	89 c8                	mov    %ecx,%eax
80103504:	c1 e0 02             	shl    $0x2,%eax
80103507:	01 c8                	add    %ecx,%eax
80103509:	01 c0                	add    %eax,%eax
8010350b:	01 d0                	add    %edx,%eax
8010350d:	83 f8 1e             	cmp    $0x1e,%eax
80103510:	7e 16                	jle    80103528 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103512:	c7 44 24 04 20 37 11 	movl   $0x80113720,0x4(%esp)
80103519:	80 
8010351a:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
80103521:	e8 ec 15 00 00       	call   80104b12 <sleep>
80103526:	eb 19                	jmp    80103541 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103528:	a1 5c 37 11 80       	mov    0x8011375c,%eax
8010352d:	40                   	inc    %eax
8010352e:	a3 5c 37 11 80       	mov    %eax,0x8011375c
      release(&log.lock);
80103533:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
8010353a:	e8 0b 1a 00 00       	call   80104f4a <release>
      break;
8010353f:	eb 02                	jmp    80103543 <begin_op+0x80>
    }
  }
80103541:	eb 92                	jmp    801034d5 <begin_op+0x12>
}
80103543:	c9                   	leave  
80103544:	c3                   	ret    

80103545 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103545:	55                   	push   %ebp
80103546:	89 e5                	mov    %esp,%ebp
80103548:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010354b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103552:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
80103559:	e8 85 19 00 00       	call   80104ee3 <acquire>
  log.outstanding -= 1;
8010355e:	a1 5c 37 11 80       	mov    0x8011375c,%eax
80103563:	48                   	dec    %eax
80103564:	a3 5c 37 11 80       	mov    %eax,0x8011375c
  if(log.committing)
80103569:	a1 60 37 11 80       	mov    0x80113760,%eax
8010356e:	85 c0                	test   %eax,%eax
80103570:	74 0c                	je     8010357e <end_op+0x39>
    panic("log.committing");
80103572:	c7 04 24 b0 86 10 80 	movl   $0x801086b0,(%esp)
80103579:	e8 d6 cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010357e:	a1 5c 37 11 80       	mov    0x8011375c,%eax
80103583:	85 c0                	test   %eax,%eax
80103585:	75 13                	jne    8010359a <end_op+0x55>
    do_commit = 1;
80103587:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010358e:	c7 05 60 37 11 80 01 	movl   $0x1,0x80113760
80103595:	00 00 00 
80103598:	eb 0c                	jmp    801035a6 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010359a:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801035a1:	e8 45 16 00 00       	call   80104beb <wakeup>
  }
  release(&log.lock);
801035a6:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801035ad:	e8 98 19 00 00       	call   80104f4a <release>

  if(do_commit){
801035b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b6:	74 33                	je     801035eb <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035b8:	e8 db 00 00 00       	call   80103698 <commit>
    acquire(&log.lock);
801035bd:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801035c4:	e8 1a 19 00 00       	call   80104ee3 <acquire>
    log.committing = 0;
801035c9:	c7 05 60 37 11 80 00 	movl   $0x0,0x80113760
801035d0:	00 00 00 
    wakeup(&log);
801035d3:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801035da:	e8 0c 16 00 00       	call   80104beb <wakeup>
    release(&log.lock);
801035df:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
801035e6:	e8 5f 19 00 00       	call   80104f4a <release>
  }
}
801035eb:	c9                   	leave  
801035ec:	c3                   	ret    

801035ed <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801035ed:	55                   	push   %ebp
801035ee:	89 e5                	mov    %esp,%ebp
801035f0:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035fa:	e9 89 00 00 00       	jmp    80103688 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035ff:	8b 15 54 37 11 80    	mov    0x80113754,%edx
80103605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103608:	01 d0                	add    %edx,%eax
8010360a:	40                   	inc    %eax
8010360b:	89 c2                	mov    %eax,%edx
8010360d:	a1 64 37 11 80       	mov    0x80113764,%eax
80103612:	89 54 24 04          	mov    %edx,0x4(%esp)
80103616:	89 04 24             	mov    %eax,(%esp)
80103619:	e8 97 cb ff ff       	call   801001b5 <bread>
8010361e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103624:	83 c0 10             	add    $0x10,%eax
80103627:	8b 04 85 2c 37 11 80 	mov    -0x7feec8d4(,%eax,4),%eax
8010362e:	89 c2                	mov    %eax,%edx
80103630:	a1 64 37 11 80       	mov    0x80113764,%eax
80103635:	89 54 24 04          	mov    %edx,0x4(%esp)
80103639:	89 04 24             	mov    %eax,(%esp)
8010363c:	e8 74 cb ff ff       	call   801001b5 <bread>
80103641:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103644:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103647:	8d 50 5c             	lea    0x5c(%eax),%edx
8010364a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364d:	83 c0 5c             	add    $0x5c,%eax
80103650:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103657:	00 
80103658:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365c:	89 04 24             	mov    %eax,(%esp)
8010365f:	e8 ab 1b 00 00       	call   8010520f <memmove>
    bwrite(to);  // write the log
80103664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103667:	89 04 24             	mov    %eax,(%esp)
8010366a:	e8 7d cb ff ff       	call   801001ec <bwrite>
    brelse(from);
8010366f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103672:	89 04 24             	mov    %eax,(%esp)
80103675:	e8 b2 cb ff ff       	call   8010022c <brelse>
    brelse(to);
8010367a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367d:	89 04 24             	mov    %eax,(%esp)
80103680:	e8 a7 cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103685:	ff 45 f4             	incl   -0xc(%ebp)
80103688:	a1 68 37 11 80       	mov    0x80113768,%eax
8010368d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103690:	0f 8f 69 ff ff ff    	jg     801035ff <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <commit>:

static void
commit()
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010369e:	a1 68 37 11 80       	mov    0x80113768,%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	7e 1e                	jle    801036c5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036a7:	e8 41 ff ff ff       	call   801035ed <write_log>
    write_head();    // Write header to disk -- the real commit
801036ac:	e8 77 fd ff ff       	call   80103428 <write_head>
    install_trans(); // Now install writes to home locations
801036b1:	e8 59 fc ff ff       	call   8010330f <install_trans>
    log.lh.n = 0;
801036b6:	c7 05 68 37 11 80 00 	movl   $0x0,0x80113768
801036bd:	00 00 00 
    write_head();    // Erase the transaction from the log
801036c0:	e8 63 fd ff ff       	call   80103428 <write_head>
  }
}
801036c5:	c9                   	leave  
801036c6:	c3                   	ret    

801036c7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036c7:	55                   	push   %ebp
801036c8:	89 e5                	mov    %esp,%ebp
801036ca:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036cd:	a1 68 37 11 80       	mov    0x80113768,%eax
801036d2:	83 f8 1d             	cmp    $0x1d,%eax
801036d5:	7f 10                	jg     801036e7 <log_write+0x20>
801036d7:	a1 68 37 11 80       	mov    0x80113768,%eax
801036dc:	8b 15 58 37 11 80    	mov    0x80113758,%edx
801036e2:	4a                   	dec    %edx
801036e3:	39 d0                	cmp    %edx,%eax
801036e5:	7c 0c                	jl     801036f3 <log_write+0x2c>
    panic("too big a transaction");
801036e7:	c7 04 24 bf 86 10 80 	movl   $0x801086bf,(%esp)
801036ee:	e8 61 ce ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801036f3:	a1 5c 37 11 80       	mov    0x8011375c,%eax
801036f8:	85 c0                	test   %eax,%eax
801036fa:	7f 0c                	jg     80103708 <log_write+0x41>
    panic("log_write outside of trans");
801036fc:	c7 04 24 d5 86 10 80 	movl   $0x801086d5,(%esp)
80103703:	e8 4c ce ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103708:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
8010370f:	e8 cf 17 00 00       	call   80104ee3 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010371b:	eb 1e                	jmp    8010373b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010371d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103720:	83 c0 10             	add    $0x10,%eax
80103723:	8b 04 85 2c 37 11 80 	mov    -0x7feec8d4(,%eax,4),%eax
8010372a:	89 c2                	mov    %eax,%edx
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	8b 40 08             	mov    0x8(%eax),%eax
80103732:	39 c2                	cmp    %eax,%edx
80103734:	75 02                	jne    80103738 <log_write+0x71>
      break;
80103736:	eb 0d                	jmp    80103745 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103738:	ff 45 f4             	incl   -0xc(%ebp)
8010373b:	a1 68 37 11 80       	mov    0x80113768,%eax
80103740:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103743:	7f d8                	jg     8010371d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103745:	8b 45 08             	mov    0x8(%ebp),%eax
80103748:	8b 40 08             	mov    0x8(%eax),%eax
8010374b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010374e:	83 c2 10             	add    $0x10,%edx
80103751:	89 04 95 2c 37 11 80 	mov    %eax,-0x7feec8d4(,%edx,4)
  if (i == log.lh.n)
80103758:	a1 68 37 11 80       	mov    0x80113768,%eax
8010375d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103760:	75 0b                	jne    8010376d <log_write+0xa6>
    log.lh.n++;
80103762:	a1 68 37 11 80       	mov    0x80113768,%eax
80103767:	40                   	inc    %eax
80103768:	a3 68 37 11 80       	mov    %eax,0x80113768
  b->flags |= B_DIRTY; // prevent eviction
8010376d:	8b 45 08             	mov    0x8(%ebp),%eax
80103770:	8b 00                	mov    (%eax),%eax
80103772:	83 c8 04             	or     $0x4,%eax
80103775:	89 c2                	mov    %eax,%edx
80103777:	8b 45 08             	mov    0x8(%ebp),%eax
8010377a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010377c:	c7 04 24 20 37 11 80 	movl   $0x80113720,(%esp)
80103783:	e8 c2 17 00 00       	call   80104f4a <release>
}
80103788:	c9                   	leave  
80103789:	c3                   	ret    
	...

8010378c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010378c:	55                   	push   %ebp
8010378d:	89 e5                	mov    %esp,%ebp
8010378f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103792:	8b 55 08             	mov    0x8(%ebp),%edx
80103795:	8b 45 0c             	mov    0xc(%ebp),%eax
80103798:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010379b:	f0 87 02             	lock xchg %eax,(%edx)
8010379e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037a4:	c9                   	leave  
801037a5:	c3                   	ret    

801037a6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037a6:	55                   	push   %ebp
801037a7:	89 e5                	mov    %esp,%ebp
801037a9:	83 e4 f0             	and    $0xfffffff0,%esp
801037ac:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037af:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037b6:	80 
801037b7:	c7 04 24 a8 65 11 80 	movl   $0x801165a8,(%esp)
801037be:	e8 75 f2 ff ff       	call   80102a38 <kinit1>
  kvmalloc();      // kernel page table
801037c3:	e8 7f 44 00 00       	call   80107c47 <kvmalloc>
  mpinit();        // detect other processors
801037c8:	e8 00 04 00 00       	call   80103bcd <mpinit>
  lapicinit();     // interrupt controller
801037cd:	e8 c6 f5 ff ff       	call   80102d98 <lapicinit>
  seginit();       // segment descriptors
801037d2:	e8 4c 3e 00 00       	call   80107623 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpunum());
801037d7:	e8 15 f7 ff ff       	call   80102ef1 <cpunum>
801037dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801037e0:	c7 04 24 f0 86 10 80 	movl   $0x801086f0,(%esp)
801037e7:	e8 d5 cb ff ff       	call   801003c1 <cprintf>
  picinit();       // another interrupt controller
801037ec:	e8 c0 05 00 00       	call   80103db1 <picinit>
  ioapicinit();    // another interrupt controller
801037f1:	e8 47 f1 ff ff       	call   8010293d <ioapicinit>
  consoleinit();   // console hardware
801037f6:	e8 a8 d2 ff ff       	call   80100aa3 <consoleinit>
  uartinit();      // serial port
801037fb:	e8 8f 31 00 00       	call   8010698f <uartinit>
  pinit();         // process table
80103800:	e8 b5 0a 00 00       	call   801042ba <pinit>
  tvinit();        // trap vectors
80103805:	e8 6e 2d 00 00       	call   80106578 <tvinit>
  binit();         // buffer cache
8010380a:	e8 25 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010380f:	e8 2c d7 ff ff       	call   80100f40 <fileinit>
  ideinit();       // disk
80103814:	e8 24 ed ff ff       	call   8010253d <ideinit>
  if(!ismp)
80103819:	a1 04 38 11 80       	mov    0x80113804,%eax
8010381e:	85 c0                	test   %eax,%eax
80103820:	75 05                	jne    80103827 <main+0x81>
    timerinit();   // uniprocessor timer
80103822:	e8 9d 2c 00 00       	call   801064c4 <timerinit>
  startothers();   // start other processors
80103827:	e8 78 00 00 00       	call   801038a4 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010382c:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103833:	8e 
80103834:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010383b:	e8 30 f2 ff ff       	call   80102a70 <kinit2>
  userinit();      // first user process
80103840:	e8 90 0b 00 00       	call   801043d5 <userinit>
  mpmain();        // finish this processor's setup
80103845:	e8 1a 00 00 00       	call   80103864 <mpmain>

8010384a <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010384a:	55                   	push   %ebp
8010384b:	89 e5                	mov    %esp,%ebp
8010384d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103850:	e8 09 44 00 00       	call   80107c5e <switchkvm>
  seginit();
80103855:	e8 c9 3d 00 00       	call   80107623 <seginit>
  lapicinit();
8010385a:	e8 39 f5 ff ff       	call   80102d98 <lapicinit>
  mpmain();
8010385f:	e8 00 00 00 00       	call   80103864 <mpmain>

80103864 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103864:	55                   	push   %ebp
80103865:	89 e5                	mov    %esp,%ebp
80103867:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpunum());
8010386a:	e8 82 f6 ff ff       	call   80102ef1 <cpunum>
8010386f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103873:	c7 04 24 07 87 10 80 	movl   $0x80108707,(%esp)
8010387a:	e8 42 cb ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
8010387f:	e8 51 2e 00 00       	call   801066d5 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103884:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010388a:	05 a8 00 00 00       	add    $0xa8,%eax
8010388f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103896:	00 
80103897:	89 04 24             	mov    %eax,(%esp)
8010389a:	e8 ed fe ff ff       	call   8010378c <xchg>
  scheduler();     // start running processes
8010389f:	e8 b6 10 00 00       	call   8010495a <scheduler>

801038a4 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038a4:	55                   	push   %ebp
801038a5:	89 e5                	mov    %esp,%ebp
801038a7:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801038aa:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038b1:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038b6:	89 44 24 08          	mov    %eax,0x8(%esp)
801038ba:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038c1:	80 
801038c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c5:	89 04 24             	mov    %eax,(%esp)
801038c8:	e8 42 19 00 00       	call   8010520f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038cd:	c7 45 f4 20 38 11 80 	movl   $0x80113820,-0xc(%ebp)
801038d4:	e9 90 00 00 00       	jmp    80103969 <startothers+0xc5>
    if(c == cpus+cpunum())  // We've started already.
801038d9:	e8 13 f6 ff ff       	call   80102ef1 <cpunum>
801038de:	89 c2                	mov    %eax,%edx
801038e0:	89 d0                	mov    %edx,%eax
801038e2:	c1 e0 02             	shl    $0x2,%eax
801038e5:	01 d0                	add    %edx,%eax
801038e7:	01 c0                	add    %eax,%eax
801038e9:	01 d0                	add    %edx,%eax
801038eb:	89 c1                	mov    %eax,%ecx
801038ed:	c1 e1 04             	shl    $0x4,%ecx
801038f0:	01 c8                	add    %ecx,%eax
801038f2:	01 d0                	add    %edx,%eax
801038f4:	05 20 38 11 80       	add    $0x80113820,%eax
801038f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038fc:	75 02                	jne    80103900 <startothers+0x5c>
      continue;
801038fe:	eb 62                	jmp    80103962 <startothers+0xbe>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103900:	e8 5e f2 ff ff       	call   80102b63 <kalloc>
80103905:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	83 e8 04             	sub    $0x4,%eax
8010390e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103911:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103917:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391c:	83 e8 08             	sub    $0x8,%eax
8010391f:	c7 00 4a 38 10 80    	movl   $0x8010384a,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103928:	8d 50 f4             	lea    -0xc(%eax),%edx
8010392b:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
80103930:	05 00 00 00 80       	add    $0x80000000,%eax
80103935:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010393a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103943:	8a 00                	mov    (%eax),%al
80103945:	0f b6 c0             	movzbl %al,%eax
80103948:	89 54 24 04          	mov    %edx,0x4(%esp)
8010394c:	89 04 24             	mov    %eax,(%esp)
8010394f:	e8 6f f6 ff ff       	call   80102fc3 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103954:	90                   	nop
80103955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103958:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010395e:	85 c0                	test   %eax,%eax
80103960:	74 f3                	je     80103955 <startothers+0xb1>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103962:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103969:	a1 00 3e 11 80       	mov    0x80113e00,%eax
8010396e:	89 c2                	mov    %eax,%edx
80103970:	89 d0                	mov    %edx,%eax
80103972:	c1 e0 02             	shl    $0x2,%eax
80103975:	01 d0                	add    %edx,%eax
80103977:	01 c0                	add    %eax,%eax
80103979:	01 d0                	add    %edx,%eax
8010397b:	89 c1                	mov    %eax,%ecx
8010397d:	c1 e1 04             	shl    $0x4,%ecx
80103980:	01 c8                	add    %ecx,%eax
80103982:	01 d0                	add    %edx,%eax
80103984:	05 20 38 11 80       	add    $0x80113820,%eax
80103989:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010398c:	0f 87 47 ff ff ff    	ja     801038d9 <startothers+0x35>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103992:	c9                   	leave  
80103993:	c3                   	ret    

80103994 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103994:	55                   	push   %ebp
80103995:	89 e5                	mov    %esp,%ebp
80103997:	83 ec 14             	sub    $0x14,%esp
8010399a:	8b 45 08             	mov    0x8(%ebp),%eax
8010399d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039a4:	89 c2                	mov    %eax,%edx
801039a6:	ec                   	in     (%dx),%al
801039a7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039aa:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801039ad:	c9                   	leave  
801039ae:	c3                   	ret    

801039af <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039af:	55                   	push   %ebp
801039b0:	89 e5                	mov    %esp,%ebp
801039b2:	83 ec 08             	sub    $0x8,%esp
801039b5:	8b 45 08             	mov    0x8(%ebp),%eax
801039b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801039bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801039bf:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039c2:	8a 45 f8             	mov    -0x8(%ebp),%al
801039c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039c8:	ee                   	out    %al,(%dx)
}
801039c9:	c9                   	leave  
801039ca:	c3                   	ret    

801039cb <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
801039cb:	55                   	push   %ebp
801039cc:	89 e5                	mov    %esp,%ebp
801039ce:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
801039d1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039df:	eb 13                	jmp    801039f4 <sum+0x29>
    sum += addr[i];
801039e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039e4:	8b 45 08             	mov    0x8(%ebp),%eax
801039e7:	01 d0                	add    %edx,%eax
801039e9:	8a 00                	mov    (%eax),%al
801039eb:	0f b6 c0             	movzbl %al,%eax
801039ee:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801039f1:	ff 45 fc             	incl   -0x4(%ebp)
801039f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039fa:	7c e5                	jl     801039e1 <sum+0x16>
    sum += addr[i];
  return sum;
801039fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039ff:	c9                   	leave  
80103a00:	c3                   	ret    

80103a01 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a01:	55                   	push   %ebp
80103a02:	89 e5                	mov    %esp,%ebp
80103a04:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a07:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0a:	05 00 00 00 80       	add    $0x80000000,%eax
80103a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a18:	01 d0                	add    %edx,%eax
80103a1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a23:	eb 3f                	jmp    80103a64 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a25:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a2c:	00 
80103a2d:	c7 44 24 04 18 87 10 	movl   $0x80108718,0x4(%esp)
80103a34:	80 
80103a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a38:	89 04 24             	mov    %eax,(%esp)
80103a3b:	e8 7d 17 00 00       	call   801051bd <memcmp>
80103a40:	85 c0                	test   %eax,%eax
80103a42:	75 1c                	jne    80103a60 <mpsearch1+0x5f>
80103a44:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a4b:	00 
80103a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4f:	89 04 24             	mov    %eax,(%esp)
80103a52:	e8 74 ff ff ff       	call   801039cb <sum>
80103a57:	84 c0                	test   %al,%al
80103a59:	75 05                	jne    80103a60 <mpsearch1+0x5f>
      return (struct mp*)p;
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	eb 11                	jmp    80103a71 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a60:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a67:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a6a:	72 b9                	jb     80103a25 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a71:	c9                   	leave  
80103a72:	c3                   	ret    

80103a73 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a73:	55                   	push   %ebp
80103a74:	89 e5                	mov    %esp,%ebp
80103a76:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a79:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a83:	83 c0 0f             	add    $0xf,%eax
80103a86:	8a 00                	mov    (%eax),%al
80103a88:	0f b6 c0             	movzbl %al,%eax
80103a8b:	c1 e0 08             	shl    $0x8,%eax
80103a8e:	89 c2                	mov    %eax,%edx
80103a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a93:	83 c0 0e             	add    $0xe,%eax
80103a96:	8a 00                	mov    (%eax),%al
80103a98:	0f b6 c0             	movzbl %al,%eax
80103a9b:	09 d0                	or     %edx,%eax
80103a9d:	c1 e0 04             	shl    $0x4,%eax
80103aa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103aa3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103aa7:	74 21                	je     80103aca <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103aa9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ab0:	00 
80103ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab4:	89 04 24             	mov    %eax,(%esp)
80103ab7:	e8 45 ff ff ff       	call   80103a01 <mpsearch1>
80103abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103abf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ac3:	74 4e                	je     80103b13 <mpsearch+0xa0>
      return mp;
80103ac5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ac8:	eb 5d                	jmp    80103b27 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acd:	83 c0 14             	add    $0x14,%eax
80103ad0:	8a 00                	mov    (%eax),%al
80103ad2:	0f b6 c0             	movzbl %al,%eax
80103ad5:	c1 e0 08             	shl    $0x8,%eax
80103ad8:	89 c2                	mov    %eax,%edx
80103ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103add:	83 c0 13             	add    $0x13,%eax
80103ae0:	8a 00                	mov    (%eax),%al
80103ae2:	0f b6 c0             	movzbl %al,%eax
80103ae5:	09 d0                	or     %edx,%eax
80103ae7:	c1 e0 0a             	shl    $0xa,%eax
80103aea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af0:	2d 00 04 00 00       	sub    $0x400,%eax
80103af5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103afc:	00 
80103afd:	89 04 24             	mov    %eax,(%esp)
80103b00:	e8 fc fe ff ff       	call   80103a01 <mpsearch1>
80103b05:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b08:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b0c:	74 05                	je     80103b13 <mpsearch+0xa0>
      return mp;
80103b0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b11:	eb 14                	jmp    80103b27 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b13:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b1a:	00 
80103b1b:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b22:	e8 da fe ff ff       	call   80103a01 <mpsearch1>
}
80103b27:	c9                   	leave  
80103b28:	c3                   	ret    

80103b29 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b29:	55                   	push   %ebp
80103b2a:	89 e5                	mov    %esp,%ebp
80103b2c:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b2f:	e8 3f ff ff ff       	call   80103a73 <mpsearch>
80103b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b3b:	74 0a                	je     80103b47 <mpconfig+0x1e>
80103b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b40:	8b 40 04             	mov    0x4(%eax),%eax
80103b43:	85 c0                	test   %eax,%eax
80103b45:	75 07                	jne    80103b4e <mpconfig+0x25>
    return 0;
80103b47:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4c:	eb 7d                	jmp    80103bcb <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b51:	8b 40 04             	mov    0x4(%eax),%eax
80103b54:	05 00 00 00 80       	add    $0x80000000,%eax
80103b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b5c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b63:	00 
80103b64:	c7 44 24 04 1d 87 10 	movl   $0x8010871d,0x4(%esp)
80103b6b:	80 
80103b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6f:	89 04 24             	mov    %eax,(%esp)
80103b72:	e8 46 16 00 00       	call   801051bd <memcmp>
80103b77:	85 c0                	test   %eax,%eax
80103b79:	74 07                	je     80103b82 <mpconfig+0x59>
    return 0;
80103b7b:	b8 00 00 00 00       	mov    $0x0,%eax
80103b80:	eb 49                	jmp    80103bcb <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b85:	8a 40 06             	mov    0x6(%eax),%al
80103b88:	3c 01                	cmp    $0x1,%al
80103b8a:	74 11                	je     80103b9d <mpconfig+0x74>
80103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8f:	8a 40 06             	mov    0x6(%eax),%al
80103b92:	3c 04                	cmp    $0x4,%al
80103b94:	74 07                	je     80103b9d <mpconfig+0x74>
    return 0;
80103b96:	b8 00 00 00 00       	mov    $0x0,%eax
80103b9b:	eb 2e                	jmp    80103bcb <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba0:	8b 40 04             	mov    0x4(%eax),%eax
80103ba3:	0f b7 c0             	movzwl %ax,%eax
80103ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
80103baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bad:	89 04 24             	mov    %eax,(%esp)
80103bb0:	e8 16 fe ff ff       	call   801039cb <sum>
80103bb5:	84 c0                	test   %al,%al
80103bb7:	74 07                	je     80103bc0 <mpconfig+0x97>
    return 0;
80103bb9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bbe:	eb 0b                	jmp    80103bcb <mpconfig+0xa2>
  *pmp = mp;
80103bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bc6:	89 10                	mov    %edx,(%eax)
  return conf;
80103bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bcb:	c9                   	leave  
80103bcc:	c3                   	ret    

80103bcd <mpinit>:

void
mpinit(void)
{
80103bcd:	55                   	push   %ebp
80103bce:	89 e5                	mov    %esp,%ebp
80103bd0:	53                   	push   %ebx
80103bd1:	83 ec 34             	sub    $0x34,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103bd4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bd7:	89 04 24             	mov    %eax,(%esp)
80103bda:	e8 4a ff ff ff       	call   80103b29 <mpconfig>
80103bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103be2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103be6:	75 05                	jne    80103bed <mpinit+0x20>
    return;
80103be8:	e9 2c 01 00 00       	jmp    80103d19 <mpinit+0x14c>
  ismp = 1;
80103bed:	c7 05 04 38 11 80 01 	movl   $0x1,0x80113804
80103bf4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfa:	8b 40 24             	mov    0x24(%eax),%eax
80103bfd:	a3 1c 37 11 80       	mov    %eax,0x8011371c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c05:	83 c0 2c             	add    $0x2c,%eax
80103c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0e:	8b 40 04             	mov    0x4(%eax),%eax
80103c11:	0f b7 d0             	movzwl %ax,%edx
80103c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c17:	01 d0                	add    %edx,%eax
80103c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1c:	e9 86 00 00 00       	jmp    80103ca7 <mpinit+0xda>
    switch(*p){
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8a 00                	mov    (%eax),%al
80103c26:	0f b6 c0             	movzbl %al,%eax
80103c29:	83 f8 04             	cmp    $0x4,%eax
80103c2c:	77 6e                	ja     80103c9c <mpinit+0xcf>
80103c2e:	8b 04 85 24 87 10 80 	mov    -0x7fef78dc(,%eax,4),%eax
80103c35:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu < NCPU) {
80103c3d:	a1 00 3e 11 80       	mov    0x80113e00,%eax
80103c42:	83 f8 07             	cmp    $0x7,%eax
80103c45:	7f 32                	jg     80103c79 <mpinit+0xac>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103c47:	8b 15 00 3e 11 80    	mov    0x80113e00,%edx
80103c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c50:	8a 48 01             	mov    0x1(%eax),%cl
80103c53:	89 d0                	mov    %edx,%eax
80103c55:	c1 e0 02             	shl    $0x2,%eax
80103c58:	01 d0                	add    %edx,%eax
80103c5a:	01 c0                	add    %eax,%eax
80103c5c:	01 d0                	add    %edx,%eax
80103c5e:	89 c3                	mov    %eax,%ebx
80103c60:	c1 e3 04             	shl    $0x4,%ebx
80103c63:	01 d8                	add    %ebx,%eax
80103c65:	01 d0                	add    %edx,%eax
80103c67:	05 20 38 11 80       	add    $0x80113820,%eax
80103c6c:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103c6e:	a1 00 3e 11 80       	mov    0x80113e00,%eax
80103c73:	40                   	inc    %eax
80103c74:	a3 00 3e 11 80       	mov    %eax,0x80113e00
      }
      p += sizeof(struct mpproc);
80103c79:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c7d:	eb 28                	jmp    80103ca7 <mpinit+0xda>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c88:	8a 40 01             	mov    0x1(%eax),%al
80103c8b:	a2 00 38 11 80       	mov    %al,0x80113800
      p += sizeof(struct mpioapic);
80103c90:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c94:	eb 11                	jmp    80103ca7 <mpinit+0xda>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c96:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c9a:	eb 0b                	jmp    80103ca7 <mpinit+0xda>
    default:
      ismp = 0;
80103c9c:	c7 05 04 38 11 80 00 	movl   $0x0,0x80113804
80103ca3:	00 00 00 
      break;
80103ca6:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103caa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cad:	0f 82 6e ff ff ff    	jb     80103c21 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp){
80103cb3:	a1 04 38 11 80       	mov    0x80113804,%eax
80103cb8:	85 c0                	test   %eax,%eax
80103cba:	75 1d                	jne    80103cd9 <mpinit+0x10c>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cbc:	c7 05 00 3e 11 80 01 	movl   $0x1,0x80113e00
80103cc3:	00 00 00 
    lapic = 0;
80103cc6:	c7 05 1c 37 11 80 00 	movl   $0x0,0x8011371c
80103ccd:	00 00 00 
    ioapicid = 0;
80103cd0:	c6 05 00 38 11 80 00 	movb   $0x0,0x80113800
    return;
80103cd7:	eb 40                	jmp    80103d19 <mpinit+0x14c>
  }

  if(mp->imcrp){
80103cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cdc:	8a 40 0c             	mov    0xc(%eax),%al
80103cdf:	84 c0                	test   %al,%al
80103ce1:	74 36                	je     80103d19 <mpinit+0x14c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ce3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103cea:	00 
80103ceb:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103cf2:	e8 b8 fc ff ff       	call   801039af <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103cf7:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103cfe:	e8 91 fc ff ff       	call   80103994 <inb>
80103d03:	83 c8 01             	or     $0x1,%eax
80103d06:	0f b6 c0             	movzbl %al,%eax
80103d09:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d0d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d14:	e8 96 fc ff ff       	call   801039af <outb>
  }
}
80103d19:	83 c4 34             	add    $0x34,%esp
80103d1c:	5b                   	pop    %ebx
80103d1d:	5d                   	pop    %ebp
80103d1e:	c3                   	ret    
	...

80103d20 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	83 ec 08             	sub    $0x8,%esp
80103d26:	8b 45 08             	mov    0x8(%ebp),%eax
80103d29:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d30:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d33:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d36:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d39:	ee                   	out    %al,(%dx)
}
80103d3a:	c9                   	leave  
80103d3b:	c3                   	ret    

80103d3c <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d3c:	55                   	push   %ebp
80103d3d:	89 e5                	mov    %esp,%ebp
80103d3f:	83 ec 0c             	sub    $0xc,%esp
80103d42:	8b 45 08             	mov    0x8(%ebp),%eax
80103d45:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d4c:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d55:	0f b6 c0             	movzbl %al,%eax
80103d58:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d5c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d63:	e8 b8 ff ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d6b:	66 c1 e8 08          	shr    $0x8,%ax
80103d6f:	0f b6 c0             	movzbl %al,%eax
80103d72:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d76:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d7d:	e8 9e ff ff ff       	call   80103d20 <outb>
}
80103d82:	c9                   	leave  
80103d83:	c3                   	ret    

80103d84 <picenable>:

void
picenable(int irq)
{
80103d84:	55                   	push   %ebp
80103d85:	89 e5                	mov    %esp,%ebp
80103d87:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8d:	ba 01 00 00 00       	mov    $0x1,%edx
80103d92:	88 c1                	mov    %al,%cl
80103d94:	d3 e2                	shl    %cl,%edx
80103d96:	89 d0                	mov    %edx,%eax
80103d98:	f7 d0                	not    %eax
80103d9a:	89 c2                	mov    %eax,%edx
80103d9c:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103da2:	21 d0                	and    %edx,%eax
80103da4:	0f b7 c0             	movzwl %ax,%eax
80103da7:	89 04 24             	mov    %eax,(%esp)
80103daa:	e8 8d ff ff ff       	call   80103d3c <picsetmask>
}
80103daf:	c9                   	leave  
80103db0:	c3                   	ret    

80103db1 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103db7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dbe:	00 
80103dbf:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103dc6:	e8 55 ff ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, 0xFF);
80103dcb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dd2:	00 
80103dd3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dda:	e8 41 ff ff ff       	call   80103d20 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ddf:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103de6:	00 
80103de7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103dee:	e8 2d ff ff ff       	call   80103d20 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103df3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103dfa:	00 
80103dfb:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e02:	e8 19 ff ff ff       	call   80103d20 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e07:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e0e:	00 
80103e0f:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e16:	e8 05 ff ff ff       	call   80103d20 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e1b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e22:	00 
80103e23:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e2a:	e8 f1 fe ff ff       	call   80103d20 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e2f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e36:	00 
80103e37:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e3e:	e8 dd fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e43:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e4a:	00 
80103e4b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e52:	e8 c9 fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e57:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e5e:	00 
80103e5f:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e66:	e8 b5 fe ff ff       	call   80103d20 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103e6b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e72:	00 
80103e73:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e7a:	e8 a1 fe ff ff       	call   80103d20 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103e7f:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103e86:	00 
80103e87:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e8e:	e8 8d fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103e93:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103e9a:	00 
80103e9b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ea2:	e8 79 fe ff ff       	call   80103d20 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ea7:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103eae:	00 
80103eaf:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eb6:	e8 65 fe ff ff       	call   80103d20 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103ebb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ec2:	00 
80103ec3:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eca:	e8 51 fe ff ff       	call   80103d20 <outb>

  if(irqmask != 0xFFFF)
80103ecf:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103ed5:	66 83 f8 ff          	cmp    $0xffffffff,%ax
80103ed9:	74 11                	je     80103eec <picinit+0x13b>
    picsetmask(irqmask);
80103edb:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103ee1:	0f b7 c0             	movzwl %ax,%eax
80103ee4:	89 04 24             	mov    %eax,(%esp)
80103ee7:	e8 50 fe ff ff       	call   80103d3c <picsetmask>
}
80103eec:	c9                   	leave  
80103eed:	c3                   	ret    
	...

80103ef0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ef0:	55                   	push   %ebp
80103ef1:	89 e5                	mov    %esp,%ebp
80103ef3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103efd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f09:	8b 10                	mov    (%eax),%edx
80103f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f10:	e8 47 d0 ff ff       	call   80100f5c <filealloc>
80103f15:	8b 55 08             	mov    0x8(%ebp),%edx
80103f18:	89 02                	mov    %eax,(%edx)
80103f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1d:	8b 00                	mov    (%eax),%eax
80103f1f:	85 c0                	test   %eax,%eax
80103f21:	0f 84 c8 00 00 00    	je     80103fef <pipealloc+0xff>
80103f27:	e8 30 d0 ff ff       	call   80100f5c <filealloc>
80103f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f2f:	89 02                	mov    %eax,(%edx)
80103f31:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f34:	8b 00                	mov    (%eax),%eax
80103f36:	85 c0                	test   %eax,%eax
80103f38:	0f 84 b1 00 00 00    	je     80103fef <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f3e:	e8 20 ec ff ff       	call   80102b63 <kalloc>
80103f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f4a:	75 05                	jne    80103f51 <pipealloc+0x61>
    goto bad;
80103f4c:	e9 9e 00 00 00       	jmp    80103fef <pipealloc+0xff>
  p->readopen = 1;
80103f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f54:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f5b:	00 00 00 
  p->writeopen = 1;
80103f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f61:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f68:	00 00 00 
  p->nwrite = 0;
80103f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f75:	00 00 00 
  p->nread = 0;
80103f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f82:	00 00 00 
  initlock(&p->lock, "pipe");
80103f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f88:	c7 44 24 04 38 87 10 	movl   $0x80108738,0x4(%esp)
80103f8f:	80 
80103f90:	89 04 24             	mov    %eax,(%esp)
80103f93:	e8 2a 0f 00 00       	call   80104ec2 <initlock>
  (*f0)->type = FD_PIPE;
80103f98:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9b:	8b 00                	mov    (%eax),%eax
80103f9d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa6:	8b 00                	mov    (%eax),%eax
80103fa8:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fac:	8b 45 08             	mov    0x8(%ebp),%eax
80103faf:	8b 00                	mov    (%eax),%eax
80103fb1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb8:	8b 00                	mov    (%eax),%eax
80103fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fbd:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc3:	8b 00                	mov    (%eax),%eax
80103fc5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fce:	8b 00                	mov    (%eax),%eax
80103fd0:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd7:	8b 00                	mov    (%eax),%eax
80103fd9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe0:	8b 00                	mov    (%eax),%eax
80103fe2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fe5:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103fe8:	b8 00 00 00 00       	mov    $0x0,%eax
80103fed:	eb 42                	jmp    80104031 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103fef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ff3:	74 0b                	je     80104000 <pipealloc+0x110>
    kfree((char*)p);
80103ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff8:	89 04 24             	mov    %eax,(%esp)
80103ffb:	e8 cd ea ff ff       	call   80102acd <kfree>
  if(*f0)
80104000:	8b 45 08             	mov    0x8(%ebp),%eax
80104003:	8b 00                	mov    (%eax),%eax
80104005:	85 c0                	test   %eax,%eax
80104007:	74 0d                	je     80104016 <pipealloc+0x126>
    fileclose(*f0);
80104009:	8b 45 08             	mov    0x8(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	89 04 24             	mov    %eax,(%esp)
80104011:	e8 ee cf ff ff       	call   80101004 <fileclose>
  if(*f1)
80104016:	8b 45 0c             	mov    0xc(%ebp),%eax
80104019:	8b 00                	mov    (%eax),%eax
8010401b:	85 c0                	test   %eax,%eax
8010401d:	74 0d                	je     8010402c <pipealloc+0x13c>
    fileclose(*f1);
8010401f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104022:	8b 00                	mov    (%eax),%eax
80104024:	89 04 24             	mov    %eax,(%esp)
80104027:	e8 d8 cf ff ff       	call   80101004 <fileclose>
  return -1;
8010402c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104031:	c9                   	leave  
80104032:	c3                   	ret    

80104033 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104033:	55                   	push   %ebp
80104034:	89 e5                	mov    %esp,%ebp
80104036:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104039:	8b 45 08             	mov    0x8(%ebp),%eax
8010403c:	89 04 24             	mov    %eax,(%esp)
8010403f:	e8 9f 0e 00 00       	call   80104ee3 <acquire>
  if(writable){
80104044:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104048:	74 1f                	je     80104069 <pipeclose+0x36>
    p->writeopen = 0;
8010404a:	8b 45 08             	mov    0x8(%ebp),%eax
8010404d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104054:	00 00 00 
    wakeup(&p->nread);
80104057:	8b 45 08             	mov    0x8(%ebp),%eax
8010405a:	05 34 02 00 00       	add    $0x234,%eax
8010405f:	89 04 24             	mov    %eax,(%esp)
80104062:	e8 84 0b 00 00       	call   80104beb <wakeup>
80104067:	eb 1d                	jmp    80104086 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104073:	00 00 00 
    wakeup(&p->nwrite);
80104076:	8b 45 08             	mov    0x8(%ebp),%eax
80104079:	05 38 02 00 00       	add    $0x238,%eax
8010407e:	89 04 24             	mov    %eax,(%esp)
80104081:	e8 65 0b 00 00       	call   80104beb <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104086:	8b 45 08             	mov    0x8(%ebp),%eax
80104089:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010408f:	85 c0                	test   %eax,%eax
80104091:	75 25                	jne    801040b8 <pipeclose+0x85>
80104093:	8b 45 08             	mov    0x8(%ebp),%eax
80104096:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010409c:	85 c0                	test   %eax,%eax
8010409e:	75 18                	jne    801040b8 <pipeclose+0x85>
    release(&p->lock);
801040a0:	8b 45 08             	mov    0x8(%ebp),%eax
801040a3:	89 04 24             	mov    %eax,(%esp)
801040a6:	e8 9f 0e 00 00       	call   80104f4a <release>
    kfree((char*)p);
801040ab:	8b 45 08             	mov    0x8(%ebp),%eax
801040ae:	89 04 24             	mov    %eax,(%esp)
801040b1:	e8 17 ea ff ff       	call   80102acd <kfree>
801040b6:	eb 0b                	jmp    801040c3 <pipeclose+0x90>
  } else
    release(&p->lock);
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	89 04 24             	mov    %eax,(%esp)
801040be:	e8 87 0e 00 00       	call   80104f4a <release>
}
801040c3:	c9                   	leave  
801040c4:	c3                   	ret    

801040c5 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040c5:	55                   	push   %ebp
801040c6:	89 e5                	mov    %esp,%ebp
801040c8:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040cb:	8b 45 08             	mov    0x8(%ebp),%eax
801040ce:	89 04 24             	mov    %eax,(%esp)
801040d1:	e8 0d 0e 00 00       	call   80104ee3 <acquire>
  for(i = 0; i < n; i++){
801040d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040dd:	e9 a4 00 00 00       	jmp    80104186 <pipewrite+0xc1>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040e2:	eb 57                	jmp    8010413b <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801040e4:	8b 45 08             	mov    0x8(%ebp),%eax
801040e7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040ed:	85 c0                	test   %eax,%eax
801040ef:	74 0d                	je     801040fe <pipewrite+0x39>
801040f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040f7:	8b 40 24             	mov    0x24(%eax),%eax
801040fa:	85 c0                	test   %eax,%eax
801040fc:	74 15                	je     80104113 <pipewrite+0x4e>
        release(&p->lock);
801040fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104101:	89 04 24             	mov    %eax,(%esp)
80104104:	e8 41 0e 00 00       	call   80104f4a <release>
        return -1;
80104109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410e:	e9 9d 00 00 00       	jmp    801041b0 <pipewrite+0xeb>
      }
      wakeup(&p->nread);
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	05 34 02 00 00       	add    $0x234,%eax
8010411b:	89 04 24             	mov    %eax,(%esp)
8010411e:	e8 c8 0a 00 00       	call   80104beb <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104123:	8b 45 08             	mov    0x8(%ebp),%eax
80104126:	8b 55 08             	mov    0x8(%ebp),%edx
80104129:	81 c2 38 02 00 00    	add    $0x238,%edx
8010412f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104133:	89 14 24             	mov    %edx,(%esp)
80104136:	e8 d7 09 00 00       	call   80104b12 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010414d:	05 00 02 00 00       	add    $0x200,%eax
80104152:	39 c2                	cmp    %eax,%edx
80104154:	74 8e                	je     801040e4 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010415f:	8d 48 01             	lea    0x1(%eax),%ecx
80104162:	8b 55 08             	mov    0x8(%ebp),%edx
80104165:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010416b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104170:	89 c1                	mov    %eax,%ecx
80104172:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104175:	8b 45 0c             	mov    0xc(%ebp),%eax
80104178:	01 d0                	add    %edx,%eax
8010417a:	8a 10                	mov    (%eax),%dl
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104183:	ff 45 f4             	incl   -0xc(%ebp)
80104186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104189:	3b 45 10             	cmp    0x10(%ebp),%eax
8010418c:	0f 8c 50 ff ff ff    	jl     801040e2 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104192:	8b 45 08             	mov    0x8(%ebp),%eax
80104195:	05 34 02 00 00       	add    $0x234,%eax
8010419a:	89 04 24             	mov    %eax,(%esp)
8010419d:	e8 49 0a 00 00       	call   80104beb <wakeup>
  release(&p->lock);
801041a2:	8b 45 08             	mov    0x8(%ebp),%eax
801041a5:	89 04 24             	mov    %eax,(%esp)
801041a8:	e8 9d 0d 00 00       	call   80104f4a <release>
  return n;
801041ad:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041b0:	c9                   	leave  
801041b1:	c3                   	ret    

801041b2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041b2:	55                   	push   %ebp
801041b3:	89 e5                	mov    %esp,%ebp
801041b5:	53                   	push   %ebx
801041b6:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041b9:	8b 45 08             	mov    0x8(%ebp),%eax
801041bc:	89 04 24             	mov    %eax,(%esp)
801041bf:	e8 1f 0d 00 00       	call   80104ee3 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041c4:	eb 3a                	jmp    80104200 <piperead+0x4e>
    if(proc->killed){
801041c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041cc:	8b 40 24             	mov    0x24(%eax),%eax
801041cf:	85 c0                	test   %eax,%eax
801041d1:	74 15                	je     801041e8 <piperead+0x36>
      release(&p->lock);
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	89 04 24             	mov    %eax,(%esp)
801041d9:	e8 6c 0d 00 00       	call   80104f4a <release>
      return -1;
801041de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e3:	e9 b3 00 00 00       	jmp    8010429b <piperead+0xe9>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801041e8:	8b 45 08             	mov    0x8(%ebp),%eax
801041eb:	8b 55 08             	mov    0x8(%ebp),%edx
801041ee:	81 c2 34 02 00 00    	add    $0x234,%edx
801041f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801041f8:	89 14 24             	mov    %edx,(%esp)
801041fb:	e8 12 09 00 00       	call   80104b12 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104209:	8b 45 08             	mov    0x8(%ebp),%eax
8010420c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104212:	39 c2                	cmp    %eax,%edx
80104214:	75 0d                	jne    80104223 <piperead+0x71>
80104216:	8b 45 08             	mov    0x8(%ebp),%eax
80104219:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010421f:	85 c0                	test   %eax,%eax
80104221:	75 a3                	jne    801041c6 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104223:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010422a:	eb 49                	jmp    80104275 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104235:	8b 45 08             	mov    0x8(%ebp),%eax
80104238:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010423e:	39 c2                	cmp    %eax,%edx
80104240:	75 02                	jne    80104244 <piperead+0x92>
      break;
80104242:	eb 39                	jmp    8010427d <piperead+0xcb>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104244:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104247:	8b 45 0c             	mov    0xc(%ebp),%eax
8010424a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010424d:	8b 45 08             	mov    0x8(%ebp),%eax
80104250:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104256:	8d 48 01             	lea    0x1(%eax),%ecx
80104259:	8b 55 08             	mov    0x8(%ebp),%edx
8010425c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104262:	25 ff 01 00 00       	and    $0x1ff,%eax
80104267:	89 c2                	mov    %eax,%edx
80104269:	8b 45 08             	mov    0x8(%ebp),%eax
8010426c:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104270:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104272:	ff 45 f4             	incl   -0xc(%ebp)
80104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104278:	3b 45 10             	cmp    0x10(%ebp),%eax
8010427b:	7c af                	jl     8010422c <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010427d:	8b 45 08             	mov    0x8(%ebp),%eax
80104280:	05 38 02 00 00       	add    $0x238,%eax
80104285:	89 04 24             	mov    %eax,(%esp)
80104288:	e8 5e 09 00 00       	call   80104beb <wakeup>
  release(&p->lock);
8010428d:	8b 45 08             	mov    0x8(%ebp),%eax
80104290:	89 04 24             	mov    %eax,(%esp)
80104293:	e8 b2 0c 00 00       	call   80104f4a <release>
  return i;
80104298:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010429b:	83 c4 24             	add    $0x24,%esp
8010429e:	5b                   	pop    %ebx
8010429f:	5d                   	pop    %ebp
801042a0:	c3                   	ret    
801042a1:	00 00                	add    %al,(%eax)
	...

801042a4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042a4:	55                   	push   %ebp
801042a5:	89 e5                	mov    %esp,%ebp
801042a7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042aa:	9c                   	pushf  
801042ab:	58                   	pop    %eax
801042ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042b2:	c9                   	leave  
801042b3:	c3                   	ret    

801042b4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042b4:	55                   	push   %ebp
801042b5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042b7:	fb                   	sti    
}
801042b8:	5d                   	pop    %ebp
801042b9:	c3                   	ret    

801042ba <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801042ba:	55                   	push   %ebp
801042bb:	89 e5                	mov    %esp,%ebp
801042bd:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801042c0:	c7 44 24 04 3d 87 10 	movl   $0x8010873d,0x4(%esp)
801042c7:	80 
801042c8:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801042cf:	e8 ee 0b 00 00       	call   80104ec2 <initlock>
}
801042d4:	c9                   	leave  
801042d5:	c3                   	ret    

801042d6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801042d6:	55                   	push   %ebp
801042d7:	89 e5                	mov    %esp,%ebp
801042d9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801042dc:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801042e3:	e8 fb 0b 00 00       	call   80104ee3 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042e8:	c7 45 f4 54 3e 11 80 	movl   $0x80113e54,-0xc(%ebp)
801042ef:	eb 50                	jmp    80104341 <allocproc+0x6b>
    if(p->state == UNUSED)
801042f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f4:	8b 40 0c             	mov    0xc(%eax),%eax
801042f7:	85 c0                	test   %eax,%eax
801042f9:	75 42                	jne    8010433d <allocproc+0x67>
      goto found;
801042fb:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801042fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ff:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104306:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010430b:	8d 50 01             	lea    0x1(%eax),%edx
8010430e:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104314:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104317:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010431a:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104321:	e8 24 0c 00 00       	call   80104f4a <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104326:	e8 38 e8 ff ff       	call   80102b63 <kalloc>
8010432b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010432e:	89 42 08             	mov    %eax,0x8(%edx)
80104331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104334:	8b 40 08             	mov    0x8(%eax),%eax
80104337:	85 c0                	test   %eax,%eax
80104339:	75 33                	jne    8010436e <allocproc+0x98>
8010433b:	eb 20                	jmp    8010435d <allocproc+0x87>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010433d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104341:	81 7d f4 54 5d 11 80 	cmpl   $0x80115d54,-0xc(%ebp)
80104348:	72 a7                	jb     801042f1 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010434a:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104351:	e8 f4 0b 00 00       	call   80104f4a <release>
  return 0;
80104356:	b8 00 00 00 00       	mov    $0x0,%eax
8010435b:	eb 76                	jmp    801043d3 <allocproc+0xfd>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104360:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104367:	b8 00 00 00 00       	mov    $0x0,%eax
8010436c:	eb 65                	jmp    801043d3 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
8010436e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104371:	8b 40 08             	mov    0x8(%eax),%eax
80104374:	05 00 10 00 00       	add    $0x1000,%eax
80104379:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010437c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104383:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104386:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104389:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010438d:	ba 34 65 10 80       	mov    $0x80106534,%edx
80104392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104395:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104397:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010439b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043a1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a7:	8b 40 1c             	mov    0x1c(%eax),%eax
801043aa:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801043b1:	00 
801043b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043b9:	00 
801043ba:	89 04 24             	mov    %eax,(%esp)
801043bd:	e8 84 0d 00 00       	call   80105146 <memset>
  p->context->eip = (uint)forkret;
801043c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c5:	8b 40 1c             	mov    0x1c(%eax),%eax
801043c8:	ba d3 4a 10 80       	mov    $0x80104ad3,%edx
801043cd:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801043d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043d3:	c9                   	leave  
801043d4:	c3                   	ret    

801043d5 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801043d5:	55                   	push   %ebp
801043d6:	89 e5                	mov    %esp,%ebp
801043d8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801043db:	e8 f6 fe ff ff       	call   801042d6 <allocproc>
801043e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	a3 44 b6 10 80       	mov    %eax,0x8010b644
  if((p->pgdir = setupkvm()) == 0)
801043eb:	e8 bc 37 00 00       	call   80107bac <setupkvm>
801043f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f3:	89 42 04             	mov    %eax,0x4(%edx)
801043f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f9:	8b 40 04             	mov    0x4(%eax),%eax
801043fc:	85 c0                	test   %eax,%eax
801043fe:	75 0c                	jne    8010440c <userinit+0x37>
    panic("userinit: out of memory?");
80104400:	c7 04 24 44 87 10 80 	movl   $0x80108744,(%esp)
80104407:	e8 48 c1 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010440c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104414:	8b 40 04             	mov    0x4(%eax),%eax
80104417:	89 54 24 08          	mov    %edx,0x8(%esp)
8010441b:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104422:	80 
80104423:	89 04 24             	mov    %eax,(%esp)
80104426:	e8 b1 39 00 00       	call   80107ddc <inituvm>
  p->sz = PGSIZE;
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104437:	8b 40 18             	mov    0x18(%eax),%eax
8010443a:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104441:	00 
80104442:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104449:	00 
8010444a:	89 04 24             	mov    %eax,(%esp)
8010444d:	e8 f4 0c 00 00       	call   80105146 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	8b 40 18             	mov    0x18(%eax),%eax
80104458:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010445e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104461:	8b 40 18             	mov    0x18(%eax),%eax
80104464:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 50 18             	mov    0x18(%eax),%edx
80104470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104473:	8b 40 18             	mov    0x18(%eax),%eax
80104476:	8b 40 2c             	mov    0x2c(%eax),%eax
80104479:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
8010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104480:	8b 50 18             	mov    0x18(%eax),%edx
80104483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104486:	8b 40 18             	mov    0x18(%eax),%eax
80104489:	8b 40 2c             	mov    0x2c(%eax),%eax
8010448c:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104493:	8b 40 18             	mov    0x18(%eax),%eax
80104496:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010449d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a0:	8b 40 18             	mov    0x18(%eax),%eax
801044a3:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	8b 40 18             	mov    0x18(%eax),%eax
801044b0:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	83 c0 6c             	add    $0x6c,%eax
801044bd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044c4:	00 
801044c5:	c7 44 24 04 5d 87 10 	movl   $0x8010875d,0x4(%esp)
801044cc:	80 
801044cd:	89 04 24             	mov    %eax,(%esp)
801044d0:	e8 7d 0e 00 00       	call   80105352 <safestrcpy>
  p->cwd = namei("/");
801044d5:	c7 04 24 66 87 10 80 	movl   $0x80108766,(%esp)
801044dc:	e8 50 df ff ff       	call   80102431 <namei>
801044e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e4:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801044e7:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801044ee:	e8 f0 09 00 00       	call   80104ee3 <acquire>

  p->state = RUNNABLE;
801044f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801044fd:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104504:	e8 41 0a 00 00       	call   80104f4a <release>
}
80104509:	c9                   	leave  
8010450a:	c3                   	ret    

8010450b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010450b:	55                   	push   %ebp
8010450c:	89 e5                	mov    %esp,%ebp
8010450e:	83 ec 28             	sub    $0x28,%esp
  uint sz;

  sz = proc->sz;
80104511:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104517:	8b 00                	mov    (%eax),%eax
80104519:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010451c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104520:	7e 34                	jle    80104556 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104522:	8b 55 08             	mov    0x8(%ebp),%edx
80104525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104528:	01 c2                	add    %eax,%edx
8010452a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104530:	8b 40 04             	mov    0x4(%eax),%eax
80104533:	89 54 24 08          	mov    %edx,0x8(%esp)
80104537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010453e:	89 04 24             	mov    %eax,(%esp)
80104541:	e8 01 3a 00 00       	call   80107f47 <allocuvm>
80104546:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104549:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010454d:	75 41                	jne    80104590 <growproc+0x85>
      return -1;
8010454f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104554:	eb 58                	jmp    801045ae <growproc+0xa3>
  } else if(n < 0){
80104556:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010455a:	79 34                	jns    80104590 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010455c:	8b 55 08             	mov    0x8(%ebp),%edx
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	01 c2                	add    %eax,%edx
80104564:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010456a:	8b 40 04             	mov    0x4(%eax),%eax
8010456d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104574:	89 54 24 04          	mov    %edx,0x4(%esp)
80104578:	89 04 24             	mov    %eax,(%esp)
8010457b:	e8 dd 3a 00 00       	call   8010805d <deallocuvm>
80104580:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104583:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104587:	75 07                	jne    80104590 <growproc+0x85>
      return -1;
80104589:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458e:	eb 1e                	jmp    801045ae <growproc+0xa3>
  }
  proc->sz = sz;
80104590:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104596:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104599:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010459b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045a1:	89 04 24             	mov    %eax,(%esp)
801045a4:	e8 cf 36 00 00       	call   80107c78 <switchuvm>
  return 0;
801045a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045ae:	c9                   	leave  
801045af:	c3                   	ret    

801045b0 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045b0:	55                   	push   %ebp
801045b1:	89 e5                	mov    %esp,%ebp
801045b3:	57                   	push   %edi
801045b4:	56                   	push   %esi
801045b5:	53                   	push   %ebx
801045b6:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0){
801045b9:	e8 18 fd ff ff       	call   801042d6 <allocproc>
801045be:	89 45 e0             	mov    %eax,-0x20(%ebp)
801045c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801045c5:	75 0a                	jne    801045d1 <fork+0x21>
    return -1;
801045c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045cc:	e9 51 01 00 00       	jmp    80104722 <fork+0x172>
  }

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801045d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d7:	8b 10                	mov    (%eax),%edx
801045d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045df:	8b 40 04             	mov    0x4(%eax),%eax
801045e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e6:	89 04 24             	mov    %eax,(%esp)
801045e9:	e8 01 3c 00 00       	call   801081ef <copyuvm>
801045ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
801045f1:	89 42 04             	mov    %eax,0x4(%edx)
801045f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045f7:	8b 40 04             	mov    0x4(%eax),%eax
801045fa:	85 c0                	test   %eax,%eax
801045fc:	75 2c                	jne    8010462a <fork+0x7a>
    kfree(np->kstack);
801045fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104601:	8b 40 08             	mov    0x8(%eax),%eax
80104604:	89 04 24             	mov    %eax,(%esp)
80104607:	e8 c1 e4 ff ff       	call   80102acd <kfree>
    np->kstack = 0;
8010460c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010460f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104616:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104619:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104625:	e9 f8 00 00 00       	jmp    80104722 <fork+0x172>
  }
  np->sz = proc->sz;
8010462a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104630:	8b 10                	mov    (%eax),%edx
80104632:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104635:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104637:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010463e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104641:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104644:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104647:	8b 50 18             	mov    0x18(%eax),%edx
8010464a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104650:	8b 40 18             	mov    0x18(%eax),%eax
80104653:	89 c3                	mov    %eax,%ebx
80104655:	b8 13 00 00 00       	mov    $0x13,%eax
8010465a:	89 d7                	mov    %edx,%edi
8010465c:	89 de                	mov    %ebx,%esi
8010465e:	89 c1                	mov    %eax,%ecx
80104660:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104662:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104665:	8b 40 18             	mov    0x18(%eax),%eax
80104668:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010466f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104676:	eb 3c                	jmp    801046b4 <fork+0x104>
    if(proc->ofile[i])
80104678:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010467e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104681:	83 c2 08             	add    $0x8,%edx
80104684:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104688:	85 c0                	test   %eax,%eax
8010468a:	74 25                	je     801046b1 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010468c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104692:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104695:	83 c2 08             	add    $0x8,%edx
80104698:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010469c:	89 04 24             	mov    %eax,(%esp)
8010469f:	e8 18 c9 ff ff       	call   80100fbc <filedup>
801046a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046a7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046aa:	83 c1 08             	add    $0x8,%ecx
801046ad:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046b1:	ff 45 e4             	incl   -0x1c(%ebp)
801046b4:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046b8:	7e be                	jle    80104678 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801046ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c0:	8b 40 68             	mov    0x68(%eax),%eax
801046c3:	89 04 24             	mov    %eax,(%esp)
801046c6:	e8 21 d2 ff ff       	call   801018ec <idup>
801046cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046ce:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801046d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d7:	8d 50 6c             	lea    0x6c(%eax),%edx
801046da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046dd:	83 c0 6c             	add    $0x6c,%eax
801046e0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046e7:	00 
801046e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801046ec:	89 04 24             	mov    %eax,(%esp)
801046ef:	e8 5e 0c 00 00       	call   80105352 <safestrcpy>

  pid = np->pid;
801046f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f7:	8b 40 10             	mov    0x10(%eax),%eax
801046fa:	89 45 dc             	mov    %eax,-0x24(%ebp)

  acquire(&ptable.lock);
801046fd:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104704:	e8 da 07 00 00       	call   80104ee3 <acquire>

  np->state = RUNNABLE;
80104709:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010470c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104713:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
8010471a:	e8 2b 08 00 00       	call   80104f4a <release>

  return pid;
8010471f:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104722:	83 c4 2c             	add    $0x2c,%esp
80104725:	5b                   	pop    %ebx
80104726:	5e                   	pop    %esi
80104727:	5f                   	pop    %edi
80104728:	5d                   	pop    %ebp
80104729:	c3                   	ret    

8010472a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010472a:	55                   	push   %ebp
8010472b:	89 e5                	mov    %esp,%ebp
8010472d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104730:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104737:	a1 44 b6 10 80       	mov    0x8010b644,%eax
8010473c:	39 c2                	cmp    %eax,%edx
8010473e:	75 0c                	jne    8010474c <exit+0x22>
    panic("init exiting");
80104740:	c7 04 24 68 87 10 80 	movl   $0x80108768,(%esp)
80104747:	e8 08 be ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010474c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104753:	eb 43                	jmp    80104798 <exit+0x6e>
    if(proc->ofile[fd]){
80104755:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010475e:	83 c2 08             	add    $0x8,%edx
80104761:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104765:	85 c0                	test   %eax,%eax
80104767:	74 2c                	je     80104795 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104769:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104772:	83 c2 08             	add    $0x8,%edx
80104775:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104779:	89 04 24             	mov    %eax,(%esp)
8010477c:	e8 83 c8 ff ff       	call   80101004 <fileclose>
      proc->ofile[fd] = 0;
80104781:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104787:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010478a:	83 c2 08             	add    $0x8,%edx
8010478d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104794:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104795:	ff 45 f0             	incl   -0x10(%ebp)
80104798:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010479c:	7e b7                	jle    80104755 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010479e:	e8 20 ed ff ff       	call   801034c3 <begin_op>
  iput(proc->cwd);
801047a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a9:	8b 40 68             	mov    0x68(%eax),%eax
801047ac:	89 04 24             	mov    %eax,(%esp)
801047af:	e8 c2 d2 ff ff       	call   80101a76 <iput>
  end_op();
801047b4:	e8 8c ed ff ff       	call   80103545 <end_op>
  proc->cwd = 0;
801047b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047bf:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801047c6:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801047cd:	e8 11 07 00 00       	call   80104ee3 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801047d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d8:	8b 40 14             	mov    0x14(%eax),%eax
801047db:	89 04 24             	mov    %eax,(%esp)
801047de:	e8 ca 03 00 00       	call   80104bad <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047e3:	c7 45 f4 54 3e 11 80 	movl   $0x80113e54,-0xc(%ebp)
801047ea:	eb 38                	jmp    80104824 <exit+0xfa>
    if(p->parent == proc){
801047ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ef:	8b 50 14             	mov    0x14(%eax),%edx
801047f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f8:	39 c2                	cmp    %eax,%edx
801047fa:	75 24                	jne    80104820 <exit+0xf6>
      p->parent = initproc;
801047fc:	8b 15 44 b6 10 80    	mov    0x8010b644,%edx
80104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104805:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480b:	8b 40 0c             	mov    0xc(%eax),%eax
8010480e:	83 f8 05             	cmp    $0x5,%eax
80104811:	75 0d                	jne    80104820 <exit+0xf6>
        wakeup1(initproc);
80104813:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80104818:	89 04 24             	mov    %eax,(%esp)
8010481b:	e8 8d 03 00 00       	call   80104bad <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104820:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104824:	81 7d f4 54 5d 11 80 	cmpl   $0x80115d54,-0xc(%ebp)
8010482b:	72 bf                	jb     801047ec <exit+0xc2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010482d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104833:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010483a:	e8 b0 01 00 00       	call   801049ef <sched>
  panic("zombie exit");
8010483f:	c7 04 24 75 87 10 80 	movl   $0x80108775,(%esp)
80104846:	e8 09 bd ff ff       	call   80100554 <panic>

8010484b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010484b:	55                   	push   %ebp
8010484c:	89 e5                	mov    %esp,%ebp
8010484e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104851:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104858:	e8 86 06 00 00       	call   80104ee3 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010485d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104864:	c7 45 f4 54 3e 11 80 	movl   $0x80113e54,-0xc(%ebp)
8010486b:	e9 9a 00 00 00       	jmp    8010490a <wait+0xbf>
      if(p->parent != proc)
80104870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104873:	8b 50 14             	mov    0x14(%eax),%edx
80104876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487c:	39 c2                	cmp    %eax,%edx
8010487e:	74 05                	je     80104885 <wait+0x3a>
        continue;
80104880:	e9 81 00 00 00       	jmp    80104906 <wait+0xbb>
      havekids = 1;
80104885:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488f:	8b 40 0c             	mov    0xc(%eax),%eax
80104892:	83 f8 05             	cmp    $0x5,%eax
80104895:	75 6f                	jne    80104906 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489a:	8b 40 10             	mov    0x10(%eax),%eax
8010489d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801048a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a3:	8b 40 08             	mov    0x8(%eax),%eax
801048a6:	89 04 24             	mov    %eax,(%esp)
801048a9:	e8 1f e2 ff ff       	call   80102acd <kfree>
        p->kstack = 0;
801048ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bb:	8b 40 04             	mov    0x4(%eax),%eax
801048be:	89 04 24             	mov    %eax,(%esp)
801048c1:	e8 4d 38 00 00       	call   80108113 <freevm>
        p->pid = 0;
801048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801048d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801048da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048dd:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801048e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801048eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ee:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801048f5:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801048fc:	e8 49 06 00 00       	call   80104f4a <release>
        return pid;
80104901:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104904:	eb 52                	jmp    80104958 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104906:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010490a:	81 7d f4 54 5d 11 80 	cmpl   $0x80115d54,-0xc(%ebp)
80104911:	0f 82 59 ff ff ff    	jb     80104870 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104917:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010491b:	74 0d                	je     8010492a <wait+0xdf>
8010491d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104923:	8b 40 24             	mov    0x24(%eax),%eax
80104926:	85 c0                	test   %eax,%eax
80104928:	74 13                	je     8010493d <wait+0xf2>
      release(&ptable.lock);
8010492a:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104931:	e8 14 06 00 00       	call   80104f4a <release>
      return -1;
80104936:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010493b:	eb 1b                	jmp    80104958 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010493d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104943:	c7 44 24 04 20 3e 11 	movl   $0x80113e20,0x4(%esp)
8010494a:	80 
8010494b:	89 04 24             	mov    %eax,(%esp)
8010494e:	e8 bf 01 00 00       	call   80104b12 <sleep>
  }
80104953:	e9 05 ff ff ff       	jmp    8010485d <wait+0x12>
}
80104958:	c9                   	leave  
80104959:	c3                   	ret    

8010495a <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010495a:	55                   	push   %ebp
8010495b:	89 e5                	mov    %esp,%ebp
8010495d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104960:	e8 4f f9 ff ff       	call   801042b4 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104965:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
8010496c:	e8 72 05 00 00       	call   80104ee3 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104971:	c7 45 f4 54 3e 11 80 	movl   $0x80113e54,-0xc(%ebp)
80104978:	eb 5b                	jmp    801049d5 <scheduler+0x7b>
      if(p->state != RUNNABLE)
8010497a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497d:	8b 40 0c             	mov    0xc(%eax),%eax
80104980:	83 f8 03             	cmp    $0x3,%eax
80104983:	74 02                	je     80104987 <scheduler+0x2d>
        continue;
80104985:	eb 4a                	jmp    801049d1 <scheduler+0x77>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104993:	89 04 24             	mov    %eax,(%esp)
80104996:	e8 dd 32 00 00       	call   80107c78 <switchuvm>
      p->state = RUNNING;
8010499b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, p->context);
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	8b 40 1c             	mov    0x1c(%eax),%eax
801049ab:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801049b2:	83 c2 04             	add    $0x4,%edx
801049b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801049b9:	89 14 24             	mov    %edx,(%esp)
801049bc:	e8 ff 09 00 00       	call   801053c0 <swtch>
      switchkvm();
801049c1:	e8 98 32 00 00       	call   80107c5e <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801049c6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801049cd:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d1:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049d5:	81 7d f4 54 5d 11 80 	cmpl   $0x80115d54,-0xc(%ebp)
801049dc:	72 9c                	jb     8010497a <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801049de:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801049e5:	e8 60 05 00 00       	call   80104f4a <release>

  }
801049ea:	e9 71 ff ff ff       	jmp    80104960 <scheduler+0x6>

801049ef <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
801049f5:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
801049fc:	e8 0d 06 00 00       	call   8010500e <holding>
80104a01:	85 c0                	test   %eax,%eax
80104a03:	75 0c                	jne    80104a11 <sched+0x22>
    panic("sched ptable.lock");
80104a05:	c7 04 24 81 87 10 80 	movl   $0x80108781,(%esp)
80104a0c:	e8 43 bb ff ff       	call   80100554 <panic>
  if(cpu->ncli != 1)
80104a11:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a17:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104a1d:	83 f8 01             	cmp    $0x1,%eax
80104a20:	74 0c                	je     80104a2e <sched+0x3f>
    panic("sched locks");
80104a22:	c7 04 24 93 87 10 80 	movl   $0x80108793,(%esp)
80104a29:	e8 26 bb ff ff       	call   80100554 <panic>
  if(proc->state == RUNNING)
80104a2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a34:	8b 40 0c             	mov    0xc(%eax),%eax
80104a37:	83 f8 04             	cmp    $0x4,%eax
80104a3a:	75 0c                	jne    80104a48 <sched+0x59>
    panic("sched running");
80104a3c:	c7 04 24 9f 87 10 80 	movl   $0x8010879f,(%esp)
80104a43:	e8 0c bb ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104a48:	e8 57 f8 ff ff       	call   801042a4 <readeflags>
80104a4d:	25 00 02 00 00       	and    $0x200,%eax
80104a52:	85 c0                	test   %eax,%eax
80104a54:	74 0c                	je     80104a62 <sched+0x73>
    panic("sched interruptible");
80104a56:	c7 04 24 ad 87 10 80 	movl   $0x801087ad,(%esp)
80104a5d:	e8 f2 ba ff ff       	call   80100554 <panic>
  intena = cpu->intena;
80104a62:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a68:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104a71:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a77:	8b 40 04             	mov    0x4(%eax),%eax
80104a7a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a81:	83 c2 1c             	add    $0x1c,%edx
80104a84:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a88:	89 14 24             	mov    %edx,(%esp)
80104a8b:	e8 30 09 00 00       	call   801053c0 <swtch>
  cpu->intena = intena;
80104a90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a99:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104a9f:	c9                   	leave  
80104aa0:	c3                   	ret    

80104aa1 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104aa1:	55                   	push   %ebp
80104aa2:	89 e5                	mov    %esp,%ebp
80104aa4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104aa7:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104aae:	e8 30 04 00 00       	call   80104ee3 <acquire>
  proc->state = RUNNABLE;
80104ab3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ac0:	e8 2a ff ff ff       	call   801049ef <sched>
  release(&ptable.lock);
80104ac5:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104acc:	e8 79 04 00 00       	call   80104f4a <release>
}
80104ad1:	c9                   	leave  
80104ad2:	c3                   	ret    

80104ad3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ad3:	55                   	push   %ebp
80104ad4:	89 e5                	mov    %esp,%ebp
80104ad6:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ad9:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104ae0:	e8 65 04 00 00       	call   80104f4a <release>

  if (first) {
80104ae5:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104aea:	85 c0                	test   %eax,%eax
80104aec:	74 22                	je     80104b10 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104aee:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104af5:	00 00 00 
    iinit(ROOTDEV);
80104af8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104aff:	e8 b3 ca ff ff       	call   801015b7 <iinit>
    initlog(ROOTDEV);
80104b04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b0b:	e8 b4 e7 ff ff       	call   801032c4 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b10:	c9                   	leave  
80104b11:	c3                   	ret    

80104b12 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b12:	55                   	push   %ebp
80104b13:	89 e5                	mov    %esp,%ebp
80104b15:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104b18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1e:	85 c0                	test   %eax,%eax
80104b20:	75 0c                	jne    80104b2e <sleep+0x1c>
    panic("sleep");
80104b22:	c7 04 24 c1 87 10 80 	movl   $0x801087c1,(%esp)
80104b29:	e8 26 ba ff ff       	call   80100554 <panic>

  if(lk == 0)
80104b2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b32:	75 0c                	jne    80104b40 <sleep+0x2e>
    panic("sleep without lk");
80104b34:	c7 04 24 c7 87 10 80 	movl   $0x801087c7,(%esp)
80104b3b:	e8 14 ba ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b40:	81 7d 0c 20 3e 11 80 	cmpl   $0x80113e20,0xc(%ebp)
80104b47:	74 17                	je     80104b60 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b49:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104b50:	e8 8e 03 00 00       	call   80104ee3 <acquire>
    release(lk);
80104b55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b58:	89 04 24             	mov    %eax,(%esp)
80104b5b:	e8 ea 03 00 00       	call   80104f4a <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b66:	8b 55 08             	mov    0x8(%ebp),%edx
80104b69:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104b6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b72:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104b79:	e8 71 fe ff ff       	call   801049ef <sched>

  // Tidy up.
  proc->chan = 0;
80104b7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b84:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b8b:	81 7d 0c 20 3e 11 80 	cmpl   $0x80113e20,0xc(%ebp)
80104b92:	74 17                	je     80104bab <sleep+0x99>
    release(&ptable.lock);
80104b94:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104b9b:	e8 aa 03 00 00       	call   80104f4a <release>
    acquire(lk);
80104ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba3:	89 04 24             	mov    %eax,(%esp)
80104ba6:	e8 38 03 00 00       	call   80104ee3 <acquire>
  }
}
80104bab:	c9                   	leave  
80104bac:	c3                   	ret    

80104bad <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104bad:	55                   	push   %ebp
80104bae:	89 e5                	mov    %esp,%ebp
80104bb0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bb3:	c7 45 fc 54 3e 11 80 	movl   $0x80113e54,-0x4(%ebp)
80104bba:	eb 24                	jmp    80104be0 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104bbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bbf:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc2:	83 f8 02             	cmp    $0x2,%eax
80104bc5:	75 15                	jne    80104bdc <wakeup1+0x2f>
80104bc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bca:	8b 40 20             	mov    0x20(%eax),%eax
80104bcd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104bd0:	75 0a                	jne    80104bdc <wakeup1+0x2f>
      p->state = RUNNABLE;
80104bd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bd5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bdc:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104be0:	81 7d fc 54 5d 11 80 	cmpl   $0x80115d54,-0x4(%ebp)
80104be7:	72 d3                	jb     80104bbc <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104be9:	c9                   	leave  
80104bea:	c3                   	ret    

80104beb <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104beb:	55                   	push   %ebp
80104bec:	89 e5                	mov    %esp,%ebp
80104bee:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104bf1:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104bf8:	e8 e6 02 00 00       	call   80104ee3 <acquire>
  wakeup1(chan);
80104bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104c00:	89 04 24             	mov    %eax,(%esp)
80104c03:	e8 a5 ff ff ff       	call   80104bad <wakeup1>
  release(&ptable.lock);
80104c08:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104c0f:	e8 36 03 00 00       	call   80104f4a <release>
}
80104c14:	c9                   	leave  
80104c15:	c3                   	ret    

80104c16 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c16:	55                   	push   %ebp
80104c17:	89 e5                	mov    %esp,%ebp
80104c19:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c1c:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104c23:	e8 bb 02 00 00       	call   80104ee3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c28:	c7 45 f4 54 3e 11 80 	movl   $0x80113e54,-0xc(%ebp)
80104c2f:	eb 41                	jmp    80104c72 <kill+0x5c>
    if(p->pid == pid){
80104c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c34:	8b 40 10             	mov    0x10(%eax),%eax
80104c37:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c3a:	75 32                	jne    80104c6e <kill+0x58>
      p->killed = 1;
80104c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c49:	8b 40 0c             	mov    0xc(%eax),%eax
80104c4c:	83 f8 02             	cmp    $0x2,%eax
80104c4f:	75 0a                	jne    80104c5b <kill+0x45>
        p->state = RUNNABLE;
80104c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c54:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c5b:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104c62:	e8 e3 02 00 00       	call   80104f4a <release>
      return 0;
80104c67:	b8 00 00 00 00       	mov    $0x0,%eax
80104c6c:	eb 1e                	jmp    80104c8c <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c72:	81 7d f4 54 5d 11 80 	cmpl   $0x80115d54,-0xc(%ebp)
80104c79:	72 b6                	jb     80104c31 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104c7b:	c7 04 24 20 3e 11 80 	movl   $0x80113e20,(%esp)
80104c82:	e8 c3 02 00 00       	call   80104f4a <release>
  return -1;
80104c87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c8c:	c9                   	leave  
80104c8d:	c3                   	ret    

80104c8e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c8e:	55                   	push   %ebp
80104c8f:	89 e5                	mov    %esp,%ebp
80104c91:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c94:	c7 45 f0 54 3e 11 80 	movl   $0x80113e54,-0x10(%ebp)
80104c9b:	e9 d5 00 00 00       	jmp    80104d75 <procdump+0xe7>
    if(p->state == UNUSED)
80104ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ca3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca6:	85 c0                	test   %eax,%eax
80104ca8:	75 05                	jne    80104caf <procdump+0x21>
      continue;
80104caa:	e9 c2 00 00 00       	jmp    80104d71 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cb2:	8b 40 0c             	mov    0xc(%eax),%eax
80104cb5:	83 f8 05             	cmp    $0x5,%eax
80104cb8:	77 23                	ja     80104cdd <procdump+0x4f>
80104cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cbd:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc0:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104cc7:	85 c0                	test   %eax,%eax
80104cc9:	74 12                	je     80104cdd <procdump+0x4f>
      state = states[p->state];
80104ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cce:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd1:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104cd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104cdb:	eb 07                	jmp    80104ce4 <procdump+0x56>
    else
      state = "???";
80104cdd:	c7 45 ec d8 87 10 80 	movl   $0x801087d8,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce7:	8d 50 6c             	lea    0x6c(%eax),%edx
80104cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ced:	8b 40 10             	mov    0x10(%eax),%eax
80104cf0:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104cf4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
80104cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cff:	c7 04 24 dc 87 10 80 	movl   $0x801087dc,(%esp)
80104d06:	e8 b6 b6 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d0e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d11:	83 f8 02             	cmp    $0x2,%eax
80104d14:	75 4f                	jne    80104d65 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d19:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d1c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d1f:	83 c0 08             	add    $0x8,%eax
80104d22:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104d25:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d29:	89 04 24             	mov    %eax,(%esp)
80104d2c:	e8 66 02 00 00       	call   80104f97 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104d31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d38:	eb 1a                	jmp    80104d54 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d41:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d45:	c7 04 24 e5 87 10 80 	movl   $0x801087e5,(%esp)
80104d4c:	e8 70 b6 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d51:	ff 45 f4             	incl   -0xc(%ebp)
80104d54:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d58:	7f 0b                	jg     80104d65 <procdump+0xd7>
80104d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d61:	85 c0                	test   %eax,%eax
80104d63:	75 d5                	jne    80104d3a <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104d65:	c7 04 24 e9 87 10 80 	movl   $0x801087e9,(%esp)
80104d6c:	e8 50 b6 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d71:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104d75:	81 7d f0 54 5d 11 80 	cmpl   $0x80115d54,-0x10(%ebp)
80104d7c:	0f 82 1e ff ff ff    	jb     80104ca0 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104d82:	c9                   	leave  
80104d83:	c3                   	ret    

80104d84 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104d84:	55                   	push   %ebp
80104d85:	89 e5                	mov    %esp,%ebp
80104d87:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8d:	83 c0 04             	add    $0x4,%eax
80104d90:	c7 44 24 04 15 88 10 	movl   $0x80108815,0x4(%esp)
80104d97:	80 
80104d98:	89 04 24             	mov    %eax,(%esp)
80104d9b:	e8 22 01 00 00       	call   80104ec2 <initlock>
  lk->name = name;
80104da0:	8b 45 08             	mov    0x8(%ebp),%eax
80104da3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104da6:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104da9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104db2:	8b 45 08             	mov    0x8(%ebp),%eax
80104db5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104dbc:	c9                   	leave  
80104dbd:	c3                   	ret    

80104dbe <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104dbe:	55                   	push   %ebp
80104dbf:	89 e5                	mov    %esp,%ebp
80104dc1:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc7:	83 c0 04             	add    $0x4,%eax
80104dca:	89 04 24             	mov    %eax,(%esp)
80104dcd:	e8 11 01 00 00       	call   80104ee3 <acquire>
  while (lk->locked) {
80104dd2:	eb 15                	jmp    80104de9 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd7:	83 c0 04             	add    $0x4,%eax
80104dda:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dde:	8b 45 08             	mov    0x8(%ebp),%eax
80104de1:	89 04 24             	mov    %eax,(%esp)
80104de4:	e8 29 fd ff ff       	call   80104b12 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104de9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dec:	8b 00                	mov    (%eax),%eax
80104dee:	85 c0                	test   %eax,%eax
80104df0:	75 e2                	jne    80104dd4 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104df2:	8b 45 08             	mov    0x8(%ebp),%eax
80104df5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = proc->pid;
80104dfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e01:	8b 50 10             	mov    0x10(%eax),%edx
80104e04:	8b 45 08             	mov    0x8(%ebp),%eax
80104e07:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0d:	83 c0 04             	add    $0x4,%eax
80104e10:	89 04 24             	mov    %eax,(%esp)
80104e13:	e8 32 01 00 00       	call   80104f4a <release>
}
80104e18:	c9                   	leave  
80104e19:	c3                   	ret    

80104e1a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104e1a:	55                   	push   %ebp
80104e1b:	89 e5                	mov    %esp,%ebp
80104e1d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104e20:	8b 45 08             	mov    0x8(%ebp),%eax
80104e23:	83 c0 04             	add    $0x4,%eax
80104e26:	89 04 24             	mov    %eax,(%esp)
80104e29:	e8 b5 00 00 00       	call   80104ee3 <acquire>
  lk->locked = 0;
80104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e37:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104e41:	8b 45 08             	mov    0x8(%ebp),%eax
80104e44:	89 04 24             	mov    %eax,(%esp)
80104e47:	e8 9f fd ff ff       	call   80104beb <wakeup>
  release(&lk->lk);
80104e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4f:	83 c0 04             	add    $0x4,%eax
80104e52:	89 04 24             	mov    %eax,(%esp)
80104e55:	e8 f0 00 00 00       	call   80104f4a <release>
}
80104e5a:	c9                   	leave  
80104e5b:	c3                   	ret    

80104e5c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
80104e5f:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104e62:	8b 45 08             	mov    0x8(%ebp),%eax
80104e65:	83 c0 04             	add    $0x4,%eax
80104e68:	89 04 24             	mov    %eax,(%esp)
80104e6b:	e8 73 00 00 00       	call   80104ee3 <acquire>
  r = lk->locked;
80104e70:	8b 45 08             	mov    0x8(%ebp),%eax
80104e73:	8b 00                	mov    (%eax),%eax
80104e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104e78:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7b:	83 c0 04             	add    $0x4,%eax
80104e7e:	89 04 24             	mov    %eax,(%esp)
80104e81:	e8 c4 00 00 00       	call   80104f4a <release>
  return r;
80104e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104e89:	c9                   	leave  
80104e8a:	c3                   	ret    
	...

80104e8c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e8c:	55                   	push   %ebp
80104e8d:	89 e5                	mov    %esp,%ebp
80104e8f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e92:	9c                   	pushf  
80104e93:	58                   	pop    %eax
80104e94:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104e97:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e9a:	c9                   	leave  
80104e9b:	c3                   	ret    

80104e9c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e9c:	55                   	push   %ebp
80104e9d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e9f:	fa                   	cli    
}
80104ea0:	5d                   	pop    %ebp
80104ea1:	c3                   	ret    

80104ea2 <sti>:

static inline void
sti(void)
{
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ea5:	fb                   	sti    
}
80104ea6:	5d                   	pop    %ebp
80104ea7:	c3                   	ret    

80104ea8 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104ea8:	55                   	push   %ebp
80104ea9:	89 e5                	mov    %esp,%ebp
80104eab:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104eae:	8b 55 08             	mov    0x8(%ebp),%edx
80104eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104eb7:	f0 87 02             	lock xchg %eax,(%edx)
80104eba:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104ebd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ec0:	c9                   	leave  
80104ec1:	c3                   	ret    

80104ec2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ec2:	55                   	push   %ebp
80104ec3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ecb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ece:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eda:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ee1:	5d                   	pop    %ebp
80104ee2:	c3                   	ret    

80104ee3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ee3:	55                   	push   %ebp
80104ee4:	89 e5                	mov    %esp,%ebp
80104ee6:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ee9:	e8 4a 01 00 00       	call   80105038 <pushcli>
  if(holding(lk))
80104eee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef1:	89 04 24             	mov    %eax,(%esp)
80104ef4:	e8 15 01 00 00       	call   8010500e <holding>
80104ef9:	85 c0                	test   %eax,%eax
80104efb:	74 0c                	je     80104f09 <acquire+0x26>
    panic("acquire");
80104efd:	c7 04 24 20 88 10 80 	movl   $0x80108820,(%esp)
80104f04:	e8 4b b6 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104f09:	90                   	nop
80104f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104f14:	00 
80104f15:	89 04 24             	mov    %eax,(%esp)
80104f18:	e8 8b ff ff ff       	call   80104ea8 <xchg>
80104f1d:	85 c0                	test   %eax,%eax
80104f1f:	75 e9                	jne    80104f0a <acquire+0x27>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104f21:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104f26:	8b 45 08             	mov    0x8(%ebp),%eax
80104f29:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f30:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104f33:	8b 45 08             	mov    0x8(%ebp),%eax
80104f36:	83 c0 0c             	add    $0xc,%eax
80104f39:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f3d:	8d 45 08             	lea    0x8(%ebp),%eax
80104f40:	89 04 24             	mov    %eax,(%esp)
80104f43:	e8 4f 00 00 00       	call   80104f97 <getcallerpcs>
}
80104f48:	c9                   	leave  
80104f49:	c3                   	ret    

80104f4a <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f4a:	55                   	push   %ebp
80104f4b:	89 e5                	mov    %esp,%ebp
80104f4d:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f50:	8b 45 08             	mov    0x8(%ebp),%eax
80104f53:	89 04 24             	mov    %eax,(%esp)
80104f56:	e8 b3 00 00 00       	call   8010500e <holding>
80104f5b:	85 c0                	test   %eax,%eax
80104f5d:	75 0c                	jne    80104f6b <release+0x21>
    panic("release");
80104f5f:	c7 04 24 28 88 10 80 	movl   $0x80108828,(%esp)
80104f66:	e8 e9 b5 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80104f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f75:	8b 45 08             	mov    0x8(%ebp),%eax
80104f78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104f7f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104f84:	8b 45 08             	mov    0x8(%ebp),%eax
80104f87:	8b 55 08             	mov    0x8(%ebp),%edx
80104f8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104f90:	e8 f7 00 00 00       	call   8010508c <popcli>
}
80104f95:	c9                   	leave  
80104f96:	c3                   	ret    

80104f97 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f97:	55                   	push   %ebp
80104f98:	89 e5                	mov    %esp,%ebp
80104f9a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa0:	83 e8 08             	sub    $0x8,%eax
80104fa3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104fa6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104fad:	eb 37                	jmp    80104fe6 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104faf:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104fb3:	74 37                	je     80104fec <getcallerpcs+0x55>
80104fb5:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104fbc:	76 2e                	jbe    80104fec <getcallerpcs+0x55>
80104fbe:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104fc2:	74 28                	je     80104fec <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104fc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fc7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd1:	01 c2                	add    %eax,%edx
80104fd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fd6:	8b 40 04             	mov    0x4(%eax),%eax
80104fd9:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104fdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fde:	8b 00                	mov    (%eax),%eax
80104fe0:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104fe3:	ff 45 f8             	incl   -0x8(%ebp)
80104fe6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fea:	7e c3                	jle    80104faf <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fec:	eb 18                	jmp    80105006 <getcallerpcs+0x6f>
    pcs[i] = 0;
80104fee:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ff1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffb:	01 d0                	add    %edx,%eax
80104ffd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105003:	ff 45 f8             	incl   -0x8(%ebp)
80105006:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010500a:	7e e2                	jle    80104fee <getcallerpcs+0x57>
    pcs[i] = 0;
}
8010500c:	c9                   	leave  
8010500d:	c3                   	ret    

8010500e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010500e:	55                   	push   %ebp
8010500f:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105011:	8b 45 08             	mov    0x8(%ebp),%eax
80105014:	8b 00                	mov    (%eax),%eax
80105016:	85 c0                	test   %eax,%eax
80105018:	74 17                	je     80105031 <holding+0x23>
8010501a:	8b 45 08             	mov    0x8(%ebp),%eax
8010501d:	8b 50 08             	mov    0x8(%eax),%edx
80105020:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105026:	39 c2                	cmp    %eax,%edx
80105028:	75 07                	jne    80105031 <holding+0x23>
8010502a:	b8 01 00 00 00       	mov    $0x1,%eax
8010502f:	eb 05                	jmp    80105036 <holding+0x28>
80105031:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105036:	5d                   	pop    %ebp
80105037:	c3                   	ret    

80105038 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105038:	55                   	push   %ebp
80105039:	89 e5                	mov    %esp,%ebp
8010503b:	83 ec 10             	sub    $0x10,%esp
  int eflags;

  eflags = readeflags();
8010503e:	e8 49 fe ff ff       	call   80104e8c <readeflags>
80105043:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105046:	e8 51 fe ff ff       	call   80104e9c <cli>
  if(cpu->ncli == 0)
8010504b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105051:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105057:	85 c0                	test   %eax,%eax
80105059:	75 15                	jne    80105070 <pushcli+0x38>
    cpu->intena = eflags & FL_IF;
8010505b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105061:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105064:	81 e2 00 02 00 00    	and    $0x200,%edx
8010506a:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  cpu->ncli += 1;
80105070:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105076:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010507d:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
80105083:	42                   	inc    %edx
80105084:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
}
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <popcli>:

void
popcli(void)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105092:	e8 f5 fd ff ff       	call   80104e8c <readeflags>
80105097:	25 00 02 00 00       	and    $0x200,%eax
8010509c:	85 c0                	test   %eax,%eax
8010509e:	74 0c                	je     801050ac <popcli+0x20>
    panic("popcli - interruptible");
801050a0:	c7 04 24 30 88 10 80 	movl   $0x80108830,(%esp)
801050a7:	e8 a8 b4 ff ff       	call   80100554 <panic>
  if(--cpu->ncli < 0)
801050ac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050b2:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801050b8:	4a                   	dec    %edx
801050b9:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801050bf:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050c5:	85 c0                	test   %eax,%eax
801050c7:	79 0c                	jns    801050d5 <popcli+0x49>
    panic("popcli");
801050c9:	c7 04 24 47 88 10 80 	movl   $0x80108847,(%esp)
801050d0:	e8 7f b4 ff ff       	call   80100554 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801050d5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050db:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050e1:	85 c0                	test   %eax,%eax
801050e3:	75 15                	jne    801050fa <popcli+0x6e>
801050e5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050eb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801050f1:	85 c0                	test   %eax,%eax
801050f3:	74 05                	je     801050fa <popcli+0x6e>
    sti();
801050f5:	e8 a8 fd ff ff       	call   80104ea2 <sti>
}
801050fa:	c9                   	leave  
801050fb:	c3                   	ret    

801050fc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	57                   	push   %edi
80105100:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105101:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105104:	8b 55 10             	mov    0x10(%ebp),%edx
80105107:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510a:	89 cb                	mov    %ecx,%ebx
8010510c:	89 df                	mov    %ebx,%edi
8010510e:	89 d1                	mov    %edx,%ecx
80105110:	fc                   	cld    
80105111:	f3 aa                	rep stos %al,%es:(%edi)
80105113:	89 ca                	mov    %ecx,%edx
80105115:	89 fb                	mov    %edi,%ebx
80105117:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010511a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010511d:	5b                   	pop    %ebx
8010511e:	5f                   	pop    %edi
8010511f:	5d                   	pop    %ebp
80105120:	c3                   	ret    

80105121 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105121:	55                   	push   %ebp
80105122:	89 e5                	mov    %esp,%ebp
80105124:	57                   	push   %edi
80105125:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105126:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105129:	8b 55 10             	mov    0x10(%ebp),%edx
8010512c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512f:	89 cb                	mov    %ecx,%ebx
80105131:	89 df                	mov    %ebx,%edi
80105133:	89 d1                	mov    %edx,%ecx
80105135:	fc                   	cld    
80105136:	f3 ab                	rep stos %eax,%es:(%edi)
80105138:	89 ca                	mov    %ecx,%edx
8010513a:	89 fb                	mov    %edi,%ebx
8010513c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010513f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105142:	5b                   	pop    %ebx
80105143:	5f                   	pop    %edi
80105144:	5d                   	pop    %ebp
80105145:	c3                   	ret    

80105146 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105146:	55                   	push   %ebp
80105147:	89 e5                	mov    %esp,%ebp
80105149:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010514c:	8b 45 08             	mov    0x8(%ebp),%eax
8010514f:	83 e0 03             	and    $0x3,%eax
80105152:	85 c0                	test   %eax,%eax
80105154:	75 49                	jne    8010519f <memset+0x59>
80105156:	8b 45 10             	mov    0x10(%ebp),%eax
80105159:	83 e0 03             	and    $0x3,%eax
8010515c:	85 c0                	test   %eax,%eax
8010515e:	75 3f                	jne    8010519f <memset+0x59>
    c &= 0xFF;
80105160:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105167:	8b 45 10             	mov    0x10(%ebp),%eax
8010516a:	c1 e8 02             	shr    $0x2,%eax
8010516d:	89 c2                	mov    %eax,%edx
8010516f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105172:	c1 e0 18             	shl    $0x18,%eax
80105175:	89 c1                	mov    %eax,%ecx
80105177:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517a:	c1 e0 10             	shl    $0x10,%eax
8010517d:	09 c1                	or     %eax,%ecx
8010517f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105182:	c1 e0 08             	shl    $0x8,%eax
80105185:	09 c8                	or     %ecx,%eax
80105187:	0b 45 0c             	or     0xc(%ebp),%eax
8010518a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010518e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105192:	8b 45 08             	mov    0x8(%ebp),%eax
80105195:	89 04 24             	mov    %eax,(%esp)
80105198:	e8 84 ff ff ff       	call   80105121 <stosl>
8010519d:	eb 19                	jmp    801051b8 <memset+0x72>
  } else
    stosb(dst, c, n);
8010519f:	8b 45 10             	mov    0x10(%ebp),%eax
801051a2:	89 44 24 08          	mov    %eax,0x8(%esp)
801051a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801051ad:	8b 45 08             	mov    0x8(%ebp),%eax
801051b0:	89 04 24             	mov    %eax,(%esp)
801051b3:	e8 44 ff ff ff       	call   801050fc <stosb>
  return dst;
801051b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051bb:	c9                   	leave  
801051bc:	c3                   	ret    

801051bd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801051bd:	55                   	push   %ebp
801051be:	89 e5                	mov    %esp,%ebp
801051c0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801051c3:	8b 45 08             	mov    0x8(%ebp),%eax
801051c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801051c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801051cf:	eb 2a                	jmp    801051fb <memcmp+0x3e>
    if(*s1 != *s2)
801051d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d4:	8a 10                	mov    (%eax),%dl
801051d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051d9:	8a 00                	mov    (%eax),%al
801051db:	38 c2                	cmp    %al,%dl
801051dd:	74 16                	je     801051f5 <memcmp+0x38>
      return *s1 - *s2;
801051df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051e2:	8a 00                	mov    (%eax),%al
801051e4:	0f b6 d0             	movzbl %al,%edx
801051e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051ea:	8a 00                	mov    (%eax),%al
801051ec:	0f b6 c0             	movzbl %al,%eax
801051ef:	29 c2                	sub    %eax,%edx
801051f1:	89 d0                	mov    %edx,%eax
801051f3:	eb 18                	jmp    8010520d <memcmp+0x50>
    s1++, s2++;
801051f5:	ff 45 fc             	incl   -0x4(%ebp)
801051f8:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801051fb:	8b 45 10             	mov    0x10(%ebp),%eax
801051fe:	8d 50 ff             	lea    -0x1(%eax),%edx
80105201:	89 55 10             	mov    %edx,0x10(%ebp)
80105204:	85 c0                	test   %eax,%eax
80105206:	75 c9                	jne    801051d1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105208:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010520d:	c9                   	leave  
8010520e:	c3                   	ret    

8010520f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010520f:	55                   	push   %ebp
80105210:	89 e5                	mov    %esp,%ebp
80105212:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105215:	8b 45 0c             	mov    0xc(%ebp),%eax
80105218:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010521b:	8b 45 08             	mov    0x8(%ebp),%eax
8010521e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105221:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105224:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105227:	73 3a                	jae    80105263 <memmove+0x54>
80105229:	8b 45 10             	mov    0x10(%ebp),%eax
8010522c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010522f:	01 d0                	add    %edx,%eax
80105231:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105234:	76 2d                	jbe    80105263 <memmove+0x54>
    s += n;
80105236:	8b 45 10             	mov    0x10(%ebp),%eax
80105239:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010523c:	8b 45 10             	mov    0x10(%ebp),%eax
8010523f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105242:	eb 10                	jmp    80105254 <memmove+0x45>
      *--d = *--s;
80105244:	ff 4d f8             	decl   -0x8(%ebp)
80105247:	ff 4d fc             	decl   -0x4(%ebp)
8010524a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010524d:	8a 10                	mov    (%eax),%dl
8010524f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105252:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105254:	8b 45 10             	mov    0x10(%ebp),%eax
80105257:	8d 50 ff             	lea    -0x1(%eax),%edx
8010525a:	89 55 10             	mov    %edx,0x10(%ebp)
8010525d:	85 c0                	test   %eax,%eax
8010525f:	75 e3                	jne    80105244 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105261:	eb 25                	jmp    80105288 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105263:	eb 16                	jmp    8010527b <memmove+0x6c>
      *d++ = *s++;
80105265:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105268:	8d 50 01             	lea    0x1(%eax),%edx
8010526b:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010526e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105271:	8d 4a 01             	lea    0x1(%edx),%ecx
80105274:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105277:	8a 12                	mov    (%edx),%dl
80105279:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010527b:	8b 45 10             	mov    0x10(%ebp),%eax
8010527e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105281:	89 55 10             	mov    %edx,0x10(%ebp)
80105284:	85 c0                	test   %eax,%eax
80105286:	75 dd                	jne    80105265 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105288:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010528b:	c9                   	leave  
8010528c:	c3                   	ret    

8010528d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010528d:	55                   	push   %ebp
8010528e:	89 e5                	mov    %esp,%ebp
80105290:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105293:	8b 45 10             	mov    0x10(%ebp),%eax
80105296:	89 44 24 08          	mov    %eax,0x8(%esp)
8010529a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529d:	89 44 24 04          	mov    %eax,0x4(%esp)
801052a1:	8b 45 08             	mov    0x8(%ebp),%eax
801052a4:	89 04 24             	mov    %eax,(%esp)
801052a7:	e8 63 ff ff ff       	call   8010520f <memmove>
}
801052ac:	c9                   	leave  
801052ad:	c3                   	ret    

801052ae <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801052ae:	55                   	push   %ebp
801052af:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801052b1:	eb 09                	jmp    801052bc <strncmp+0xe>
    n--, p++, q++;
801052b3:	ff 4d 10             	decl   0x10(%ebp)
801052b6:	ff 45 08             	incl   0x8(%ebp)
801052b9:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801052bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052c0:	74 17                	je     801052d9 <strncmp+0x2b>
801052c2:	8b 45 08             	mov    0x8(%ebp),%eax
801052c5:	8a 00                	mov    (%eax),%al
801052c7:	84 c0                	test   %al,%al
801052c9:	74 0e                	je     801052d9 <strncmp+0x2b>
801052cb:	8b 45 08             	mov    0x8(%ebp),%eax
801052ce:	8a 10                	mov    (%eax),%dl
801052d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d3:	8a 00                	mov    (%eax),%al
801052d5:	38 c2                	cmp    %al,%dl
801052d7:	74 da                	je     801052b3 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801052d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052dd:	75 07                	jne    801052e6 <strncmp+0x38>
    return 0;
801052df:	b8 00 00 00 00       	mov    $0x0,%eax
801052e4:	eb 14                	jmp    801052fa <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801052e6:	8b 45 08             	mov    0x8(%ebp),%eax
801052e9:	8a 00                	mov    (%eax),%al
801052eb:	0f b6 d0             	movzbl %al,%edx
801052ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f1:	8a 00                	mov    (%eax),%al
801052f3:	0f b6 c0             	movzbl %al,%eax
801052f6:	29 c2                	sub    %eax,%edx
801052f8:	89 d0                	mov    %edx,%eax
}
801052fa:	5d                   	pop    %ebp
801052fb:	c3                   	ret    

801052fc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052fc:	55                   	push   %ebp
801052fd:	89 e5                	mov    %esp,%ebp
801052ff:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105302:	8b 45 08             	mov    0x8(%ebp),%eax
80105305:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105308:	90                   	nop
80105309:	8b 45 10             	mov    0x10(%ebp),%eax
8010530c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010530f:	89 55 10             	mov    %edx,0x10(%ebp)
80105312:	85 c0                	test   %eax,%eax
80105314:	7e 1c                	jle    80105332 <strncpy+0x36>
80105316:	8b 45 08             	mov    0x8(%ebp),%eax
80105319:	8d 50 01             	lea    0x1(%eax),%edx
8010531c:	89 55 08             	mov    %edx,0x8(%ebp)
8010531f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105322:	8d 4a 01             	lea    0x1(%edx),%ecx
80105325:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105328:	8a 12                	mov    (%edx),%dl
8010532a:	88 10                	mov    %dl,(%eax)
8010532c:	8a 00                	mov    (%eax),%al
8010532e:	84 c0                	test   %al,%al
80105330:	75 d7                	jne    80105309 <strncpy+0xd>
    ;
  while(n-- > 0)
80105332:	eb 0c                	jmp    80105340 <strncpy+0x44>
    *s++ = 0;
80105334:	8b 45 08             	mov    0x8(%ebp),%eax
80105337:	8d 50 01             	lea    0x1(%eax),%edx
8010533a:	89 55 08             	mov    %edx,0x8(%ebp)
8010533d:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105340:	8b 45 10             	mov    0x10(%ebp),%eax
80105343:	8d 50 ff             	lea    -0x1(%eax),%edx
80105346:	89 55 10             	mov    %edx,0x10(%ebp)
80105349:	85 c0                	test   %eax,%eax
8010534b:	7f e7                	jg     80105334 <strncpy+0x38>
    *s++ = 0;
  return os;
8010534d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105350:	c9                   	leave  
80105351:	c3                   	ret    

80105352 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105352:	55                   	push   %ebp
80105353:	89 e5                	mov    %esp,%ebp
80105355:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105358:	8b 45 08             	mov    0x8(%ebp),%eax
8010535b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010535e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105362:	7f 05                	jg     80105369 <safestrcpy+0x17>
    return os;
80105364:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105367:	eb 2e                	jmp    80105397 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105369:	ff 4d 10             	decl   0x10(%ebp)
8010536c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105370:	7e 1c                	jle    8010538e <safestrcpy+0x3c>
80105372:	8b 45 08             	mov    0x8(%ebp),%eax
80105375:	8d 50 01             	lea    0x1(%eax),%edx
80105378:	89 55 08             	mov    %edx,0x8(%ebp)
8010537b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010537e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105381:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105384:	8a 12                	mov    (%edx),%dl
80105386:	88 10                	mov    %dl,(%eax)
80105388:	8a 00                	mov    (%eax),%al
8010538a:	84 c0                	test   %al,%al
8010538c:	75 db                	jne    80105369 <safestrcpy+0x17>
    ;
  *s = 0;
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105394:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105397:	c9                   	leave  
80105398:	c3                   	ret    

80105399 <strlen>:

int
strlen(const char *s)
{
80105399:	55                   	push   %ebp
8010539a:	89 e5                	mov    %esp,%ebp
8010539c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010539f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801053a6:	eb 03                	jmp    801053ab <strlen+0x12>
801053a8:	ff 45 fc             	incl   -0x4(%ebp)
801053ab:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	01 d0                	add    %edx,%eax
801053b3:	8a 00                	mov    (%eax),%al
801053b5:	84 c0                	test   %al,%al
801053b7:	75 ef                	jne    801053a8 <strlen+0xf>
    ;
  return n;
801053b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053bc:	c9                   	leave  
801053bd:	c3                   	ret    
	...

801053c0 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801053c0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801053c4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801053c8:	55                   	push   %ebp
  pushl %ebx
801053c9:	53                   	push   %ebx
  pushl %esi
801053ca:	56                   	push   %esi
  pushl %edi
801053cb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801053cc:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801053ce:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801053d0:	5f                   	pop    %edi
  popl %esi
801053d1:	5e                   	pop    %esi
  popl %ebx
801053d2:	5b                   	pop    %ebx
  popl %ebp
801053d3:	5d                   	pop    %ebp
  ret
801053d4:	c3                   	ret    
801053d5:	00 00                	add    %al,(%eax)
	...

801053d8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801053d8:	55                   	push   %ebp
801053d9:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801053db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053e1:	8b 00                	mov    (%eax),%eax
801053e3:	3b 45 08             	cmp    0x8(%ebp),%eax
801053e6:	76 12                	jbe    801053fa <fetchint+0x22>
801053e8:	8b 45 08             	mov    0x8(%ebp),%eax
801053eb:	8d 50 04             	lea    0x4(%eax),%edx
801053ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053f4:	8b 00                	mov    (%eax),%eax
801053f6:	39 c2                	cmp    %eax,%edx
801053f8:	76 07                	jbe    80105401 <fetchint+0x29>
    return -1;
801053fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ff:	eb 0f                	jmp    80105410 <fetchint+0x38>
  *ip = *(int*)(addr);
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
80105404:	8b 10                	mov    (%eax),%edx
80105406:	8b 45 0c             	mov    0xc(%ebp),%eax
80105409:	89 10                	mov    %edx,(%eax)
  return 0;
8010540b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105410:	5d                   	pop    %ebp
80105411:	c3                   	ret    

80105412 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105412:	55                   	push   %ebp
80105413:	89 e5                	mov    %esp,%ebp
80105415:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105418:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541e:	8b 00                	mov    (%eax),%eax
80105420:	3b 45 08             	cmp    0x8(%ebp),%eax
80105423:	77 07                	ja     8010542c <fetchstr+0x1a>
    return -1;
80105425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542a:	eb 44                	jmp    80105470 <fetchstr+0x5e>
  *pp = (char*)addr;
8010542c:	8b 55 08             	mov    0x8(%ebp),%edx
8010542f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105432:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105434:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543a:	8b 00                	mov    (%eax),%eax
8010543c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010543f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105442:	8b 00                	mov    (%eax),%eax
80105444:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105447:	eb 1a                	jmp    80105463 <fetchstr+0x51>
    if(*s == 0)
80105449:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010544c:	8a 00                	mov    (%eax),%al
8010544e:	84 c0                	test   %al,%al
80105450:	75 0e                	jne    80105460 <fetchstr+0x4e>
      return s - *pp;
80105452:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105455:	8b 45 0c             	mov    0xc(%ebp),%eax
80105458:	8b 00                	mov    (%eax),%eax
8010545a:	29 c2                	sub    %eax,%edx
8010545c:	89 d0                	mov    %edx,%eax
8010545e:	eb 10                	jmp    80105470 <fetchstr+0x5e>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105460:	ff 45 fc             	incl   -0x4(%ebp)
80105463:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105466:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105469:	72 de                	jb     80105449 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010546b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105470:	c9                   	leave  
80105471:	c3                   	ret    

80105472 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105472:	55                   	push   %ebp
80105473:	89 e5                	mov    %esp,%ebp
80105475:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105478:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547e:	8b 40 18             	mov    0x18(%eax),%eax
80105481:	8b 50 44             	mov    0x44(%eax),%edx
80105484:	8b 45 08             	mov    0x8(%ebp),%eax
80105487:	c1 e0 02             	shl    $0x2,%eax
8010548a:	01 d0                	add    %edx,%eax
8010548c:	8d 50 04             	lea    0x4(%eax),%edx
8010548f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105492:	89 44 24 04          	mov    %eax,0x4(%esp)
80105496:	89 14 24             	mov    %edx,(%esp)
80105499:	e8 3a ff ff ff       	call   801053d8 <fetchint>
}
8010549e:	c9                   	leave  
8010549f:	c3                   	ret    

801054a0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801054a0:	55                   	push   %ebp
801054a1:	89 e5                	mov    %esp,%ebp
801054a3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(argint(n, &i) < 0)
801054a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801054ad:	8b 45 08             	mov    0x8(%ebp),%eax
801054b0:	89 04 24             	mov    %eax,(%esp)
801054b3:	e8 ba ff ff ff       	call   80105472 <argint>
801054b8:	85 c0                	test   %eax,%eax
801054ba:	79 07                	jns    801054c3 <argptr+0x23>
    return -1;
801054bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c1:	eb 43                	jmp    80105506 <argptr+0x66>
  if(size < 0 || (uint)i >= proc->sz || (uint)i+size > proc->sz)
801054c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054c7:	78 27                	js     801054f0 <argptr+0x50>
801054c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054cc:	89 c2                	mov    %eax,%edx
801054ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d4:	8b 00                	mov    (%eax),%eax
801054d6:	39 c2                	cmp    %eax,%edx
801054d8:	73 16                	jae    801054f0 <argptr+0x50>
801054da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054dd:	89 c2                	mov    %eax,%edx
801054df:	8b 45 10             	mov    0x10(%ebp),%eax
801054e2:	01 c2                	add    %eax,%edx
801054e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ea:	8b 00                	mov    (%eax),%eax
801054ec:	39 c2                	cmp    %eax,%edx
801054ee:	76 07                	jbe    801054f7 <argptr+0x57>
    return -1;
801054f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f5:	eb 0f                	jmp    80105506 <argptr+0x66>
  *pp = (char*)i;
801054f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054fa:	89 c2                	mov    %eax,%edx
801054fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ff:	89 10                	mov    %edx,(%eax)
  return 0;
80105501:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105506:	c9                   	leave  
80105507:	c3                   	ret    

80105508 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105508:	55                   	push   %ebp
80105509:	89 e5                	mov    %esp,%ebp
8010550b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010550e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105511:	89 44 24 04          	mov    %eax,0x4(%esp)
80105515:	8b 45 08             	mov    0x8(%ebp),%eax
80105518:	89 04 24             	mov    %eax,(%esp)
8010551b:	e8 52 ff ff ff       	call   80105472 <argint>
80105520:	85 c0                	test   %eax,%eax
80105522:	79 07                	jns    8010552b <argstr+0x23>
    return -1;
80105524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105529:	eb 12                	jmp    8010553d <argstr+0x35>
  return fetchstr(addr, pp);
8010552b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010552e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105531:	89 54 24 04          	mov    %edx,0x4(%esp)
80105535:	89 04 24             	mov    %eax,(%esp)
80105538:	e8 d5 fe ff ff       	call   80105412 <fetchstr>
}
8010553d:	c9                   	leave  
8010553e:	c3                   	ret    

8010553f <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010553f:	55                   	push   %ebp
80105540:	89 e5                	mov    %esp,%ebp
80105542:	53                   	push   %ebx
80105543:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105546:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010554c:	8b 40 18             	mov    0x18(%eax),%eax
8010554f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105552:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105555:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105559:	7e 30                	jle    8010558b <syscall+0x4c>
8010555b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555e:	83 f8 15             	cmp    $0x15,%eax
80105561:	77 28                	ja     8010558b <syscall+0x4c>
80105563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105566:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010556d:	85 c0                	test   %eax,%eax
8010556f:	74 1a                	je     8010558b <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105571:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105577:	8b 58 18             	mov    0x18(%eax),%ebx
8010557a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557d:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105584:	ff d0                	call   *%eax
80105586:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105589:	eb 3d                	jmp    801055c8 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010558b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105591:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105594:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010559a:	8b 40 10             	mov    0x10(%eax),%eax
8010559d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801055a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ac:	c7 04 24 4e 88 10 80 	movl   $0x8010884e,(%esp)
801055b3:	e8 09 ae ff ff       	call   801003c1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801055b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055be:	8b 40 18             	mov    0x18(%eax),%eax
801055c1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801055c8:	83 c4 24             	add    $0x24,%esp
801055cb:	5b                   	pop    %ebx
801055cc:	5d                   	pop    %ebp
801055cd:	c3                   	ret    
	...

801055d0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801055d0:	55                   	push   %ebp
801055d1:	89 e5                	mov    %esp,%ebp
801055d3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801055d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801055dd:	8b 45 08             	mov    0x8(%ebp),%eax
801055e0:	89 04 24             	mov    %eax,(%esp)
801055e3:	e8 8a fe ff ff       	call   80105472 <argint>
801055e8:	85 c0                	test   %eax,%eax
801055ea:	79 07                	jns    801055f3 <argfd+0x23>
    return -1;
801055ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f1:	eb 50                	jmp    80105643 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801055f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f6:	85 c0                	test   %eax,%eax
801055f8:	78 21                	js     8010561b <argfd+0x4b>
801055fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055fd:	83 f8 0f             	cmp    $0xf,%eax
80105600:	7f 19                	jg     8010561b <argfd+0x4b>
80105602:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105608:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010560b:	83 c2 08             	add    $0x8,%edx
8010560e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105612:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105615:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105619:	75 07                	jne    80105622 <argfd+0x52>
    return -1;
8010561b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105620:	eb 21                	jmp    80105643 <argfd+0x73>
  if(pfd)
80105622:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105626:	74 08                	je     80105630 <argfd+0x60>
    *pfd = fd;
80105628:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010562b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105630:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105634:	74 08                	je     8010563e <argfd+0x6e>
    *pf = f;
80105636:	8b 45 10             	mov    0x10(%ebp),%eax
80105639:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010563c:	89 10                	mov    %edx,(%eax)
  return 0;
8010563e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105643:	c9                   	leave  
80105644:	c3                   	ret    

80105645 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105645:	55                   	push   %ebp
80105646:	89 e5                	mov    %esp,%ebp
80105648:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010564b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105652:	eb 2f                	jmp    80105683 <fdalloc+0x3e>
    if(proc->ofile[fd] == 0){
80105654:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010565d:	83 c2 08             	add    $0x8,%edx
80105660:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105664:	85 c0                	test   %eax,%eax
80105666:	75 18                	jne    80105680 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105668:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105671:	8d 4a 08             	lea    0x8(%edx),%ecx
80105674:	8b 55 08             	mov    0x8(%ebp),%edx
80105677:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010567b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010567e:	eb 0e                	jmp    8010568e <fdalloc+0x49>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105680:	ff 45 fc             	incl   -0x4(%ebp)
80105683:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105687:	7e cb                	jle    80105654 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105689:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010568e:	c9                   	leave  
8010568f:	c3                   	ret    

80105690 <sys_dup>:

int
sys_dup(void)
{
80105690:	55                   	push   %ebp
80105691:	89 e5                	mov    %esp,%ebp
80105693:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105696:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105699:	89 44 24 08          	mov    %eax,0x8(%esp)
8010569d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056a4:	00 
801056a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056ac:	e8 1f ff ff ff       	call   801055d0 <argfd>
801056b1:	85 c0                	test   %eax,%eax
801056b3:	79 07                	jns    801056bc <sys_dup+0x2c>
    return -1;
801056b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ba:	eb 29                	jmp    801056e5 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801056bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056bf:	89 04 24             	mov    %eax,(%esp)
801056c2:	e8 7e ff ff ff       	call   80105645 <fdalloc>
801056c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ce:	79 07                	jns    801056d7 <sys_dup+0x47>
    return -1;
801056d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d5:	eb 0e                	jmp    801056e5 <sys_dup+0x55>
  filedup(f);
801056d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056da:	89 04 24             	mov    %eax,(%esp)
801056dd:	e8 da b8 ff ff       	call   80100fbc <filedup>
  return fd;
801056e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056e5:	c9                   	leave  
801056e6:	c3                   	ret    

801056e7 <sys_read>:

int
sys_read(void)
{
801056e7:	55                   	push   %ebp
801056e8:	89 e5                	mov    %esp,%ebp
801056ea:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056f0:	89 44 24 08          	mov    %eax,0x8(%esp)
801056f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056fb:	00 
801056fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105703:	e8 c8 fe ff ff       	call   801055d0 <argfd>
80105708:	85 c0                	test   %eax,%eax
8010570a:	78 35                	js     80105741 <sys_read+0x5a>
8010570c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010570f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105713:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010571a:	e8 53 fd ff ff       	call   80105472 <argint>
8010571f:	85 c0                	test   %eax,%eax
80105721:	78 1e                	js     80105741 <sys_read+0x5a>
80105723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105726:	89 44 24 08          	mov    %eax,0x8(%esp)
8010572a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010572d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105731:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105738:	e8 63 fd ff ff       	call   801054a0 <argptr>
8010573d:	85 c0                	test   %eax,%eax
8010573f:	79 07                	jns    80105748 <sys_read+0x61>
    return -1;
80105741:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105746:	eb 19                	jmp    80105761 <sys_read+0x7a>
  return fileread(f, p, n);
80105748:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010574b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010574e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105751:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105755:	89 54 24 04          	mov    %edx,0x4(%esp)
80105759:	89 04 24             	mov    %eax,(%esp)
8010575c:	e8 bc b9 ff ff       	call   8010111d <fileread>
}
80105761:	c9                   	leave  
80105762:	c3                   	ret    

80105763 <sys_write>:

int
sys_write(void)
{
80105763:	55                   	push   %ebp
80105764:	89 e5                	mov    %esp,%ebp
80105766:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105769:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010576c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105770:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105777:	00 
80105778:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010577f:	e8 4c fe ff ff       	call   801055d0 <argfd>
80105784:	85 c0                	test   %eax,%eax
80105786:	78 35                	js     801057bd <sys_write+0x5a>
80105788:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010578b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010578f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105796:	e8 d7 fc ff ff       	call   80105472 <argint>
8010579b:	85 c0                	test   %eax,%eax
8010579d:	78 1e                	js     801057bd <sys_write+0x5a>
8010579f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a2:	89 44 24 08          	mov    %eax,0x8(%esp)
801057a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801057ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057b4:	e8 e7 fc ff ff       	call   801054a0 <argptr>
801057b9:	85 c0                	test   %eax,%eax
801057bb:	79 07                	jns    801057c4 <sys_write+0x61>
    return -1;
801057bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c2:	eb 19                	jmp    801057dd <sys_write+0x7a>
  return filewrite(f, p, n);
801057c4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801057d5:	89 04 24             	mov    %eax,(%esp)
801057d8:	e8 fb b9 ff ff       	call   801011d8 <filewrite>
}
801057dd:	c9                   	leave  
801057de:	c3                   	ret    

801057df <sys_close>:

int
sys_close(void)
{
801057df:	55                   	push   %ebp
801057e0:	89 e5                	mov    %esp,%ebp
801057e2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801057e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057e8:	89 44 24 08          	mov    %eax,0x8(%esp)
801057ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801057f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057fa:	e8 d1 fd ff ff       	call   801055d0 <argfd>
801057ff:	85 c0                	test   %eax,%eax
80105801:	79 07                	jns    8010580a <sys_close+0x2b>
    return -1;
80105803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105808:	eb 24                	jmp    8010582e <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010580a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105810:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105813:	83 c2 08             	add    $0x8,%edx
80105816:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010581d:	00 
  fileclose(f);
8010581e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105821:	89 04 24             	mov    %eax,(%esp)
80105824:	e8 db b7 ff ff       	call   80101004 <fileclose>
  return 0;
80105829:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010582e:	c9                   	leave  
8010582f:	c3                   	ret    

80105830 <sys_fstat>:

int
sys_fstat(void)
{
80105830:	55                   	push   %ebp
80105831:	89 e5                	mov    %esp,%ebp
80105833:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105836:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105839:	89 44 24 08          	mov    %eax,0x8(%esp)
8010583d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105844:	00 
80105845:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010584c:	e8 7f fd ff ff       	call   801055d0 <argfd>
80105851:	85 c0                	test   %eax,%eax
80105853:	78 1f                	js     80105874 <sys_fstat+0x44>
80105855:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010585c:	00 
8010585d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105860:	89 44 24 04          	mov    %eax,0x4(%esp)
80105864:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010586b:	e8 30 fc ff ff       	call   801054a0 <argptr>
80105870:	85 c0                	test   %eax,%eax
80105872:	79 07                	jns    8010587b <sys_fstat+0x4b>
    return -1;
80105874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105879:	eb 12                	jmp    8010588d <sys_fstat+0x5d>
  return filestat(f, st);
8010587b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010587e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105881:	89 54 24 04          	mov    %edx,0x4(%esp)
80105885:	89 04 24             	mov    %eax,(%esp)
80105888:	e8 41 b8 ff ff       	call   801010ce <filestat>
}
8010588d:	c9                   	leave  
8010588e:	c3                   	ret    

8010588f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010588f:	55                   	push   %ebp
80105890:	89 e5                	mov    %esp,%ebp
80105892:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105895:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105898:	89 44 24 04          	mov    %eax,0x4(%esp)
8010589c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058a3:	e8 60 fc ff ff       	call   80105508 <argstr>
801058a8:	85 c0                	test   %eax,%eax
801058aa:	78 17                	js     801058c3 <sys_link+0x34>
801058ac:	8d 45 dc             	lea    -0x24(%ebp),%eax
801058af:	89 44 24 04          	mov    %eax,0x4(%esp)
801058b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058ba:	e8 49 fc ff ff       	call   80105508 <argstr>
801058bf:	85 c0                	test   %eax,%eax
801058c1:	79 0a                	jns    801058cd <sys_link+0x3e>
    return -1;
801058c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c8:	e9 3d 01 00 00       	jmp    80105a0a <sys_link+0x17b>

  begin_op();
801058cd:	e8 f1 db ff ff       	call   801034c3 <begin_op>
  if((ip = namei(old)) == 0){
801058d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801058d5:	89 04 24             	mov    %eax,(%esp)
801058d8:	e8 54 cb ff ff       	call   80102431 <namei>
801058dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058e4:	75 0f                	jne    801058f5 <sys_link+0x66>
    end_op();
801058e6:	e8 5a dc ff ff       	call   80103545 <end_op>
    return -1;
801058eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f0:	e9 15 01 00 00       	jmp    80105a0a <sys_link+0x17b>
  }

  ilock(ip);
801058f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f8:	89 04 24             	mov    %eax,(%esp)
801058fb:	e8 1e c0 ff ff       	call   8010191e <ilock>
  if(ip->type == T_DIR){
80105900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105903:	8b 40 50             	mov    0x50(%eax),%eax
80105906:	66 83 f8 01          	cmp    $0x1,%ax
8010590a:	75 1a                	jne    80105926 <sys_link+0x97>
    iunlockput(ip);
8010590c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590f:	89 04 24             	mov    %eax,(%esp)
80105912:	e8 f3 c1 ff ff       	call   80101b0a <iunlockput>
    end_op();
80105917:	e8 29 dc ff ff       	call   80103545 <end_op>
    return -1;
8010591c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105921:	e9 e4 00 00 00       	jmp    80105a0a <sys_link+0x17b>
  }

  ip->nlink++;
80105926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105929:	66 8b 40 56          	mov    0x56(%eax),%ax
8010592d:	40                   	inc    %eax
8010592e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105931:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105938:	89 04 24             	mov    %eax,(%esp)
8010593b:	e8 1b be ff ff       	call   8010175b <iupdate>
  iunlock(ip);
80105940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105943:	89 04 24             	mov    %eax,(%esp)
80105946:	e8 e7 c0 ff ff       	call   80101a32 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010594b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010594e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105951:	89 54 24 04          	mov    %edx,0x4(%esp)
80105955:	89 04 24             	mov    %eax,(%esp)
80105958:	e8 f6 ca ff ff       	call   80102453 <nameiparent>
8010595d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105960:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105964:	75 02                	jne    80105968 <sys_link+0xd9>
    goto bad;
80105966:	eb 68                	jmp    801059d0 <sys_link+0x141>
  ilock(dp);
80105968:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596b:	89 04 24             	mov    %eax,(%esp)
8010596e:	e8 ab bf ff ff       	call   8010191e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105976:	8b 10                	mov    (%eax),%edx
80105978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597b:	8b 00                	mov    (%eax),%eax
8010597d:	39 c2                	cmp    %eax,%edx
8010597f:	75 20                	jne    801059a1 <sys_link+0x112>
80105981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105984:	8b 40 04             	mov    0x4(%eax),%eax
80105987:	89 44 24 08          	mov    %eax,0x8(%esp)
8010598b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010598e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105995:	89 04 24             	mov    %eax,(%esp)
80105998:	e8 e0 c7 ff ff       	call   8010217d <dirlink>
8010599d:	85 c0                	test   %eax,%eax
8010599f:	79 0d                	jns    801059ae <sys_link+0x11f>
    iunlockput(dp);
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	89 04 24             	mov    %eax,(%esp)
801059a7:	e8 5e c1 ff ff       	call   80101b0a <iunlockput>
    goto bad;
801059ac:	eb 22                	jmp    801059d0 <sys_link+0x141>
  }
  iunlockput(dp);
801059ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b1:	89 04 24             	mov    %eax,(%esp)
801059b4:	e8 51 c1 ff ff       	call   80101b0a <iunlockput>
  iput(ip);
801059b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bc:	89 04 24             	mov    %eax,(%esp)
801059bf:	e8 b2 c0 ff ff       	call   80101a76 <iput>

  end_op();
801059c4:	e8 7c db ff ff       	call   80103545 <end_op>

  return 0;
801059c9:	b8 00 00 00 00       	mov    $0x0,%eax
801059ce:	eb 3a                	jmp    80105a0a <sys_link+0x17b>

bad:
  ilock(ip);
801059d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d3:	89 04 24             	mov    %eax,(%esp)
801059d6:	e8 43 bf ff ff       	call   8010191e <ilock>
  ip->nlink--;
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	66 8b 40 56          	mov    0x56(%eax),%ax
801059e2:	48                   	dec    %eax
801059e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059e6:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	89 04 24             	mov    %eax,(%esp)
801059f0:	e8 66 bd ff ff       	call   8010175b <iupdate>
  iunlockput(ip);
801059f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f8:	89 04 24             	mov    %eax,(%esp)
801059fb:	e8 0a c1 ff ff       	call   80101b0a <iunlockput>
  end_op();
80105a00:	e8 40 db ff ff       	call   80103545 <end_op>
  return -1;
80105a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a0a:	c9                   	leave  
80105a0b:	c3                   	ret    

80105a0c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105a0c:	55                   	push   %ebp
80105a0d:	89 e5                	mov    %esp,%ebp
80105a0f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a12:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105a19:	eb 4a                	jmp    80105a65 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a25:	00 
80105a26:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a31:	8b 45 08             	mov    0x8(%ebp),%eax
80105a34:	89 04 24             	mov    %eax,(%esp)
80105a37:	e8 66 c3 ff ff       	call   80101da2 <readi>
80105a3c:	83 f8 10             	cmp    $0x10,%eax
80105a3f:	74 0c                	je     80105a4d <isdirempty+0x41>
      panic("isdirempty: readi");
80105a41:	c7 04 24 6a 88 10 80 	movl   $0x8010886a,(%esp)
80105a48:	e8 07 ab ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105a4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a50:	66 85 c0             	test   %ax,%ax
80105a53:	74 07                	je     80105a5c <isdirempty+0x50>
      return 0;
80105a55:	b8 00 00 00 00       	mov    $0x0,%eax
80105a5a:	eb 1b                	jmp    80105a77 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5f:	83 c0 10             	add    $0x10,%eax
80105a62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a68:	8b 45 08             	mov    0x8(%ebp),%eax
80105a6b:	8b 40 58             	mov    0x58(%eax),%eax
80105a6e:	39 c2                	cmp    %eax,%edx
80105a70:	72 a9                	jb     80105a1b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a72:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a77:	c9                   	leave  
80105a78:	c3                   	ret    

80105a79 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a79:	55                   	push   %ebp
80105a7a:	89 e5                	mov    %esp,%ebp
80105a7c:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a7f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a8d:	e8 76 fa ff ff       	call   80105508 <argstr>
80105a92:	85 c0                	test   %eax,%eax
80105a94:	79 0a                	jns    80105aa0 <sys_unlink+0x27>
    return -1;
80105a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9b:	e9 a9 01 00 00       	jmp    80105c49 <sys_unlink+0x1d0>

  begin_op();
80105aa0:	e8 1e da ff ff       	call   801034c3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105aa5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105aa8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105aab:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aaf:	89 04 24             	mov    %eax,(%esp)
80105ab2:	e8 9c c9 ff ff       	call   80102453 <nameiparent>
80105ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105abe:	75 0f                	jne    80105acf <sys_unlink+0x56>
    end_op();
80105ac0:	e8 80 da ff ff       	call   80103545 <end_op>
    return -1;
80105ac5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aca:	e9 7a 01 00 00       	jmp    80105c49 <sys_unlink+0x1d0>
  }

  ilock(dp);
80105acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad2:	89 04 24             	mov    %eax,(%esp)
80105ad5:	e8 44 be ff ff       	call   8010191e <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ada:	c7 44 24 04 7c 88 10 	movl   $0x8010887c,0x4(%esp)
80105ae1:	80 
80105ae2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ae5:	89 04 24             	mov    %eax,(%esp)
80105ae8:	e8 a8 c5 ff ff       	call   80102095 <namecmp>
80105aed:	85 c0                	test   %eax,%eax
80105aef:	0f 84 3f 01 00 00    	je     80105c34 <sys_unlink+0x1bb>
80105af5:	c7 44 24 04 7e 88 10 	movl   $0x8010887e,0x4(%esp)
80105afc:	80 
80105afd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b00:	89 04 24             	mov    %eax,(%esp)
80105b03:	e8 8d c5 ff ff       	call   80102095 <namecmp>
80105b08:	85 c0                	test   %eax,%eax
80105b0a:	0f 84 24 01 00 00    	je     80105c34 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105b10:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105b13:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b17:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b21:	89 04 24             	mov    %eax,(%esp)
80105b24:	e8 8e c5 ff ff       	call   801020b7 <dirlookup>
80105b29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b30:	75 05                	jne    80105b37 <sys_unlink+0xbe>
    goto bad;
80105b32:	e9 fd 00 00 00       	jmp    80105c34 <sys_unlink+0x1bb>
  ilock(ip);
80105b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3a:	89 04 24             	mov    %eax,(%esp)
80105b3d:	e8 dc bd ff ff       	call   8010191e <ilock>

  if(ip->nlink < 1)
80105b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b45:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b49:	66 85 c0             	test   %ax,%ax
80105b4c:	7f 0c                	jg     80105b5a <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105b4e:	c7 04 24 81 88 10 80 	movl   $0x80108881,(%esp)
80105b55:	e8 fa a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5d:	8b 40 50             	mov    0x50(%eax),%eax
80105b60:	66 83 f8 01          	cmp    $0x1,%ax
80105b64:	75 1f                	jne    80105b85 <sys_unlink+0x10c>
80105b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b69:	89 04 24             	mov    %eax,(%esp)
80105b6c:	e8 9b fe ff ff       	call   80105a0c <isdirempty>
80105b71:	85 c0                	test   %eax,%eax
80105b73:	75 10                	jne    80105b85 <sys_unlink+0x10c>
    iunlockput(ip);
80105b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b78:	89 04 24             	mov    %eax,(%esp)
80105b7b:	e8 8a bf ff ff       	call   80101b0a <iunlockput>
    goto bad;
80105b80:	e9 af 00 00 00       	jmp    80105c34 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105b85:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105b8c:	00 
80105b8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b94:	00 
80105b95:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b98:	89 04 24             	mov    %eax,(%esp)
80105b9b:	e8 a6 f5 ff ff       	call   80105146 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ba0:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ba3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105baa:	00 
80105bab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105baf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb9:	89 04 24             	mov    %eax,(%esp)
80105bbc:	e8 45 c3 ff ff       	call   80101f06 <writei>
80105bc1:	83 f8 10             	cmp    $0x10,%eax
80105bc4:	74 0c                	je     80105bd2 <sys_unlink+0x159>
    panic("unlink: writei");
80105bc6:	c7 04 24 93 88 10 80 	movl   $0x80108893,(%esp)
80105bcd:	e8 82 a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd5:	8b 40 50             	mov    0x50(%eax),%eax
80105bd8:	66 83 f8 01          	cmp    $0x1,%ax
80105bdc:	75 1a                	jne    80105bf8 <sys_unlink+0x17f>
    dp->nlink--;
80105bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be1:	66 8b 40 56          	mov    0x56(%eax),%ax
80105be5:	48                   	dec    %eax
80105be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105be9:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	89 04 24             	mov    %eax,(%esp)
80105bf3:	e8 63 bb ff ff       	call   8010175b <iupdate>
  }
  iunlockput(dp);
80105bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfb:	89 04 24             	mov    %eax,(%esp)
80105bfe:	e8 07 bf ff ff       	call   80101b0a <iunlockput>

  ip->nlink--;
80105c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c06:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c0a:	48                   	dec    %eax
80105c0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c0e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c15:	89 04 24             	mov    %eax,(%esp)
80105c18:	e8 3e bb ff ff       	call   8010175b <iupdate>
  iunlockput(ip);
80105c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c20:	89 04 24             	mov    %eax,(%esp)
80105c23:	e8 e2 be ff ff       	call   80101b0a <iunlockput>

  end_op();
80105c28:	e8 18 d9 ff ff       	call   80103545 <end_op>

  return 0;
80105c2d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c32:	eb 15                	jmp    80105c49 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c37:	89 04 24             	mov    %eax,(%esp)
80105c3a:	e8 cb be ff ff       	call   80101b0a <iunlockput>
  end_op();
80105c3f:	e8 01 d9 ff ff       	call   80103545 <end_op>
  return -1;
80105c44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c49:	c9                   	leave  
80105c4a:	c3                   	ret    

80105c4b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c4b:	55                   	push   %ebp
80105c4c:	89 e5                	mov    %esp,%ebp
80105c4e:	83 ec 48             	sub    $0x48,%esp
80105c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c54:	8b 55 10             	mov    0x10(%ebp),%edx
80105c57:	8b 45 14             	mov    0x14(%ebp),%eax
80105c5a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c5e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c62:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c66:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c69:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c70:	89 04 24             	mov    %eax,(%esp)
80105c73:	e8 db c7 ff ff       	call   80102453 <nameiparent>
80105c78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c7f:	75 0a                	jne    80105c8b <create+0x40>
    return 0;
80105c81:	b8 00 00 00 00       	mov    $0x0,%eax
80105c86:	e9 79 01 00 00       	jmp    80105e04 <create+0x1b9>
  ilock(dp);
80105c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8e:	89 04 24             	mov    %eax,(%esp)
80105c91:	e8 88 bc ff ff       	call   8010191e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c96:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c99:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c9d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca7:	89 04 24             	mov    %eax,(%esp)
80105caa:	e8 08 c4 ff ff       	call   801020b7 <dirlookup>
80105caf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cb6:	74 46                	je     80105cfe <create+0xb3>
    iunlockput(dp);
80105cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbb:	89 04 24             	mov    %eax,(%esp)
80105cbe:	e8 47 be ff ff       	call   80101b0a <iunlockput>
    ilock(ip);
80105cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc6:	89 04 24             	mov    %eax,(%esp)
80105cc9:	e8 50 bc ff ff       	call   8010191e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105cce:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105cd3:	75 14                	jne    80105ce9 <create+0x9e>
80105cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd8:	8b 40 50             	mov    0x50(%eax),%eax
80105cdb:	66 83 f8 02          	cmp    $0x2,%ax
80105cdf:	75 08                	jne    80105ce9 <create+0x9e>
      return ip;
80105ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce4:	e9 1b 01 00 00       	jmp    80105e04 <create+0x1b9>
    iunlockput(ip);
80105ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cec:	89 04 24             	mov    %eax,(%esp)
80105cef:	e8 16 be ff ff       	call   80101b0a <iunlockput>
    return 0;
80105cf4:	b8 00 00 00 00       	mov    $0x0,%eax
80105cf9:	e9 06 01 00 00       	jmp    80105e04 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105cfe:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d05:	8b 00                	mov    (%eax),%eax
80105d07:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d0b:	89 04 24             	mov    %eax,(%esp)
80105d0e:	e8 76 b9 ff ff       	call   80101689 <ialloc>
80105d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d1a:	75 0c                	jne    80105d28 <create+0xdd>
    panic("create: ialloc");
80105d1c:	c7 04 24 a2 88 10 80 	movl   $0x801088a2,(%esp)
80105d23:	e8 2c a8 ff ff       	call   80100554 <panic>

  ilock(ip);
80105d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2b:	89 04 24             	mov    %eax,(%esp)
80105d2e:	e8 eb bb ff ff       	call   8010191e <ilock>
  ip->major = major;
80105d33:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d36:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105d39:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105d3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d40:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d43:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4a:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d53:	89 04 24             	mov    %eax,(%esp)
80105d56:	e8 00 ba ff ff       	call   8010175b <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d5b:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d60:	75 68                	jne    80105dca <create+0x17f>
    dp->nlink++;  // for ".."
80105d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d65:	66 8b 40 56          	mov    0x56(%eax),%ax
80105d69:	40                   	inc    %eax
80105d6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d6d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d74:	89 04 24             	mov    %eax,(%esp)
80105d77:	e8 df b9 ff ff       	call   8010175b <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7f:	8b 40 04             	mov    0x4(%eax),%eax
80105d82:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d86:	c7 44 24 04 7c 88 10 	movl   $0x8010887c,0x4(%esp)
80105d8d:	80 
80105d8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d91:	89 04 24             	mov    %eax,(%esp)
80105d94:	e8 e4 c3 ff ff       	call   8010217d <dirlink>
80105d99:	85 c0                	test   %eax,%eax
80105d9b:	78 21                	js     80105dbe <create+0x173>
80105d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da0:	8b 40 04             	mov    0x4(%eax),%eax
80105da3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105da7:	c7 44 24 04 7e 88 10 	movl   $0x8010887e,0x4(%esp)
80105dae:	80 
80105daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db2:	89 04 24             	mov    %eax,(%esp)
80105db5:	e8 c3 c3 ff ff       	call   8010217d <dirlink>
80105dba:	85 c0                	test   %eax,%eax
80105dbc:	79 0c                	jns    80105dca <create+0x17f>
      panic("create dots");
80105dbe:	c7 04 24 b1 88 10 80 	movl   $0x801088b1,(%esp)
80105dc5:	e8 8a a7 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcd:	8b 40 04             	mov    0x4(%eax),%eax
80105dd0:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dd4:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dde:	89 04 24             	mov    %eax,(%esp)
80105de1:	e8 97 c3 ff ff       	call   8010217d <dirlink>
80105de6:	85 c0                	test   %eax,%eax
80105de8:	79 0c                	jns    80105df6 <create+0x1ab>
    panic("create: dirlink");
80105dea:	c7 04 24 bd 88 10 80 	movl   $0x801088bd,(%esp)
80105df1:	e8 5e a7 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80105df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df9:	89 04 24             	mov    %eax,(%esp)
80105dfc:	e8 09 bd ff ff       	call   80101b0a <iunlockput>

  return ip;
80105e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e04:	c9                   	leave  
80105e05:	c3                   	ret    

80105e06 <sys_open>:

int
sys_open(void)
{
80105e06:	55                   	push   %ebp
80105e07:	89 e5                	mov    %esp,%ebp
80105e09:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105e0c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e1a:	e8 e9 f6 ff ff       	call   80105508 <argstr>
80105e1f:	85 c0                	test   %eax,%eax
80105e21:	78 17                	js     80105e3a <sys_open+0x34>
80105e23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e26:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e31:	e8 3c f6 ff ff       	call   80105472 <argint>
80105e36:	85 c0                	test   %eax,%eax
80105e38:	79 0a                	jns    80105e44 <sys_open+0x3e>
    return -1;
80105e3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e3f:	e9 5b 01 00 00       	jmp    80105f9f <sys_open+0x199>

  begin_op();
80105e44:	e8 7a d6 ff ff       	call   801034c3 <begin_op>

  if(omode & O_CREATE){
80105e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e4c:	25 00 02 00 00       	and    $0x200,%eax
80105e51:	85 c0                	test   %eax,%eax
80105e53:	74 3b                	je     80105e90 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e58:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e5f:	00 
80105e60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e67:	00 
80105e68:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105e6f:	00 
80105e70:	89 04 24             	mov    %eax,(%esp)
80105e73:	e8 d3 fd ff ff       	call   80105c4b <create>
80105e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e7f:	75 6a                	jne    80105eeb <sys_open+0xe5>
      end_op();
80105e81:	e8 bf d6 ff ff       	call   80103545 <end_op>
      return -1;
80105e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8b:	e9 0f 01 00 00       	jmp    80105f9f <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e93:	89 04 24             	mov    %eax,(%esp)
80105e96:	e8 96 c5 ff ff       	call   80102431 <namei>
80105e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea2:	75 0f                	jne    80105eb3 <sys_open+0xad>
      end_op();
80105ea4:	e8 9c d6 ff ff       	call   80103545 <end_op>
      return -1;
80105ea9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eae:	e9 ec 00 00 00       	jmp    80105f9f <sys_open+0x199>
    }
    ilock(ip);
80105eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb6:	89 04 24             	mov    %eax,(%esp)
80105eb9:	e8 60 ba ff ff       	call   8010191e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec1:	8b 40 50             	mov    0x50(%eax),%eax
80105ec4:	66 83 f8 01          	cmp    $0x1,%ax
80105ec8:	75 21                	jne    80105eeb <sys_open+0xe5>
80105eca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ecd:	85 c0                	test   %eax,%eax
80105ecf:	74 1a                	je     80105eeb <sys_open+0xe5>
      iunlockput(ip);
80105ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 2e bc ff ff       	call   80101b0a <iunlockput>
      end_op();
80105edc:	e8 64 d6 ff ff       	call   80103545 <end_op>
      return -1;
80105ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee6:	e9 b4 00 00 00       	jmp    80105f9f <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105eeb:	e8 6c b0 ff ff       	call   80100f5c <filealloc>
80105ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ef3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ef7:	74 14                	je     80105f0d <sys_open+0x107>
80105ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efc:	89 04 24             	mov    %eax,(%esp)
80105eff:	e8 41 f7 ff ff       	call   80105645 <fdalloc>
80105f04:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105f07:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105f0b:	79 28                	jns    80105f35 <sys_open+0x12f>
    if(f)
80105f0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f11:	74 0b                	je     80105f1e <sys_open+0x118>
      fileclose(f);
80105f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f16:	89 04 24             	mov    %eax,(%esp)
80105f19:	e8 e6 b0 ff ff       	call   80101004 <fileclose>
    iunlockput(ip);
80105f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f21:	89 04 24             	mov    %eax,(%esp)
80105f24:	e8 e1 bb ff ff       	call   80101b0a <iunlockput>
    end_op();
80105f29:	e8 17 d6 ff ff       	call   80103545 <end_op>
    return -1;
80105f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f33:	eb 6a                	jmp    80105f9f <sys_open+0x199>
  }
  iunlock(ip);
80105f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f38:	89 04 24             	mov    %eax,(%esp)
80105f3b:	e8 f2 ba ff ff       	call   80101a32 <iunlock>
  end_op();
80105f40:	e8 00 d6 ff ff       	call   80103545 <end_op>

  f->type = FD_INODE;
80105f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f48:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f54:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f64:	83 e0 01             	and    $0x1,%eax
80105f67:	85 c0                	test   %eax,%eax
80105f69:	0f 94 c0             	sete   %al
80105f6c:	88 c2                	mov    %al,%dl
80105f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f71:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f77:	83 e0 01             	and    $0x1,%eax
80105f7a:	85 c0                	test   %eax,%eax
80105f7c:	75 0a                	jne    80105f88 <sys_open+0x182>
80105f7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f81:	83 e0 02             	and    $0x2,%eax
80105f84:	85 c0                	test   %eax,%eax
80105f86:	74 07                	je     80105f8f <sys_open+0x189>
80105f88:	b8 01 00 00 00       	mov    $0x1,%eax
80105f8d:	eb 05                	jmp    80105f94 <sys_open+0x18e>
80105f8f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f94:	88 c2                	mov    %al,%dl
80105f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f99:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f9f:	c9                   	leave  
80105fa0:	c3                   	ret    

80105fa1 <sys_mkdir>:

int
sys_mkdir(void)
{
80105fa1:	55                   	push   %ebp
80105fa2:	89 e5                	mov    %esp,%ebp
80105fa4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105fa7:	e8 17 d5 ff ff       	call   801034c3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105faf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fba:	e8 49 f5 ff ff       	call   80105508 <argstr>
80105fbf:	85 c0                	test   %eax,%eax
80105fc1:	78 2c                	js     80105fef <sys_mkdir+0x4e>
80105fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fcd:	00 
80105fce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fd5:	00 
80105fd6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105fdd:	00 
80105fde:	89 04 24             	mov    %eax,(%esp)
80105fe1:	e8 65 fc ff ff       	call   80105c4b <create>
80105fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fe9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fed:	75 0c                	jne    80105ffb <sys_mkdir+0x5a>
    end_op();
80105fef:	e8 51 d5 ff ff       	call   80103545 <end_op>
    return -1;
80105ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff9:	eb 15                	jmp    80106010 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffe:	89 04 24             	mov    %eax,(%esp)
80106001:	e8 04 bb ff ff       	call   80101b0a <iunlockput>
  end_op();
80106006:	e8 3a d5 ff ff       	call   80103545 <end_op>
  return 0;
8010600b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106010:	c9                   	leave  
80106011:	c3                   	ret    

80106012 <sys_mknod>:

int
sys_mknod(void)
{
80106012:	55                   	push   %ebp
80106013:	89 e5                	mov    %esp,%ebp
80106015:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106018:	e8 a6 d4 ff ff       	call   801034c3 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010601d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106020:	89 44 24 04          	mov    %eax,0x4(%esp)
80106024:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010602b:	e8 d8 f4 ff ff       	call   80105508 <argstr>
80106030:	85 c0                	test   %eax,%eax
80106032:	78 5e                	js     80106092 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106034:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106037:	89 44 24 04          	mov    %eax,0x4(%esp)
8010603b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106042:	e8 2b f4 ff ff       	call   80105472 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106047:	85 c0                	test   %eax,%eax
80106049:	78 47                	js     80106092 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010604b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010604e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106052:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106059:	e8 14 f4 ff ff       	call   80105472 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010605e:	85 c0                	test   %eax,%eax
80106060:	78 30                	js     80106092 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106062:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106065:	0f bf c8             	movswl %ax,%ecx
80106068:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010606b:	0f bf d0             	movswl %ax,%edx
8010606e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106071:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106075:	89 54 24 08          	mov    %edx,0x8(%esp)
80106079:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106080:	00 
80106081:	89 04 24             	mov    %eax,(%esp)
80106084:	e8 c2 fb ff ff       	call   80105c4b <create>
80106089:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010608c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106090:	75 0c                	jne    8010609e <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106092:	e8 ae d4 ff ff       	call   80103545 <end_op>
    return -1;
80106097:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609c:	eb 15                	jmp    801060b3 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010609e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a1:	89 04 24             	mov    %eax,(%esp)
801060a4:	e8 61 ba ff ff       	call   80101b0a <iunlockput>
  end_op();
801060a9:	e8 97 d4 ff ff       	call   80103545 <end_op>
  return 0;
801060ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060b3:	c9                   	leave  
801060b4:	c3                   	ret    

801060b5 <sys_chdir>:

int
sys_chdir(void)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060bb:	e8 03 d4 ff ff       	call   801034c3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801060c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801060c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060ce:	e8 35 f4 ff ff       	call   80105508 <argstr>
801060d3:	85 c0                	test   %eax,%eax
801060d5:	78 14                	js     801060eb <sys_chdir+0x36>
801060d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060da:	89 04 24             	mov    %eax,(%esp)
801060dd:	e8 4f c3 ff ff       	call   80102431 <namei>
801060e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060e9:	75 0c                	jne    801060f7 <sys_chdir+0x42>
    end_op();
801060eb:	e8 55 d4 ff ff       	call   80103545 <end_op>
    return -1;
801060f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f5:	eb 60                	jmp    80106157 <sys_chdir+0xa2>
  }
  ilock(ip);
801060f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fa:	89 04 24             	mov    %eax,(%esp)
801060fd:	e8 1c b8 ff ff       	call   8010191e <ilock>
  if(ip->type != T_DIR){
80106102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106105:	8b 40 50             	mov    0x50(%eax),%eax
80106108:	66 83 f8 01          	cmp    $0x1,%ax
8010610c:	74 17                	je     80106125 <sys_chdir+0x70>
    iunlockput(ip);
8010610e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106111:	89 04 24             	mov    %eax,(%esp)
80106114:	e8 f1 b9 ff ff       	call   80101b0a <iunlockput>
    end_op();
80106119:	e8 27 d4 ff ff       	call   80103545 <end_op>
    return -1;
8010611e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106123:	eb 32                	jmp    80106157 <sys_chdir+0xa2>
  }
  iunlock(ip);
80106125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106128:	89 04 24             	mov    %eax,(%esp)
8010612b:	e8 02 b9 ff ff       	call   80101a32 <iunlock>
  iput(proc->cwd);
80106130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106136:	8b 40 68             	mov    0x68(%eax),%eax
80106139:	89 04 24             	mov    %eax,(%esp)
8010613c:	e8 35 b9 ff ff       	call   80101a76 <iput>
  end_op();
80106141:	e8 ff d3 ff ff       	call   80103545 <end_op>
  proc->cwd = ip;
80106146:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010614c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010614f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106152:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106157:	c9                   	leave  
80106158:	c3                   	ret    

80106159 <sys_exec>:

int
sys_exec(void)
{
80106159:	55                   	push   %ebp
8010615a:	89 e5                	mov    %esp,%ebp
8010615c:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106162:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106165:	89 44 24 04          	mov    %eax,0x4(%esp)
80106169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106170:	e8 93 f3 ff ff       	call   80105508 <argstr>
80106175:	85 c0                	test   %eax,%eax
80106177:	78 1a                	js     80106193 <sys_exec+0x3a>
80106179:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010617f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010618a:	e8 e3 f2 ff ff       	call   80105472 <argint>
8010618f:	85 c0                	test   %eax,%eax
80106191:	79 0a                	jns    8010619d <sys_exec+0x44>
    return -1;
80106193:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106198:	e9 c7 00 00 00       	jmp    80106264 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
8010619d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801061a4:	00 
801061a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061ac:	00 
801061ad:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061b3:	89 04 24             	mov    %eax,(%esp)
801061b6:	e8 8b ef ff ff       	call   80105146 <memset>
  for(i=0;; i++){
801061bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801061c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c5:	83 f8 1f             	cmp    $0x1f,%eax
801061c8:	76 0a                	jbe    801061d4 <sys_exec+0x7b>
      return -1;
801061ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cf:	e9 90 00 00 00       	jmp    80106264 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801061d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d7:	c1 e0 02             	shl    $0x2,%eax
801061da:	89 c2                	mov    %eax,%edx
801061dc:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801061e2:	01 c2                	add    %eax,%edx
801061e4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801061ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ee:	89 14 24             	mov    %edx,(%esp)
801061f1:	e8 e2 f1 ff ff       	call   801053d8 <fetchint>
801061f6:	85 c0                	test   %eax,%eax
801061f8:	79 07                	jns    80106201 <sys_exec+0xa8>
      return -1;
801061fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ff:	eb 63                	jmp    80106264 <sys_exec+0x10b>
    if(uarg == 0){
80106201:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106207:	85 c0                	test   %eax,%eax
80106209:	75 26                	jne    80106231 <sys_exec+0xd8>
      argv[i] = 0;
8010620b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106215:	00 00 00 00 
      break;
80106219:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010621a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106223:	89 54 24 04          	mov    %edx,0x4(%esp)
80106227:	89 04 24             	mov    %eax,(%esp)
8010622a:	e8 d1 a8 ff ff       	call   80100b00 <exec>
8010622f:	eb 33                	jmp    80106264 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106231:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106237:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010623a:	c1 e2 02             	shl    $0x2,%edx
8010623d:	01 c2                	add    %eax,%edx
8010623f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106245:	89 54 24 04          	mov    %edx,0x4(%esp)
80106249:	89 04 24             	mov    %eax,(%esp)
8010624c:	e8 c1 f1 ff ff       	call   80105412 <fetchstr>
80106251:	85 c0                	test   %eax,%eax
80106253:	79 07                	jns    8010625c <sys_exec+0x103>
      return -1;
80106255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625a:	eb 08                	jmp    80106264 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010625c:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010625f:	e9 5e ff ff ff       	jmp    801061c2 <sys_exec+0x69>
  return exec(path, argv);
}
80106264:	c9                   	leave  
80106265:	c3                   	ret    

80106266 <sys_pipe>:

int
sys_pipe(void)
{
80106266:	55                   	push   %ebp
80106267:	89 e5                	mov    %esp,%ebp
80106269:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010626c:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106273:	00 
80106274:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106277:	89 44 24 04          	mov    %eax,0x4(%esp)
8010627b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106282:	e8 19 f2 ff ff       	call   801054a0 <argptr>
80106287:	85 c0                	test   %eax,%eax
80106289:	79 0a                	jns    80106295 <sys_pipe+0x2f>
    return -1;
8010628b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106290:	e9 9b 00 00 00       	jmp    80106330 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106295:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106298:	89 44 24 04          	mov    %eax,0x4(%esp)
8010629c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010629f:	89 04 24             	mov    %eax,(%esp)
801062a2:	e8 49 dc ff ff       	call   80103ef0 <pipealloc>
801062a7:	85 c0                	test   %eax,%eax
801062a9:	79 07                	jns    801062b2 <sys_pipe+0x4c>
    return -1;
801062ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b0:	eb 7e                	jmp    80106330 <sys_pipe+0xca>
  fd0 = -1;
801062b2:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801062b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062bc:	89 04 24             	mov    %eax,(%esp)
801062bf:	e8 81 f3 ff ff       	call   80105645 <fdalloc>
801062c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062cb:	78 14                	js     801062e1 <sys_pipe+0x7b>
801062cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d0:	89 04 24             	mov    %eax,(%esp)
801062d3:	e8 6d f3 ff ff       	call   80105645 <fdalloc>
801062d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062df:	79 37                	jns    80106318 <sys_pipe+0xb2>
    if(fd0 >= 0)
801062e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e5:	78 14                	js     801062fb <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801062e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062f0:	83 c2 08             	add    $0x8,%edx
801062f3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801062fa:	00 
    fileclose(rf);
801062fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062fe:	89 04 24             	mov    %eax,(%esp)
80106301:	e8 fe ac ff ff       	call   80101004 <fileclose>
    fileclose(wf);
80106306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106309:	89 04 24             	mov    %eax,(%esp)
8010630c:	e8 f3 ac ff ff       	call   80101004 <fileclose>
    return -1;
80106311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106316:	eb 18                	jmp    80106330 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106318:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010631b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010631e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106320:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106323:	8d 50 04             	lea    0x4(%eax),%edx
80106326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106329:	89 02                	mov    %eax,(%edx)
  return 0;
8010632b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106330:	c9                   	leave  
80106331:	c3                   	ret    
	...

80106334 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106334:	55                   	push   %ebp
80106335:	89 e5                	mov    %esp,%ebp
80106337:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010633a:	e8 71 e2 ff ff       	call   801045b0 <fork>
}
8010633f:	c9                   	leave  
80106340:	c3                   	ret    

80106341 <sys_exit>:

int
sys_exit(void)
{
80106341:	55                   	push   %ebp
80106342:	89 e5                	mov    %esp,%ebp
80106344:	83 ec 08             	sub    $0x8,%esp
  exit();
80106347:	e8 de e3 ff ff       	call   8010472a <exit>
  return 0;  // not reached
8010634c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106351:	c9                   	leave  
80106352:	c3                   	ret    

80106353 <sys_wait>:

int
sys_wait(void)
{
80106353:	55                   	push   %ebp
80106354:	89 e5                	mov    %esp,%ebp
80106356:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106359:	e8 ed e4 ff ff       	call   8010484b <wait>
}
8010635e:	c9                   	leave  
8010635f:	c3                   	ret    

80106360 <sys_kill>:

int
sys_kill(void)
{
80106360:	55                   	push   %ebp
80106361:	89 e5                	mov    %esp,%ebp
80106363:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106366:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106369:	89 44 24 04          	mov    %eax,0x4(%esp)
8010636d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106374:	e8 f9 f0 ff ff       	call   80105472 <argint>
80106379:	85 c0                	test   %eax,%eax
8010637b:	79 07                	jns    80106384 <sys_kill+0x24>
    return -1;
8010637d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106382:	eb 0b                	jmp    8010638f <sys_kill+0x2f>
  return kill(pid);
80106384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106387:	89 04 24             	mov    %eax,(%esp)
8010638a:	e8 87 e8 ff ff       	call   80104c16 <kill>
}
8010638f:	c9                   	leave  
80106390:	c3                   	ret    

80106391 <sys_getpid>:

int
sys_getpid(void)
{
80106391:	55                   	push   %ebp
80106392:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106394:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010639a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010639d:	5d                   	pop    %ebp
8010639e:	c3                   	ret    

8010639f <sys_sbrk>:

int
sys_sbrk(void)
{
8010639f:	55                   	push   %ebp
801063a0:	89 e5                	mov    %esp,%ebp
801063a2:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801063a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801063ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063b3:	e8 ba f0 ff ff       	call   80105472 <argint>
801063b8:	85 c0                	test   %eax,%eax
801063ba:	79 07                	jns    801063c3 <sys_sbrk+0x24>
    return -1;
801063bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c1:	eb 24                	jmp    801063e7 <sys_sbrk+0x48>
  addr = proc->sz;
801063c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063c9:	8b 00                	mov    (%eax),%eax
801063cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801063ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d1:	89 04 24             	mov    %eax,(%esp)
801063d4:	e8 32 e1 ff ff       	call   8010450b <growproc>
801063d9:	85 c0                	test   %eax,%eax
801063db:	79 07                	jns    801063e4 <sys_sbrk+0x45>
    return -1;
801063dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e2:	eb 03                	jmp    801063e7 <sys_sbrk+0x48>
  return addr;
801063e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063e7:	c9                   	leave  
801063e8:	c3                   	ret    

801063e9 <sys_sleep>:

int
sys_sleep(void)
{
801063e9:	55                   	push   %ebp
801063ea:	89 e5                	mov    %esp,%ebp
801063ec:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801063ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063fd:	e8 70 f0 ff ff       	call   80105472 <argint>
80106402:	85 c0                	test   %eax,%eax
80106404:	79 07                	jns    8010640d <sys_sleep+0x24>
    return -1;
80106406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640b:	eb 6c                	jmp    80106479 <sys_sleep+0x90>
  acquire(&tickslock);
8010640d:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
80106414:	e8 ca ea ff ff       	call   80104ee3 <acquire>
  ticks0 = ticks;
80106419:	a1 a0 65 11 80       	mov    0x801165a0,%eax
8010641e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106421:	eb 34                	jmp    80106457 <sys_sleep+0x6e>
    if(proc->killed){
80106423:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106429:	8b 40 24             	mov    0x24(%eax),%eax
8010642c:	85 c0                	test   %eax,%eax
8010642e:	74 13                	je     80106443 <sys_sleep+0x5a>
      release(&tickslock);
80106430:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
80106437:	e8 0e eb ff ff       	call   80104f4a <release>
      return -1;
8010643c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106441:	eb 36                	jmp    80106479 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106443:	c7 44 24 04 60 5d 11 	movl   $0x80115d60,0x4(%esp)
8010644a:	80 
8010644b:	c7 04 24 a0 65 11 80 	movl   $0x801165a0,(%esp)
80106452:	e8 bb e6 ff ff       	call   80104b12 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106457:	a1 a0 65 11 80       	mov    0x801165a0,%eax
8010645c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010645f:	89 c2                	mov    %eax,%edx
80106461:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106464:	39 c2                	cmp    %eax,%edx
80106466:	72 bb                	jb     80106423 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106468:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
8010646f:	e8 d6 ea ff ff       	call   80104f4a <release>
  return 0;
80106474:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106479:	c9                   	leave  
8010647a:	c3                   	ret    

8010647b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010647b:	55                   	push   %ebp
8010647c:	89 e5                	mov    %esp,%ebp
8010647e:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106481:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
80106488:	e8 56 ea ff ff       	call   80104ee3 <acquire>
  xticks = ticks;
8010648d:	a1 a0 65 11 80       	mov    0x801165a0,%eax
80106492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106495:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
8010649c:	e8 a9 ea ff ff       	call   80104f4a <release>
  return xticks;
801064a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064a4:	c9                   	leave  
801064a5:	c3                   	ret    
	...

801064a8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801064a8:	55                   	push   %ebp
801064a9:	89 e5                	mov    %esp,%ebp
801064ab:	83 ec 08             	sub    $0x8,%esp
801064ae:	8b 45 08             	mov    0x8(%ebp),%eax
801064b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801064b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801064b8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064bb:	8a 45 f8             	mov    -0x8(%ebp),%al
801064be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801064c1:	ee                   	out    %al,(%dx)
}
801064c2:	c9                   	leave  
801064c3:	c3                   	ret    

801064c4 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801064c4:	55                   	push   %ebp
801064c5:	89 e5                	mov    %esp,%ebp
801064c7:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801064ca:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801064d1:	00 
801064d2:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801064d9:	e8 ca ff ff ff       	call   801064a8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801064de:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801064e5:	00 
801064e6:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064ed:	e8 b6 ff ff ff       	call   801064a8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801064f2:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801064f9:	00 
801064fa:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106501:	e8 a2 ff ff ff       	call   801064a8 <outb>
  picenable(IRQ_TIMER);
80106506:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010650d:	e8 72 d8 ff ff       	call   80103d84 <picenable>
}
80106512:	c9                   	leave  
80106513:	c3                   	ret    

80106514 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106514:	1e                   	push   %ds
  pushl %es
80106515:	06                   	push   %es
  pushl %fs
80106516:	0f a0                	push   %fs
  pushl %gs
80106518:	0f a8                	push   %gs
  pushal
8010651a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010651b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010651f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106521:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106523:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106527:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106529:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010652b:	54                   	push   %esp
  call trap
8010652c:	e8 c0 01 00 00       	call   801066f1 <trap>
  addl $4, %esp
80106531:	83 c4 04             	add    $0x4,%esp

80106534 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106534:	61                   	popa   
  popl %gs
80106535:	0f a9                	pop    %gs
  popl %fs
80106537:	0f a1                	pop    %fs
  popl %es
80106539:	07                   	pop    %es
  popl %ds
8010653a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010653b:	83 c4 08             	add    $0x8,%esp
  iret
8010653e:	cf                   	iret   
	...

80106540 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106540:	55                   	push   %ebp
80106541:	89 e5                	mov    %esp,%ebp
80106543:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106546:	8b 45 0c             	mov    0xc(%ebp),%eax
80106549:	48                   	dec    %eax
8010654a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010654e:	8b 45 08             	mov    0x8(%ebp),%eax
80106551:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106555:	8b 45 08             	mov    0x8(%ebp),%eax
80106558:	c1 e8 10             	shr    $0x10,%eax
8010655b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010655f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106562:	0f 01 18             	lidtl  (%eax)
}
80106565:	c9                   	leave  
80106566:	c3                   	ret    

80106567 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106567:	55                   	push   %ebp
80106568:	89 e5                	mov    %esp,%ebp
8010656a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010656d:	0f 20 d0             	mov    %cr2,%eax
80106570:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106573:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106576:	c9                   	leave  
80106577:	c3                   	ret    

80106578 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106578:	55                   	push   %ebp
80106579:	89 e5                	mov    %esp,%ebp
8010657b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010657e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106585:	e9 b8 00 00 00       	jmp    80106642 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010658a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658d:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106594:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106597:	66 89 04 d5 a0 5d 11 	mov    %ax,-0x7feea260(,%edx,8)
8010659e:	80 
8010659f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a2:	66 c7 04 c5 a2 5d 11 	movw   $0x8,-0x7feea25e(,%eax,8)
801065a9:	80 08 00 
801065ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065af:	8a 14 c5 a4 5d 11 80 	mov    -0x7feea25c(,%eax,8),%dl
801065b6:	83 e2 e0             	and    $0xffffffe0,%edx
801065b9:	88 14 c5 a4 5d 11 80 	mov    %dl,-0x7feea25c(,%eax,8)
801065c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c3:	8a 14 c5 a4 5d 11 80 	mov    -0x7feea25c(,%eax,8),%dl
801065ca:	83 e2 1f             	and    $0x1f,%edx
801065cd:	88 14 c5 a4 5d 11 80 	mov    %dl,-0x7feea25c(,%eax,8)
801065d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d7:	8a 14 c5 a5 5d 11 80 	mov    -0x7feea25b(,%eax,8),%dl
801065de:	83 e2 f0             	and    $0xfffffff0,%edx
801065e1:	83 ca 0e             	or     $0xe,%edx
801065e4:	88 14 c5 a5 5d 11 80 	mov    %dl,-0x7feea25b(,%eax,8)
801065eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ee:	8a 14 c5 a5 5d 11 80 	mov    -0x7feea25b(,%eax,8),%dl
801065f5:	83 e2 ef             	and    $0xffffffef,%edx
801065f8:	88 14 c5 a5 5d 11 80 	mov    %dl,-0x7feea25b(,%eax,8)
801065ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106602:	8a 14 c5 a5 5d 11 80 	mov    -0x7feea25b(,%eax,8),%dl
80106609:	83 e2 9f             	and    $0xffffff9f,%edx
8010660c:	88 14 c5 a5 5d 11 80 	mov    %dl,-0x7feea25b(,%eax,8)
80106613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106616:	8a 14 c5 a5 5d 11 80 	mov    -0x7feea25b(,%eax,8),%dl
8010661d:	83 ca 80             	or     $0xffffff80,%edx
80106620:	88 14 c5 a5 5d 11 80 	mov    %dl,-0x7feea25b(,%eax,8)
80106627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662a:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106631:	c1 e8 10             	shr    $0x10,%eax
80106634:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106637:	66 89 04 d5 a6 5d 11 	mov    %ax,-0x7feea25a(,%edx,8)
8010663e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010663f:	ff 45 f4             	incl   -0xc(%ebp)
80106642:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106649:	0f 8e 3b ff ff ff    	jle    8010658a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010664f:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106654:	66 a3 a0 5f 11 80    	mov    %ax,0x80115fa0
8010665a:	66 c7 05 a2 5f 11 80 	movw   $0x8,0x80115fa2
80106661:	08 00 
80106663:	a0 a4 5f 11 80       	mov    0x80115fa4,%al
80106668:	83 e0 e0             	and    $0xffffffe0,%eax
8010666b:	a2 a4 5f 11 80       	mov    %al,0x80115fa4
80106670:	a0 a4 5f 11 80       	mov    0x80115fa4,%al
80106675:	83 e0 1f             	and    $0x1f,%eax
80106678:	a2 a4 5f 11 80       	mov    %al,0x80115fa4
8010667d:	a0 a5 5f 11 80       	mov    0x80115fa5,%al
80106682:	83 c8 0f             	or     $0xf,%eax
80106685:	a2 a5 5f 11 80       	mov    %al,0x80115fa5
8010668a:	a0 a5 5f 11 80       	mov    0x80115fa5,%al
8010668f:	83 e0 ef             	and    $0xffffffef,%eax
80106692:	a2 a5 5f 11 80       	mov    %al,0x80115fa5
80106697:	a0 a5 5f 11 80       	mov    0x80115fa5,%al
8010669c:	83 c8 60             	or     $0x60,%eax
8010669f:	a2 a5 5f 11 80       	mov    %al,0x80115fa5
801066a4:	a0 a5 5f 11 80       	mov    0x80115fa5,%al
801066a9:	83 c8 80             	or     $0xffffff80,%eax
801066ac:	a2 a5 5f 11 80       	mov    %al,0x80115fa5
801066b1:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801066b6:	c1 e8 10             	shr    $0x10,%eax
801066b9:	66 a3 a6 5f 11 80    	mov    %ax,0x80115fa6

  initlock(&tickslock, "time");
801066bf:	c7 44 24 04 d0 88 10 	movl   $0x801088d0,0x4(%esp)
801066c6:	80 
801066c7:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
801066ce:	e8 ef e7 ff ff       	call   80104ec2 <initlock>
}
801066d3:	c9                   	leave  
801066d4:	c3                   	ret    

801066d5 <idtinit>:

void
idtinit(void)
{
801066d5:	55                   	push   %ebp
801066d6:	89 e5                	mov    %esp,%ebp
801066d8:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801066db:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801066e2:	00 
801066e3:	c7 04 24 a0 5d 11 80 	movl   $0x80115da0,(%esp)
801066ea:	e8 51 fe ff ff       	call   80106540 <lidt>
}
801066ef:	c9                   	leave  
801066f0:	c3                   	ret    

801066f1 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801066f1:	55                   	push   %ebp
801066f2:	89 e5                	mov    %esp,%ebp
801066f4:	57                   	push   %edi
801066f5:	56                   	push   %esi
801066f6:	53                   	push   %ebx
801066f7:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801066fa:	8b 45 08             	mov    0x8(%ebp),%eax
801066fd:	8b 40 30             	mov    0x30(%eax),%eax
80106700:	83 f8 40             	cmp    $0x40,%eax
80106703:	75 3f                	jne    80106744 <trap+0x53>
    if(proc->killed)
80106705:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010670b:	8b 40 24             	mov    0x24(%eax),%eax
8010670e:	85 c0                	test   %eax,%eax
80106710:	74 05                	je     80106717 <trap+0x26>
      exit();
80106712:	e8 13 e0 ff ff       	call   8010472a <exit>
    proc->tf = tf;
80106717:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010671d:	8b 55 08             	mov    0x8(%ebp),%edx
80106720:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106723:	e8 17 ee ff ff       	call   8010553f <syscall>
    if(proc->killed)
80106728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010672e:	8b 40 24             	mov    0x24(%eax),%eax
80106731:	85 c0                	test   %eax,%eax
80106733:	74 0a                	je     8010673f <trap+0x4e>
      exit();
80106735:	e8 f0 df ff ff       	call   8010472a <exit>
    return;
8010673a:	e9 11 02 00 00       	jmp    80106950 <trap+0x25f>
8010673f:	e9 0c 02 00 00       	jmp    80106950 <trap+0x25f>
  }

  switch(tf->trapno){
80106744:	8b 45 08             	mov    0x8(%ebp),%eax
80106747:	8b 40 30             	mov    0x30(%eax),%eax
8010674a:	83 e8 20             	sub    $0x20,%eax
8010674d:	83 f8 1f             	cmp    $0x1f,%eax
80106750:	0f 87 ae 00 00 00    	ja     80106804 <trap+0x113>
80106756:	8b 04 85 78 89 10 80 	mov    -0x7fef7688(,%eax,4),%eax
8010675d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpunum() == 0){
8010675f:	e8 8d c7 ff ff       	call   80102ef1 <cpunum>
80106764:	85 c0                	test   %eax,%eax
80106766:	75 2f                	jne    80106797 <trap+0xa6>
      acquire(&tickslock);
80106768:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
8010676f:	e8 6f e7 ff ff       	call   80104ee3 <acquire>
      ticks++;
80106774:	a1 a0 65 11 80       	mov    0x801165a0,%eax
80106779:	40                   	inc    %eax
8010677a:	a3 a0 65 11 80       	mov    %eax,0x801165a0
      wakeup(&ticks);
8010677f:	c7 04 24 a0 65 11 80 	movl   $0x801165a0,(%esp)
80106786:	e8 60 e4 ff ff       	call   80104beb <wakeup>
      release(&tickslock);
8010678b:	c7 04 24 60 5d 11 80 	movl   $0x80115d60,(%esp)
80106792:	e8 b3 e7 ff ff       	call   80104f4a <release>
    }
    lapiceoi();
80106797:	e8 fd c7 ff ff       	call   80102f99 <lapiceoi>
    break;
8010679c:	e9 2d 01 00 00       	jmp    801068ce <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067a1:	e8 c4 bf ff ff       	call   8010276a <ideintr>
    lapiceoi();
801067a6:	e8 ee c7 ff ff       	call   80102f99 <lapiceoi>
    break;
801067ab:	e9 1e 01 00 00       	jmp    801068ce <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067b0:	e8 65 c5 ff ff       	call   80102d1a <kbdintr>
    lapiceoi();
801067b5:	e8 df c7 ff ff       	call   80102f99 <lapiceoi>
    break;
801067ba:	e9 0f 01 00 00       	jmp    801068ce <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067bf:	e8 79 03 00 00       	call   80106b3d <uartintr>
    lapiceoi();
801067c4:	e8 d0 c7 ff ff       	call   80102f99 <lapiceoi>
    break;
801067c9:	e9 00 01 00 00       	jmp    801068ce <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067ce:	8b 45 08             	mov    0x8(%ebp),%eax
801067d1:	8b 70 38             	mov    0x38(%eax),%esi
            cpunum(), tf->cs, tf->eip);
801067d4:	8b 45 08             	mov    0x8(%ebp),%eax
801067d7:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067da:	0f b7 d8             	movzwl %ax,%ebx
801067dd:	e8 0f c7 ff ff       	call   80102ef1 <cpunum>
801067e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
801067e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801067ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801067ee:	c7 04 24 d8 88 10 80 	movl   $0x801088d8,(%esp)
801067f5:	e8 c7 9b ff ff       	call   801003c1 <cprintf>
            cpunum(), tf->cs, tf->eip);
    lapiceoi();
801067fa:	e8 9a c7 ff ff       	call   80102f99 <lapiceoi>
    break;
801067ff:	e9 ca 00 00 00       	jmp    801068ce <trap+0x1dd>

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106804:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010680a:	85 c0                	test   %eax,%eax
8010680c:	74 10                	je     8010681e <trap+0x12d>
8010680e:	8b 45 08             	mov    0x8(%ebp),%eax
80106811:	8b 40 3c             	mov    0x3c(%eax),%eax
80106814:	0f b7 c0             	movzwl %ax,%eax
80106817:	83 e0 03             	and    $0x3,%eax
8010681a:	85 c0                	test   %eax,%eax
8010681c:	75 40                	jne    8010685e <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010681e:	e8 44 fd ff ff       	call   80106567 <rcr2>
80106823:	89 c3                	mov    %eax,%ebx
80106825:	8b 45 08             	mov    0x8(%ebp),%eax
80106828:	8b 70 38             	mov    0x38(%eax),%esi
8010682b:	e8 c1 c6 ff ff       	call   80102ef1 <cpunum>
80106830:	8b 55 08             	mov    0x8(%ebp),%edx
80106833:	8b 52 30             	mov    0x30(%edx),%edx
80106836:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010683a:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010683e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106842:	89 54 24 04          	mov    %edx,0x4(%esp)
80106846:	c7 04 24 fc 88 10 80 	movl   $0x801088fc,(%esp)
8010684d:	e8 6f 9b ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpunum(), tf->eip, rcr2());
      panic("trap");
80106852:	c7 04 24 2e 89 10 80 	movl   $0x8010892e,(%esp)
80106859:	e8 f6 9c ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010685e:	e8 04 fd ff ff       	call   80106567 <rcr2>
80106863:	89 c3                	mov    %eax,%ebx
80106865:	8b 45 08             	mov    0x8(%ebp),%eax
80106868:	8b 78 38             	mov    0x38(%eax),%edi
8010686b:	e8 81 c6 ff ff       	call   80102ef1 <cpunum>
80106870:	89 c2                	mov    %eax,%edx
80106872:	8b 45 08             	mov    0x8(%ebp),%eax
80106875:	8b 70 34             	mov    0x34(%eax),%esi
80106878:	8b 45 08             	mov    0x8(%ebp),%eax
8010687b:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
8010687e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106884:	83 c0 6c             	add    $0x6c,%eax
80106887:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010688a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpunum(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106890:	8b 40 10             	mov    0x10(%eax),%eax
80106893:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
80106897:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010689b:	89 54 24 14          	mov    %edx,0x14(%esp)
8010689f:	89 74 24 10          	mov    %esi,0x10(%esp)
801068a3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801068a7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801068aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801068ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801068b2:	c7 04 24 34 89 10 80 	movl   $0x80108934,(%esp)
801068b9:	e8 03 9b ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
            rcr2());
    proc->killed = 1;
801068be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068c4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068cb:	eb 01                	jmp    801068ce <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801068cd:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801068ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068d4:	85 c0                	test   %eax,%eax
801068d6:	74 23                	je     801068fb <trap+0x20a>
801068d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068de:	8b 40 24             	mov    0x24(%eax),%eax
801068e1:	85 c0                	test   %eax,%eax
801068e3:	74 16                	je     801068fb <trap+0x20a>
801068e5:	8b 45 08             	mov    0x8(%ebp),%eax
801068e8:	8b 40 3c             	mov    0x3c(%eax),%eax
801068eb:	0f b7 c0             	movzwl %ax,%eax
801068ee:	83 e0 03             	and    $0x3,%eax
801068f1:	83 f8 03             	cmp    $0x3,%eax
801068f4:	75 05                	jne    801068fb <trap+0x20a>
    exit();
801068f6:	e8 2f de ff ff       	call   8010472a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801068fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106901:	85 c0                	test   %eax,%eax
80106903:	74 1e                	je     80106923 <trap+0x232>
80106905:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010690b:	8b 40 0c             	mov    0xc(%eax),%eax
8010690e:	83 f8 04             	cmp    $0x4,%eax
80106911:	75 10                	jne    80106923 <trap+0x232>
80106913:	8b 45 08             	mov    0x8(%ebp),%eax
80106916:	8b 40 30             	mov    0x30(%eax),%eax
80106919:	83 f8 20             	cmp    $0x20,%eax
8010691c:	75 05                	jne    80106923 <trap+0x232>
    yield();
8010691e:	e8 7e e1 ff ff       	call   80104aa1 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106923:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106929:	85 c0                	test   %eax,%eax
8010692b:	74 23                	je     80106950 <trap+0x25f>
8010692d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106933:	8b 40 24             	mov    0x24(%eax),%eax
80106936:	85 c0                	test   %eax,%eax
80106938:	74 16                	je     80106950 <trap+0x25f>
8010693a:	8b 45 08             	mov    0x8(%ebp),%eax
8010693d:	8b 40 3c             	mov    0x3c(%eax),%eax
80106940:	0f b7 c0             	movzwl %ax,%eax
80106943:	83 e0 03             	and    $0x3,%eax
80106946:	83 f8 03             	cmp    $0x3,%eax
80106949:	75 05                	jne    80106950 <trap+0x25f>
    exit();
8010694b:	e8 da dd ff ff       	call   8010472a <exit>
}
80106950:	83 c4 3c             	add    $0x3c,%esp
80106953:	5b                   	pop    %ebx
80106954:	5e                   	pop    %esi
80106955:	5f                   	pop    %edi
80106956:	5d                   	pop    %ebp
80106957:	c3                   	ret    

80106958 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106958:	55                   	push   %ebp
80106959:	89 e5                	mov    %esp,%ebp
8010695b:	83 ec 14             	sub    $0x14,%esp
8010695e:	8b 45 08             	mov    0x8(%ebp),%eax
80106961:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106965:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106968:	89 c2                	mov    %eax,%edx
8010696a:	ec                   	in     (%dx),%al
8010696b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010696e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106971:	c9                   	leave  
80106972:	c3                   	ret    

80106973 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106973:	55                   	push   %ebp
80106974:	89 e5                	mov    %esp,%ebp
80106976:	83 ec 08             	sub    $0x8,%esp
80106979:	8b 45 08             	mov    0x8(%ebp),%eax
8010697c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010697f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106983:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106986:	8a 45 f8             	mov    -0x8(%ebp),%al
80106989:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010698c:	ee                   	out    %al,(%dx)
}
8010698d:	c9                   	leave  
8010698e:	c3                   	ret    

8010698f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010698f:	55                   	push   %ebp
80106990:	89 e5                	mov    %esp,%ebp
80106992:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106995:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010699c:	00 
8010699d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801069a4:	e8 ca ff ff ff       	call   80106973 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801069a9:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801069b0:	00 
801069b1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801069b8:	e8 b6 ff ff ff       	call   80106973 <outb>
  outb(COM1+0, 115200/9600);
801069bd:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801069c4:	00 
801069c5:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069cc:	e8 a2 ff ff ff       	call   80106973 <outb>
  outb(COM1+1, 0);
801069d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069d8:	00 
801069d9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801069e0:	e8 8e ff ff ff       	call   80106973 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801069e5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801069ec:	00 
801069ed:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801069f4:	e8 7a ff ff ff       	call   80106973 <outb>
  outb(COM1+4, 0);
801069f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a00:	00 
80106a01:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106a08:	e8 66 ff ff ff       	call   80106973 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106a0d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106a14:	00 
80106a15:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a1c:	e8 52 ff ff ff       	call   80106973 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a21:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a28:	e8 2b ff ff ff       	call   80106958 <inb>
80106a2d:	3c ff                	cmp    $0xff,%al
80106a2f:	75 02                	jne    80106a33 <uartinit+0xa4>
    return;
80106a31:	eb 67                	jmp    80106a9a <uartinit+0x10b>
  uart = 1;
80106a33:	c7 05 48 b6 10 80 01 	movl   $0x1,0x8010b648
80106a3a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a3d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106a44:	e8 0f ff ff ff       	call   80106958 <inb>
  inb(COM1+0);
80106a49:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a50:	e8 03 ff ff ff       	call   80106958 <inb>
  picenable(IRQ_COM1);
80106a55:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a5c:	e8 23 d3 ff ff       	call   80103d84 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106a61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a68:	00 
80106a69:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a70:	e8 78 bf ff ff       	call   801029ed <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a75:	c7 45 f4 f8 89 10 80 	movl   $0x801089f8,-0xc(%ebp)
80106a7c:	eb 13                	jmp    80106a91 <uartinit+0x102>
    uartputc(*p);
80106a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a81:	8a 00                	mov    (%eax),%al
80106a83:	0f be c0             	movsbl %al,%eax
80106a86:	89 04 24             	mov    %eax,(%esp)
80106a89:	e8 0e 00 00 00       	call   80106a9c <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a8e:	ff 45 f4             	incl   -0xc(%ebp)
80106a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a94:	8a 00                	mov    (%eax),%al
80106a96:	84 c0                	test   %al,%al
80106a98:	75 e4                	jne    80106a7e <uartinit+0xef>
    uartputc(*p);
}
80106a9a:	c9                   	leave  
80106a9b:	c3                   	ret    

80106a9c <uartputc>:

void
uartputc(int c)
{
80106a9c:	55                   	push   %ebp
80106a9d:	89 e5                	mov    %esp,%ebp
80106a9f:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106aa2:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80106aa7:	85 c0                	test   %eax,%eax
80106aa9:	75 02                	jne    80106aad <uartputc+0x11>
    return;
80106aab:	eb 4a                	jmp    80106af7 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106aad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ab4:	eb 0f                	jmp    80106ac5 <uartputc+0x29>
    microdelay(10);
80106ab6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106abd:	e8 fc c4 ff ff       	call   80102fbe <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ac2:	ff 45 f4             	incl   -0xc(%ebp)
80106ac5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ac9:	7f 16                	jg     80106ae1 <uartputc+0x45>
80106acb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ad2:	e8 81 fe ff ff       	call   80106958 <inb>
80106ad7:	0f b6 c0             	movzbl %al,%eax
80106ada:	83 e0 20             	and    $0x20,%eax
80106add:	85 c0                	test   %eax,%eax
80106adf:	74 d5                	je     80106ab6 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae4:	0f b6 c0             	movzbl %al,%eax
80106ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aeb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106af2:	e8 7c fe ff ff       	call   80106973 <outb>
}
80106af7:	c9                   	leave  
80106af8:	c3                   	ret    

80106af9 <uartgetc>:

static int
uartgetc(void)
{
80106af9:	55                   	push   %ebp
80106afa:	89 e5                	mov    %esp,%ebp
80106afc:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106aff:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80106b04:	85 c0                	test   %eax,%eax
80106b06:	75 07                	jne    80106b0f <uartgetc+0x16>
    return -1;
80106b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b0d:	eb 2c                	jmp    80106b3b <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106b0f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b16:	e8 3d fe ff ff       	call   80106958 <inb>
80106b1b:	0f b6 c0             	movzbl %al,%eax
80106b1e:	83 e0 01             	and    $0x1,%eax
80106b21:	85 c0                	test   %eax,%eax
80106b23:	75 07                	jne    80106b2c <uartgetc+0x33>
    return -1;
80106b25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2a:	eb 0f                	jmp    80106b3b <uartgetc+0x42>
  return inb(COM1+0);
80106b2c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b33:	e8 20 fe ff ff       	call   80106958 <inb>
80106b38:	0f b6 c0             	movzbl %al,%eax
}
80106b3b:	c9                   	leave  
80106b3c:	c3                   	ret    

80106b3d <uartintr>:

void
uartintr(void)
{
80106b3d:	55                   	push   %ebp
80106b3e:	89 e5                	mov    %esp,%ebp
80106b40:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106b43:	c7 04 24 f9 6a 10 80 	movl   $0x80106af9,(%esp)
80106b4a:	e8 7c 9c ff ff       	call   801007cb <consoleintr>
}
80106b4f:	c9                   	leave  
80106b50:	c3                   	ret    
80106b51:	00 00                	add    %al,(%eax)
	...

80106b54 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b54:	6a 00                	push   $0x0
  pushl $0
80106b56:	6a 00                	push   $0x0
  jmp alltraps
80106b58:	e9 b7 f9 ff ff       	jmp    80106514 <alltraps>

80106b5d <vector1>:
.globl vector1
vector1:
  pushl $0
80106b5d:	6a 00                	push   $0x0
  pushl $1
80106b5f:	6a 01                	push   $0x1
  jmp alltraps
80106b61:	e9 ae f9 ff ff       	jmp    80106514 <alltraps>

80106b66 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b66:	6a 00                	push   $0x0
  pushl $2
80106b68:	6a 02                	push   $0x2
  jmp alltraps
80106b6a:	e9 a5 f9 ff ff       	jmp    80106514 <alltraps>

80106b6f <vector3>:
.globl vector3
vector3:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $3
80106b71:	6a 03                	push   $0x3
  jmp alltraps
80106b73:	e9 9c f9 ff ff       	jmp    80106514 <alltraps>

80106b78 <vector4>:
.globl vector4
vector4:
  pushl $0
80106b78:	6a 00                	push   $0x0
  pushl $4
80106b7a:	6a 04                	push   $0x4
  jmp alltraps
80106b7c:	e9 93 f9 ff ff       	jmp    80106514 <alltraps>

80106b81 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b81:	6a 00                	push   $0x0
  pushl $5
80106b83:	6a 05                	push   $0x5
  jmp alltraps
80106b85:	e9 8a f9 ff ff       	jmp    80106514 <alltraps>

80106b8a <vector6>:
.globl vector6
vector6:
  pushl $0
80106b8a:	6a 00                	push   $0x0
  pushl $6
80106b8c:	6a 06                	push   $0x6
  jmp alltraps
80106b8e:	e9 81 f9 ff ff       	jmp    80106514 <alltraps>

80106b93 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b93:	6a 00                	push   $0x0
  pushl $7
80106b95:	6a 07                	push   $0x7
  jmp alltraps
80106b97:	e9 78 f9 ff ff       	jmp    80106514 <alltraps>

80106b9c <vector8>:
.globl vector8
vector8:
  pushl $8
80106b9c:	6a 08                	push   $0x8
  jmp alltraps
80106b9e:	e9 71 f9 ff ff       	jmp    80106514 <alltraps>

80106ba3 <vector9>:
.globl vector9
vector9:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $9
80106ba5:	6a 09                	push   $0x9
  jmp alltraps
80106ba7:	e9 68 f9 ff ff       	jmp    80106514 <alltraps>

80106bac <vector10>:
.globl vector10
vector10:
  pushl $10
80106bac:	6a 0a                	push   $0xa
  jmp alltraps
80106bae:	e9 61 f9 ff ff       	jmp    80106514 <alltraps>

80106bb3 <vector11>:
.globl vector11
vector11:
  pushl $11
80106bb3:	6a 0b                	push   $0xb
  jmp alltraps
80106bb5:	e9 5a f9 ff ff       	jmp    80106514 <alltraps>

80106bba <vector12>:
.globl vector12
vector12:
  pushl $12
80106bba:	6a 0c                	push   $0xc
  jmp alltraps
80106bbc:	e9 53 f9 ff ff       	jmp    80106514 <alltraps>

80106bc1 <vector13>:
.globl vector13
vector13:
  pushl $13
80106bc1:	6a 0d                	push   $0xd
  jmp alltraps
80106bc3:	e9 4c f9 ff ff       	jmp    80106514 <alltraps>

80106bc8 <vector14>:
.globl vector14
vector14:
  pushl $14
80106bc8:	6a 0e                	push   $0xe
  jmp alltraps
80106bca:	e9 45 f9 ff ff       	jmp    80106514 <alltraps>

80106bcf <vector15>:
.globl vector15
vector15:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $15
80106bd1:	6a 0f                	push   $0xf
  jmp alltraps
80106bd3:	e9 3c f9 ff ff       	jmp    80106514 <alltraps>

80106bd8 <vector16>:
.globl vector16
vector16:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $16
80106bda:	6a 10                	push   $0x10
  jmp alltraps
80106bdc:	e9 33 f9 ff ff       	jmp    80106514 <alltraps>

80106be1 <vector17>:
.globl vector17
vector17:
  pushl $17
80106be1:	6a 11                	push   $0x11
  jmp alltraps
80106be3:	e9 2c f9 ff ff       	jmp    80106514 <alltraps>

80106be8 <vector18>:
.globl vector18
vector18:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $18
80106bea:	6a 12                	push   $0x12
  jmp alltraps
80106bec:	e9 23 f9 ff ff       	jmp    80106514 <alltraps>

80106bf1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $19
80106bf3:	6a 13                	push   $0x13
  jmp alltraps
80106bf5:	e9 1a f9 ff ff       	jmp    80106514 <alltraps>

80106bfa <vector20>:
.globl vector20
vector20:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $20
80106bfc:	6a 14                	push   $0x14
  jmp alltraps
80106bfe:	e9 11 f9 ff ff       	jmp    80106514 <alltraps>

80106c03 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $21
80106c05:	6a 15                	push   $0x15
  jmp alltraps
80106c07:	e9 08 f9 ff ff       	jmp    80106514 <alltraps>

80106c0c <vector22>:
.globl vector22
vector22:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $22
80106c0e:	6a 16                	push   $0x16
  jmp alltraps
80106c10:	e9 ff f8 ff ff       	jmp    80106514 <alltraps>

80106c15 <vector23>:
.globl vector23
vector23:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $23
80106c17:	6a 17                	push   $0x17
  jmp alltraps
80106c19:	e9 f6 f8 ff ff       	jmp    80106514 <alltraps>

80106c1e <vector24>:
.globl vector24
vector24:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $24
80106c20:	6a 18                	push   $0x18
  jmp alltraps
80106c22:	e9 ed f8 ff ff       	jmp    80106514 <alltraps>

80106c27 <vector25>:
.globl vector25
vector25:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $25
80106c29:	6a 19                	push   $0x19
  jmp alltraps
80106c2b:	e9 e4 f8 ff ff       	jmp    80106514 <alltraps>

80106c30 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $26
80106c32:	6a 1a                	push   $0x1a
  jmp alltraps
80106c34:	e9 db f8 ff ff       	jmp    80106514 <alltraps>

80106c39 <vector27>:
.globl vector27
vector27:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $27
80106c3b:	6a 1b                	push   $0x1b
  jmp alltraps
80106c3d:	e9 d2 f8 ff ff       	jmp    80106514 <alltraps>

80106c42 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $28
80106c44:	6a 1c                	push   $0x1c
  jmp alltraps
80106c46:	e9 c9 f8 ff ff       	jmp    80106514 <alltraps>

80106c4b <vector29>:
.globl vector29
vector29:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $29
80106c4d:	6a 1d                	push   $0x1d
  jmp alltraps
80106c4f:	e9 c0 f8 ff ff       	jmp    80106514 <alltraps>

80106c54 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $30
80106c56:	6a 1e                	push   $0x1e
  jmp alltraps
80106c58:	e9 b7 f8 ff ff       	jmp    80106514 <alltraps>

80106c5d <vector31>:
.globl vector31
vector31:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $31
80106c5f:	6a 1f                	push   $0x1f
  jmp alltraps
80106c61:	e9 ae f8 ff ff       	jmp    80106514 <alltraps>

80106c66 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $32
80106c68:	6a 20                	push   $0x20
  jmp alltraps
80106c6a:	e9 a5 f8 ff ff       	jmp    80106514 <alltraps>

80106c6f <vector33>:
.globl vector33
vector33:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $33
80106c71:	6a 21                	push   $0x21
  jmp alltraps
80106c73:	e9 9c f8 ff ff       	jmp    80106514 <alltraps>

80106c78 <vector34>:
.globl vector34
vector34:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $34
80106c7a:	6a 22                	push   $0x22
  jmp alltraps
80106c7c:	e9 93 f8 ff ff       	jmp    80106514 <alltraps>

80106c81 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $35
80106c83:	6a 23                	push   $0x23
  jmp alltraps
80106c85:	e9 8a f8 ff ff       	jmp    80106514 <alltraps>

80106c8a <vector36>:
.globl vector36
vector36:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $36
80106c8c:	6a 24                	push   $0x24
  jmp alltraps
80106c8e:	e9 81 f8 ff ff       	jmp    80106514 <alltraps>

80106c93 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $37
80106c95:	6a 25                	push   $0x25
  jmp alltraps
80106c97:	e9 78 f8 ff ff       	jmp    80106514 <alltraps>

80106c9c <vector38>:
.globl vector38
vector38:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $38
80106c9e:	6a 26                	push   $0x26
  jmp alltraps
80106ca0:	e9 6f f8 ff ff       	jmp    80106514 <alltraps>

80106ca5 <vector39>:
.globl vector39
vector39:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $39
80106ca7:	6a 27                	push   $0x27
  jmp alltraps
80106ca9:	e9 66 f8 ff ff       	jmp    80106514 <alltraps>

80106cae <vector40>:
.globl vector40
vector40:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $40
80106cb0:	6a 28                	push   $0x28
  jmp alltraps
80106cb2:	e9 5d f8 ff ff       	jmp    80106514 <alltraps>

80106cb7 <vector41>:
.globl vector41
vector41:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $41
80106cb9:	6a 29                	push   $0x29
  jmp alltraps
80106cbb:	e9 54 f8 ff ff       	jmp    80106514 <alltraps>

80106cc0 <vector42>:
.globl vector42
vector42:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $42
80106cc2:	6a 2a                	push   $0x2a
  jmp alltraps
80106cc4:	e9 4b f8 ff ff       	jmp    80106514 <alltraps>

80106cc9 <vector43>:
.globl vector43
vector43:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $43
80106ccb:	6a 2b                	push   $0x2b
  jmp alltraps
80106ccd:	e9 42 f8 ff ff       	jmp    80106514 <alltraps>

80106cd2 <vector44>:
.globl vector44
vector44:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $44
80106cd4:	6a 2c                	push   $0x2c
  jmp alltraps
80106cd6:	e9 39 f8 ff ff       	jmp    80106514 <alltraps>

80106cdb <vector45>:
.globl vector45
vector45:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $45
80106cdd:	6a 2d                	push   $0x2d
  jmp alltraps
80106cdf:	e9 30 f8 ff ff       	jmp    80106514 <alltraps>

80106ce4 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $46
80106ce6:	6a 2e                	push   $0x2e
  jmp alltraps
80106ce8:	e9 27 f8 ff ff       	jmp    80106514 <alltraps>

80106ced <vector47>:
.globl vector47
vector47:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $47
80106cef:	6a 2f                	push   $0x2f
  jmp alltraps
80106cf1:	e9 1e f8 ff ff       	jmp    80106514 <alltraps>

80106cf6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $48
80106cf8:	6a 30                	push   $0x30
  jmp alltraps
80106cfa:	e9 15 f8 ff ff       	jmp    80106514 <alltraps>

80106cff <vector49>:
.globl vector49
vector49:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $49
80106d01:	6a 31                	push   $0x31
  jmp alltraps
80106d03:	e9 0c f8 ff ff       	jmp    80106514 <alltraps>

80106d08 <vector50>:
.globl vector50
vector50:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $50
80106d0a:	6a 32                	push   $0x32
  jmp alltraps
80106d0c:	e9 03 f8 ff ff       	jmp    80106514 <alltraps>

80106d11 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $51
80106d13:	6a 33                	push   $0x33
  jmp alltraps
80106d15:	e9 fa f7 ff ff       	jmp    80106514 <alltraps>

80106d1a <vector52>:
.globl vector52
vector52:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $52
80106d1c:	6a 34                	push   $0x34
  jmp alltraps
80106d1e:	e9 f1 f7 ff ff       	jmp    80106514 <alltraps>

80106d23 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $53
80106d25:	6a 35                	push   $0x35
  jmp alltraps
80106d27:	e9 e8 f7 ff ff       	jmp    80106514 <alltraps>

80106d2c <vector54>:
.globl vector54
vector54:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $54
80106d2e:	6a 36                	push   $0x36
  jmp alltraps
80106d30:	e9 df f7 ff ff       	jmp    80106514 <alltraps>

80106d35 <vector55>:
.globl vector55
vector55:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $55
80106d37:	6a 37                	push   $0x37
  jmp alltraps
80106d39:	e9 d6 f7 ff ff       	jmp    80106514 <alltraps>

80106d3e <vector56>:
.globl vector56
vector56:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $56
80106d40:	6a 38                	push   $0x38
  jmp alltraps
80106d42:	e9 cd f7 ff ff       	jmp    80106514 <alltraps>

80106d47 <vector57>:
.globl vector57
vector57:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $57
80106d49:	6a 39                	push   $0x39
  jmp alltraps
80106d4b:	e9 c4 f7 ff ff       	jmp    80106514 <alltraps>

80106d50 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $58
80106d52:	6a 3a                	push   $0x3a
  jmp alltraps
80106d54:	e9 bb f7 ff ff       	jmp    80106514 <alltraps>

80106d59 <vector59>:
.globl vector59
vector59:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $59
80106d5b:	6a 3b                	push   $0x3b
  jmp alltraps
80106d5d:	e9 b2 f7 ff ff       	jmp    80106514 <alltraps>

80106d62 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $60
80106d64:	6a 3c                	push   $0x3c
  jmp alltraps
80106d66:	e9 a9 f7 ff ff       	jmp    80106514 <alltraps>

80106d6b <vector61>:
.globl vector61
vector61:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $61
80106d6d:	6a 3d                	push   $0x3d
  jmp alltraps
80106d6f:	e9 a0 f7 ff ff       	jmp    80106514 <alltraps>

80106d74 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $62
80106d76:	6a 3e                	push   $0x3e
  jmp alltraps
80106d78:	e9 97 f7 ff ff       	jmp    80106514 <alltraps>

80106d7d <vector63>:
.globl vector63
vector63:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $63
80106d7f:	6a 3f                	push   $0x3f
  jmp alltraps
80106d81:	e9 8e f7 ff ff       	jmp    80106514 <alltraps>

80106d86 <vector64>:
.globl vector64
vector64:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $64
80106d88:	6a 40                	push   $0x40
  jmp alltraps
80106d8a:	e9 85 f7 ff ff       	jmp    80106514 <alltraps>

80106d8f <vector65>:
.globl vector65
vector65:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $65
80106d91:	6a 41                	push   $0x41
  jmp alltraps
80106d93:	e9 7c f7 ff ff       	jmp    80106514 <alltraps>

80106d98 <vector66>:
.globl vector66
vector66:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $66
80106d9a:	6a 42                	push   $0x42
  jmp alltraps
80106d9c:	e9 73 f7 ff ff       	jmp    80106514 <alltraps>

80106da1 <vector67>:
.globl vector67
vector67:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $67
80106da3:	6a 43                	push   $0x43
  jmp alltraps
80106da5:	e9 6a f7 ff ff       	jmp    80106514 <alltraps>

80106daa <vector68>:
.globl vector68
vector68:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $68
80106dac:	6a 44                	push   $0x44
  jmp alltraps
80106dae:	e9 61 f7 ff ff       	jmp    80106514 <alltraps>

80106db3 <vector69>:
.globl vector69
vector69:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $69
80106db5:	6a 45                	push   $0x45
  jmp alltraps
80106db7:	e9 58 f7 ff ff       	jmp    80106514 <alltraps>

80106dbc <vector70>:
.globl vector70
vector70:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $70
80106dbe:	6a 46                	push   $0x46
  jmp alltraps
80106dc0:	e9 4f f7 ff ff       	jmp    80106514 <alltraps>

80106dc5 <vector71>:
.globl vector71
vector71:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $71
80106dc7:	6a 47                	push   $0x47
  jmp alltraps
80106dc9:	e9 46 f7 ff ff       	jmp    80106514 <alltraps>

80106dce <vector72>:
.globl vector72
vector72:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $72
80106dd0:	6a 48                	push   $0x48
  jmp alltraps
80106dd2:	e9 3d f7 ff ff       	jmp    80106514 <alltraps>

80106dd7 <vector73>:
.globl vector73
vector73:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $73
80106dd9:	6a 49                	push   $0x49
  jmp alltraps
80106ddb:	e9 34 f7 ff ff       	jmp    80106514 <alltraps>

80106de0 <vector74>:
.globl vector74
vector74:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $74
80106de2:	6a 4a                	push   $0x4a
  jmp alltraps
80106de4:	e9 2b f7 ff ff       	jmp    80106514 <alltraps>

80106de9 <vector75>:
.globl vector75
vector75:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $75
80106deb:	6a 4b                	push   $0x4b
  jmp alltraps
80106ded:	e9 22 f7 ff ff       	jmp    80106514 <alltraps>

80106df2 <vector76>:
.globl vector76
vector76:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $76
80106df4:	6a 4c                	push   $0x4c
  jmp alltraps
80106df6:	e9 19 f7 ff ff       	jmp    80106514 <alltraps>

80106dfb <vector77>:
.globl vector77
vector77:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $77
80106dfd:	6a 4d                	push   $0x4d
  jmp alltraps
80106dff:	e9 10 f7 ff ff       	jmp    80106514 <alltraps>

80106e04 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $78
80106e06:	6a 4e                	push   $0x4e
  jmp alltraps
80106e08:	e9 07 f7 ff ff       	jmp    80106514 <alltraps>

80106e0d <vector79>:
.globl vector79
vector79:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $79
80106e0f:	6a 4f                	push   $0x4f
  jmp alltraps
80106e11:	e9 fe f6 ff ff       	jmp    80106514 <alltraps>

80106e16 <vector80>:
.globl vector80
vector80:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $80
80106e18:	6a 50                	push   $0x50
  jmp alltraps
80106e1a:	e9 f5 f6 ff ff       	jmp    80106514 <alltraps>

80106e1f <vector81>:
.globl vector81
vector81:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $81
80106e21:	6a 51                	push   $0x51
  jmp alltraps
80106e23:	e9 ec f6 ff ff       	jmp    80106514 <alltraps>

80106e28 <vector82>:
.globl vector82
vector82:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $82
80106e2a:	6a 52                	push   $0x52
  jmp alltraps
80106e2c:	e9 e3 f6 ff ff       	jmp    80106514 <alltraps>

80106e31 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $83
80106e33:	6a 53                	push   $0x53
  jmp alltraps
80106e35:	e9 da f6 ff ff       	jmp    80106514 <alltraps>

80106e3a <vector84>:
.globl vector84
vector84:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $84
80106e3c:	6a 54                	push   $0x54
  jmp alltraps
80106e3e:	e9 d1 f6 ff ff       	jmp    80106514 <alltraps>

80106e43 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $85
80106e45:	6a 55                	push   $0x55
  jmp alltraps
80106e47:	e9 c8 f6 ff ff       	jmp    80106514 <alltraps>

80106e4c <vector86>:
.globl vector86
vector86:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $86
80106e4e:	6a 56                	push   $0x56
  jmp alltraps
80106e50:	e9 bf f6 ff ff       	jmp    80106514 <alltraps>

80106e55 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $87
80106e57:	6a 57                	push   $0x57
  jmp alltraps
80106e59:	e9 b6 f6 ff ff       	jmp    80106514 <alltraps>

80106e5e <vector88>:
.globl vector88
vector88:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $88
80106e60:	6a 58                	push   $0x58
  jmp alltraps
80106e62:	e9 ad f6 ff ff       	jmp    80106514 <alltraps>

80106e67 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $89
80106e69:	6a 59                	push   $0x59
  jmp alltraps
80106e6b:	e9 a4 f6 ff ff       	jmp    80106514 <alltraps>

80106e70 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $90
80106e72:	6a 5a                	push   $0x5a
  jmp alltraps
80106e74:	e9 9b f6 ff ff       	jmp    80106514 <alltraps>

80106e79 <vector91>:
.globl vector91
vector91:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $91
80106e7b:	6a 5b                	push   $0x5b
  jmp alltraps
80106e7d:	e9 92 f6 ff ff       	jmp    80106514 <alltraps>

80106e82 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $92
80106e84:	6a 5c                	push   $0x5c
  jmp alltraps
80106e86:	e9 89 f6 ff ff       	jmp    80106514 <alltraps>

80106e8b <vector93>:
.globl vector93
vector93:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $93
80106e8d:	6a 5d                	push   $0x5d
  jmp alltraps
80106e8f:	e9 80 f6 ff ff       	jmp    80106514 <alltraps>

80106e94 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $94
80106e96:	6a 5e                	push   $0x5e
  jmp alltraps
80106e98:	e9 77 f6 ff ff       	jmp    80106514 <alltraps>

80106e9d <vector95>:
.globl vector95
vector95:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $95
80106e9f:	6a 5f                	push   $0x5f
  jmp alltraps
80106ea1:	e9 6e f6 ff ff       	jmp    80106514 <alltraps>

80106ea6 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $96
80106ea8:	6a 60                	push   $0x60
  jmp alltraps
80106eaa:	e9 65 f6 ff ff       	jmp    80106514 <alltraps>

80106eaf <vector97>:
.globl vector97
vector97:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $97
80106eb1:	6a 61                	push   $0x61
  jmp alltraps
80106eb3:	e9 5c f6 ff ff       	jmp    80106514 <alltraps>

80106eb8 <vector98>:
.globl vector98
vector98:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $98
80106eba:	6a 62                	push   $0x62
  jmp alltraps
80106ebc:	e9 53 f6 ff ff       	jmp    80106514 <alltraps>

80106ec1 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $99
80106ec3:	6a 63                	push   $0x63
  jmp alltraps
80106ec5:	e9 4a f6 ff ff       	jmp    80106514 <alltraps>

80106eca <vector100>:
.globl vector100
vector100:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $100
80106ecc:	6a 64                	push   $0x64
  jmp alltraps
80106ece:	e9 41 f6 ff ff       	jmp    80106514 <alltraps>

80106ed3 <vector101>:
.globl vector101
vector101:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $101
80106ed5:	6a 65                	push   $0x65
  jmp alltraps
80106ed7:	e9 38 f6 ff ff       	jmp    80106514 <alltraps>

80106edc <vector102>:
.globl vector102
vector102:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $102
80106ede:	6a 66                	push   $0x66
  jmp alltraps
80106ee0:	e9 2f f6 ff ff       	jmp    80106514 <alltraps>

80106ee5 <vector103>:
.globl vector103
vector103:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $103
80106ee7:	6a 67                	push   $0x67
  jmp alltraps
80106ee9:	e9 26 f6 ff ff       	jmp    80106514 <alltraps>

80106eee <vector104>:
.globl vector104
vector104:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $104
80106ef0:	6a 68                	push   $0x68
  jmp alltraps
80106ef2:	e9 1d f6 ff ff       	jmp    80106514 <alltraps>

80106ef7 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $105
80106ef9:	6a 69                	push   $0x69
  jmp alltraps
80106efb:	e9 14 f6 ff ff       	jmp    80106514 <alltraps>

80106f00 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $106
80106f02:	6a 6a                	push   $0x6a
  jmp alltraps
80106f04:	e9 0b f6 ff ff       	jmp    80106514 <alltraps>

80106f09 <vector107>:
.globl vector107
vector107:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $107
80106f0b:	6a 6b                	push   $0x6b
  jmp alltraps
80106f0d:	e9 02 f6 ff ff       	jmp    80106514 <alltraps>

80106f12 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $108
80106f14:	6a 6c                	push   $0x6c
  jmp alltraps
80106f16:	e9 f9 f5 ff ff       	jmp    80106514 <alltraps>

80106f1b <vector109>:
.globl vector109
vector109:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $109
80106f1d:	6a 6d                	push   $0x6d
  jmp alltraps
80106f1f:	e9 f0 f5 ff ff       	jmp    80106514 <alltraps>

80106f24 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $110
80106f26:	6a 6e                	push   $0x6e
  jmp alltraps
80106f28:	e9 e7 f5 ff ff       	jmp    80106514 <alltraps>

80106f2d <vector111>:
.globl vector111
vector111:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $111
80106f2f:	6a 6f                	push   $0x6f
  jmp alltraps
80106f31:	e9 de f5 ff ff       	jmp    80106514 <alltraps>

80106f36 <vector112>:
.globl vector112
vector112:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $112
80106f38:	6a 70                	push   $0x70
  jmp alltraps
80106f3a:	e9 d5 f5 ff ff       	jmp    80106514 <alltraps>

80106f3f <vector113>:
.globl vector113
vector113:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $113
80106f41:	6a 71                	push   $0x71
  jmp alltraps
80106f43:	e9 cc f5 ff ff       	jmp    80106514 <alltraps>

80106f48 <vector114>:
.globl vector114
vector114:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $114
80106f4a:	6a 72                	push   $0x72
  jmp alltraps
80106f4c:	e9 c3 f5 ff ff       	jmp    80106514 <alltraps>

80106f51 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $115
80106f53:	6a 73                	push   $0x73
  jmp alltraps
80106f55:	e9 ba f5 ff ff       	jmp    80106514 <alltraps>

80106f5a <vector116>:
.globl vector116
vector116:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $116
80106f5c:	6a 74                	push   $0x74
  jmp alltraps
80106f5e:	e9 b1 f5 ff ff       	jmp    80106514 <alltraps>

80106f63 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $117
80106f65:	6a 75                	push   $0x75
  jmp alltraps
80106f67:	e9 a8 f5 ff ff       	jmp    80106514 <alltraps>

80106f6c <vector118>:
.globl vector118
vector118:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $118
80106f6e:	6a 76                	push   $0x76
  jmp alltraps
80106f70:	e9 9f f5 ff ff       	jmp    80106514 <alltraps>

80106f75 <vector119>:
.globl vector119
vector119:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $119
80106f77:	6a 77                	push   $0x77
  jmp alltraps
80106f79:	e9 96 f5 ff ff       	jmp    80106514 <alltraps>

80106f7e <vector120>:
.globl vector120
vector120:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $120
80106f80:	6a 78                	push   $0x78
  jmp alltraps
80106f82:	e9 8d f5 ff ff       	jmp    80106514 <alltraps>

80106f87 <vector121>:
.globl vector121
vector121:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $121
80106f89:	6a 79                	push   $0x79
  jmp alltraps
80106f8b:	e9 84 f5 ff ff       	jmp    80106514 <alltraps>

80106f90 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $122
80106f92:	6a 7a                	push   $0x7a
  jmp alltraps
80106f94:	e9 7b f5 ff ff       	jmp    80106514 <alltraps>

80106f99 <vector123>:
.globl vector123
vector123:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $123
80106f9b:	6a 7b                	push   $0x7b
  jmp alltraps
80106f9d:	e9 72 f5 ff ff       	jmp    80106514 <alltraps>

80106fa2 <vector124>:
.globl vector124
vector124:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $124
80106fa4:	6a 7c                	push   $0x7c
  jmp alltraps
80106fa6:	e9 69 f5 ff ff       	jmp    80106514 <alltraps>

80106fab <vector125>:
.globl vector125
vector125:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $125
80106fad:	6a 7d                	push   $0x7d
  jmp alltraps
80106faf:	e9 60 f5 ff ff       	jmp    80106514 <alltraps>

80106fb4 <vector126>:
.globl vector126
vector126:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $126
80106fb6:	6a 7e                	push   $0x7e
  jmp alltraps
80106fb8:	e9 57 f5 ff ff       	jmp    80106514 <alltraps>

80106fbd <vector127>:
.globl vector127
vector127:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $127
80106fbf:	6a 7f                	push   $0x7f
  jmp alltraps
80106fc1:	e9 4e f5 ff ff       	jmp    80106514 <alltraps>

80106fc6 <vector128>:
.globl vector128
vector128:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $128
80106fc8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106fcd:	e9 42 f5 ff ff       	jmp    80106514 <alltraps>

80106fd2 <vector129>:
.globl vector129
vector129:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $129
80106fd4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106fd9:	e9 36 f5 ff ff       	jmp    80106514 <alltraps>

80106fde <vector130>:
.globl vector130
vector130:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $130
80106fe0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106fe5:	e9 2a f5 ff ff       	jmp    80106514 <alltraps>

80106fea <vector131>:
.globl vector131
vector131:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $131
80106fec:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ff1:	e9 1e f5 ff ff       	jmp    80106514 <alltraps>

80106ff6 <vector132>:
.globl vector132
vector132:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $132
80106ff8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106ffd:	e9 12 f5 ff ff       	jmp    80106514 <alltraps>

80107002 <vector133>:
.globl vector133
vector133:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $133
80107004:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107009:	e9 06 f5 ff ff       	jmp    80106514 <alltraps>

8010700e <vector134>:
.globl vector134
vector134:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $134
80107010:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107015:	e9 fa f4 ff ff       	jmp    80106514 <alltraps>

8010701a <vector135>:
.globl vector135
vector135:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $135
8010701c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107021:	e9 ee f4 ff ff       	jmp    80106514 <alltraps>

80107026 <vector136>:
.globl vector136
vector136:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $136
80107028:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010702d:	e9 e2 f4 ff ff       	jmp    80106514 <alltraps>

80107032 <vector137>:
.globl vector137
vector137:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $137
80107034:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107039:	e9 d6 f4 ff ff       	jmp    80106514 <alltraps>

8010703e <vector138>:
.globl vector138
vector138:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $138
80107040:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107045:	e9 ca f4 ff ff       	jmp    80106514 <alltraps>

8010704a <vector139>:
.globl vector139
vector139:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $139
8010704c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107051:	e9 be f4 ff ff       	jmp    80106514 <alltraps>

80107056 <vector140>:
.globl vector140
vector140:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $140
80107058:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010705d:	e9 b2 f4 ff ff       	jmp    80106514 <alltraps>

80107062 <vector141>:
.globl vector141
vector141:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $141
80107064:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107069:	e9 a6 f4 ff ff       	jmp    80106514 <alltraps>

8010706e <vector142>:
.globl vector142
vector142:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $142
80107070:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107075:	e9 9a f4 ff ff       	jmp    80106514 <alltraps>

8010707a <vector143>:
.globl vector143
vector143:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $143
8010707c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107081:	e9 8e f4 ff ff       	jmp    80106514 <alltraps>

80107086 <vector144>:
.globl vector144
vector144:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $144
80107088:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010708d:	e9 82 f4 ff ff       	jmp    80106514 <alltraps>

80107092 <vector145>:
.globl vector145
vector145:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $145
80107094:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107099:	e9 76 f4 ff ff       	jmp    80106514 <alltraps>

8010709e <vector146>:
.globl vector146
vector146:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $146
801070a0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801070a5:	e9 6a f4 ff ff       	jmp    80106514 <alltraps>

801070aa <vector147>:
.globl vector147
vector147:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $147
801070ac:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801070b1:	e9 5e f4 ff ff       	jmp    80106514 <alltraps>

801070b6 <vector148>:
.globl vector148
vector148:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $148
801070b8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801070bd:	e9 52 f4 ff ff       	jmp    80106514 <alltraps>

801070c2 <vector149>:
.globl vector149
vector149:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $149
801070c4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070c9:	e9 46 f4 ff ff       	jmp    80106514 <alltraps>

801070ce <vector150>:
.globl vector150
vector150:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $150
801070d0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801070d5:	e9 3a f4 ff ff       	jmp    80106514 <alltraps>

801070da <vector151>:
.globl vector151
vector151:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $151
801070dc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801070e1:	e9 2e f4 ff ff       	jmp    80106514 <alltraps>

801070e6 <vector152>:
.globl vector152
vector152:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $152
801070e8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801070ed:	e9 22 f4 ff ff       	jmp    80106514 <alltraps>

801070f2 <vector153>:
.globl vector153
vector153:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $153
801070f4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801070f9:	e9 16 f4 ff ff       	jmp    80106514 <alltraps>

801070fe <vector154>:
.globl vector154
vector154:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $154
80107100:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107105:	e9 0a f4 ff ff       	jmp    80106514 <alltraps>

8010710a <vector155>:
.globl vector155
vector155:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $155
8010710c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107111:	e9 fe f3 ff ff       	jmp    80106514 <alltraps>

80107116 <vector156>:
.globl vector156
vector156:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $156
80107118:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010711d:	e9 f2 f3 ff ff       	jmp    80106514 <alltraps>

80107122 <vector157>:
.globl vector157
vector157:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $157
80107124:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107129:	e9 e6 f3 ff ff       	jmp    80106514 <alltraps>

8010712e <vector158>:
.globl vector158
vector158:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $158
80107130:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107135:	e9 da f3 ff ff       	jmp    80106514 <alltraps>

8010713a <vector159>:
.globl vector159
vector159:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $159
8010713c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107141:	e9 ce f3 ff ff       	jmp    80106514 <alltraps>

80107146 <vector160>:
.globl vector160
vector160:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $160
80107148:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010714d:	e9 c2 f3 ff ff       	jmp    80106514 <alltraps>

80107152 <vector161>:
.globl vector161
vector161:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $161
80107154:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107159:	e9 b6 f3 ff ff       	jmp    80106514 <alltraps>

8010715e <vector162>:
.globl vector162
vector162:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $162
80107160:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107165:	e9 aa f3 ff ff       	jmp    80106514 <alltraps>

8010716a <vector163>:
.globl vector163
vector163:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $163
8010716c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107171:	e9 9e f3 ff ff       	jmp    80106514 <alltraps>

80107176 <vector164>:
.globl vector164
vector164:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $164
80107178:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010717d:	e9 92 f3 ff ff       	jmp    80106514 <alltraps>

80107182 <vector165>:
.globl vector165
vector165:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $165
80107184:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107189:	e9 86 f3 ff ff       	jmp    80106514 <alltraps>

8010718e <vector166>:
.globl vector166
vector166:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $166
80107190:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107195:	e9 7a f3 ff ff       	jmp    80106514 <alltraps>

8010719a <vector167>:
.globl vector167
vector167:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $167
8010719c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801071a1:	e9 6e f3 ff ff       	jmp    80106514 <alltraps>

801071a6 <vector168>:
.globl vector168
vector168:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $168
801071a8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801071ad:	e9 62 f3 ff ff       	jmp    80106514 <alltraps>

801071b2 <vector169>:
.globl vector169
vector169:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $169
801071b4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801071b9:	e9 56 f3 ff ff       	jmp    80106514 <alltraps>

801071be <vector170>:
.globl vector170
vector170:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $170
801071c0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071c5:	e9 4a f3 ff ff       	jmp    80106514 <alltraps>

801071ca <vector171>:
.globl vector171
vector171:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $171
801071cc:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801071d1:	e9 3e f3 ff ff       	jmp    80106514 <alltraps>

801071d6 <vector172>:
.globl vector172
vector172:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $172
801071d8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801071dd:	e9 32 f3 ff ff       	jmp    80106514 <alltraps>

801071e2 <vector173>:
.globl vector173
vector173:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $173
801071e4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801071e9:	e9 26 f3 ff ff       	jmp    80106514 <alltraps>

801071ee <vector174>:
.globl vector174
vector174:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $174
801071f0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801071f5:	e9 1a f3 ff ff       	jmp    80106514 <alltraps>

801071fa <vector175>:
.globl vector175
vector175:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $175
801071fc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107201:	e9 0e f3 ff ff       	jmp    80106514 <alltraps>

80107206 <vector176>:
.globl vector176
vector176:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $176
80107208:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010720d:	e9 02 f3 ff ff       	jmp    80106514 <alltraps>

80107212 <vector177>:
.globl vector177
vector177:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $177
80107214:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107219:	e9 f6 f2 ff ff       	jmp    80106514 <alltraps>

8010721e <vector178>:
.globl vector178
vector178:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $178
80107220:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107225:	e9 ea f2 ff ff       	jmp    80106514 <alltraps>

8010722a <vector179>:
.globl vector179
vector179:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $179
8010722c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107231:	e9 de f2 ff ff       	jmp    80106514 <alltraps>

80107236 <vector180>:
.globl vector180
vector180:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $180
80107238:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010723d:	e9 d2 f2 ff ff       	jmp    80106514 <alltraps>

80107242 <vector181>:
.globl vector181
vector181:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $181
80107244:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107249:	e9 c6 f2 ff ff       	jmp    80106514 <alltraps>

8010724e <vector182>:
.globl vector182
vector182:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $182
80107250:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107255:	e9 ba f2 ff ff       	jmp    80106514 <alltraps>

8010725a <vector183>:
.globl vector183
vector183:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $183
8010725c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107261:	e9 ae f2 ff ff       	jmp    80106514 <alltraps>

80107266 <vector184>:
.globl vector184
vector184:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $184
80107268:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010726d:	e9 a2 f2 ff ff       	jmp    80106514 <alltraps>

80107272 <vector185>:
.globl vector185
vector185:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $185
80107274:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107279:	e9 96 f2 ff ff       	jmp    80106514 <alltraps>

8010727e <vector186>:
.globl vector186
vector186:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $186
80107280:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107285:	e9 8a f2 ff ff       	jmp    80106514 <alltraps>

8010728a <vector187>:
.globl vector187
vector187:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $187
8010728c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107291:	e9 7e f2 ff ff       	jmp    80106514 <alltraps>

80107296 <vector188>:
.globl vector188
vector188:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $188
80107298:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010729d:	e9 72 f2 ff ff       	jmp    80106514 <alltraps>

801072a2 <vector189>:
.globl vector189
vector189:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $189
801072a4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801072a9:	e9 66 f2 ff ff       	jmp    80106514 <alltraps>

801072ae <vector190>:
.globl vector190
vector190:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $190
801072b0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801072b5:	e9 5a f2 ff ff       	jmp    80106514 <alltraps>

801072ba <vector191>:
.globl vector191
vector191:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $191
801072bc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072c1:	e9 4e f2 ff ff       	jmp    80106514 <alltraps>

801072c6 <vector192>:
.globl vector192
vector192:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $192
801072c8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072cd:	e9 42 f2 ff ff       	jmp    80106514 <alltraps>

801072d2 <vector193>:
.globl vector193
vector193:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $193
801072d4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801072d9:	e9 36 f2 ff ff       	jmp    80106514 <alltraps>

801072de <vector194>:
.globl vector194
vector194:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $194
801072e0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801072e5:	e9 2a f2 ff ff       	jmp    80106514 <alltraps>

801072ea <vector195>:
.globl vector195
vector195:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $195
801072ec:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801072f1:	e9 1e f2 ff ff       	jmp    80106514 <alltraps>

801072f6 <vector196>:
.globl vector196
vector196:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $196
801072f8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801072fd:	e9 12 f2 ff ff       	jmp    80106514 <alltraps>

80107302 <vector197>:
.globl vector197
vector197:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $197
80107304:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107309:	e9 06 f2 ff ff       	jmp    80106514 <alltraps>

8010730e <vector198>:
.globl vector198
vector198:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $198
80107310:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107315:	e9 fa f1 ff ff       	jmp    80106514 <alltraps>

8010731a <vector199>:
.globl vector199
vector199:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $199
8010731c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107321:	e9 ee f1 ff ff       	jmp    80106514 <alltraps>

80107326 <vector200>:
.globl vector200
vector200:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $200
80107328:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010732d:	e9 e2 f1 ff ff       	jmp    80106514 <alltraps>

80107332 <vector201>:
.globl vector201
vector201:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $201
80107334:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107339:	e9 d6 f1 ff ff       	jmp    80106514 <alltraps>

8010733e <vector202>:
.globl vector202
vector202:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $202
80107340:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107345:	e9 ca f1 ff ff       	jmp    80106514 <alltraps>

8010734a <vector203>:
.globl vector203
vector203:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $203
8010734c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107351:	e9 be f1 ff ff       	jmp    80106514 <alltraps>

80107356 <vector204>:
.globl vector204
vector204:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $204
80107358:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010735d:	e9 b2 f1 ff ff       	jmp    80106514 <alltraps>

80107362 <vector205>:
.globl vector205
vector205:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $205
80107364:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107369:	e9 a6 f1 ff ff       	jmp    80106514 <alltraps>

8010736e <vector206>:
.globl vector206
vector206:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $206
80107370:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107375:	e9 9a f1 ff ff       	jmp    80106514 <alltraps>

8010737a <vector207>:
.globl vector207
vector207:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $207
8010737c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107381:	e9 8e f1 ff ff       	jmp    80106514 <alltraps>

80107386 <vector208>:
.globl vector208
vector208:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $208
80107388:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010738d:	e9 82 f1 ff ff       	jmp    80106514 <alltraps>

80107392 <vector209>:
.globl vector209
vector209:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $209
80107394:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107399:	e9 76 f1 ff ff       	jmp    80106514 <alltraps>

8010739e <vector210>:
.globl vector210
vector210:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $210
801073a0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801073a5:	e9 6a f1 ff ff       	jmp    80106514 <alltraps>

801073aa <vector211>:
.globl vector211
vector211:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $211
801073ac:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801073b1:	e9 5e f1 ff ff       	jmp    80106514 <alltraps>

801073b6 <vector212>:
.globl vector212
vector212:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $212
801073b8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801073bd:	e9 52 f1 ff ff       	jmp    80106514 <alltraps>

801073c2 <vector213>:
.globl vector213
vector213:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $213
801073c4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073c9:	e9 46 f1 ff ff       	jmp    80106514 <alltraps>

801073ce <vector214>:
.globl vector214
vector214:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $214
801073d0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801073d5:	e9 3a f1 ff ff       	jmp    80106514 <alltraps>

801073da <vector215>:
.globl vector215
vector215:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $215
801073dc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801073e1:	e9 2e f1 ff ff       	jmp    80106514 <alltraps>

801073e6 <vector216>:
.globl vector216
vector216:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $216
801073e8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801073ed:	e9 22 f1 ff ff       	jmp    80106514 <alltraps>

801073f2 <vector217>:
.globl vector217
vector217:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $217
801073f4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801073f9:	e9 16 f1 ff ff       	jmp    80106514 <alltraps>

801073fe <vector218>:
.globl vector218
vector218:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $218
80107400:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107405:	e9 0a f1 ff ff       	jmp    80106514 <alltraps>

8010740a <vector219>:
.globl vector219
vector219:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $219
8010740c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107411:	e9 fe f0 ff ff       	jmp    80106514 <alltraps>

80107416 <vector220>:
.globl vector220
vector220:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $220
80107418:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010741d:	e9 f2 f0 ff ff       	jmp    80106514 <alltraps>

80107422 <vector221>:
.globl vector221
vector221:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $221
80107424:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107429:	e9 e6 f0 ff ff       	jmp    80106514 <alltraps>

8010742e <vector222>:
.globl vector222
vector222:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $222
80107430:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107435:	e9 da f0 ff ff       	jmp    80106514 <alltraps>

8010743a <vector223>:
.globl vector223
vector223:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $223
8010743c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107441:	e9 ce f0 ff ff       	jmp    80106514 <alltraps>

80107446 <vector224>:
.globl vector224
vector224:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $224
80107448:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010744d:	e9 c2 f0 ff ff       	jmp    80106514 <alltraps>

80107452 <vector225>:
.globl vector225
vector225:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $225
80107454:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107459:	e9 b6 f0 ff ff       	jmp    80106514 <alltraps>

8010745e <vector226>:
.globl vector226
vector226:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $226
80107460:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107465:	e9 aa f0 ff ff       	jmp    80106514 <alltraps>

8010746a <vector227>:
.globl vector227
vector227:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $227
8010746c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107471:	e9 9e f0 ff ff       	jmp    80106514 <alltraps>

80107476 <vector228>:
.globl vector228
vector228:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $228
80107478:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010747d:	e9 92 f0 ff ff       	jmp    80106514 <alltraps>

80107482 <vector229>:
.globl vector229
vector229:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $229
80107484:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107489:	e9 86 f0 ff ff       	jmp    80106514 <alltraps>

8010748e <vector230>:
.globl vector230
vector230:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $230
80107490:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107495:	e9 7a f0 ff ff       	jmp    80106514 <alltraps>

8010749a <vector231>:
.globl vector231
vector231:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $231
8010749c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801074a1:	e9 6e f0 ff ff       	jmp    80106514 <alltraps>

801074a6 <vector232>:
.globl vector232
vector232:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $232
801074a8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801074ad:	e9 62 f0 ff ff       	jmp    80106514 <alltraps>

801074b2 <vector233>:
.globl vector233
vector233:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $233
801074b4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801074b9:	e9 56 f0 ff ff       	jmp    80106514 <alltraps>

801074be <vector234>:
.globl vector234
vector234:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $234
801074c0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074c5:	e9 4a f0 ff ff       	jmp    80106514 <alltraps>

801074ca <vector235>:
.globl vector235
vector235:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $235
801074cc:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801074d1:	e9 3e f0 ff ff       	jmp    80106514 <alltraps>

801074d6 <vector236>:
.globl vector236
vector236:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $236
801074d8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801074dd:	e9 32 f0 ff ff       	jmp    80106514 <alltraps>

801074e2 <vector237>:
.globl vector237
vector237:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $237
801074e4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801074e9:	e9 26 f0 ff ff       	jmp    80106514 <alltraps>

801074ee <vector238>:
.globl vector238
vector238:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $238
801074f0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801074f5:	e9 1a f0 ff ff       	jmp    80106514 <alltraps>

801074fa <vector239>:
.globl vector239
vector239:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $239
801074fc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107501:	e9 0e f0 ff ff       	jmp    80106514 <alltraps>

80107506 <vector240>:
.globl vector240
vector240:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $240
80107508:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010750d:	e9 02 f0 ff ff       	jmp    80106514 <alltraps>

80107512 <vector241>:
.globl vector241
vector241:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $241
80107514:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107519:	e9 f6 ef ff ff       	jmp    80106514 <alltraps>

8010751e <vector242>:
.globl vector242
vector242:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $242
80107520:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107525:	e9 ea ef ff ff       	jmp    80106514 <alltraps>

8010752a <vector243>:
.globl vector243
vector243:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $243
8010752c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107531:	e9 de ef ff ff       	jmp    80106514 <alltraps>

80107536 <vector244>:
.globl vector244
vector244:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $244
80107538:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010753d:	e9 d2 ef ff ff       	jmp    80106514 <alltraps>

80107542 <vector245>:
.globl vector245
vector245:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $245
80107544:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107549:	e9 c6 ef ff ff       	jmp    80106514 <alltraps>

8010754e <vector246>:
.globl vector246
vector246:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $246
80107550:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107555:	e9 ba ef ff ff       	jmp    80106514 <alltraps>

8010755a <vector247>:
.globl vector247
vector247:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $247
8010755c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107561:	e9 ae ef ff ff       	jmp    80106514 <alltraps>

80107566 <vector248>:
.globl vector248
vector248:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $248
80107568:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010756d:	e9 a2 ef ff ff       	jmp    80106514 <alltraps>

80107572 <vector249>:
.globl vector249
vector249:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $249
80107574:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107579:	e9 96 ef ff ff       	jmp    80106514 <alltraps>

8010757e <vector250>:
.globl vector250
vector250:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $250
80107580:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107585:	e9 8a ef ff ff       	jmp    80106514 <alltraps>

8010758a <vector251>:
.globl vector251
vector251:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $251
8010758c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107591:	e9 7e ef ff ff       	jmp    80106514 <alltraps>

80107596 <vector252>:
.globl vector252
vector252:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $252
80107598:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010759d:	e9 72 ef ff ff       	jmp    80106514 <alltraps>

801075a2 <vector253>:
.globl vector253
vector253:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $253
801075a4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801075a9:	e9 66 ef ff ff       	jmp    80106514 <alltraps>

801075ae <vector254>:
.globl vector254
vector254:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $254
801075b0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801075b5:	e9 5a ef ff ff       	jmp    80106514 <alltraps>

801075ba <vector255>:
.globl vector255
vector255:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $255
801075bc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075c1:	e9 4e ef ff ff       	jmp    80106514 <alltraps>
	...

801075c8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801075c8:	55                   	push   %ebp
801075c9:	89 e5                	mov    %esp,%ebp
801075cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801075ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801075d1:	48                   	dec    %eax
801075d2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801075d6:	8b 45 08             	mov    0x8(%ebp),%eax
801075d9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801075dd:	8b 45 08             	mov    0x8(%ebp),%eax
801075e0:	c1 e8 10             	shr    $0x10,%eax
801075e3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801075e7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075ea:	0f 01 10             	lgdtl  (%eax)
}
801075ed:	c9                   	leave  
801075ee:	c3                   	ret    

801075ef <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801075ef:	55                   	push   %ebp
801075f0:	89 e5                	mov    %esp,%ebp
801075f2:	83 ec 04             	sub    $0x4,%esp
801075f5:	8b 45 08             	mov    0x8(%ebp),%eax
801075f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801075fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801075ff:	0f 00 d8             	ltr    %ax
}
80107602:	c9                   	leave  
80107603:	c3                   	ret    

80107604 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107604:	55                   	push   %ebp
80107605:	89 e5                	mov    %esp,%ebp
80107607:	83 ec 04             	sub    $0x4,%esp
8010760a:	8b 45 08             	mov    0x8(%ebp),%eax
8010760d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107614:	8e e8                	mov    %eax,%gs
}
80107616:	c9                   	leave  
80107617:	c3                   	ret    

80107618 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107618:	55                   	push   %ebp
80107619:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010761b:	8b 45 08             	mov    0x8(%ebp),%eax
8010761e:	0f 22 d8             	mov    %eax,%cr3
}
80107621:	5d                   	pop    %ebp
80107622:	c3                   	ret    

80107623 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107623:	55                   	push   %ebp
80107624:	89 e5                	mov    %esp,%ebp
80107626:	53                   	push   %ebx
80107627:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010762a:	e8 c2 b8 ff ff       	call   80102ef1 <cpunum>
8010762f:	89 c2                	mov    %eax,%edx
80107631:	89 d0                	mov    %edx,%eax
80107633:	c1 e0 02             	shl    $0x2,%eax
80107636:	01 d0                	add    %edx,%eax
80107638:	01 c0                	add    %eax,%eax
8010763a:	01 d0                	add    %edx,%eax
8010763c:	89 c1                	mov    %eax,%ecx
8010763e:	c1 e1 04             	shl    $0x4,%ecx
80107641:	01 c8                	add    %ecx,%eax
80107643:	01 d0                	add    %edx,%eax
80107645:	05 20 38 11 80       	add    $0x80113820,%eax
8010764a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010764d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107650:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107659:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010765f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107662:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107669:	8a 50 7d             	mov    0x7d(%eax),%dl
8010766c:	83 e2 f0             	and    $0xfffffff0,%edx
8010766f:	83 ca 0a             	or     $0xa,%edx
80107672:	88 50 7d             	mov    %dl,0x7d(%eax)
80107675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107678:	8a 50 7d             	mov    0x7d(%eax),%dl
8010767b:	83 ca 10             	or     $0x10,%edx
8010767e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107684:	8a 50 7d             	mov    0x7d(%eax),%dl
80107687:	83 e2 9f             	and    $0xffffff9f,%edx
8010768a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010768d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107690:	8a 50 7d             	mov    0x7d(%eax),%dl
80107693:	83 ca 80             	or     $0xffffff80,%edx
80107696:	88 50 7d             	mov    %dl,0x7d(%eax)
80107699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769c:	8a 50 7e             	mov    0x7e(%eax),%dl
8010769f:	83 ca 0f             	or     $0xf,%edx
801076a2:	88 50 7e             	mov    %dl,0x7e(%eax)
801076a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a8:	8a 50 7e             	mov    0x7e(%eax),%dl
801076ab:	83 e2 ef             	and    $0xffffffef,%edx
801076ae:	88 50 7e             	mov    %dl,0x7e(%eax)
801076b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b4:	8a 50 7e             	mov    0x7e(%eax),%dl
801076b7:	83 e2 df             	and    $0xffffffdf,%edx
801076ba:	88 50 7e             	mov    %dl,0x7e(%eax)
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	8a 50 7e             	mov    0x7e(%eax),%dl
801076c3:	83 ca 40             	or     $0x40,%edx
801076c6:	88 50 7e             	mov    %dl,0x7e(%eax)
801076c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cc:	8a 50 7e             	mov    0x7e(%eax),%dl
801076cf:	83 ca 80             	or     $0xffffff80,%edx
801076d2:	88 50 7e             	mov    %dl,0x7e(%eax)
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801076dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076df:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801076e6:	ff ff 
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801076f2:	00 00 
801076f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f7:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801076fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107701:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107707:	83 e2 f0             	and    $0xfffffff0,%edx
8010770a:	83 ca 02             	or     $0x2,%edx
8010770d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107716:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010771c:	83 ca 10             	or     $0x10,%edx
8010771f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107728:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010772e:	83 e2 9f             	and    $0xffffff9f,%edx
80107731:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107740:	83 ca 80             	or     $0xffffff80,%edx
80107743:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774c:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107752:	83 ca 0f             	or     $0xf,%edx
80107755:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010775b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775e:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107764:	83 e2 ef             	and    $0xffffffef,%edx
80107767:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010776d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107770:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107776:	83 e2 df             	and    $0xffffffdf,%edx
80107779:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010777f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107782:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107788:	83 ca 40             	or     $0x40,%edx
8010778b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107794:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010779a:	83 ca 80             	or     $0xffffff80,%edx
8010779d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801077b7:	ff ff 
801077b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077c3:	00 00 
801077c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d2:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801077d8:	83 e2 f0             	and    $0xfffffff0,%edx
801077db:	83 ca 0a             	or     $0xa,%edx
801077de:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e7:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801077ed:	83 ca 10             	or     $0x10,%edx
801077f0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801077ff:	83 ca 60             	or     $0x60,%edx
80107802:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780b:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107811:	83 ca 80             	or     $0xffffff80,%edx
80107814:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010781a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107823:	83 ca 0f             	or     $0xf,%edx
80107826:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107835:	83 e2 ef             	and    $0xffffffef,%edx
80107838:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010783e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107841:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107847:	83 e2 df             	and    $0xffffffdf,%edx
8010784a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107853:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107859:	83 ca 40             	or     $0x40,%edx
8010785c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107865:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010786b:	83 ca 80             	or     $0xffffff80,%edx
8010786e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107877:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010787e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107881:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107888:	ff ff 
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107894:	00 00 
80107896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107899:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801078a9:	83 e2 f0             	and    $0xfffffff0,%edx
801078ac:	83 ca 02             	or     $0x2,%edx
801078af:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801078b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b8:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801078be:	83 ca 10             	or     $0x10,%edx
801078c1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801078c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ca:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801078d0:	83 ca 60             	or     $0x60,%edx
801078d3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801078d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dc:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801078e2:	83 ca 80             	or     $0xffffff80,%edx
801078e5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
801078f4:	83 ca 0f             	or     $0xf,%edx
801078f7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107900:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107906:	83 e2 ef             	and    $0xffffffef,%edx
80107909:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010790f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107912:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107918:	83 e2 df             	and    $0xffffffdf,%edx
8010791b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107924:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
8010792a:	83 ca 40             	or     $0x40,%edx
8010792d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107936:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
8010793c:	83 ca 80             	or     $0xffffff80,%edx
8010793f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107948:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu and proc -- these are private per cpu.
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010794f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107952:	05 b4 00 00 00       	add    $0xb4,%eax
80107957:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010795a:	81 c2 b4 00 00 00    	add    $0xb4,%edx
80107960:	c1 ea 10             	shr    $0x10,%edx
80107963:	88 d1                	mov    %dl,%cl
80107965:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107968:	81 c2 b4 00 00 00    	add    $0xb4,%edx
8010796e:	c1 ea 18             	shr    $0x18,%edx
80107971:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107974:	66 c7 83 88 00 00 00 	movw   $0x0,0x88(%ebx)
8010797b:	00 00 
8010797d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107980:	66 89 83 8a 00 00 00 	mov    %ax,0x8a(%ebx)
80107987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107999:	83 e1 f0             	and    $0xfffffff0,%ecx
8010799c:	83 c9 02             	or     $0x2,%ecx
8010799f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801079a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a8:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
801079ae:	83 c9 10             	or     $0x10,%ecx
801079b1:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
801079c0:	83 e1 9f             	and    $0xffffff9f,%ecx
801079c3:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801079c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cc:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
801079d2:	83 c9 80             	or     $0xffffff80,%ecx
801079d5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
801079e4:	83 e1 f0             	and    $0xfffffff0,%ecx
801079e7:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801079ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f0:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
801079f6:	83 e1 ef             	and    $0xffffffef,%ecx
801079f9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107a08:	83 e1 df             	and    $0xffffffdf,%ecx
80107a0b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a14:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107a1a:	83 c9 40             	or     $0x40,%ecx
80107a1d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107a2c:	83 c9 80             	or     $0xffffff80,%ecx
80107a2f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a38:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	83 c0 70             	add    $0x70,%eax
80107a44:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107a4b:	00 
80107a4c:	89 04 24             	mov    %eax,(%esp)
80107a4f:	e8 74 fb ff ff       	call   801075c8 <lgdt>
  loadgs(SEG_KCPU << 3);
80107a54:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107a5b:	e8 a4 fb ff ff       	call   80107604 <loadgs>

  // Initialize cpu-local storage.
  cpu = c;
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107a69:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107a70:	00 00 00 00 
}
80107a74:	83 c4 24             	add    $0x24,%esp
80107a77:	5b                   	pop    %ebx
80107a78:	5d                   	pop    %ebp
80107a79:	c3                   	ret    

80107a7a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a7a:	55                   	push   %ebp
80107a7b:	89 e5                	mov    %esp,%ebp
80107a7d:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107a80:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a83:	c1 e8 16             	shr    $0x16,%eax
80107a86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a90:	01 d0                	add    %edx,%eax
80107a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a98:	8b 00                	mov    (%eax),%eax
80107a9a:	83 e0 01             	and    $0x1,%eax
80107a9d:	85 c0                	test   %eax,%eax
80107a9f:	74 14                	je     80107ab5 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aa4:	8b 00                	mov    (%eax),%eax
80107aa6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aab:	05 00 00 00 80       	add    $0x80000000,%eax
80107ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ab3:	eb 48                	jmp    80107afd <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ab5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ab9:	74 0e                	je     80107ac9 <walkpgdir+0x4f>
80107abb:	e8 a3 b0 ff ff       	call   80102b63 <kalloc>
80107ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ac3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ac7:	75 07                	jne    80107ad0 <walkpgdir+0x56>
      return 0;
80107ac9:	b8 00 00 00 00       	mov    $0x0,%eax
80107ace:	eb 44                	jmp    80107b14 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ad0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ad7:	00 
80107ad8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107adf:	00 
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	89 04 24             	mov    %eax,(%esp)
80107ae6:	e8 5b d6 ff ff       	call   80105146 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aee:	05 00 00 00 80       	add    $0x80000000,%eax
80107af3:	83 c8 07             	or     $0x7,%eax
80107af6:	89 c2                	mov    %eax,%edx
80107af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107afb:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107afd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b00:	c1 e8 0c             	shr    $0xc,%eax
80107b03:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	01 d0                	add    %edx,%eax
}
80107b14:	c9                   	leave  
80107b15:	c3                   	ret    

80107b16 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b16:	55                   	push   %ebp
80107b17:	89 e5                	mov    %esp,%ebp
80107b19:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b27:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b2a:	8b 45 10             	mov    0x10(%ebp),%eax
80107b2d:	01 d0                	add    %edx,%eax
80107b2f:	48                   	dec    %eax
80107b30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b38:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107b3f:	00 
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b47:	8b 45 08             	mov    0x8(%ebp),%eax
80107b4a:	89 04 24             	mov    %eax,(%esp)
80107b4d:	e8 28 ff ff ff       	call   80107a7a <walkpgdir>
80107b52:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b59:	75 07                	jne    80107b62 <mappages+0x4c>
      return -1;
80107b5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b60:	eb 48                	jmp    80107baa <mappages+0x94>
    if(*pte & PTE_P)
80107b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b65:	8b 00                	mov    (%eax),%eax
80107b67:	83 e0 01             	and    $0x1,%eax
80107b6a:	85 c0                	test   %eax,%eax
80107b6c:	74 0c                	je     80107b7a <mappages+0x64>
      panic("remap");
80107b6e:	c7 04 24 00 8a 10 80 	movl   $0x80108a00,(%esp)
80107b75:	e8 da 89 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107b7a:	8b 45 18             	mov    0x18(%ebp),%eax
80107b7d:	0b 45 14             	or     0x14(%ebp),%eax
80107b80:	83 c8 01             	or     $0x1,%eax
80107b83:	89 c2                	mov    %eax,%edx
80107b85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b88:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107b90:	75 08                	jne    80107b9a <mappages+0x84>
      break;
80107b92:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107b93:	b8 00 00 00 00       	mov    $0x0,%eax
80107b98:	eb 10                	jmp    80107baa <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107b9a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ba1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ba8:	eb 8e                	jmp    80107b38 <mappages+0x22>
  return 0;
}
80107baa:	c9                   	leave  
80107bab:	c3                   	ret    

80107bac <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107bac:	55                   	push   %ebp
80107bad:	89 e5                	mov    %esp,%ebp
80107baf:	53                   	push   %ebx
80107bb0:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107bb3:	e8 ab af ff ff       	call   80102b63 <kalloc>
80107bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bbf:	75 07                	jne    80107bc8 <setupkvm+0x1c>
    return 0;
80107bc1:	b8 00 00 00 00       	mov    $0x0,%eax
80107bc6:	eb 79                	jmp    80107c41 <setupkvm+0x95>
  memset(pgdir, 0, PGSIZE);
80107bc8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107bcf:	00 
80107bd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107bd7:	00 
80107bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bdb:	89 04 24             	mov    %eax,(%esp)
80107bde:	e8 63 d5 ff ff       	call   80105146 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107be3:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107bea:	eb 49                	jmp    80107c35 <setupkvm+0x89>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bef:	8b 48 0c             	mov    0xc(%eax),%ecx
80107bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf5:	8b 50 04             	mov    0x4(%eax),%edx
80107bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfb:	8b 58 08             	mov    0x8(%eax),%ebx
80107bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c01:	8b 40 04             	mov    0x4(%eax),%eax
80107c04:	29 c3                	sub    %eax,%ebx
80107c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c09:	8b 00                	mov    (%eax),%eax
80107c0b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107c0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107c13:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107c17:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c1e:	89 04 24             	mov    %eax,(%esp)
80107c21:	e8 f0 fe ff ff       	call   80107b16 <mappages>
80107c26:	85 c0                	test   %eax,%eax
80107c28:	79 07                	jns    80107c31 <setupkvm+0x85>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107c2a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c2f:	eb 10                	jmp    80107c41 <setupkvm+0x95>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c31:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c35:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107c3c:	72 ae                	jb     80107bec <setupkvm+0x40>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c41:	83 c4 34             	add    $0x34,%esp
80107c44:	5b                   	pop    %ebx
80107c45:	5d                   	pop    %ebp
80107c46:	c3                   	ret    

80107c47 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c47:	55                   	push   %ebp
80107c48:	89 e5                	mov    %esp,%ebp
80107c4a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c4d:	e8 5a ff ff ff       	call   80107bac <setupkvm>
80107c52:	a3 a4 65 11 80       	mov    %eax,0x801165a4
  switchkvm();
80107c57:	e8 02 00 00 00       	call   80107c5e <switchkvm>
}
80107c5c:	c9                   	leave  
80107c5d:	c3                   	ret    

80107c5e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c5e:	55                   	push   %ebp
80107c5f:	89 e5                	mov    %esp,%ebp
80107c61:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107c64:	a1 a4 65 11 80       	mov    0x801165a4,%eax
80107c69:	05 00 00 00 80       	add    $0x80000000,%eax
80107c6e:	89 04 24             	mov    %eax,(%esp)
80107c71:	e8 a2 f9 ff ff       	call   80107618 <lcr3>
}
80107c76:	c9                   	leave  
80107c77:	c3                   	ret    

80107c78 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c78:	55                   	push   %ebp
80107c79:	89 e5                	mov    %esp,%ebp
80107c7b:	53                   	push   %ebx
80107c7c:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107c7f:	e8 b4 d3 ff ff       	call   80105038 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107c84:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107c8a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c91:	83 c2 08             	add    $0x8,%edx
80107c94:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107c9b:	83 c1 08             	add    $0x8,%ecx
80107c9e:	c1 e9 10             	shr    $0x10,%ecx
80107ca1:	88 cb                	mov    %cl,%bl
80107ca3:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107caa:	83 c1 08             	add    $0x8,%ecx
80107cad:	c1 e9 18             	shr    $0x18,%ecx
80107cb0:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107cb7:	67 00 
80107cb9:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
80107cc0:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107cc6:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107ccc:	83 e2 f0             	and    $0xfffffff0,%edx
80107ccf:	83 ca 09             	or     $0x9,%edx
80107cd2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107cd8:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107cde:	83 ca 10             	or     $0x10,%edx
80107ce1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ce7:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107ced:	83 e2 9f             	and    $0xffffff9f,%edx
80107cf0:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107cf6:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107cfc:	83 ca 80             	or     $0xffffff80,%edx
80107cff:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107d05:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107d0b:	83 e2 f0             	and    $0xfffffff0,%edx
80107d0e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d14:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107d1a:	83 e2 ef             	and    $0xffffffef,%edx
80107d1d:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d23:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107d29:	83 e2 df             	and    $0xffffffdf,%edx
80107d2c:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d32:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107d38:	83 ca 40             	or     $0x40,%edx
80107d3b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d41:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107d47:	83 e2 7f             	and    $0x7f,%edx
80107d4a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d50:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107d56:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d5c:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107d62:	83 e2 ef             	and    $0xffffffef,%edx
80107d65:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107d6b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d71:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107d77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d7d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107d84:	8b 52 08             	mov    0x8(%edx),%edx
80107d87:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107d8d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  cpu->ts.iomb = (ushort) 0xFFFF;
80107d90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d96:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107d9c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107da3:	e8 47 f8 ff ff       	call   801075ef <ltr>
  if(p->pgdir == 0)
80107da8:	8b 45 08             	mov    0x8(%ebp),%eax
80107dab:	8b 40 04             	mov    0x4(%eax),%eax
80107dae:	85 c0                	test   %eax,%eax
80107db0:	75 0c                	jne    80107dbe <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107db2:	c7 04 24 06 8a 10 80 	movl   $0x80108a06,(%esp)
80107db9:	e8 96 87 ff ff       	call   80100554 <panic>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc1:	8b 40 04             	mov    0x4(%eax),%eax
80107dc4:	05 00 00 00 80       	add    $0x80000000,%eax
80107dc9:	89 04 24             	mov    %eax,(%esp)
80107dcc:	e8 47 f8 ff ff       	call   80107618 <lcr3>
  popcli();
80107dd1:	e8 b6 d2 ff ff       	call   8010508c <popcli>
}
80107dd6:	83 c4 14             	add    $0x14,%esp
80107dd9:	5b                   	pop    %ebx
80107dda:	5d                   	pop    %ebp
80107ddb:	c3                   	ret    

80107ddc <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ddc:	55                   	push   %ebp
80107ddd:	89 e5                	mov    %esp,%ebp
80107ddf:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107de2:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107de9:	76 0c                	jbe    80107df7 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107deb:	c7 04 24 1a 8a 10 80 	movl   $0x80108a1a,(%esp)
80107df2:	e8 5d 87 ff ff       	call   80100554 <panic>
  mem = kalloc();
80107df7:	e8 67 ad ff ff       	call   80102b63 <kalloc>
80107dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107dff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e06:	00 
80107e07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e0e:	00 
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	89 04 24             	mov    %eax,(%esp)
80107e15:	e8 2c d3 ff ff       	call   80105146 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1d:	05 00 00 00 80       	add    $0x80000000,%eax
80107e22:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e29:	00 
80107e2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107e2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e35:	00 
80107e36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e3d:	00 
80107e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e41:	89 04 24             	mov    %eax,(%esp)
80107e44:	e8 cd fc ff ff       	call   80107b16 <mappages>
  memmove(mem, init, sz);
80107e49:	8b 45 10             	mov    0x10(%ebp),%eax
80107e4c:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e53:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	89 04 24             	mov    %eax,(%esp)
80107e5d:	e8 ad d3 ff ff       	call   8010520f <memmove>
}
80107e62:	c9                   	leave  
80107e63:	c3                   	ret    

80107e64 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e64:	55                   	push   %ebp
80107e65:	89 e5                	mov    %esp,%ebp
80107e67:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e6d:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e72:	85 c0                	test   %eax,%eax
80107e74:	74 0c                	je     80107e82 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107e76:	c7 04 24 34 8a 10 80 	movl   $0x80108a34,(%esp)
80107e7d:	e8 d2 86 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107e82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e89:	e9 a6 00 00 00       	jmp    80107f34 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e94:	01 d0                	add    %edx,%eax
80107e96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e9d:	00 
80107e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea5:	89 04 24             	mov    %eax,(%esp)
80107ea8:	e8 cd fb ff ff       	call   80107a7a <walkpgdir>
80107ead:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107eb0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107eb4:	75 0c                	jne    80107ec2 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107eb6:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
80107ebd:	e8 92 86 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80107ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec5:	8b 00                	mov    (%eax),%eax
80107ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ecc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed2:	8b 55 18             	mov    0x18(%ebp),%edx
80107ed5:	29 c2                	sub    %eax,%edx
80107ed7:	89 d0                	mov    %edx,%eax
80107ed9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107ede:	77 0f                	ja     80107eef <loaduvm+0x8b>
      n = sz - i;
80107ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee3:	8b 55 18             	mov    0x18(%ebp),%edx
80107ee6:	29 c2                	sub    %eax,%edx
80107ee8:	89 d0                	mov    %edx,%eax
80107eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107eed:	eb 07                	jmp    80107ef6 <loaduvm+0x92>
    else
      n = PGSIZE;
80107eef:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef9:	8b 55 14             	mov    0x14(%ebp),%edx
80107efc:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80107eff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f02:	05 00 00 00 80       	add    $0x80000000,%eax
80107f07:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107f0a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f0e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107f12:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f16:	8b 45 10             	mov    0x10(%ebp),%eax
80107f19:	89 04 24             	mov    %eax,(%esp)
80107f1c:	e8 81 9e ff ff       	call   80101da2 <readi>
80107f21:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f24:	74 07                	je     80107f2d <loaduvm+0xc9>
      return -1;
80107f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f2b:	eb 18                	jmp    80107f45 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107f2d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f37:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f3a:	0f 82 4e ff ff ff    	jb     80107e8e <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107f40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f45:	c9                   	leave  
80107f46:	c3                   	ret    

80107f47 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f47:	55                   	push   %ebp
80107f48:	89 e5                	mov    %esp,%ebp
80107f4a:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f4d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f50:	85 c0                	test   %eax,%eax
80107f52:	79 0a                	jns    80107f5e <allocuvm+0x17>
    return 0;
80107f54:	b8 00 00 00 00       	mov    $0x0,%eax
80107f59:	e9 fd 00 00 00       	jmp    8010805b <allocuvm+0x114>
  if(newsz < oldsz)
80107f5e:	8b 45 10             	mov    0x10(%ebp),%eax
80107f61:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f64:	73 08                	jae    80107f6e <allocuvm+0x27>
    return oldsz;
80107f66:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f69:	e9 ed 00 00 00       	jmp    8010805b <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80107f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f71:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107f7e:	e9 c9 00 00 00       	jmp    8010804c <allocuvm+0x105>
    mem = kalloc();
80107f83:	e8 db ab ff ff       	call   80102b63 <kalloc>
80107f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107f8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f8f:	75 2f                	jne    80107fc0 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80107f91:	c7 04 24 75 8a 10 80 	movl   $0x80108a75,(%esp)
80107f98:	e8 24 84 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa0:	89 44 24 08          	mov    %eax,0x8(%esp)
80107fa4:	8b 45 10             	mov    0x10(%ebp),%eax
80107fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fab:	8b 45 08             	mov    0x8(%ebp),%eax
80107fae:	89 04 24             	mov    %eax,(%esp)
80107fb1:	e8 a7 00 00 00       	call   8010805d <deallocuvm>
      return 0;
80107fb6:	b8 00 00 00 00       	mov    $0x0,%eax
80107fbb:	e9 9b 00 00 00       	jmp    8010805b <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80107fc0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fc7:	00 
80107fc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fcf:	00 
80107fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd3:	89 04 24             	mov    %eax,(%esp)
80107fd6:	e8 6b d1 ff ff       	call   80105146 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fde:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe7:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107fee:	00 
80107fef:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107ff3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ffa:	00 
80107ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fff:	8b 45 08             	mov    0x8(%ebp),%eax
80108002:	89 04 24             	mov    %eax,(%esp)
80108005:	e8 0c fb ff ff       	call   80107b16 <mappages>
8010800a:	85 c0                	test   %eax,%eax
8010800c:	79 37                	jns    80108045 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
8010800e:	c7 04 24 8d 8a 10 80 	movl   $0x80108a8d,(%esp)
80108015:	e8 a7 83 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010801a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801d:	89 44 24 08          	mov    %eax,0x8(%esp)
80108021:	8b 45 10             	mov    0x10(%ebp),%eax
80108024:	89 44 24 04          	mov    %eax,0x4(%esp)
80108028:	8b 45 08             	mov    0x8(%ebp),%eax
8010802b:	89 04 24             	mov    %eax,(%esp)
8010802e:	e8 2a 00 00 00       	call   8010805d <deallocuvm>
      kfree(mem);
80108033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108036:	89 04 24             	mov    %eax,(%esp)
80108039:	e8 8f aa ff ff       	call   80102acd <kfree>
      return 0;
8010803e:	b8 00 00 00 00       	mov    $0x0,%eax
80108043:	eb 16                	jmp    8010805b <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108045:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010804c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108052:	0f 82 2b ff ff ff    	jb     80107f83 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108058:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010805b:	c9                   	leave  
8010805c:	c3                   	ret    

8010805d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010805d:	55                   	push   %ebp
8010805e:	89 e5                	mov    %esp,%ebp
80108060:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108063:	8b 45 10             	mov    0x10(%ebp),%eax
80108066:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108069:	72 08                	jb     80108073 <deallocuvm+0x16>
    return oldsz;
8010806b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806e:	e9 9e 00 00 00       	jmp    80108111 <deallocuvm+0xb4>

  a = PGROUNDUP(newsz);
80108073:	8b 45 10             	mov    0x10(%ebp),%eax
80108076:	05 ff 0f 00 00       	add    $0xfff,%eax
8010807b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108080:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108083:	eb 7d                	jmp    80108102 <deallocuvm+0xa5>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108088:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010808f:	00 
80108090:	89 44 24 04          	mov    %eax,0x4(%esp)
80108094:	8b 45 08             	mov    0x8(%ebp),%eax
80108097:	89 04 24             	mov    %eax,(%esp)
8010809a:	e8 db f9 ff ff       	call   80107a7a <walkpgdir>
8010809f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801080a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080a6:	75 09                	jne    801080b1 <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
801080a8:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801080af:	eb 4a                	jmp    801080fb <deallocuvm+0x9e>
    else if((*pte & PTE_P) != 0){
801080b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b4:	8b 00                	mov    (%eax),%eax
801080b6:	83 e0 01             	and    $0x1,%eax
801080b9:	85 c0                	test   %eax,%eax
801080bb:	74 3e                	je     801080fb <deallocuvm+0x9e>
      pa = PTE_ADDR(*pte);
801080bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c0:	8b 00                	mov    (%eax),%eax
801080c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801080ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080ce:	75 0c                	jne    801080dc <deallocuvm+0x7f>
        panic("kfree");
801080d0:	c7 04 24 a9 8a 10 80 	movl   $0x80108aa9,(%esp)
801080d7:	e8 78 84 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
801080dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080df:	05 00 00 00 80       	add    $0x80000000,%eax
801080e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801080e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080ea:	89 04 24             	mov    %eax,(%esp)
801080ed:	e8 db a9 ff ff       	call   80102acd <kfree>
      *pte = 0;
801080f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801080fb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108105:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108108:	0f 82 77 ff ff ff    	jb     80108085 <deallocuvm+0x28>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010810e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108111:	c9                   	leave  
80108112:	c3                   	ret    

80108113 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108113:	55                   	push   %ebp
80108114:	89 e5                	mov    %esp,%ebp
80108116:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108119:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010811d:	75 0c                	jne    8010812b <freevm+0x18>
    panic("freevm: no pgdir");
8010811f:	c7 04 24 af 8a 10 80 	movl   $0x80108aaf,(%esp)
80108126:	e8 29 84 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010812b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108132:	00 
80108133:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010813a:	80 
8010813b:	8b 45 08             	mov    0x8(%ebp),%eax
8010813e:	89 04 24             	mov    %eax,(%esp)
80108141:	e8 17 ff ff ff       	call   8010805d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108146:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010814d:	eb 44                	jmp    80108193 <freevm+0x80>
    if(pgdir[i] & PTE_P){
8010814f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108152:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108159:	8b 45 08             	mov    0x8(%ebp),%eax
8010815c:	01 d0                	add    %edx,%eax
8010815e:	8b 00                	mov    (%eax),%eax
80108160:	83 e0 01             	and    $0x1,%eax
80108163:	85 c0                	test   %eax,%eax
80108165:	74 29                	je     80108190 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108171:	8b 45 08             	mov    0x8(%ebp),%eax
80108174:	01 d0                	add    %edx,%eax
80108176:	8b 00                	mov    (%eax),%eax
80108178:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817d:	05 00 00 00 80       	add    $0x80000000,%eax
80108182:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108188:	89 04 24             	mov    %eax,(%esp)
8010818b:	e8 3d a9 ff ff       	call   80102acd <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108190:	ff 45 f4             	incl   -0xc(%ebp)
80108193:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010819a:	76 b3                	jbe    8010814f <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010819c:	8b 45 08             	mov    0x8(%ebp),%eax
8010819f:	89 04 24             	mov    %eax,(%esp)
801081a2:	e8 26 a9 ff ff       	call   80102acd <kfree>
}
801081a7:	c9                   	leave  
801081a8:	c3                   	ret    

801081a9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801081a9:	55                   	push   %ebp
801081aa:	89 e5                	mov    %esp,%ebp
801081ac:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081b6:	00 
801081b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801081be:	8b 45 08             	mov    0x8(%ebp),%eax
801081c1:	89 04 24             	mov    %eax,(%esp)
801081c4:	e8 b1 f8 ff ff       	call   80107a7a <walkpgdir>
801081c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801081cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081d0:	75 0c                	jne    801081de <clearpteu+0x35>
    panic("clearpteu");
801081d2:	c7 04 24 c0 8a 10 80 	movl   $0x80108ac0,(%esp)
801081d9:	e8 76 83 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
801081de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e1:	8b 00                	mov    (%eax),%eax
801081e3:	83 e0 fb             	and    $0xfffffffb,%eax
801081e6:	89 c2                	mov    %eax,%edx
801081e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081eb:	89 10                	mov    %edx,(%eax)
}
801081ed:	c9                   	leave  
801081ee:	c3                   	ret    

801081ef <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801081ef:	55                   	push   %ebp
801081f0:	89 e5                	mov    %esp,%ebp
801081f2:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801081f5:	e8 b2 f9 ff ff       	call   80107bac <setupkvm>
801081fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108201:	75 0a                	jne    8010820d <copyuvm+0x1e>
    return 0;
80108203:	b8 00 00 00 00       	mov    $0x0,%eax
80108208:	e9 f8 00 00 00       	jmp    80108305 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
8010820d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108214:	e9 cb 00 00 00       	jmp    801082e4 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108223:	00 
80108224:	89 44 24 04          	mov    %eax,0x4(%esp)
80108228:	8b 45 08             	mov    0x8(%ebp),%eax
8010822b:	89 04 24             	mov    %eax,(%esp)
8010822e:	e8 47 f8 ff ff       	call   80107a7a <walkpgdir>
80108233:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108236:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010823a:	75 0c                	jne    80108248 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010823c:	c7 04 24 ca 8a 10 80 	movl   $0x80108aca,(%esp)
80108243:	e8 0c 83 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010824b:	8b 00                	mov    (%eax),%eax
8010824d:	83 e0 01             	and    $0x1,%eax
80108250:	85 c0                	test   %eax,%eax
80108252:	75 0c                	jne    80108260 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108254:	c7 04 24 e4 8a 10 80 	movl   $0x80108ae4,(%esp)
8010825b:	e8 f4 82 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108260:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108263:	8b 00                	mov    (%eax),%eax
80108265:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010826a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010826d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108270:	8b 00                	mov    (%eax),%eax
80108272:	25 ff 0f 00 00       	and    $0xfff,%eax
80108277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010827a:	e8 e4 a8 ff ff       	call   80102b63 <kalloc>
8010827f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108282:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108286:	75 02                	jne    8010828a <copyuvm+0x9b>
      goto bad;
80108288:	eb 6b                	jmp    801082f5 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010828a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010828d:	05 00 00 00 80       	add    $0x80000000,%eax
80108292:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108299:	00 
8010829a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010829e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082a1:	89 04 24             	mov    %eax,(%esp)
801082a4:	e8 66 cf ff ff       	call   8010520f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801082a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801082ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082af:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801082b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b8:	89 54 24 10          	mov    %edx,0x10(%esp)
801082bc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801082c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082c7:	00 
801082c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801082cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082cf:	89 04 24             	mov    %eax,(%esp)
801082d2:	e8 3f f8 ff ff       	call   80107b16 <mappages>
801082d7:	85 c0                	test   %eax,%eax
801082d9:	79 02                	jns    801082dd <copyuvm+0xee>
      goto bad;
801082db:	eb 18                	jmp    801082f5 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801082dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082ea:	0f 82 29 ff ff ff    	jb     80108219 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
801082f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f3:	eb 10                	jmp    80108305 <copyuvm+0x116>

bad:
  freevm(d);
801082f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f8:	89 04 24             	mov    %eax,(%esp)
801082fb:	e8 13 fe ff ff       	call   80108113 <freevm>
  return 0;
80108300:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108305:	c9                   	leave  
80108306:	c3                   	ret    

80108307 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108307:	55                   	push   %ebp
80108308:	89 e5                	mov    %esp,%ebp
8010830a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010830d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108314:	00 
80108315:	8b 45 0c             	mov    0xc(%ebp),%eax
80108318:	89 44 24 04          	mov    %eax,0x4(%esp)
8010831c:	8b 45 08             	mov    0x8(%ebp),%eax
8010831f:	89 04 24             	mov    %eax,(%esp)
80108322:	e8 53 f7 ff ff       	call   80107a7a <walkpgdir>
80108327:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010832a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832d:	8b 00                	mov    (%eax),%eax
8010832f:	83 e0 01             	and    $0x1,%eax
80108332:	85 c0                	test   %eax,%eax
80108334:	75 07                	jne    8010833d <uva2ka+0x36>
    return 0;
80108336:	b8 00 00 00 00       	mov    $0x0,%eax
8010833b:	eb 22                	jmp    8010835f <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010833d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108340:	8b 00                	mov    (%eax),%eax
80108342:	83 e0 04             	and    $0x4,%eax
80108345:	85 c0                	test   %eax,%eax
80108347:	75 07                	jne    80108350 <uva2ka+0x49>
    return 0;
80108349:	b8 00 00 00 00       	mov    $0x0,%eax
8010834e:	eb 0f                	jmp    8010835f <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108353:	8b 00                	mov    (%eax),%eax
80108355:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010835a:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010835f:	c9                   	leave  
80108360:	c3                   	ret    

80108361 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108361:	55                   	push   %ebp
80108362:	89 e5                	mov    %esp,%ebp
80108364:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108367:	8b 45 10             	mov    0x10(%ebp),%eax
8010836a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010836d:	e9 87 00 00 00       	jmp    801083f9 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108372:	8b 45 0c             	mov    0xc(%ebp),%eax
80108375:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010837a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010837d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108380:	89 44 24 04          	mov    %eax,0x4(%esp)
80108384:	8b 45 08             	mov    0x8(%ebp),%eax
80108387:	89 04 24             	mov    %eax,(%esp)
8010838a:	e8 78 ff ff ff       	call   80108307 <uva2ka>
8010838f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108392:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108396:	75 07                	jne    8010839f <copyout+0x3e>
      return -1;
80108398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010839d:	eb 69                	jmp    80108408 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010839f:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801083a5:	29 c2                	sub    %eax,%edx
801083a7:	89 d0                	mov    %edx,%eax
801083a9:	05 00 10 00 00       	add    $0x1000,%eax
801083ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801083b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b4:	3b 45 14             	cmp    0x14(%ebp),%eax
801083b7:	76 06                	jbe    801083bf <copyout+0x5e>
      n = len;
801083b9:	8b 45 14             	mov    0x14(%ebp),%eax
801083bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801083bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801083c5:	29 c2                	sub    %eax,%edx
801083c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083ca:	01 c2                	add    %eax,%edx
801083cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801083d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801083da:	89 14 24             	mov    %edx,(%esp)
801083dd:	e8 2d ce ff ff       	call   8010520f <memmove>
    len -= n;
801083e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e5:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801083e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083eb:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801083ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f1:	05 00 10 00 00       	add    $0x1000,%eax
801083f6:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801083f9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801083fd:	0f 85 6f ff ff ff    	jne    80108372 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108403:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108408:	c9                   	leave  
80108409:	c3                   	ret    
