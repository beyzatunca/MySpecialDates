# 📸 Görselleri Assets.xcassets'e Ekleme Kılavuzu

## 🎯 Sorun
Celebrate ekranında template görselleri görünmüyor çünkü görseller Assets.xcassets içine Image Set olarak eklenmemiş.

## ✅ Çözüm: Görselleri Assets.xcassets'e Ekleme

### Adım 1: Xcode'da Assets.xcassets'i Açın
1. Xcode'da sol panelde `MySpecialDates` projesini bulun
2. `Assets.xcassets` klasörüne tıklayın

### Adım 2: Yeni Image Set Oluşturun
1. Assets.xcassets içinde boş bir alana sağ tıklayın
2. "New Image Set" seçeneğini seçin
3. Yeni Image Set'in adını template görselinin adıyla değiştirin (örn: `animal-themed`)

### Adım 3: Görselleri Ekleyin
1. Oluşturduğunuz Image Set'e tıklayın
2. Sağ panelde görsel alanları görünecek (1x, 2x, 3x)
3. Görsel dosyalarınızı sürükleyip bırakın:
   - **1x**: Normal çözünürlük (örn: 300x400px)
   - **2x**: Retina çözünürlük (örn: 600x800px) - **Önerilen**
   - **3x**: Retina HD çözünürlük (örn: 900x1200px) - **Opsiyonel**

### Adım 4: Görsel İsimlerini Kontrol Edin
`CardTemplateList.json` dosyasındaki görsel isimleri ile Assets.xcassets'teki Image Set isimlerinin **tam olarak aynı** olması gerekiyor:

- ✅ `animal-themed` → Assets.xcassets'te `animal-themed` Image Set
- ✅ `baloon-themed` → Assets.xcassets'te `baloon-themed` Image Set
- ✅ `bowling-themed` → Assets.xcassets'te `bowling-themed` Image Set
- ✅ `candle-themed` → Assets.xcassets'te `candle-themed` Image Set
- ✅ `hand-drawed-black-themed` → Assets.xcassets'te `hand-drawed-black-themed` Image Set

### Adım 5: Build ve Test
1. Xcode'da `Cmd + B` ile build edin
2. Simülatörde uygulamayı çalıştırın
3. Celebrate ekranında görseller görünmelidir

## 🔍 Hızlı Kontrol

Görsellerin doğru eklendiğini kontrol etmek için:

1. Assets.xcassets klasöründe şu Image Set'lerin olduğundan emin olun:
   - `animal-themed`
   - `baloon-themed`
   - `bowling-themed`
   - `candle-themed`
   - `hand-drawed-black-themed`

2. Her Image Set'in içinde en azından 2x görsel olduğundan emin olun

## ⚠️ Önemli Notlar

- Görsel isimleri **büyük/küçük harf duyarlıdır**
- Tire (`-`) ve alt çizgi (`_`) farklıdır
- Görseller PNG veya JPEG formatında olabilir
- En azından 2x çözünürlükte görsel eklemeniz önerilir

## 🚀 Otomatik Yükleme

Kod tarafında görseller otomatik olarak yüklenir:
- `ImageAssetHelper` sınıfı farklı yöntemlerle görsel yüklemeyi dener
- Görsel bulunamazsa placeholder gösterilir
- Console'da görsel yükleme durumu loglanır

## 📝 Yeni Template Ekleme

Yeni bir template eklemek için:

1. Görseli Assets.xcassets'e Image Set olarak ekleyin
2. `CardTemplateList.json` dosyasına yeni template ekleyin
3. `previewImageName` ve `backgroundImageName` alanlarını Image Set adıyla eşleştirin
4. Uygulamayı yeniden build edin

Görseller otomatik olarak Celebrate ekranında görünecektir!


