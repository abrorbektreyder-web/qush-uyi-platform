import { useState } from 'react';
import { Save, Shield, Smartphone, Bell, Eye } from 'lucide-react';

export const Settings = () => {
    const [activeTab, setActiveTab] = useState('umumiy');
    const [loading, setLoading] = useState(false);

    const handleSave = () => {
        setLoading(true);
        setTimeout(() => {
            setLoading(false);
            alert('Sozlamalar muvaffaqiyatli saqlandi!');
        }, 1000);
    };

    return (
        <div style={{ animation: 'fadeIn 0.5s ease' }}>
            <header style={{ marginBottom: '32px' }}>
                <h1 style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <Shield color="var(--primary)" /> Platforma Sozlamalari
                </h1>
                <p style={{ color: 'var(--text-muted)' }}>Admin markazi va platforma ishlash sozlamalarini boshqaring.</p>
            </header>

            <div style={{ display: 'flex', gap: '32px' }}>
                {/* TaBlar */}
                <div style={{ width: '250px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    <button
                        className={`btn ${activeTab === 'umumiy' ? 'btn-primary' : 'btn-outline'}`}
                        style={{ justifyContent: 'flex-start' }}
                        onClick={() => setActiveTab('umumiy')}
                    >
                        <Eye size={18} /> Umumiy
                    </button>
                    <button
                        className={`btn ${activeTab === 'xavfsizlik' ? 'btn-primary' : 'btn-outline'}`}
                        style={{ justifyContent: 'flex-start' }}
                        onClick={() => setActiveTab('xavfsizlik')}
                    >
                        <Shield size={18} /> Xavfsizlik va API
                    </button>
                    <button
                        className={`btn ${activeTab === 'xabarnoma' ? 'btn-primary' : 'btn-outline'}`}
                        style={{ justifyContent: 'flex-start' }}
                        onClick={() => setActiveTab('xabarnoma')}
                    >
                        <Bell size={18} /> Bildirishnomalar
                    </button>
                </div>

                {/* Content */}
                <div className="glass-panel" style={{ flex: 1 }}>
                    {activeTab === 'umumiy' && (
                        <div style={{ animation: 'fadeIn 0.3s' }}>
                            <h2 style={{ marginBottom: '24px' }}>Umumiy Ma'lumotlar</h2>

                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Loyiha Nomi</label>
                                <input type="text" defaultValue="Qush Uyi" style={inputStyle} />
                            </div>

                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Asosiy Valyuta</label>
                                <select style={inputStyle}>
                                    <option value="UZS">UZS (So'm)</option>
                                    <option value="USD">USD (Dollar)</option>
                                </select>
                            </div>

                            <div style={{ marginBottom: '24px' }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Texnik Yordam Raqami</label>
                                <input type="text" defaultValue="+998 90 123 45 67" style={inputStyle} />
                            </div>
                        </div>
                    )}

                    {activeTab === 'xavfsizlik' && (
                        <div style={{ animation: 'fadeIn 0.3s' }}>
                            <h2 style={{ marginBottom: '24px' }}>Xizmatlar Integratsiyasi API</h2>

                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Payme API Key</label>
                                <input type="password" defaultValue="************************" style={inputStyle} />
                            </div>

                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Click Secret Key</label>
                                <input type="password" defaultValue="************************" style={inputStyle} />
                            </div>
                        </div>
                    )}

                    {activeTab === 'xabarnoma' && (
                        <div style={{ animation: 'fadeIn 0.3s' }}>
                            <h2 style={{ marginBottom: '24px' }}>Telegram Bildirishnomalari</h2>

                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px', padding: '16px', background: 'rgba(255,255,255,0.05)', borderRadius: '8px' }}>
                                <div>
                                    <h4 style={{ margin: 0 }}>Yangi E'lon Tushganda</h4>
                                    <p style={{ margin: 0, fontSize: '0.8rem', color: 'var(--text-muted)' }}>Adminga xat kelishi.</p>
                                </div>
                                <input type="checkbox" defaultChecked style={{ width: '20px', height: '20px' }} />
                            </div>

                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px', padding: '16px', background: 'rgba(255,255,255,0.05)', borderRadius: '8px' }}>
                                <div>
                                    <h4 style={{ margin: 0 }}>Do'kondan (Shop) Buyurtma Tushganda</h4>
                                    <p style={{ margin: 0, fontSize: '0.8rem', color: 'var(--text-muted)' }}>Adminga xat kelishi.</p>
                                </div>
                                <input type="checkbox" defaultChecked style={{ width: '20px', height: '20px' }} />
                            </div>
                        </div>
                    )}

                    <div style={{ marginTop: '32px', paddingTop: '24px', borderTop: '1px solid var(--border-glass)' }}>
                        <button className="btn btn-primary" onClick={handleSave} disabled={loading}>
                            {loading ? 'Saqlanmoqda...' : <><Save size={18} /> O'zgarishlarni Saqlash</>}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

const inputStyle = {
    width: '100%',
    padding: '12px 16px',
    borderRadius: '8px',
    background: 'rgba(0,0,0,0.2)',
    border: '1px solid var(--border-glass)',
    color: 'white',
    outline: 'none',
    fontSize: '1rem',
};
