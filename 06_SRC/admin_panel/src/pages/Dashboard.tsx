import React, { useState, useEffect } from 'react';
import {
    AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
    XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid
} from 'recharts';
import {
    Wallet, Activity, ArrowUpRight, ArrowDownRight, TrendingUp,
    Users, ShoppingBag, Shield, Clock, Eye, Zap, Bird,
    DollarSign, Package, CheckCircle2
} from 'lucide-react';

const volumeData = [
    { name: '18 Fev', escrow: 4200, shop: 2400, total: 6600 },
    { name: '19 Fev', escrow: 3800, shop: 3100, total: 6900 },
    { name: '20 Fev', escrow: 6500, shop: 4200, total: 10700 },
    { name: '21 Fev', escrow: 5100, shop: 3908, total: 9008 },
    { name: '22 Fev', escrow: 9200, shop: 5800, total: 15000 },
    { name: '23 Fev', escrow: 12000, shop: 7200, total: 19200 },
    { name: '24 Fev', escrow: 9500, shop: 6400, total: 15900 },
];

const recentActivity = [
    { id: 1, type: 'escrow', user: 'Abror', bird: 'Sappa (Kabutar)', amount: 500000, time: '12 min oldin', status: 'completed' },
    { id: 2, type: 'verification', user: 'Sardor', bird: 'Tustovuq', amount: 0, time: '25 min oldin', status: 'pending' },
    { id: 3, type: 'shop', user: 'Jasur', bird: 'Ozuqa (5 kg)', amount: 85000, time: '1 soat oldin', status: 'completed' },
    { id: 4, type: 'escrow', user: 'Dilshod', bird: "To'ti (juft)", amount: 1200000, time: '2 soat oldin', status: 'processing' },
    { id: 5, type: 'listing', user: 'Nodir', bird: 'Bedana (10 ta)', amount: 300000, time: '3 soat oldin', status: 'completed' },
];

