import React, { useState, useEffect } from 'react';
import {
    AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid
} from 'recharts';
import {
    Wallet, Activity, ShoppingBag, Users, Zap, ArrowUpRight, ArrowDownRight
} from 'lucide-react';

const sparkData = [
    { v: 3200 }, { v: 4100 }, { v: 3800 }, { v: 5200 }, { v: 6800 }, { v: 9200 }, { v: 7400 },
];

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
        const dur = 1200;
        const start = Date.now();
        const target = { e: 14500000, d: 68, s: 2100000, u: 342 };
        const tick = () => {
            const p = Math.min((Date.now() - start) / dur, 1);
            const ease = 1 - Math.pow(1 - p, 3);
            setVals({
                e: Math.round(target.e * ease),
                d: Math.round(target.d * ease),
                s: Math.round(target.s * ease),
                u: Math.round(target.u * ease),
            });
            if (p < 1) requestAnimationFrame(tick);
        };
        requestAnimationFrame(tick);
    }, []);

    const fmt = (n: number) => {
        if (n >= 1000000) return `${(n / 1000000).toFixed(1)}M`;
        if (n >= 1000) return `${(n / 1000).toFixed(0)}K`;
        return n.toString();
    };

    return (
        <div className="dash-compact">
            {/* ─── TOP BAR ─── */}
            <div className="dash-top">
                <div className="dash-top-left">
                    <h1 className="dash-heading">Dashboard</h1>
                    <span className="dash-time">
                        {time.toLocaleDateString('uz-UZ', { month: 'short', day: 'numeric' })} &middot; {time.toLocaleTimeString('uz-UZ', { hour: '2-digit', minute: '2-digit' })}
                    </span>
                </div>
                <div className="dash-live">
                    <span className="dash-live-dot" />
                    LIVE
                </div>
            </div>

            {/* ─── KPI ROW ─── */}
            <div className="kpi-row">
                <div className="kpi-card glass-panel" style={{ '--accent': '#00FF87' } as React.CSSProperties}>
                    <div className="kpi-top">
                        <div className="kpi-icon-wrap" style={{ background: 'rgba(0,255,135,0.08)' }}>
                            <Wallet size={20} color="#00FF87" />
                        </div>
                        <span className="kpi-badge up"><ArrowUpRight size={12} /> 12%</span>
                    </div>
                    <h2 className="kpi-num">{fmt(vals.e)}</h2>
                    <span className="kpi-label">Escrow (UZS)</span>
                </div>

                <div className="kpi-card glass-panel" style={{ '--accent': '#FFB020' } as React.CSSProperties}>
                    <div className="kpi-top">
                        <div className="kpi-icon-wrap" style={{ background: 'rgba(255,176,32,0.08)' }}>
                            <Activity size={20} color="#FFB020" />
                        </div>
                        <span className="kpi-badge down"><ArrowDownRight size={12} /> 2%</span>
                    </div>
                    <h2 className="kpi-num">{vals.d} ta</h2>
                    <span className="kpi-label">Bitimlar</span>
                </div>

                <div className="kpi-card glass-panel" style={{ '--accent': '#4FC3F7' } as React.CSSProperties}>
                    <div className="kpi-top">
                        <div className="kpi-icon-wrap" style={{ background: 'rgba(79,195,247,0.08)' }}>
                            <ShoppingBag size={20} color="#4FC3F7" />
                        </div>
                        <span className="kpi-badge up"><ArrowUpRight size={12} /> 8%</span>
                    </div>
                    <h2 className="kpi-num">{fmt(vals.s)}</h2>
                    <span className="kpi-label">Do'kon (UZS)</span>
                </div>

                <div className="kpi-card glass-panel" style={{ '--accent': '#CE93D8' } as React.CSSProperties}>
                    <div className="kpi-top">
                        <div className="kpi-icon-wrap" style={{ background: 'rgba(206,147,216,0.08)' }}>
                            <Users size={20} color="#CE93D8" />
                        </div>
                        <span className="kpi-badge up"><ArrowUpRight size={12} /> 5%</span>
                    </div>
                    <h2 className="kpi-num">{vals.u}</h2>
                    <span className="kpi-label">Foydalanuvchilar</span>
                </div>
            </div>

            {/* ─── CHART ─── */}
            <div className="dash-chart glass-panel">
                <div className="dash-chart-head">
                    <div>
                        <h3 className="dash-chart-title">Aylanma</h3>
                        <span className="dash-chart-sub">So'nggi 7 kun</span>
                    </div>
                    <div className="dash-chart-legend">
                        <span><i className="dot" style={{ background: '#00FF87' }} /> Escrow</span>
                        <span><i className="dot" style={{ background: '#4FC3F7' }} /> Do'kon</span>
                    </div>
                </div>
                <div className="dash-chart-body">
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={volumeData} margin={{ top: 8, right: 12, bottom: 0, left: -10 }}>
                            <defs>
                                <linearGradient id="gE" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="0%" stopColor="#00FF87" stopOpacity={0.25} />
                                    <stop offset="100%" stopColor="#00FF87" stopOpacity={0} />
                                </linearGradient>
                                <linearGradient id="gS" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="0%" stopColor="#4FC3F7" stopOpacity={0.15} />
                                    <stop offset="100%" stopColor="#4FC3F7" stopOpacity={0} />
                                </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                            <XAxis dataKey="name" stroke="var(--text-muted)" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                            <YAxis stroke="var(--text-muted)" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                            <Tooltip
                                contentStyle={{
                                    background: 'rgba(15,17,30,0.92)',
                                    border: '1px solid rgba(0,255,135,0.15)',
                                    borderRadius: '10px',
                                    backdropFilter: 'blur(12px)',
                                    fontSize: '0.8rem',
                                }}
                                labelStyle={{ color: '#fff', fontWeight: 600 }}
                            />
                            <Area type="monotone" dataKey="escrow" stroke="#00FF87" strokeWidth={2} fill="url(#gE)" />
                            <Area type="monotone" dataKey="shop" stroke="#4FC3F7" strokeWidth={1.5} fill="url(#gS)" />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};
