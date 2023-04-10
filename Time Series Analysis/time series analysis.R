#Import Data
data <- read.csv("C:/Users/Indah/Documents/data jumlah wisatawan.csv", 
                 sep = ";", header = TRUE)
head(data)

#Eksplorasi Data
plot.ts(data$Jumlah.Wisatawan, 
        main = "Plot Deret Waktu Jumlah Kunjungan Wisatawan Mancanegara 
        ke Indonesia Menurut Pintu Masuk Batam",
        xlab = "Bulan", ylab = "Jumlah Wisatawan")

#Uji Stasioneritas
## Uji Stasioneritas Ragam
library(forecast)
lambda <- BoxCox.lambda(data)
lambda
## Uji Stasioneritas Rata-Rata
deret <- ts(data$Jumlah.Wisatawan, start = 2017, frequency = 12)
library(tseries)
adf.test(deret)

#Penanganan Data Tidak Stasioner
## Differencing 1
differencing.1_deret <- diff(deret, differences = 1)
differencing.1 <- ts(differencing.1_deret)
plot.ts(differencing.1,
        main = "Plot Deret Waktu Jumlah Kunjungan Wisatawan Mancanegara 
        ke Indonesia Menurut Pintu Masuk Batam",
        xlab = "Bulan", ylab = "Jumlah Wisatawan")
adf.test(differencing.1)
## Differencing 2
differencing.2_deret <- diff(deret, differences = 2)
differencing.2 <- ts(differencing.2_deret)
plot.ts(differencing.2,
        main = "Plot Deret Waktu Jumlah Kunjungan Wisatawan Mancanegara 
        ke Indonesia Menurut Pintu Masuk Batam",
        xlab = "Bulan", ylab = "Jumlah Wisatawan")
adf.test(differencing.2)

#Identifikasi Model
acf(differencing.2,
    main = "Plot ACF Jumlah Kunjungan Wisatawan Mancanegara 
    ke Indonesia Menurut Pintu Masuk Batam")
pacf(differencing.2,
     main = "Plot PACF Jumlah Kunjungan Wisatawan Mancanegara 
     ke Indonesia Menurut Pintu Masuk Batam")

#Pendugaan Parameter
model <- arima(differencing.2, order = c(3,2,1), method = "ML")
library(lmtest)
coeftest(model)

#Uji Diagnostik
## Residual Plot
plot(scale(model$residuals), type = "o", xlab = "Waktu", 
     ylab = "Standardize Residuals", main = "Standardize Residual From Model")
## Normalitas Sisaan
sisaan <- model$residuals
shapiro.test(sisaan)
## Autokorelasi Residual
Box.test(sisaan, type = "Ljung")

#Overfitting Model
## ARIMA (4,2,1)
ARIMA421 <- arima(differencing.2, order = c(4,2,1), method = "ML")
coeftest(ARIMA421)
## ARIMA (3,2,2)
ARIMA322 <- arima(differencing.2, order = c(3,2,2), method = "ML")
coeftest(ARIMA322)

#Model Terbaik
Model.ARIMA <- c("ARIMA (3,2,1)", "ARIMA (3,2,2)")
Nilai.AIC <- c(model$aic, ARIMA322$aic)
perbandingan <- data.frame(Model.ARIMA,Nilai.AIC)
perbandingan

#Peramalan
model_forecast <- arima(differencing.2, order = c(3,2,2))
ramalan_model <- forecast(model_forecast, h = 12)
ramalan_model
plot(ramalan_model)
