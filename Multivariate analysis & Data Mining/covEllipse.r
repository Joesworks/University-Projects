#######################################################################

## Calculates the polar coordinate r(theta) for a covariance ellipse
## defined by the covariance matrix S
rEllipse <- function(theta, S) {
    s1Sqr <- S[1,1]
    s2Sqr <- S[2,2]
    s12 <- S[1,2]

    num <- s1Sqr*s2Sqr-s12^2
    den <- s2Sqr*cos(theta)^2 + s1Sqr*sin(theta)^2 - 2*s12*sin(theta)*cos(theta)

    return((sqrt(num/den)))
}

polarEllipse <- function(theta, S, scale=1) {
    r <- rEllipse(theta, S)
    return(scale*r*data.frame(x=cos(theta), y=sin(theta)))
}

calculateCovEllipse <- function(S, scale=1) {
    return(
        polarEllipse(seq(0,2*pi,by=0.01),
                     S,scale)
        )
}
