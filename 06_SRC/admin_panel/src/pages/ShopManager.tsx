import { useState } from 'react';
import { PackageSearch, PlusCircle, Edit, Trash2, X, AlertCircle } from 'lucide-react';

export const ShopManager = () => {
    const [items, setItems] = useState([
        { id: '1', name: 'Premium Don (Yem)', price: 45000, stock: 100, category: 'Ozuqa' },
        { id: '2', name: 'Vitaminki (Dori)', price: 25000, stock: 45, category: 'Tibbiyot' },
        { id: '3', name: 'Katta Qafas (Golden)', price: 350000, stock: 8, category: 'Inventar' },
    ]);

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [modalMode, setModalMode] = useState<'create' | 'edit'>('create');
    const [currentItem, setCurrentItem] = useState<{ id: string, name: string, price: number, stock: number, category: string } | null>(null);

    const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

    const openCreateModal = () => {
        setModalMode('create');
        setCurrentItem({ id: '', name: '', price: 0, stock: 0, category: 'Ozuqa' });
        setIsModalOpen(true);
    };

    const openEditModal = (item: any) => {
        setModalMode('edit');
        setCurrentItem({ ...item });
        setIsModalOpen(true);
    };

    const handleDelete = (id: string) => {
        setItems((prev) => prev.filter(i => i.id !== id));
        setDeleteConfirmId(null);
    };

    const handleSave = () => {
        if (!currentItem) return;
        if (modalMode === 'create') {
            const newItem = { ...currentItem, id: Date.now().toString() };
            setItems([newItem, ...items]);
        } else {
            setItems(items.map((i) => (i.id === currentItem.id ? currentItem : i)));
        }
        setIsModalOpen(false);
        // Toast can be added here
    };

    return (
        <div style={{ animation: 'fadeIn 0.5s ease' }}>
            <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px', gap: '16px', flexWrap: 'wrap' }}>
                <div>
                    <h1 style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <PackageSearch color="var(--primary)" /> Do'kon (Official Shop)
                    </h1>
                    <p style={{ color: 'var(--text-muted)' }}>Mijozlarga rasmiy ozuqa va anjomlar sotish uchun ombor.</p>
                </div>
                <button className="btn btn-primary" onClick={openCreateModal}>
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
                                        <button className="btn btn-outline" style={{ padding: '6px' }} title="Tahrirlash" onClick={() => openEditModal(item)}>
                                            <Edit size={16} />
                                        </button>
                                        <button className="btn btn-danger" style={{ padding: '6px' }} title="O'chirish" onClick={() => setDeleteConfirmId(item.id)}>
                                            <Trash2 size={16} />
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {/* Modal for Create/Edit */}
            {isModalOpen && currentItem && (
                <div className="modal-overlay">
                    <div className="modal-content">
                        <button className="modal-close" onClick={() => setIsModalOpen(false)}><X size={24} /></button>
                        <h2 style={{ marginBottom: '24px' }}>{modalMode === 'create' ? "Yangi Maxsulot Qo'shish" : "Maxsulotni Tahrirlash"}</h2>

                        <div style={{ marginBottom: '16px' }}>
                            <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Maxsulot nomi</label>
                            <input
                                type="text"
                                value={currentItem.name}
                                onChange={(e) => setCurrentItem({ ...currentItem, name: e.target.value })}
                                style={inputStyle}
                            />
                        </div>

                        <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
                            <div style={{ flex: 1 }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Narxi (UZS)</label>
                                <input
                                    type="number"
                                    value={currentItem.price === 0 ? '' : currentItem.price}
                                    onChange={(e) => setCurrentItem({ ...currentItem, price: Number(e.target.value) })}
                                    style={inputStyle}
                                />
                            </div>
                            <div style={{ flex: 1 }}>
                                <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Omborda (dona)</label>
                                <input
                                    type="number"
                                    value={currentItem.stock === 0 ? '' : currentItem.stock}
                                    onChange={(e) => setCurrentItem({ ...currentItem, stock: Number(e.target.value) })}
                                    style={inputStyle}
                                />
                            </div>
                        </div>

                        <div style={{ marginBottom: '24px' }}>
                            <label style={{ display: 'block', color: 'var(--text-muted)', marginBottom: '8px' }}>Turkum</label>
                            <select
                                value={currentItem.category}
                                onChange={(e) => setCurrentItem({ ...currentItem, category: e.target.value })}
                                style={inputStyle}
                            >
                                <option value="Ozuqa">Ozuqa / Yem</option>
                                <option value="Tibbiyot">Tibbiyot / Dori</option>
                                <option value="Inventar">Inventar / Qafas</option>
                            </select>
                        </div>

                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                            <button className="btn btn-outline" style={{ color: 'var(--text-muted)', borderColor: 'var(--border-glass)' }} onClick={() => setIsModalOpen(false)}>Bekor qilish</button>
                            <button className="btn btn-primary" onClick={handleSave}>Saqlash</button>
                        </div>
                    </div>
                </div>
            )}

            {/* Modal for Delete Confirmation */}
            {deleteConfirmId && (
                <div className="modal-overlay">
                    <div className="modal-content" style={{ maxWidth: '400px', textAlign: 'center' }}>
                        <AlertCircle size={60} color="var(--danger)" style={{ margin: '0 auto 16px' }} />
                        <h2>Diqqat! O'chirish</h2>
                        <p style={{ color: 'var(--text-muted)', margin: '16px 0 24px' }}>Haqiqatan ham ushbu maxsulotni ombordan o'chirib tashlamoqchimisiz? Uni orqaga qaytarib bo'lmaydi.</p>

                        <div style={{ display: 'flex', justifyContent: 'center', gap: '16px' }}>
                            <button className="btn btn-outline" style={{ color: 'var(--text-muted)', borderColor: 'var(--border-glass)' }} onClick={() => setDeleteConfirmId(null)}>Bekor qilish</button>
                            <button className="btn btn-danger" onClick={() => handleDelete(deleteConfirmId)}>Ha, O'chirish</button>
                        </div>
                    </div>
                </div>
            )}
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
