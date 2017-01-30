function p = multivariateGaussian(X, mu, var)
%MULTIVARIATEGAUSSIAN Computes the probability density function of the
%multivariate gaussian distribution.
%    p = MULTIVARIATEGAUSSIAN(X, mu, Sigma2) Computes the probability 
%    density function of the examples X under the multivariate gaussian 
%    distribution with parameters mu and Sigma2. If Sigma2 is a matrix, it is
%    treated as the covariance matrix. If Sigma2 is a vector, it is treated
%    as the \sigma^2 values of the variances in each dimension (a diagonal
%    covariance matrix)
%

k = length(mu);

if (size(var, 2) == 1) || (size(var, 1) == 1)
    var = diag(var);
end

X = bsxfun(@minus, X, mu(:)');
p = (2 * pi) ^ (- k / 2) * det(var) ^ (-0.5) * ...
    exp(-0.5 * sum(bsxfun(@times, X * pinv(var), X), 2));

end