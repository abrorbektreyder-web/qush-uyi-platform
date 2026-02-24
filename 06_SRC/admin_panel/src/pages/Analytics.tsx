import React from 'react';
import {
    AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
    XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid
} from 'recharts';
import {
    Bird, Shield, Clock, Eye, Package, TrendingUp,
    DollarSign, ShoppingBag, CheckCircle2, X
} from 'lucide-react';

const volumeData = [
    { name: '18 Fev', escrow: 4200, shop: 2400 },
    { name: '19 Fev', escrow: 3800, shop: 3100 },
    { name: '20 Fev', escrow: 6500, shop: 4200 },
    { name: '21 Fev', escrow: 5100, shop: 3908 },
    { name: '22 Fev', escrow: 9200, shop: 5800 },
    { name: '23 Fev', escrow: 12000, shop: 7200 },
    { name: '24 Fev', escrow: 9500, shop: 6400 },
];

const weeklyData = [
    { day: 'Du', value: 12 },
    { day: 'Se', value: 19 },
    { day: 'Cho', value: 15 },
    { day: 'Pa', value: 25 },
    { day: 'Ju', value: 22 },
    { day: 'Sha', value: 30 },
    { day: 'Ya', value: 18 },
];

const pieData = [
    { name: 'Kabutar', value: 42, color: '#00FF87' },
    { name: "To'ti", value: 23, color: '#FFB020' },
    { name: 'Bedana', value: 18, color: '#4FC3F7' },
    { name: 'Kanareyka', value: 10, color: '#CE93D8' },
    { name: 'Boshqa', value: 7, color: '#FF7043' },
];

const recentActivity = [
    { id: 1, type: 'escrow', user: 'Abror', bird: 'Sappa (Kabutar)', amount: 500000, time: '12 min oldin', status: 'completed' },
    { id: 2, type: 'verification', user: 'Sardor', bird: 'Tustovuq', amount: 0, time: '25 min oldin', status: 'pending' },
    { id: 3, type: 'shop', user: 'Jasur', bird: 'Ozuqa (5 kg)', amount: 85000, time: '1 soat oldin', status: 'completed' },
    { id: 4, type: 'escrow', user: 'Dilshod', bird: "To'ti (juft)", amount: 1200000, time: '2 soat oldin', status: 'processing' },
    { id: 5, type: 'listing', user: 'Nodir', bird: 'Bedana (10 ta)', amount: 300000, time: '3 soat oldin', status: 'completed' },
];

interface AnalyticsProps {
    onClose: () => void;
}

