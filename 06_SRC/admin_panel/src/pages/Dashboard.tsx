import React from 'react';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';
import { Wallet, Activity, ArrowUpRight, ArrowDownRight } from 'lucide-react';

const mockData = [
    { name: '10 Fev', uv: 4000, pv: 2400 },
    { name: '11 Fev', uv: 3000, pv: 1398 },
    { name: '12 Fev', uv: 5000, pv: 8000 },
    { name: '13 Fev', uv: 2780, pv: 3908 },
    { name: '14 Fev', uv: 8900, pv: 4800 },
    { name: '15 Fev', uv: 12000, pv: 8900 },
    { name: '16 Fev', uv: 9500, pv: 6000 },
];

export const Dashboard: React.FC = () => {
    return (
        <div style={{ animation: 'fadeIn 0.5s ease' }}>
            <header style={{ marginBottom: '32px' }}>
                <h1>Moliya & Analitika (Real-Time)</h1>
                <p style={{ color: 'var(--text-muted)' }}>Bugungi kun uchun umumiy platforma aylanmasi va status</p>
            </header>

            {/* KPI Cards */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '24px', marginBottom: '40px' }}>
                <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                    <div style={{ background: 'rgba(0, 255, 135, 0.1)', padding: '16px', borderRadius: '50%', color: 'var(--primary)' }}>
                        <Wallet size={32} />
                    </div>
                    <div>
                        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Muzlatilgan Pullar (Escrow)</p>
                        <h2 style={{ fontSize: '1.8rem' }}>14.5M UZS</h2>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--primary)', fontSize: '0.8rem', marginTop: '4px' }}>
                            <ArrowUpRight size={16} /> +12% o'sish
                        </div>
                    </div>
                </div>

                <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                    <div style={{ background: 'rgba(255, 176, 32, 0.1)', padding: '16px', borderRadius: '50%', color: 'var(--warning)' }}>
                        <Activity size={32} />
                    </div>
                    <div>
                        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Bugungi Bitimlar</p>
                        <h2 style={{ fontSize: '1.8rem' }}>68 ta</h2>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--warning)', fontSize: '0.8rem', marginTop: '4px' }}>
                            -2% pasayish
                        </div>
                    </div>
                </div>

                <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                    <div style={{ background: 'rgba(255, 255, 255, 0.1)', padding: '16px', borderRadius: '50%', color: '#FFF' }}>
                        <ArrowDownRight size={32} />
                    </div>
                    <div>
                        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Shop Kirim (Do'kon)</p>
                        <h2 style={{ fontSize: '1.8rem' }}>2.1M UZS</h2>
                    </div>
                </div>
            </div>

            {/* Charts */}
            <div className="glass-panel" style={{ height: '400px', display: 'flex', flexDirection: 'column' }}>
                <h3 style={{ marginBottom: '24px' }}>Aylanma Tarixi (Volume)</h3>
                <div style={{ flex: 1 }}>
                    <ResponsiveContainer width="100%" height="100%">
                        <LineChart data={mockData} margin={{ top: 5, right: 20, bottom: 5, left: 0 }}>
                            <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                            <XAxis dataKey="name" stroke="var(--text-muted)" />
                            <YAxis stroke="var(--text-muted)" />
                            <Tooltip
                                contentStyle={{ backgroundColor: 'var(--bg-surface)', border: '1px solid var(--border-glass)', borderRadius: '8px' }}
                                itemStyle={{ color: 'var(--primary)' }}
                            />
                            <Line type="monotone" dataKey="uv" stroke="var(--primary)" strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 8 }} />
                        </LineChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};
