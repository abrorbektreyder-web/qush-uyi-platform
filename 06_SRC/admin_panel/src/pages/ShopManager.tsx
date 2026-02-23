import { useState } from 'react';
import { PackageSearch, PlusCircle, Edit, Trash2 } from 'lucide-react';

export const ShopManager = () => {
    const [items] = useState([
        { id: '1', name: 'Premium Don (Yem)', price: 45000, stock: 100, category: 'Ozuqa' },
        { id: '2', name: 'Vitaminki (Dori)', price: 25000, stock: 45, category: 'Tibbiyot' },
        { id: '3', name: 'Katta Qafas (Golden)', price: 350000, stock: 8, category: 'Inventar' },
    ]);

    return (
        <div style={{ animation: 'fadeIn 0.5s ease' }}>
            <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
                <div>
                    <h1 style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <PackageSearch color="var(--primary)" /> Do'kon (Official Shop)
                    </h1>
                    <p style={{ color: 'var(--text-muted)' }}>Mijozlarga rasmiy ozuqa va anjomlar sotish uchun ombor.</p>
                </div>
                <button className="btn btn-primary">
                    <PlusCircle size={20} /> Yangi Maxsulot
                </button>
            </header>

            <div className="glass-panel">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>Nom / Tavsif</th>
                            <th>Turkum</th>
                            <th>Narx (UZS)</th>
                            <th>Ombordagi Qoldiq</th>
                            <th>Boshqaruv</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items.map((item) => (
                            <tr key={item.id}>
                                <td style={{ fontWeight: 600 }}>{item.name}</td>
                                <td><span className="status-badge" style={{ background: 'rgba(255,255,255,0.05)', color: 'var(--text-muted)' }}>{item.category}</span></td>
                                <td style={{ color: 'var(--primary)', fontWeight: 'bold' }}>{item.price.toLocaleString()}</td>
                                <td>
                                    <span style={{ color: item.stock < 10 ? 'var(--danger)' : '#FFF' }}>{item.stock} dona</span>
                                </td>
                                <td>
                                    <div style={{ display: 'flex', gap: '8px' }}>
                                        <button className="btn btn-outline" style={{ padding: '6px' }} title="Tahrirlash">
                                            <Edit size={16} />
                                        </button>
                                        <button className="btn btn-danger" style={{ padding: '6px' }} title="O'chirish">
                                            <Trash2 size={16} />
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};
