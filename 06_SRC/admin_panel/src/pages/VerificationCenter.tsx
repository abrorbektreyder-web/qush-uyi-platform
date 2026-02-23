import React, { useState } from 'react';
import { Check, X, ShieldAlert } from 'lucide-react';

export const VerificationCenter: React.FC = () => {
    const [data, setData] = useState([
        { id: 'BQ-901', seller: 'Akrom J.', bird: 'Tustovuq Zoti', file: 'Pasport.pdf', status: 'pending' },
        { id: 'BQ-902', seller: 'Salim Ota', bird: 'Oq Uy Kabutari', file: 'Video_tekshiruv.mp4', status: 'pending' },
        { id: 'BQ-903', seller: 'VET.UZ', bird: 'Litsenziya Tasdiqlash', file: 'Lic-1002.pdf', status: 'pending' },
    ]);

    const [previewFile, setPreviewFile] = useState<{ id: string, name: string } | null>(null);

    const handleAction = (id: string, action: 'approve' | 'reject') => {
        setData((prev) => prev.map((item) => item.id === id ? { ...item, status: action === 'approve' ? 'success' : 'danger' } : item));
    };

    return (
        <div style={{ animation: 'fadeIn 0.5s ease' }}>
            <header style={{ marginBottom: '32px' }}>
                <h1 style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <ShieldAlert color="var(--primary)" /> Verifikatsiya Markazi
                </h1>
                <p style={{ color: 'var(--text-muted)' }}>Qush pasporti va diagnostik videolarni tekshirib (✅) belgi bering.</p>
            </header>

            <div className="glass-panel">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>Ariza ID</th>
                            <th>Sotuvchi/Vet</th>
                            <th>Obyekt</th>
                            <th>Hujjat</th>
                            <th>Status / Aksiya</th>
                        </tr>
                    </thead>
                    <tbody>
                        {data.map((item) => (
                            <tr key={item.id}>
                                <td style={{ fontWeight: 'bold' }}>{item.id}</td>
                                <td>{item.seller}</td>
                                <td>{item.bird}</td>
                                <td
                                    style={{ color: 'var(--primary)', cursor: 'pointer', textDecoration: 'underline' }}
                                    onClick={() => setPreviewFile({ id: item.id, name: item.file })}
                                >
                                    {item.file}
                                </td>
                                <td>
                                    {item.status === 'pending' ? (
                                        <div style={{ display: 'flex', gap: '8px' }}>
                                            <button className="btn btn-outline" style={{ padding: '6px 12px' }} onClick={() => handleAction(item.id, 'approve')}>
                                                <Check size={16} /> Tasdiqlash
                                            </button>
                                            <button className="btn btn-danger" style={{ padding: '6px 12px' }} onClick={() => handleAction(item.id, 'reject')}>
                                                <X size={16} /> Rad yetish
                                            </button>
                                        </div>
                                    ) : item.status === 'success' ? (
                                        <span className="status-badge success">TASDIQLANGAN</span>
                                    ) : (
                                        <span className="status-badge" style={{ background: 'rgba(255, 73, 73, 0.1)', color: 'var(--danger)' }}>RAD ETILDI</span>
                                    )}
                                </td>
                            </tr>
                        ))}
                        {data.length === 0 && (
                            <tr>
                                <td colSpan={5} style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '32px' }}>Hozircha arizalar yo'q.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {/* File Preview Modal */}
            {previewFile && (
                <div className="modal-overlay">
                    <div className="modal-content">
                        <button className="modal-close" onClick={() => setPreviewFile(null)}><X size={24} /></button>
                        <h2 style={{ marginBottom: '16px' }}>Hujjatni ko'rish</h2>
                        <div style={{ background: '#000', borderRadius: '8px', padding: '32px', textAlign: 'center', marginBottom: '16px' }}>
                            <ShieldAlert size={60} color="var(--primary)" style={{ marginBottom: '16px', display: 'inline-block' }} />
                            <p style={{ color: 'var(--text-muted)' }}>{previewFile.name}</p>
                            <h3 style={{ marginTop: '8px' }}>[Preview Mode: {previewFile.name.split('.').pop()?.toUpperCase()}]</h3>
                            <p style={{ marginTop: '16px', fontSize: '0.8rem', color: 'gray' }}>Ushbu fayl backend server orqali renderlanishi mumkin. Hozirgi holatda Admin faqat mock oynani o'qimoqda.</p>
                        </div>

                        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                            <button className="btn btn-primary" onClick={() => {
                                handleAction(previewFile.id, 'approve');
                                setPreviewFile(null);
                            }}>Tasdiqlash</button>
                            <button className="btn btn-danger" onClick={() => {
                                handleAction(previewFile.id, 'reject');
                                setPreviewFile(null);
                            }}>Rad Yetish</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
