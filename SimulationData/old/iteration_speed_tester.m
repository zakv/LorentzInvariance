size=1000;

f=@(x)x+1;
tempIn=zeros(size);
tempOut=zeros(size);

disp('Slow Iteration')
tic
for j=1:numel(tempIn)
    tempOut(j)=f(tempIn(j));
end
toc

disp('Possibly faster Iteration')
tic
tempOut=arrayfun(f,tempIn);
toc