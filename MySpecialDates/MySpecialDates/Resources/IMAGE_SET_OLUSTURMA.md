# 🖼️ Görselleri Image Set Olarak Yapılandırma

## ⚠️ Sorun
Görseller Assets.xcassets içine `.jpg` dosyaları olarak eklenmiş, ancak Xcode bunları **Image Set** olarak yapılandırmadığı için bundle'a dahil edilmiyor ve uygulamada görünmüyor.

## ✅ Çözüm: Image Set Oluşturma

### Adım 1: Mevcut .jpg Dosyalarını Silin (Opsiyonel)
1. Xcode'da Assets.xcassets içindeki `.jpg` dosyalarını seçin
2. Sağ tıklayıp "Delete" seçin (sadece referansı silin, dosyayı silmeyin)

### Adım 2: Yeni Image Set Oluşturun
Her görsel için:

1. **Assets.xcassets** içinde boş bir alana sağ tıklayın
2. **"New Image Set"** seçeneğini seçin
3. Yeni Image Set'in adını template adıyla değiştirin:
   - `animal-themed` (tire ile, tam olarak bu şekilde)
   - `baloon-themed`
   - `bowling-themed`
   - `candle-themed`
   - `hand-drawed-black-themed`

### Adım 3: Görselleri Image Set'e Ekleyin
1. Oluşturduğunuz Image Set'e tıklayın
2. Sağ panelde görsel alanları görünecek:
   - **Universal** (veya **1x, 2x, 3x**)
3. Görsel dosyanızı sürükleyip bırakın:
   - **2x** alanına görseli ekleyin (en önemlisi)
   - **3x** alanına da aynı görseli ekleyebilirsiniz (opsiyonel)

### Adım 4: Kontrol Edin
Her Image Set'in:
- ✅ Doğru isimde olduğundan emin olun (tire ile: `animal-themed`)
- ✅ İçinde görsel olduğundan emin olun
- ✅ `CardTemplateList.json`'daki isimle tam olarak eşleştiğinden emin olun

### Adım 5: Build ve Test
1. Xcode'da **Cmd + B** ile build edin
2. Simülatörde uygulamayı çalıştırın
3. Celebrate ekranında görseller görünmelidir

## 📋 Hızlı Kontrol Listesi

- [ ] `animal-themed` Image Set oluşturuldu
- [ ] `baloon-themed` Image Set oluşturuldu
- [ ] `bowling-themed` Image Set oluşturuldu
- [ ] `candle-themed` Image Set oluşturuldu
- [ ] `hand-drawed-black-themed` Image Set oluşturuldu
- [ ] Her Image Set'in içinde görsel var
- [ ] Image Set isimleri `CardTemplateList.json` ile eşleşiyor
- [ ] Build başarılı
- [ ] Simülatörde görseller görünüyor

## 🔍 Görsel Yükleme Mantığı

Kod şu sırayla görsel yüklemeyi dener:
1. **Image Set** olarak Assets.xcassets'ten (`UIImage(named:)`)
2. Bundle'dan direkt dosya olarak
3. Farklı isim varyasyonları

**Önemli:** Görsellerin çalışması için **mutlaka Image Set** olarak yapılandırılması gerekiyor!


