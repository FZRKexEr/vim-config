let g:plug_url_format='https://ghproxy.com/https://github.com/%s'

if(has('mac') || has('unix'))
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://ghproxy.com/https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall | source ~/.vimrc
  endif
endif

call plug#begin()
  Plug 'wakatime/vim-wakatime'
  Plug 'thaerkh/vim-workspace'
  Plug 'aperezdc/vim-template'
  Plug 'skywind3000/vim-auto-popmenu'
  Plug 'skywind3000/vim-dict'
  Plug 'dense-analysis/ale'
  Plug 'sainnhe/sonokai'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'wincent/terminus'
  Plug 'yianwillis/vimcdoc'
  Plug 'ap/vim-buftabline'
  Plug 'mhinz/vim-startify'
  Plug 'octol/vim-cpp-enhanced-highlight'
call plug#end()

autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" core options
filetype plugin on
set encoding=UTF-8
set fileformats=unix,dos,mac
set autochdir

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set cindent
set clipboard=unnamed
set whichwrap+=<,>
set backspace=eol,indent

set number
set signcolumn=yes
set hlsearch
set wrap
set hidden

syntax on
let mapleader = ' '

" colorscheme - sonokai
if has('termguicolors')
  set termguicolors
endif
let g:sonokai_style = 'default'
let g:sonokai_better_performance = 1
colorscheme sonokai


" macvim and gvim
if has('gui_macvim')
  autocmd GUIEnter * set vb t_vb=
  set guifont=UbuntuMono\ Nerd\ Font\ Mono:h16
elseif has('gui_running')
  set guioptions-=T
  set guioptions-=e
  set t_Co=256
  set guitablabel=%M\ %t
  if has('unix')
    set guifont=UbuntuMono\ Nerd\ Font\ Mono\ 18
  else
    set guifont=UbuntuMono_Nerd_Font_Mono:h18:cANSI:qDRAFT
  endif
endif

" Compile and run
nnoremap <space>r :call CodeRunner() <CR>

function! CodeRunner()
  if (has('unix') || has('gui_running'))
    silent execute 'w'
    let l:run = 'AsyncRun -mode=term -pos=right -save=1 '
    let l:cmd = {}
    let l:cmd['cpp'] = " -DLOCAL -std=c++17 -Wall -O2 \"$(VIM_FILEPATH)\" && "

    if executable('g++-12')
      let l:cmd['cpp'] = 'g++-12' . l:cmd['cpp']
    else
      let l:cmd['cpp'] = 'g++' . l:cmd['cpp']
    endif

    if has('unix')
      let l:cmd['cpp'] = l:cmd['cpp'] . './a.out'
    else
      let l:cmd['cpp'] = l:cmd['cpp'] . 'a.exe'
    endif
    
    " windows and terminal vim can't automatic cleanup (No solution has been found so far.)
    if (has('nvim') || has('gui_macvim'))
      let l:cmd['cpp'] = "-post=silent\\ execute\\ '!rm\\ a.out' " . l:cmd['cpp']
    endif

    let l:cmd['python'] = 'python3 % '
    let l:cmd['lua'] = 'lua % '
    let l:cmd['sh'] = 'sh % '

    if has_key(cmd, &filetype)
      execute l:run . l:cmd[&filetype]
    endif
  else
    echo 'On windows, it can only be compiled and run in gvim'
  endif
endfunction

if executable('oj')

  nnoremap <space>t :call TestSamples() <CR>

  function! s:ReadProblemURLFromCurrentBuffer()
    let l:lines = getline(0, line('$'))
    for l:line in l:lines
      let l:record = split(l:line, ' ')
      for l:r in l:record
        let l:url = matchstr(r, '^\(http\|https\):.*$')
        if l:url !=? ''
          return l:url
        endif
      endfor
    endfor
    return ''
  endfunction
  
  function! s:MakeSampleDLCommand(url)
    let l:cur_buf_dir = expand('%:h')
    let l:target_dir = l:cur_buf_dir . '/test'
    let l:dl_command = printf('oj download -d %s %s', l:target_dir, a:url)
    return l:dl_command
  endfunction
  function! s:DownloadSamples(url)
    let l:command = s:MakeSampleDLCommand(a:url)
    return l:command
"    call execute("AsyncRun -mode=term -pos=right -save=1 " . l:command)
  endfunction
  