const pieData = [
    { name: 'Kabutar', value: 42, color: '#00FF87' },
    { name: "To'ti", value: 23, color: '#FFB020' },
    { name: 'Bedana', value: 18, color: '#4FC3F7' },
    { name: 'Kanareyka', value: 10, color: '#CE93D8' },
    { name: 'Boshqa', value: 7, color: '#FF7043' },
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

export const Dashboard: React.FC = () => {
    const [currentTime, setCurrentTime] = useState(new Date());
    const [animatedValues, setAnimatedValues] = useState({
        escrow: 0, deals: 0, shop: 0, users: 0
    });

    useEffect(() => {
        const timer = setInterval(() => setCurrentTime(new Date()), 1000);
        return () => clearInterval(timer);
    }, []);

    // Animate numbers on mount
    useEffect(() => {
        const duration = 1500;
        const start = Date.now();
        const targets = { escrow: 14500000, deals: 68, shop: 2100000, users: 342 };

        const animate = () => {
            const elapsed = Date.now() - start;
            const progress = Math.min(elapsed / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3); // easeOutCubic

            setAnimatedValues({
                escrow: Math.round(targets.escrow * eased),
                deals: Math.round(targets.deals * eased),
                shop: Math.round(targets.shop * eased),
                users: Math.round(targets.users * eased),
            });

            if (progress < 1) requestAnimationFrame(animate);
        };
        requestAnimationFrame(animate);
    }, []);

    const formatUZS = (n: number) => {
        if (n >= 1000000) return `${(n / 1000000).toFixed(1)}M`;
        if (n >= 1000) return `${(n / 1000).toFixed(0)}K`;
        return n.toString();
    };

    return (
        <div className="premium-dashboard">
            {/* ─── HEADER ─── */}
            <header className="dash-header">
                <div>
                    <h1 className="dash-title">
                        <Zap size={28} style={{ color: 'var(--primary)' }} />
                        Dashboard
                    </h1>
                    <p className="dash-subtitle">
                        Real-vaqt analitika • {currentTime.toLocaleDateString('uz-UZ', {
                            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
                        })} • {currentTime.toLocaleTimeString('uz-UZ')}
                    </p>
                </div>
                <div className="dash-header-actions">
                    <div className="live-indicator">
                        <span className="live-dot" />
                        LIVE
                    </div>
                </div>
            </header>

            {/* ─── KPI BENTO GRID ─── */}
            <div className="kpi-grid">
                <KpiCard
                    icon={<Wallet size={24} />}
                    label="Muzlatilgan Pullar"
                    value={`${formatUZS(animatedValues.escrow)} UZS`}
                    change="+12%"
                    trend="up"
                    color="#00FF87"
                    detail="Escrow hisobi"
                />
                <KpiCard
                    icon={<Activity size={24} />}
                    label="Bugungi Bitimlar"
                    value={`${animatedValues.deals} ta`}
                    change="-2%"
                    trend="down"
                    color="#FFB020"
                    detail="Sotuvlar + Escrow"
                />
                <KpiCard
                    icon={<ShoppingBag size={24} />}
                    label="Do'kon Kirimi"
                    value={`${formatUZS(animatedValues.shop)} UZS`}
                    change="+8%"
                    trend="up"
                    color="#4FC3F7"
                    detail="Ozuqa + Aksessuarlar"
                />
                <KpiCard
                    icon={<Users size={24} />}
                    label="Aktiv Foydalanuvchilar"
                    value={`${animatedValues.users}`}
                    change="+5%"
                    trend="up"
                    color="#CE93D8"
                    detail="Bugun faol"
                />
            </div>

            {/* ─── CHARTS ROW ─── */}
            <div className="charts-grid">
                {/* Main Volume Chart */}
                <div className="glass-panel chart-main">
                    <div className="chart-header">
                        <div>
                            <h3>📊 Aylanma Tarixi</h3>
                            <p className="chart-subtitle">So'nggi 7 kun uchun moliyaviy ko'rsatkichlar</p>
                        </div>
                        <div className="chart-legend">
                            <span className="legend-item"><span className="legend-dot" style={{ background: '#00FF87' }} /> Escrow</span>
                            <span className="legend-item"><span className="legend-dot" style={{ background: '#4FC3F7' }} /> Do'kon</span>
                        </div>
                    </div>
                    <div style={{ height: 300 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={volumeData} margin={{ top: 10, right: 20, bottom: 0, left: 0 }}>
                                <defs>
                                    <linearGradient id="gradEscrow" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#00FF87" stopOpacity={0.3} />
                                        <stop offset="100%" stopColor="#00FF87" stopOpacity={0} />
                                    </linearGradient>
                                    <linearGradient id="gradShop" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#4FC3F7" stopOpacity={0.2} />
                                        <stop offset="100%" stopColor="#4FC3F7" stopOpacity={0} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                                <XAxis dataKey="name" stroke="var(--text-muted)" tick={{ fontSize: 12 }} />
                                <YAxis stroke="var(--text-muted)" tick={{ fontSize: 12 }} />
                                <Tooltip
                                    contentStyle={{
                                        backgroundColor: 'rgba(21, 24, 40, 0.95)',
                                        border: '1px solid rgba(0,255,135,0.2)',
                                        borderRadius: '12px',
                                        backdropFilter: 'blur(10px)',
                                    }}
                                    labelStyle={{ color: '#fff', fontWeight: 600 }}
                                />
                                <Area type="monotone" dataKey="escrow" stroke="#00FF87" strokeWidth={2.5} fill="url(#gradEscrow)" />
                                <Area type="monotone" dataKey="shop" stroke="#4FC3F7" strokeWidth={2} fill="url(#gradShop)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Weekly Bar Chart */}
                <div className="glass-panel chart-side">
                    <h3>📅 Haftalik E'lonlar</h3>
                    <p className="chart-subtitle">Kunlar bo'yicha yangi e'lonlar</p>
                    <div style={{ height: 220, marginTop: 16 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={weeklyData}>
                                <XAxis dataKey="day" stroke="var(--text-muted)" tick={{ fontSize: 12 }} />
                                <YAxis stroke="var(--text-muted)" tick={{ fontSize: 12 }} />
                                <Tooltip
                                    contentStyle={{
                                        backgroundColor: 'rgba(21, 24, 40, 0.95)',
                                        border: '1px solid rgba(0,255,135,0.2)',
                                        borderRadius: '12px',
                                    }}
                                />
                                <Bar dataKey="value" radius={[6, 6, 0, 0]}>
                                    {weeklyData.map((_, index) => (
                                        <Cell
                                            key={index}
                                            fill={index === weeklyData.length - 2 ? '#00FF87' : 'rgba(0,255,135,0.2)'}
                                        />
                                    ))}
                                </Bar>
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>

            {/* ─── BOTTOM ROW ─── */}
            <div className="bottom-grid">
                {/* Category Pie Chart */}
                <div className="glass-panel">
                    <h3>🐦 Kategoriya Taqsimoti</h3>
                    <p className="chart-subtitle">Faol e'lonlar turlar bo'yicha</p>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginTop: 16 }}>
                        <div style={{ width: 140, height: 140 }}>
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={pieData}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={40}
                                        outerRadius={65}
                                        paddingAngle={3}
                                        dataKey="value"
                                    >
                                        {pieData.map((entry, i) => (
                                            <Cell key={i} fill={entry.color} />
                                        ))}
                                    </Pie>
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                        <div className="pie-legend">
                            {pieData.map((entry, i) => (
                                <div key={i} className="pie-legend-item">
                                    <span className="pie-dot" style={{ background: entry.color }} />
                                    <span className="pie-label">{entry.name}</span>
                                    <span className="pie-value">{entry.value}%</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Quick Stats */}
                <div className="glass-panel">
                    <h3>⚡ Tezkor Ko'rsatkichlar</h3>
                    <p className="chart-subtitle">Bugungi holat</p>
                    <div className="quick-stats">
                        <QuickStatItem icon={<Bird size={18} />} label="Faol E'lonlar" value="156" color="#00FF87" />
                        <QuickStatItem icon={<Shield size={18} />} label="Tekshirilgan" value="89" color="#4FC3F7" />
                        <QuickStatItem icon={<Clock size={18} />} label="Kutilayotgan" value="12" color="#FFB020" />
                        <QuickStatItem icon={<Eye size={18} />} label="Bugun Ko'rilgan" value="2.4K" color="#CE93D8" />
                        <QuickStatItem icon={<Package size={18} />} label="Do'kon Buyurtma" value="34" color="#FF7043" />
                        <QuickStatItem icon={<TrendingUp size={18} />} label="Konversiya" value="4.2%" color="#00FF87" />
                    </div>
                </div>

                {/* Recent Activity */}
                <div className="glass-panel activity-panel">
                    <h3>🕐 So'nggi Faoliyat</h3>
                    <p className="chart-subtitle">Real-vaqt tranzaksiyalar</p>
                    <div className="activity-list">
                        {recentActivity.map((item) => (
                            <div key={item.id} className="activity-item">
                                <div className={`activity-icon ${item.type}`}>
                                    {item.type === 'escrow' && <DollarSign size={16} />}
                                    {item.type === 'verification' && <CheckCircle2 size={16} />}
                                    {item.type === 'shop' && <ShoppingBag size={16} />}
                                    {item.type === 'listing' && <Bird size={16} />}
                                </div>
                                <div className="activity-info">
                                    <span className="activity-name">{item.user}</span>
                                    <span className="activity-desc">{item.bird}</span>
                                </div>
                                <div className="activity-meta">
                                    {item.amount > 0 && (
                                        <span className="activity-amount">
                                            {item.amount >= 1000000
                                                ? `${(item.amount / 1000000).toFixed(1)}M`
                                                : `${(item.amount / 1000).toFixed(0)}K`} UZS
                                        </span>
                                    )}
                                    <span className="activity-time">{item.time}</span>
                                    <span className={`status-badge ${item.status}`}>
                                        {item.status === 'completed' ? '✓' : item.status === 'pending' ? '⏳' : '⟳'}
                                    </span>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

// ── KPI Card Component ──
const KpiCard: React.FC<{
    icon: React.ReactNode;
    label: string;
    value: string;
    change: string;
    trend: 'up' | 'down';
    color: string;
    detail: string;
}> = ({ icon, label, value, change, trend, color, detail }) => (
    <div className="kpi-card glass-panel">
        <div className="kpi-icon" style={{ background: `${color}15`, color }}>
            {icon}
        </div>
        <div className="kpi-content">
            <p className="kpi-label">{label}</p>
            <h2 className="kpi-value" style={{ color }}>{value}</h2>
            <div className="kpi-footer">
                <span className={`kpi-change ${trend}`} style={{ color: trend === 'up' ? '#00FF87' : '#FF4949' }}>
                    {trend === 'up' ? <ArrowUpRight size={14} /> : <ArrowDownRight size={14} />}
                    {change}
                </span>
                <span className="kpi-detail">{detail}</span>
            </div>
        </div>
    </div>
);

// ── Quick Stat Item ──
const QuickStatItem: React.FC<{
    icon: React.ReactNode;
    label: string;
    value: string;
    color: string;
}> = ({ icon, label, value, color }) => (
    <div className="quick-stat-item">
        <div className="quick-stat-icon" style={{ background: `${color}15`, color }}>
            {icon}
        </div>
        <div>
            <span className="quick-stat-value">{value}</span>
            <span className="quick-stat-label">{label}</span>
        </div>
    </div>
);
