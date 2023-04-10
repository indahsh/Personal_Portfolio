#Import Data
data1 <- read.csv("C:/Users/Indah/Downloads/data susenas.csv", sep = ";", 
                 header = TRUE)
head(data1)
data <- data1[-1]

#Statistika Deskriptif
statistika.deskriptif <- summary(data)
statistika.deskriptif

#Pengujian Asumsi
## Uji Sampel Representatif
library(psych)
KMO <- KMO(data)
KMO
## Uji Nonmultikolinearitas
korelasi <- cor(data)
korelasi

#Standardisasi Data
standardisasi.data <- scale(data, center = TRUE, scale = TRUE)

#Metode Terbaik
## Korelasi Cophenetic
matriks.jarak1 <- dist(data)

# 1. Single Linkage
cluster.hierarki.single <- hclust(matriks.jarak1, method = "single")
jarak.single <- cophenetic(cluster.hierarki.single)
korelasi.single <- cor(matriks.jarak1,jarak.single)

# 2. Average Linkage
cluster.hierarki.average <- hclust(matriks.jarak1, method = "ave")
jarak.average <- cophenetic(cluster.hierarki.average)
korelasi.average <- cor(matriks.jarak1,jarak.average)

# 3. Complete Linkage
cluster.hierarki.complete <- hclust(matriks.jarak1, method = "complete")
jarak.complete <- cophenetic(cluster.hierarki.complete)
korelasi.complete <- cor(matriks.jarak1,jarak.complete)

# 4. Centroid Linkage
cluster.hierarki.centroid <- hclust(matriks.jarak1, method = "centroid")
jarak.centroid <- cophenetic(cluster.hierarki.centroid)
korelasi.centroid <- cor(matriks.jarak1,jarak.centroid)

# 5. Ward
cluster.hierarki.ward <- hclust(matriks.jarak1, method = "ward.D")
jarak.ward <- cophenetic(cluster.hierarki.ward)
korelasi.ward <- cor(matriks.jarak1,jarak.ward)

### Metode Terbaik
korelasi.cophenetic <- data.frame(korelasi.single, korelasi.average, 
                                  korelasi.complete, korelasi.centroid,
                                  korelasi.ward)
korelasi.cophenetic

#Cluster Optimal
library(clValid)
validasi <- clValid(obj = data.frame(standardisasi.data), nClust = 2:5, 
                   clMethods = "hierarchical", validation = "internal", 
                   method = "average", maxitems = length(standardisasi.data),
                   verbose = TRUE)
optimalScores(validasi)
par(mfrow=c(1,3))
plot(validasi)

#Analisis Cluster Hierarki
## Matriks Jarak
matriks.jarak <- dist(standardisasi.data, method = "euclidean", 
                      diag = FALSE)
matriks.jarak
## Cluster Dendrogram
cluster.hierarki <- hclust(matriks.jarak, method = "average")
plot(cluster.hierarki)
rect.hclust(cluster.hierarki, k = 2, border = 2:5)
## Cluster Membership
cluster <- cutree(cluster.hierarki, k = 2)
cbind(data1[1], cluster)

#Perbandingan Cluster
aggregate(data, list(cutree(cluster.hierarki, k = 2)), mean)