"  command! -nargs=0 DownloadSamples :call s:DownloadSamples(s:ReadProblemURLFromCurrentBuffer())
  
  function! s:MakeTestSamplesCommand()
    let l:cur_buf_cpp = expand('%')
    let l:cur_buf_dir = expand('%:h')
    let l:sample_file_dir = l:cur_buf_dir . '/test'
    let l:compiler = 'g++'
    if executable('g++-12')
      let l:compiler = 'g++-12'
    endif
    let l:test_command = printf(l:compiler . ' -DONLINE_JUDGE -DLOCAL_TEST %s && oj test -d %s -t 4',l:cur_buf_cpp, l:sample_file_dir)
    return l:test_command
  endfunction

  function! TestSamples() " s:TestSamples()
    let l:cur_buf_dir = expand('%:h')
    let l:target_sample1 = l:cur_buf_dir . '/test/sample-1.in'
    let l:target_sample2 = l:cur_buf_dir . '/test/random-000.in'
    if (filereadable(target_sample1) == 0) && (filereadable(target_sample2) == 0)
      let l:command = s:DownloadSamples(s:ReadProblemURLFromCurrentBuffer()) . ' && ' . s:MakeTestSamplesCommand()
      call execute("AsyncRun -post=silent\\ execute\\ '!rm\\ a.out' -mode=term -pos=right -save=1 " . l:command)
    else
      let l:command = s:MakeTestSamplesCommand()
      call execute("AsyncRun -post=silent\\ execute\\ '!rm\\ a.out' -mode=term -pos=right -save=1 " . l:command)
    endif
  endfunction
  
"  command! -nargs=0 TestSamples :call s:TestSamples()
  
  function! s:MakeSubmitCommand(url)
    let l:cur_buf_cpp = expand('%')
    let l:submit_command = printf('oj submit -y %s %s', a:url, l:cur_buf_cpp)
    return l:submit_command
  endfunction
  function! s:SubmitCode(url)
    let l:command = s:MakeSubmitCommand(a:url)
    call execute("AsyncRun -post=silent\\ execute\\ '!rm\\ a.out' -mode=term -pos=right -save=1 " . l:command)
  endfunction
  
  command! -nargs=0 SubmitCode :call s:SubmitCode(s:ReadProblemURLFromCurrentBuffer())
endif

" Ale
let g:ale_linters = {'cpp': ['cc']}

if executable('g++-12')
  let g:ale_cpp_cc_executable = 'g++-12' 
else
  let g:ale_cpp_cc_executable = 'g++' 
endif

let g:ale_cpp_cc_options = '-DLOCAL -std=c++17 -Wall -O2'
let g:ale_cpp_cppcheck_options = '-DLOCAL -std=c++17 -Wall -O2'

" buffer and windows
nnoremap <S-l> :bn<CR>
nnoremap <S-h> :bp<CR>
nnoremap <space>q :bd<CR>
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" autosave
let g:workspace_autosave_always = 1

" auto popmenu
let g:apc_enable_ft = {'text':1, 'markdown':1, 'cpp':1, 'python':1}
set complete=.,k,w,b
set completeopt=menu,menuone,noselect
set shortmess+=c

" template
let g:templates_no_builtin_templates=1
let g:templates_global_name_prefix='template'
let g:templates_name_prefix='template.local'
let g:templates_detect_git=1

" startify

let g:startify_files_number = 5
let g:startify_lists = [
       \ { 'type': 'files',     'header': ['   MRU']            },
       \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
       \ { 'type': 'commands',  'header': ['   Commands']       },
       \ ]

autocmd User Startified nmap <buffer> l <plug>(startify-open-buffers)


let g:ascii = [
   \ '██╗     ██╗███████╗███╗   ██╗██████╗ ',
   \ '██║     ██║╚══███╔╝████╗  ██║██╔══██╗',
   \ '██║     ██║  ███╔╝ ██╔██╗ ██║██████╔╝',
   \ '██║     ██║ ███╔╝  ██║╚██╗██║██╔══██╗',
   \ '███████╗██║███████╗██║ ╚████║██████╔╝',
   \ '╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝╚═════╝ ',
   \ '                                     ',
   \ ]