export const Analytics: React.FC<AnalyticsProps> = ({ onClose }) => {
    return (
        <div className="analytics-overlay" onClick={onClose}>
            <div className="analytics-panel" onClick={(e) => e.stopPropagation()}>
                {/* Header */}
                <div className="analytics-header">
                    <div>
                        <h2 className="analytics-title">Analitika</h2>
                        <p className="analytics-sub">Batafsil ko'rsatkichlar va statistika</p>
                    </div>
                    <button className="analytics-close" onClick={onClose} aria-label="Yopish">
                        <X size={20} />
                    </button>
                </div>

                {/* Content */}
                <div className="analytics-body">
                    {/* Volume Chart */}
                    <div className="analytics-section">
                        <h3 className="analytics-section-title">Moliyaviy Aylanma</h3>
                        <div className="analytics-chart-legend">
                            <span><i className="dot" style={{ background: '#00FF87' }} /> Escrow</span>
                            <span><i className="dot" style={{ background: '#4FC3F7' }} /> Do'kon</span>
                        </div>
                        <div style={{ height: 220 }}>
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={volumeData} margin={{ top: 8, right: 12, bottom: 0, left: -10 }}>
                                    <defs>
                                        <linearGradient id="agE" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stopColor="#00FF87" stopOpacity={0.25} />
                                            <stop offset="100%" stopColor="#00FF87" stopOpacity={0} />
                                        </linearGradient>
                                        <linearGradient id="agS" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stopColor="#4FC3F7" stopOpacity={0.15} />
                                            <stop offset="100%" stopColor="#4FC3F7" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                                    <XAxis dataKey="name" stroke="var(--text-muted)" tick={{ fontSize: 11 }} axisLine={false} />
                                    <YAxis stroke="var(--text-muted)" tick={{ fontSize: 11 }} axisLine={false} />
                                    <Tooltip contentStyle={{ background: 'rgba(15,17,30,0.95)', border: '1px solid rgba(0,255,135,0.15)', borderRadius: '10px', fontSize: '0.8rem' }} />
                                    <Area type="monotone" dataKey="escrow" stroke="#00FF87" strokeWidth={2} fill="url(#agE)" />
                                    <Area type="monotone" dataKey="shop" stroke="#4FC3F7" strokeWidth={1.5} fill="url(#agS)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    {/* Weekly + Pie Row */}
                    <div className="analytics-row">
                        <div className="analytics-section" style={{ flex: 1 }}>
                            <h3 className="analytics-section-title">Haftalik E'lonlar</h3>
                            <div style={{ height: 180 }}>
                                <ResponsiveContainer width="100%" height="100%">
                                    <BarChart data={weeklyData}>
                                        <XAxis dataKey="day" stroke="var(--text-muted)" tick={{ fontSize: 11 }} axisLine={false} />
                                        <YAxis stroke="var(--text-muted)" tick={{ fontSize: 11 }} axisLine={false} />
                                        <Tooltip contentStyle={{ background: 'rgba(15,17,30,0.95)', border: '1px solid rgba(0,255,135,0.15)', borderRadius: '10px', fontSize: '0.8rem' }} />
                                        <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                                            {weeklyData.map((_, i) => (
                                                <Cell key={i} fill={i === 5 ? '#00FF87' : 'rgba(0,255,135,0.15)'} />
                                            ))}
                                        </Bar>
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>
                        </div>

                        <div className="analytics-section" style={{ width: 240 }}>
                            <h3 className="analytics-section-title">Kategoriyalar</h3>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 8 }}>
                                <div style={{ width: 100, height: 100 }}>
                                    <ResponsiveContainer width="100%" height="100%">
                                        <PieChart>
                                            <Pie data={pieData} cx="50%" cy="50%" innerRadius={30} outerRadius={48} paddingAngle={3} dataKey="value">
                                                {pieData.map((e, i) => <Cell key={i} fill={e.color} />)}
                                            </Pie>
                                        </PieChart>
                                    </ResponsiveContainer>
                                </div>
                                <div className="pie-legend-sm">
                                    {pieData.map((e, i) => (
                                        <div key={i} className="pie-row">
                                            <i className="dot" style={{ background: e.color }} />
                                            <span className="pie-name">{e.name}</span>
                                            <span className="pie-val">{e.value}%</span>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Quick Stats */}
                    <div className="analytics-section">
                        <h3 className="analytics-section-title">Tezkor Ko'rsatkichlar</h3>
                        <div className="quick-grid">
                            <StatItem icon={<Bird size={16} />} label="Faol E'lonlar" value="156" color="#00FF87" />
                            <StatItem icon={<Shield size={16} />} label="Tekshirilgan" value="89" color="#4FC3F7" />
                            <StatItem icon={<Clock size={16} />} label="Kutilayotgan" value="12" color="#FFB020" />
                            <StatItem icon={<Eye size={16} />} label="Ko'rilgan" value="2.4K" color="#CE93D8" />
                            <StatItem icon={<Package size={16} />} label="Buyurtma" value="34" color="#FF7043" />
                            <StatItem icon={<TrendingUp size={16} />} label="Konversiya" value="4.2%" color="#00FF87" />
                        </div>
                    </div>

                    {/* Activity */}
                    <div className="analytics-section">
                        <h3 className="analytics-section-title">So'nggi Faoliyat</h3>
                        <div className="activity-compact">
                            {recentActivity.map((item) => (
                                <div key={item.id} className="act-row">
                                    <div className={`act-icon ${item.type}`}>
                                        {item.type === 'escrow' && <DollarSign size={14} />}
                                        {item.type === 'verification' && <CheckCircle2 size={14} />}
                                        {item.type === 'shop' && <ShoppingBag size={14} />}
                                        {item.type === 'listing' && <Bird size={14} />}
                                    </div>
                                    <div className="act-info">
                                        <span className="act-name">{item.user}</span>
                                        <span className="act-desc">{item.bird}</span>
                                    </div>
                                    <div className="act-right">
                                        {item.amount > 0 && (
                                            <span className="act-amt">
                                                {item.amount >= 1000000 ? `${(item.amount / 1000000).toFixed(1)}M` : `${(item.amount / 1000).toFixed(0)}K`}
                                            </span>
                                        )}
                                        <span className="act-time">{item.time}</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

const StatItem: React.FC<{ icon: React.ReactNode; label: string; value: string; color: string }> = ({ icon, label, value, color }) => (
    <div className="stat-chip">
        <div className="stat-chip-icon" style={{ background: `${color}12`, color }}>{icon}</div>
        <span className="stat-chip-val">{value}</span>
        <span className="stat-chip-label">{label}</span>
    </div>
);
