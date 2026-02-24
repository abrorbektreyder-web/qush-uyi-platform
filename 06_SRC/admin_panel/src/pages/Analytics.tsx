import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
    AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
    XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid
} from 'recharts';
import {
    Bird, Shield, Clock, Eye, Package, TrendingUp,
    DollarSign, ShoppingBag, CheckCircle2, ArrowLeft
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
    { day: 'Du', value: 12 }, { day: 'Se', value: 19 }, { day: 'Cho', value: 15 },
    { day: 'Pa', value: 25 }, { day: 'Ju', value: 22 }, { day: 'Sha', value: 30 }, { day: 'Ya', value: 18 },
];

const pieData = [
    { name: 'Kabutar', value: 42, color: '#00FF87' },
    { name: "To'ti", value: 23, color: '#FFB020' },
    { name: 'Bedana', value: 18, color: '#4FC3F7' },
    { name: 'Kanareyka', value: 10, color: '#CE93D8' },
    { name: 'Boshqa', value: 7, color: '#FF7043' },
];

const activity = [
    { id: 1, type: 'escrow', user: 'Abror', bird: 'Sappa (Kabutar)', amount: 500000, time: '12 min oldin', status: 'completed' },
    { id: 2, type: 'verification', user: 'Sardor', bird: 'Tustovuq', amount: 0, time: '25 min oldin', status: 'pending' },
    { id: 3, type: 'shop', user: 'Jasur', bird: 'Ozuqa (5 kg)', amount: 85000, time: '1 soat oldin', status: 'completed' },
    { id: 4, type: 'escrow', user: 'Dilshod', bird: "To'ti (juft)", amount: 1200000, time: '2 soat oldin', status: 'processing' },
    { id: 5, type: 'listing', user: 'Nodir', bird: 'Bedana (10 ta)', amount: 300000, time: '3 soat oldin', status: 'completed' },
];