let g:startify_custom_header_quotes = [
      \ ['我们都喜欢看书，喜欢听音乐，都最喜欢猫，都不擅长向别人表达自己的感受。不能吃的食物都能列出长长一串，中意的科目都全然不觉得难受，讨厌的科目学起来都深恶痛绝。', '——《国境以南 太阳以西》'],
      \ ['时间和感情的流程由于场所改变便遽然改变的情形毕竟是有的。', '——《国境以南 太阳以西》'],
      \ ['年过二十时我忽然心想：说不定自己再不能成为一个地道的人了。我犯过几个错误，但实际上那甚至连错误都不是。与其说是错误，或许莫如说是我自身与生俱来的倾向性东西。如此想着，我黯然神伤。', '——《国境以南 太阳以西》'],
      \ ['他当初对妻有纪子所以一见倾心，也并不是因为她长得漂亮，而是因为从其长相中明确感觉到了“为我自己准备的东西”。', '——《国境以南 太阳以西》'],
      \ ['不去见岛本之后，我也经常怀念她。在整个青春期这一充满困惑的痛苦过程中，那温馨的记忆不知给了我多少次鼓励和慰藉。很长时间里，我在自己心中为她保存了一块特殊园地。就像在餐馆最里边一张安静的桌面上悄然竖起“预订席”标牌一样，我将那块园地只留给了她一个人，尽管我推想再不可能见到她了。', '——《国境以南 太阳以西》'],
      \ ['她长得不算怎么漂亮。就是说，不是母亲看全班合影时会叹息“这孩子叫什么名字，好漂亮啊”那一类型的，但我从第一次见面就觉得她惹人喜爱。照片上倒看不出来，现实中的她却有一种自然打动人心的毫不矫饰的温情。确乎不是足以到处炫耀的美少女，但细想之下，我也并不具有值得向人吹嘘的那类东西。', '——《国境以南 太阳以西》'],
      \ ['但是，只消坐在她身边碰一下她的手指，我心里就顿时油然充满温馨。即使是对别人不好开口的事，在她面前也能畅所欲言。我喜欢吻她的眼睑和嘴唇，喜欢撩起她的头发吻那小小的耳朵。一吻，她便哧哧地笑。如今想起她，星期日那静静的清晨都每每浮现在眼前。天朗气清、刚刚开始的星期日，作业没有、什么也没有、尽可做自己喜欢的事的星期日——她屡屡让我产生如此星期日清晨般的心绪。', '——《国境以南 太阳以西》' ],
      \ ['需要的是小小的积累，不仅仅是话语和许诺，还要将小小的具体的事实一个个小心积累起来，只有这样两人才能一步一步走向前去。她所追求的，我想归根结蒂便是这个。', '——《国境以南 太阳以西》'],
      \ ['她不是——也许应该说她也不是——一起上街时令擦肩而过的男人不由回头的那一类型，不如说几乎不引人注意更为准确。然而第一次同她相见，我就莫名其妙地被她深深吸引了。那简直就像在光天化日下走路时突然被肉眼看不见的闷雷击中一般，没有保留没有条件，没有原因没有交代，没有“但是”没有“如果”。', '——《国境以南 太阳以西》'],
      \ ['我们之间有几个大的不同点，而且是随着成长、随着年龄增大而逐渐扩大的那类不同点。现在回头看去，我看得十分清楚。', '——《国境以南 太阳以西》'],
      \ ['世上没有意思的事多得堆成山，用不着一一放在心上。', '——《国境以南 太阳以西》'],
      \ ['如果天不下雨或当时我带伞（那是可能的，因为离开旅馆时我犹豫了半天，不知该不该带伞），那么就不会碰上她了。而若碰不上她，恐怕我现在都将在出版教科书的公司工作，晚上一个人背靠宿舍墙壁自言自语地喝酒。每次想到这里，我都认识到这样一点：其实我们只能在有限的可能性中生存。', '——《国境以南 太阳以西》'],
      \ ['“非常喜欢过去的你，所以不想见了现在的你以后产生失望。”', '——《国境以南 太阳以西》'],
      \ ['幸福不幸福，自己也不大清楚。不过至少不觉得不幸，也不孤独。”停顿片刻，我又加上一句：“有时候会因为什么突然这样想来着：在你家客厅两人听音乐的时候大约是我一生中最幸福的时光。', '——《国境以南 太阳以西》'],
      \ ['“哄女孩子怕是正好。”“跟你说，岛本，你好像不大晓得，鸡尾酒这种饮料大体上还真是干这个用的。”', '——《国境以南 太阳以西》'],
      \ ['“我做不出酒柜，汽车上的油过滤器也换不了，邮票都贴不正，电话号也时常按错。不过有创意的鸡尾酒倒配出了几种，评价也不错。”', '——《国境以南 太阳以西》'],
      \ ['算不上多么幸福的时代，又有很多欲望得不到满足，更年轻、更饥渴、更孤独，但我确实单纯，就像一清见底的池水。当时听的音乐的每一音节、看的书的每一行都好像深深沁入肺腑，神经如楔子一样尖锐，眼里的光尖刻得足以刺穿对方。就是那么一个年代。', '——《国境以南 太阳以西》'],
      \ ['“岛本，还能见到你？”“大概能吧。”说着，她嘴唇上漾出淡淡的笑意，犹如无风的日子里静静升起的一小缕烟。“大概。”', '——《国境以南 太阳以西》'],
      \ ['我在其旁边坐下，闭起眼睛。音乐声渐次远离，剩下我孑身一人。柔软的夜幕中，雨仍在无声无息地下着。', '——《国境以南 太阳以西》'],
      \ ['我这个人对于她并非那么可贵的存在。想到这里，我一阵难受，就好像心里开了一个小洞。她不该把那样的话说出口，某种话语是应当永远留在心里的。', '——《国境以南 太阳以西》'],
      \ [' “为什么不看新小说？”“怕是不愿意失望吧。看无聊的书，觉得像是白白浪费时间，又失望得很。过去不然。时间多的是，看无聊的书也总觉得有所收获。就那样。如今不一样，认为纯属浪费时间。也许是上年纪的关系。”', '——《国境以南 太阳以西》'],
      \ ['“嗳，初君，为什么这里所有的鸡尾酒都比别处的好喝呢？”“因为付出了相应的努力，不努力不可能如愿以偿。”', '——《国境以南 太阳以西》'],
      \ ['“你认为为什么那么多人每晚每晚大把花钱特意来这里喝酒？那是因为大家都或多或少地在寻求虚拟场所。他们是为了看巧夺天工俨然空中楼阁的人造庭园，为了让自己也进入其中才来这里的。”', '——《国境以南 太阳以西》'],
      \ ['至今仍真真切切记得那时的感触，那感触曾怎样使我内心震颤也没有忘记。', '——《国境以南 太阳以西》'],
      \ ['“可你不知道，不知道什么也不创造是多么空虚。”', '——《国境以南 太阳以西》'],
      \ ['“无论什么迟早都要消失。这个店能持续到什么时候也无法晓得。如果人们的嗜好多少改变、经济流势多少改变的话，现在这里的状况一转眼就无影无踪了。这种例子我见了好几个，说没就没。有形的东西迟早都要没影，但是某种情思将永远存留下去。”', '——《国境以南 太阳以西》'],
      \ ['她脸上没有任何堪称表情的表情。脸是对着我，却什么都不想说，只是静静地看着我，仿佛在眺望相距遥远的风景。感觉上真好像自己离她很远很远。她和我之间，或许隔着无法想象的距离。如此一想，我心中不能不泛起某种悲哀。她眼睛里含有让我泛起悲哀的什么。', '——《国境以南 太阳以西》'],
      \ ['我看着岛本的眼睛。那眼睛仿佛是什么风都吹不到的石荫下的一泓深邃的泉水，那儿一切都静止不动，一片岑寂。凝神窥视，勉强可以看出映在水面上的物像。', '——《国境以南 太阳以西》'],
      \ ['眼望如此风景的时间里，我蓦然想道，自己迟早肯定还将在哪里目睹同样的风景。这就是所谓既视感的反向——不是觉得自己以往什么时候见过与此相同的风景，而是预感将来什么时候仍将在哪里与此风景相遇。', '——《国境以南 太阳以西》'],
      \ ['我知道她需要我，而我也需要她。但我设法克制了自己。我必须在此止步。再往前去，很可能再也退不回来。但止步需付出相当大的努力。', '——《国境以南 太阳以西》'],
      \ ['我沿着青山大街驱车前行。假如再也见不到她，脑袋肯定得出故障。她一下车，世界都好像一下子变得空空荡荡了。', '——《国境以南 太阳以西》'],
      \ ['这么想着，心情沉重起来。我在被这世界一点一点拉下水去。这是第一步。这次就认了，但往下没准还有别的什么找到头上。', '——《国境以南 太阳以西》'],
      \ ['“记住，别找无聊女人。和无聊女人风流，自己不久都会无聊。和糊涂女人厮混，自己都要糊涂起来。话虽这么说，可也不要同太好的女人搞在一起。和好女人深入下去，就很难再退出来了，而退不出来，势必迷失方向。我说的你懂吧？”', '——《国境以南 太阳以西》'],
      \ ['“你有看人的眼力。有看人的眼力是非常了不起的才能，要永远珍惜才是。我本身自是一文不值，但并非只生了一文不值的货色。”', '——《国境以南 太阳以西》'],
      \ ['有形的东西倏忽间就了无踪影，有纪子也好，我们所在的房间也好，墙壁也好天花板也好窗扇也好，注意到时都可能不翼而飞。接着，我一下子想起了泉。一如那个男的深深伤害有纪子一样，我大概也深深伤害了泉。有纪子其后遇上了我，而泉大概谁也没遇上。', '——《国境以南 太阳以西》'],
      \ ['我坐在窗边椅子上，怔怔地望那墓地，望了许久。我觉得很多景物都以岛本出现为界而前后大不相同。厨房里传来有纪子准备做晚饭的声响，在我听来竟那般虚无缥缈，仿佛从辽远的世界顺着管道或其他什么传来的。', '——《国境以南 太阳以西》'],
      \ ['明天早晨睁开眼睛，世界肯定变得眉清目秀，一切都比今天令人心旷神怡。然而不可能那样。明天说不定事情更伤脑筋。问题是我在闹恋爱，而又这样有妻、有女儿。', '——《国境以南 太阳以西》'],
      \ ['我觉得自己似乎不在自己体内，我的身体仿佛是从哪里随便借来的临时性容器。明天我将何去何从呢？如果可能，我真想立刻给女儿买一匹马，在一切杳然消失之前，在一切损毁破灭之前。', '——《国境以南 太阳以西》'],
      \ ['微笑仍是以往那种妩媚的微笑，可是我无法从中读出当时她心中的感情涟漪，甚至读不出她对于必须离去是难过还是不怎么难过，抑或是否为同我分别感到释然，就连那时她是否有返回的必要我都无从确认。', '——《国境以南 太阳以西》'],
      \ ['当时两人之间产生的温煦而自然的亲昵已一去不复返，那次奇特的短暂旅行当中发生的事我们从没提起，尽管并无约定。', '——《国境以南 太阳以西》'],
      \ ['岛本心中有只属于她自身的与世隔绝的小天地，那是惟独她知晓、惟独她接受的天地，我无法步入其中。门扇仅仅向我开启了一次，现在已经关闭。', '——《国境以南 太阳以西》'],
      \ ['人这东西一旦开始辩解，就要没完没了辩解下去，我不想活成那个样子。', '——《国境以南 太阳以西》'],
      \ ['在某种意义上，唯其笑得不够释然，才更能打动人的心弦。', '——《国境以南 太阳以西》'],
      \ ['岛本缓缓摇头，像想起什么往昔场景似的在眼角聚起迷人的皱纹。“跟你说，初君，照片上什么也看不出来的，纯粹是影子罢了。真实的我却在另一个地方，没反映在照片上。”她说。', '——《国境以南 太阳以西》'],
      \ ['照片让我一阵心痛。它使我切实感受到了自己以前失去了多少时间——那是永远不可复得的宝贵时光，是任凭多少努力都无法挽回的时光，是只存在于当时当地的时光。我许久许久地凝视着照片。', '——《国境以南 太阳以西》'],
      \ ['她漾出仿佛费解的微笑看着我，就好像我脸上有什么异常。“也真是怪——你想填补那段岁月的空白，我却想多少把它弄成空白。”她说。', '——《国境以南 太阳以西》'],
      \ ['“十二岁时分开天各一方，三十七时如此不期而遇……对我们来说，怕是这样再合适不过。”', '——《国境以南 太阳以西》'],
      \ ['“如今的你也多少开始想往女孩裙子伸手以外的事了吧？”', '——《国境以南 太阳以西》'],
      \ ['这么说着，她喝了一口加入柠檬的巴黎水。这是三月中旬一个暖洋洋的午后，在表参道步行的人群中，已有年轻人换上了半袖衫。', '——《国境以南 太阳以西》'],
      \ ['“即使那时候我同你交往，最后也肯定成为你的累赘，我想。你肯定要腻烦我的，你肯定想飞往更有动感更为广阔的天地，而那样的结果对于我怕是不好受的。”', '——《国境以南 太阳以西》'],
      \ ['“我不是什么了不起的人，没有任何值得自豪的东西，而且比过去比现在还要粗野、自大和麻木不仁。所以，也许很难说我这人适合你。不过有一点可以断言：我决不会腻烦你。这点上我和别人不同。就你而言，我的确是个特殊存在，这我感觉得出。”', '——《国境以南 太阳以西》'],
      \ ['“嗯，初君，”她说，“非常遗憾的是，某种事物是不能后退的。一旦推向前去，就再也后退不得，怎么努力都无济于事。假如当时出了差错——哪怕错一点点——那么也只能将错就错。”', '——《国境以南 太阳以西》'],
      \ ['“还记得吧？我们听的那张唱片，第二乐章最后部分有两次小小的唱针杂音，吱呀吱呀的。”我说，“而没那杂音，我怎么也沉不下心来。”', '——《国境以南 太阳以西》'],
      \ ['空闲下来我便一边听西方古典音乐，一边从客厅窗口呆呆地打量青山墓地。不再像以前那样看书了，埋头看书渐渐变得困难起来。', '——《国境以南 太阳以西》'],
      \ ['已经到了改变装修样式、重新研究经营方针的阶段。大凡开店都有稳定期和求变期，同人一样。若同一环境持续太久，任何东西的活力都要逐步减退。', '——《国境以南 太阳以西》'],
      \ ['紧张的工作使我没工夫想入非非，而每天坚持锻炼又给了我日常性的工作精力。于是我不再虚度光阴，无论做什么都尽可能全力以赴。洗脸时认真洗脸，听音乐时认真听音乐。其实也只有这样我才能好端端地活下去。', '——《国境以南 太阳以西》'],
      \ ['谁也不知晓我真正何所思何所想，如同我不知晓岛本何所思何所想一样。', '——《国境以南 太阳以西》'],
      \ ['虽说我即将进入人们称之为中年的年龄段，但身上全然没有多余脂肪，头发见疏的征兆也未出现，白发一根都没有。由于坚持体育运动的关系，体力上也没觉出怎么衰减。生活有条不紊，注意不暴饮暴食，病患从不沾身，从外表上看也就三十出头。', '——《国境以南 太阳以西》'],
      \ ['然而在岛本不再露面之后，我时不时觉得这里活活成了没有空气的月球表面。', '——《国境以南 太阳以西》'],
      \ ['窗外可以望见黑魆魆的墓地和从窗下的公路疾驰而过的汽车前灯。我手拿酒瓶凝目注视眼前的光景。联结子夜和黎明的时间又黑又长，有时我甚至想道，若能哭上一场该何等畅快。但不知为何而哭，不知为谁而哭。若为别人哭，未免过于自以为是；而若为自己哭，年龄又老大不小了。', '——《国境以南 太阳以西》'],
      \ ['我原本喜欢在街上走着打量各式各样的建筑和店铺，喜欢看人们忙于生计的身姿，喜欢自己的双腿在街上移行的感觉。然而此时此刻环绕我的一切无不显得死气沉沉、虚无缥缈，似乎所有的建筑都摇摇欲坠，所有的街树都黯然失色，所有男女都抛弃了水灵灵的情感和活生生的梦幻。', '——《国境以南 太阳以西》'],
      \ ['九点半岛本来了。不可思议，她每次来时都是静静的雨夜。', '——《国境以南 太阳以西》'],
      \ ['“对不起，总之。本该联系一下才是。但某种东西我是不想触动的，想原封不动保存在那里。我来这里或不来这里——来这里时我在这里，不来这里时……我在别处。”', '——《国境以南 太阳以西》'],
      \ ['我想有纪子此前不知已把这句话在脑袋里重复了多少遍，话语中带有明晰的轮廓和重量，从其回响中我感觉得出。', '——《国境以南 太阳以西》'],
      \ ['估计往后再不可能见到岛本了。她只存在于我的记忆中。她已从我面前消失。她曾经在那里，但现在已杳无踪影。那里是不存在所谓中间的。不存在中间性的东西的地方也不存在中间。国境以南或许有大概存在，而太阳以西则不存在大概。', '——《国境以南 太阳以西》'],
      \ ['然而我现在这样伤害了你，我想我这人大概相当自私自利、不地道、无价值。我无谓地伤害周围的人，同时又因此伤害自身。损毁别人，损毁自己。我不是想这样才这样的，而是不想这样也得这样。', '——《国境以南 太阳以西》'],
      \ ['我目光转向窗外，外面一无所见，惟独联结子夜与天明的无名时空横陈开去。', '——《国境以南 太阳以西》'],
      \ ['黑暗中我想到落于海面的雨——浩瀚无边的大海上无声无息地、不为任何人知晓地降落的雨。雨安安静静地叩击海面，鱼们甚至都浑然不觉。', '——《国境以南 太阳以西》'],
      \]

let g:startify_custom_header = g:ascii + startify#fortune#quote()
