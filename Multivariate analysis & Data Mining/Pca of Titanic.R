plot(subset(titanic.full[c(3,5,6,7,8,10,12)]),col=ifelse (titanic.full$Survived==0, "red", "blue"))

titanic.pca<-prcomp(subset(titanic.full[c(6,10)]),center = TRUE, scale = TRUE)

print(titanic.pca)
plot(titanic.pca$x[,1:2],col=ifelse(titanic.full$Survived==1,"blue","red"))


