library(keras)
library(tensorflow)
library(tidyverse)
library(quantmod)
library(plotly)
library(Metrics)
getSymbols("GOOG")
head(GOOG)
data<-read.csv("GOOG.csv")
chartSeries(GOOG)
myts<- data[c(1:3800),c(2,3,4,5,7)]
plot.ts(myts$Close)
msd.open = c(mean(myts$Open), sd(myts$Open))
msd.low = c(mean(myts$Low), sd(myts$Low))
msd.close = c(mean(myts$Close), sd(myts$Close))
msd.high = c(mean(myts$High), sd(myts$High))
msd.vol = c(mean(myts$Volume), sd(myts$Volume))

myts$Close = (myts$Close - msd.close[1])/msd.close[2]
myts$Volume = (myts$Volume - msd.vol[1])/msd.vol[2]
myts$High = (myts$High-msd.high[1])/msd.high[2]
myts$Open=(myts$Open-msd.open[1])/msd.open[2]
myts$Low=(myts$Low-msd.low[1])/msd.low[2]
datalags = 10
train = myts[seq(2700 + datalags), ]
test = myts[2700 + datalags + seq(1100 + datalags), ]
batch.size = 50

x.train = array(data = lag(cbind(train$Close, train$Volume,train$High,train$Open,train$Low), datalags)[-(1:datalags), ], dim = c(nrow(train) - datalags,
                                                                                                                                 datalags, 5))
y.train = array(data = train$Close[-(1:datalags)], dim = c(nrow(train)-datalags, 1))


x.test = array(data = lag(cbind(test$Volume, test$Close, test$High,test$Open,test$Low),datalags)[-(1:datalags), ], dim = c(nrow(test) - datalags, datalags, 5))

y.test = array(data = test$Close[-(1:datalags)], dim = c(nrow(test) - datalags, 1))
model <- keras_model_sequential()

model %>%
  layer_lstm(units = 100,
             input_shape = c(datalags, 5),
             batch_size = batch.size,
             return_sequences = TRUE) %>%
  layer_dropout(rate = 0.5) %>%
  layer_lstm(units = 50,
             return_sequences = FALSE) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 1)

model %>%
  compile(loss = 'mae', optimizer = 'adam', validation_split="0.1")

model
{
 history<- model %>% fit(x = x.train,
                y = y.train,
                batch_size = batch.size,
                repeats = 10,
                epochs = 40,
                verbose = 1,
                validation_split = 0.1,
                shuffle = FALSE)
}
pred_out <- model %>% predict(x.test, batch_size = batch.size) %>% .[,1]

myts$index <- 1:nrow(myts) 

tsactual<-data[c(2701:3790),c(5)]

plot_ly(myts, x = ~index, y = ~Close, type = "scatter", mode = "markers", color = ~Volume) %>%
  add_trace(y = c(rep(NA, 2700), pred_out), x = myts$index, name = "LSTM prediction", mode = "lines")
plot(history)

yhat<- pred_out[c(0:1090)]*msd.close[2]+msd.close[1]
Testerror<-rmse(tsactual,yhat)
Testerror
