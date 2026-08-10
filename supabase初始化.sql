-- ============================================================
-- CAYEE 参数筛选器 - Supabase 数据库初始化脚本
-- 使用方法：登录 Supabase → 左侧 SQL Editor → 新建查询 → 粘贴全部 → Run
-- ============================================================

-- 1. 创建分类配置表
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INT DEFAULT 0,
  config JSONB NOT NULL DEFAULT '{}'
);

-- 2. 创建产品表
CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  category TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  model TEXT NOT NULL,
  manufacturer TEXT DEFAULT '',
  spec_data JSONB DEFAULT '{}',
  price TEXT DEFAULT '',
  datasheet_url TEXT DEFAULT '',
  image_url TEXT DEFAULT '',
  remark TEXT DEFAULT '',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.1 兼容已创建的旧表：增加图片和备注字段
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT '';
ALTER TABLE products ADD COLUMN IF NOT EXISTS remark TEXT DEFAULT '';

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_model ON products(model);

-- 3. 启用行级安全(RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 4. RLS策略：允许公开读取
CREATE POLICY "Public read categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Public read products" ON products FOR SELECT USING (true);

-- 5. RLS策略：允许公开写入（后台管理页面需要）
CREATE POLICY "Public write categories" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write products" ON products FOR ALL USING (true) WITH CHECK (true);

-- 6. 插入3个分类配置
INSERT INTO categories (id, name, sort_order, config) VALUES
('mlcc', 'MLCC电容', 1, '{"filters":[{"key":"kind","name":"种类","options":["Class I","Class II","汽车级","高压","软端子"]},{"key":"package","name":"封装/体积","options":["0201","0402","0603","0805","1206","1210","1812","2220"]},{"key":"capacitance","name":"容值","options":["1pF","10pF","100pF","1nF","10nF","100nF","1μF","10μF","100μF"]},{"key":"tolerance","name":"精度","options":["±0.1pF","±0.25pF","±0.5pF","±1%","±2%","±5%","±10%","±20%"]},{"key":"rated_voltage","name":"额定电压","options":["6.3V","10V","16V","25V","50V","100V","250V","500V","1kV"]},{"key":"temp_coefficient","name":"温度系数","options":["C0G(NP0)","X7R","X5R","Y5V","X8R","U2J"]},{"key":"manufacturer","name":"制造商","options":["CAYEE","Murata","TDK","Samsung","Yageo","Taiyo Yuden"]},{"key":"model","name":"型号","options":["CC0603KRX7R9BB104","CC0805KKX5R8BB106","CC1206KKX7RDBB102"]}]}'),
('smd_al_electrolytic', '贴片型铝电解电容', 2, '{"filters":[{"key":"kind","name":"种类","options":["普通贴片铝电解","低阻抗","宽温","长寿命","高纹波"]},{"key":"body_diameter","name":"电容体直径","options":["4mm","5mm","6.3mm","8mm","10mm","12.5mm"]},{"key":"body_length","name":"电容体长度","options":["5.4mm","5.8mm","7.7mm","10mm","13.5mm","16mm"]},{"key":"capacitance","name":"容值","options":["1μF","2.2μF","4.7μF","10μF","22μF","47μF","100μF","220μF","470μF"]},{"key":"tolerance","name":"精度","options":["±10%","±20%","±30%"]},{"key":"rated_voltage","name":"额定电压","options":["6.3V","10V","16V","25V","35V","50V","63V","100V"]},{"key":"ripple_current","name":"纹波电流","options":["10mA","50mA","100mA","200mA","500mA","1A"]},{"key":"esr","name":"等效串联电阻(ESR)","options":["≤0.1Ω","≤0.5Ω","≤1Ω","≤2Ω","≤5Ω"]},{"key":"operating_life","name":"工作寿命","options":["1000h","2000h","5000h","10000h","15000h"]},{"key":"operating_temp","name":"工作温度","options":["-40℃~85℃","-40℃~105℃","-55℃~105℃","-40℃~125℃","-55℃~150℃"]}]}'),
('pptc', '自恢复保险丝', 3, '{"filters":[{"key":"kind","name":"种类","options":["贴片型","插件型","径向引线"]},{"key":"series","name":"Series","options":["SMD0603","SMD0805","SMD1206","SMD1210","SMD1812","SMD2920"]},{"key":"ihold","name":"Ihold(A)","options":["0.05","0.1","0.2","0.5","1.0","1.5","2.0","3.0"]},{"key":"itrip","name":"Itrip(A)","options":["0.1","0.2","0.4","1.0","2.0","3.0","4.0","6.0"]},{"key":"vmax","name":"Vmax(VDC)","options":["6V","8V","12V","16V","24V","30V","60V"]},{"key":"trip_current","name":"Max Time to Trip Current(A)","options":["0.5","1.0","2.0","5.0","10.0","20.0"]},{"key":"trip_time","name":"Max Time to Trip Tmax(S)","options":["0.1","0.5","1.0","2.0","5.0","10.0"]},{"key":"imax","name":"Imax(A)","options":["10","20","40","60","100"]},{"key":"pd_typ","name":"Pd typ(W)","options":["0.2","0.5","1.0","1.5","2.0"]},{"key":"rimin","name":"Rimin(Ω)","options":["0.01","0.05","0.1","0.2","0.5","1.0"]},{"key":"r1max","name":"R1max(Ω)","options":["0.1","0.5","1.0","2.0","5.0","10.0"]},{"key":"package","name":"Package","options":["0603","0805","1206","1210","1812","2920","DIP"]}]}')
ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, config=EXCLUDED.config, sort_order=EXCLUDED.sort_order;

-- 7. 插入示例产品数据

-- MLCC电容
INSERT INTO products (category, model, manufacturer, spec_data, price, datasheet_url, image_url, remark, sort_order) VALUES
('mlcc', 'CC0603KRX7R9BB104', 'CAYEE', '{"kind":"Class II","package":"0603","capacitance":"100nF","tolerance":"±10%","rated_voltage":"50V","temp_coefficient":"X7R"}', '0.015', '', '', '常用陶瓷电容', 1),
('mlcc', 'CC0805KKX5R8BB106', 'CAYEE', '{"kind":"Class II","package":"0805","capacitance":"10μF","tolerance":"±10%","rated_voltage":"25V","temp_coefficient":"X5R"}', '0.028', '', '', '大容量去耦', 2),
('mlcc', 'CC1206KKX7RDBB102', 'CAYEE', '{"kind":"Class II","package":"1206","capacitance":"1nF","tolerance":"±10%","rated_voltage":"1kV","temp_coefficient":"X7R"}', '0.035', '', '', '高压场景', 3),
('mlcc', 'CC0603JRNPO9BN100', 'CAYEE', '{"kind":"Class I","package":"0603","capacitance":"10pF","tolerance":"±5%","rated_voltage":"50V","temp_coefficient":"C0G(NP0)"}', '0.012', '', '', '高频稳定', 4),
('mlcc', 'CC1812KKX7RDBB474', 'CAYEE', '{"kind":"高压","package":"1812","capacitance":"470nF","tolerance":"±10%","rated_voltage":"500V","temp_coefficient":"X7R"}', '0.085', '', '', '高压大封装', 5);

-- 贴片型铝电解电容
INSERT INTO products (category, model, manufacturer, spec_data, price, datasheet_url, image_url, remark, sort_order) VALUES
('smd_al_electrolytic', 'CAY-VEJ100M1VTR-0605', 'CAYEE', '{"kind":"普通贴片铝电解","body_diameter":"6.3mm","body_length":"5.8mm","capacitance":"100μF","tolerance":"±20%","rated_voltage":"35V","ripple_current":"200mA","esr":"≤1Ω","operating_life":"2000h","operating_temp":"-40℃~105℃"}', '0.120', '', '', '常规贴片铝电解', 1),
('smd_al_electrolytic', 'CAY-VEJ220M1ETR-0807', 'CAYEE', '{"kind":"低阻抗","body_diameter":"8mm","body_length":"7.7mm","capacitance":"220μF","tolerance":"±20%","rated_voltage":"25V","ripple_current":"500mA","esr":"≤0.5Ω","operating_life":"5000h","operating_temp":"-55℃~105℃"}', '0.180', '', '', '低ESR', 2),
('smd_al_electrolytic', 'CAY-VEJ470M1CTR-1010', 'CAYEE', '{"kind":"高纹波","body_diameter":"10mm","body_length":"10mm","capacitance":"470μF","tolerance":"±20%","rated_voltage":"16V","ripple_current":"1A","esr":"≤0.2Ω","operating_life":"10000h","operating_temp":"-40℃~125℃"}', '0.320', '', '', '高纹波长寿命', 3);

-- 自恢复保险丝
INSERT INTO products (category, model, manufacturer, spec_data, price, datasheet_url, image_url, remark, sort_order) VALUES
('pptc', 'CAY-MSMD050-1206', 'CAYEE', '{"kind":"贴片型","series":"SMD1206","ihold":"0.5","itrip":"1.0","vmax":"6V","trip_current":"8.0","trip_time":"0.3","imax":"100","pd_typ":"0.6","rimin":"0.15","r1max":"0.8","package":"1206"}', '0.045', '', '', '1206贴片保险丝', 1),
('pptc', 'CAY-MSMD110-1206', 'CAYEE', '{"kind":"贴片型","series":"SMD1206","ihold":"1.1","itrip":"2.2","vmax":"6V","trip_current":"8.0","trip_time":"0.5","imax":"100","pd_typ":"0.8","rimin":"0.08","r1max":"0.5","package":"1206"}', '0.055', '', '', '1.1A保持电流', 2),
('pptc', 'CAY-MSMD200-1812', 'CAYEE', '{"kind":"贴片型","series":"SMD1812","ihold":"2.0","itrip":"4.0","vmax":"8V","trip_current":"8.0","trip_time":"1.0","imax":"100","pd_typ":"1.0","rimin":"0.04","r1max":"0.2","package":"1812"}', '0.085', '', '', '1812大电流', 3),
('pptc', 'CAY-RXEF050-72R', 'CAYEE', '{"kind":"径向引线","series":"RXEF","ihold":"0.5","itrip":"1.0","vmax":"72V","trip_current":"8.0","trip_time":"2.0","imax":"40","pd_typ":"0.7","rimin":"0.2","r1max":"1.0","package":"DIP"}', '0.120', '', '', '径向引线插件', 4);

-- 完成
SELECT 'CAYEE 数据库初始化完成！共插入 3 个分类，12 条产品数据。' AS result;
