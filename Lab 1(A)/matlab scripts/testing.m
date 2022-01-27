h = animatedline;
axis([0,2*pi,-90,90])

x = linspace(0,2*pi,1000);
y = sin(x) * 90;
z = (1/0.088) * sin(x) * 90;

for k = 1:length(z)
    addpoints(h,x(k),y(k));
    drawnow
end