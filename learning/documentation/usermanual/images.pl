# LaTeX2HTML 2002-2-1 (1.70)
# Associate images original text with physical files.


$key = q/includegraphics{fig_example};LFS=11;AAT/;
$cached_env_img{$key} = q|<IMG
 WIDTH="425" HEIGHT="198" ALIGN="BOTTOM" BORDER="0"
 SRC="|."$dir".q|img1.gif"
 ALT="\includegraphics{fig_example}">|; 

$key = q/left.yright>;MSF=1.4;LFS=11;AAT/;
$cached_env_img{$key} = q|<IMG
 WIDTH="20" HEIGHT="30" ALIGN="MIDDLE" BORDER="0"
 SRC="|."$dir".q|img3.gif"
 ALT="$\left.y\right&gt;$">|; 

$key = q/left<right.;MSF=1.4;LFS=11;AAT/;
$cached_env_img{$key} = q|<IMG
 WIDTH="11" HEIGHT="30" ALIGN="MIDDLE" BORDER="0"
 SRC="|."$dir".q|img2.gif"
 ALT="$\left&lt;\right.$">|; 

1;

