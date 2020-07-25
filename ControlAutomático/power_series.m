function c = power_series(b,a,n)

%F(z) = (b0+b1*z^-1+b2*z^-2+...)/(a0+a1*z^-1+a2*z^-2+...)

if n>length(a)
    av = [a zeros(1,n-length(a))];
    bv = [b zeros(1,n-length(b))];
elseif n<=length(a) && n>length(b)
    av = a(1:n);
    bv = [b zeros(1,n-length(b))];
else
    av = a(1:n);
    bv = b(1:n);
end

A = zeros(n);

for i = 1:n
    A = A + diag(av(i)*ones(1,n-i+1),-(i-1));
end

c = (A^-1*bv')';
