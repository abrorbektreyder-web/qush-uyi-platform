import React, { useState, useEffect } from 'react';
import {
    AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid
} from 'recharts';
import {
    Wallet, Activity, ShoppingBag, Users, ArrowUpRight, ArrowDownRight
} from 'lucide-react';

const volumeData = [
    { name: '18', escrow: 4200, shop: 2400 },
    { name: '19', escrow: 3800, shop: 3100 },
    { name: '20', escrow: 6500, shop: 4200 },
    { name: '21', escrow: 5100, shop: 3908 },
    { name: '22', escrow: 9200, shop: 5800 },
    { name: '23', escrow: 12000, shop: 7200 },
    { name: '24', escrow: 9500, shop: 6400 },
];

export const Dashboard: React.FC = () => {
    const [time, setTime] = useState(new Date());
    const [vals, setVals] = useState({ e: 0, d: 0, s: 0, u: 0 });

    useEffect(() => {
        const t = setInterval(() => setTime(new Date()), 1000);
        return () => clearInterval(t);
    }, []);

    useEffect(() => {
        const dur = 1200, start = Date.now();
        const tgt = { e: 14500000, d: 68, s: 2100000, u: 342 };
        const tick = () => {
            const p = Math.min((Date.now() - start) / dur, 1);
            const ease = 1 - Math.pow(1 - p, 3);
            setVals({ e: Math.round(tgt.e * ease), d: Math.round(tgt.d * ease), s: Math.round(tgt.s * ease), u: Math.round(tgt.u * ease) });
            if (p < 1) requestAnimationFrame(tick);
        };
        requestAnimationFrame(tick);
    }, []);

    const fmt = (n: number) => n >= 1e6 ? `${(n / 1e6).toFixed(1)}M` : n >= 1e3 ? `${(n / 1e3).toFixed(0)}K` : `${n}`;

    return (
        <div className="dash">
            {/* Header */}
            <div className="dash-hd">
                <div>
                    <h1 className="dash-h1">Dashboard</h1>
                    <p className="dash-sub">
                        {time.toLocaleDateString('uz-UZ', { month: 'long', day: 'numeric' })} &middot; {time.toLocaleTimeString('uz-UZ', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                    </p>
                </div>
                <div className="dash-badge"><span className="pulse-dot" /> Real-time</div>
            </div>

            {/* KPI Grid */}
            <div className="kpi-grid">
                <KpiCard
                    icon={<Wallet size={22} />}
                    title="Muzlatilgan Pullar"
                    value={`${fmt(vals.e)} UZS`}
                    change={12} up
                    accent="#00FF87"
                    sub="Escrow hisobi"
                />
                <KpiCard
                    icon={<Activity size={22} />}
                    title="Bugungi Bitimlar"
                    value={`${vals.d} ta`}
                    change={-2}
                    accent="#FFB020"
                    sub="Sotuvlar + Escrow"
                />
                <KpiCard
                    icon={<ShoppingBag size={22} />}
                    title="Do'kon Kirimi"
                    value={`${fmt(vals.s)} UZS`}
                    change={8} up
                    accent="#4FC3F7"
                    sub="Ozuqa & Aksessuarlar"
                />
                <KpiCard
                    icon={<Users size={22} />}
                    title="Foydalanuvchilar"
                    value={`${vals.u}`}
                    change={5} up
                    accent="#CE93D8"
                    sub="Bugun faol"
                />
            </div>

            {/* Chart */}
            <div className="dash-chart-card">
                <div className="dash-chart-hd">
                    <h3>Moliyaviy Aylanma</h3>
                    <div className="dash-chart-legend">
                        <span><i style={{ background: '#00FF87' }} /> Escrow</span>
                        <span><i style={{ background: '#4FC3F7' }} /> Do'kon</span>
                    </div>
                </div>
                <div className="dash-chart-area">
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={volumeData} margin={{ top: 8, right: 16, bottom: 0, left: -16 }}>
                            <defs>
                                <linearGradient id="gE" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="0%" stopColor="#00FF87" stopOpacity={0.2} />
                                    <stop offset="100%" stopColor="#00FF87" stopOpacity={0} />
                                </linearGradient>
                                <linearGradient id="gS" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="0%" stopColor="#4FC3F7" stopOpacity={0.12} />
                                    <stop offset="100%" stopColor="#4FC3F7" stopOpacity={0} />
                                </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                            <XAxis dataKey="name" stroke="#4a5065" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                            <YAxis stroke="#4a5065" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                            <Tooltip
                                contentStyle={{ background: '#111529', border: '1px solid rgba(0,255,135,0.12)', borderRadius: '12px', fontSize: '0.82rem' }}
                                labelStyle={{ color: '#fff', fontWeight: 600 }}
                            />
                            <Area type="monotone" dataKey="escrow" stroke="#00FF87" strokeWidth={2.5} fill="url(#gE)" dot={false} />
                            <Area type="monotone" dataKey="shop" stroke="#4FC3F7" strokeWidth={1.5} fill="url(#gS)" dot={false} />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};

/* ─── KPI CARD ─── */
const KpiCard: React.FC<{
    icon: React.ReactNode;
    title: string;
    value: string;
    change: number;
    up?: boolean;
    accent: string;
    sub: string;
}> = ({ icon, title, value, change, accent, sub }) => {
    const isUp = change > 0;
    return (
        <div className="kpi">
            <div className="kpi-row-top">
                <div className="kpi-ico" style={{ background: `${accent}10`, color: accent }}>{icon}</div>
                <span className={`kpi-ch ${isUp ? 'up' : 'down'}`}>
                    {isUp ? <ArrowUpRight size={13} /> : <ArrowDownRight size={13} />}
                    {Math.abs(change)}%
                </span>
            </div>
            <h2 className="kpi-val">{value}</h2>
            <p className="kpi-title">{title}</p>
            <span className="kpi-sub">{sub}</span>
        </div>
    );
};