export const Analytics: React.FC = () => {
    const navigate = useNavigate();

    return (
        <div className="an-page">
            {/* Header */}
            <div className="an-hd">
                <button className="an-back" onClick={() => navigate('/')} aria-label="Orqaga">
                    <ArrowLeft size={20} />
                </button>
                <div>
                    <h1 className="an-h1">Analitika</h1>
                    <p className="an-sub">Batafsil ko'rsatkichlar va statistika</p>
                </div>
            </div>

            {/* Row 1: Volume + Weekly */}
            <div className="an-row">
                <div className="an-card an-card-lg">
                    <div className="an-card-hd">
                        <h3>Moliyaviy Aylanma</h3>
                        <div className="an-legend">
                            <span><i style={{ background: '#00FF87' }} /> Escrow</span>
                            <span><i style={{ background: '#4FC3F7' }} /> Do'kon</span>
                        </div>
                    </div>
                    <div style={{ height: 240 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={volumeData} margin={{ top: 8, right: 12, bottom: 0, left: -10 }}>
                                <defs>
                                    <linearGradient id="ge" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#00FF87" stopOpacity={0.2} />
                                        <stop offset="100%" stopColor="#00FF87" stopOpacity={0} />
                                    </linearGradient>
                                    <linearGradient id="gs" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#4FC3F7" stopOpacity={0.12} />
                                        <stop offset="100%" stopColor="#4FC3F7" stopOpacity={0} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                                <XAxis dataKey="name" stroke="#4a5065" tick={{ fontSize: 11 }} axisLine={false} />
                                <YAxis stroke="#4a5065" tick={{ fontSize: 11 }} axisLine={false} />
                                <Tooltip contentStyle={{ background: '#111529', border: '1px solid rgba(0,255,135,0.12)', borderRadius: '12px', fontSize: '0.82rem' }} />
                                <Area type="monotone" dataKey="escrow" stroke="#00FF87" strokeWidth={2} fill="url(#ge)" dot={false} />
                                <Area type="monotone" dataKey="shop" stroke="#4FC3F7" strokeWidth={1.5} fill="url(#gs)" dot={false} />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                <div className="an-card">
                    <h3>Haftalik E'lonlar</h3>
                    <div style={{ height: 240 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={weeklyData}>
                                <XAxis dataKey="day" stroke="#4a5065" tick={{ fontSize: 11 }} axisLine={false} />
                                <YAxis stroke="#4a5065" tick={{ fontSize: 11 }} axisLine={false} />
                                <Tooltip contentStyle={{ background: '#111529', border: '1px solid rgba(0,255,135,0.12)', borderRadius: '12px', fontSize: '0.82rem' }} />
                                <Bar dataKey="value" radius={[6, 6, 0, 0]}>
                                    {weeklyData.map((_, i) => (
                                        <Cell key={i} fill={i === 5 ? '#00FF87' : 'rgba(0,255,135,0.12)'} />
                                    ))}
                                </Bar>
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>

            {/* Row 2: Categories + Stats + Activity */}
            <div className="an-row an-row-3">
                {/* Pie */}
                <div className="an-card">
                    <h3>Kategoriya Taqsimoti</h3>
                    <div className="an-pie-wrap">
                        <div style={{ width: 120, height: 120 }}>
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie data={pieData} cx="50%" cy="50%" innerRadius={36} outerRadius={56} paddingAngle={3} dataKey="value">
                                        {pieData.map((e, i) => <Cell key={i} fill={e.color} />)}
                                    </Pie>
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                        <div className="an-pie-leg">
                            {pieData.map((e, i) => (
                                <div key={i} className="an-pie-row">
                                    <i style={{ background: e.color }} />
                                    <span>{e.name}</span>
                                    <b>{e.value}%</b>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Quick Stats */}
                <div className="an-card">
                    <h3>Tezkor Ko'rsatkichlar</h3>
                    <div className="an-stats">
                        <Stat icon={<Bird size={16} />} label="Faol E'lonlar" val="156" c="#00FF87" />
                        <Stat icon={<Shield size={16} />} label="Tekshirilgan" val="89" c="#4FC3F7" />
                        <Stat icon={<Clock size={16} />} label="Kutilayotgan" val="12" c="#FFB020" />
                        <Stat icon={<Eye size={16} />} label="Ko'rilgan" val="2.4K" c="#CE93D8" />
                        <Stat icon={<Package size={16} />} label="Buyurtma" val="34" c="#FF7043" />
                        <Stat icon={<TrendingUp size={16} />} label="Konversiya" val="4.2%" c="#00FF87" />
                    </div>
                </div>

                {/* Activity */}
                <div className="an-card">
                    <h3>So'nggi Faoliyat</h3>
                    <div className="an-act-list">
                        {activity.map((a) => (
                            <div key={a.id} className="an-act">
                                <div className={`an-act-ico ${a.type}`}>
                                    {a.type === 'escrow' && <DollarSign size={14} />}
                                    {a.type === 'verification' && <CheckCircle2 size={14} />}
                                    {a.type === 'shop' && <ShoppingBag size={14} />}
                                    {a.type === 'listing' && <Bird size={14} />}
                                </div>
                                <div className="an-act-info">
                                    <b>{a.user}</b>
                                    <span>{a.bird}</span>
                                </div>
                                <div className="an-act-r">
                                    {a.amount > 0 && <b className="an-act-amt">{a.amount >= 1e6 ? `${(a.amount / 1e6).toFixed(1)}M` : `${(a.amount / 1e3).toFixed(0)}K`}</b>}
                                    <span>{a.time}</span>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

const Stat: React.FC<{ icon: React.ReactNode; label: string; val: string; c: string }> = ({ icon, label, val, c }) => (
    <div className="an-stat">
        <div className="an-stat-ico" style={{ background: `${c}10`, color: c }}>{icon}</div>
        <b>{val}</b>
        <span>{label}</span>
    </div>
);
