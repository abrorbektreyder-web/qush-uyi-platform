import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Store, Settings, LogOut, Bird, ShieldCheck } from 'lucide-react';

interface SidebarProps {
    onLogout: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ onLogout }) => {
    return (
        <aside className="sidebar">
            {/* Brand */}
            <div style={{
                padding: '0 28px 24px 28px',
                borderBottom: '1px solid var(--border-glass)',
                marginBottom: '12px',
            }}>
                <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                }}>
                    <div style={{
                        width: 42,
                        height: 42,
                        borderRadius: '12px',
                        background: 'linear-gradient(135deg, rgba(0,255,135,0.2), rgba(0,255,135,0.05))',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        border: '1px solid rgba(0,255,135,0.15)',
                    }}>
                        <Bird size={22} color="#00FF87" />
                    </div>
                    <div>
                        <h2 style={{
                            color: 'var(--text-main)',
                            fontSize: '1.2rem',
                            fontWeight: 800,
                            letterSpacing: '-0.5px',
                            margin: 0,
                        }}>
                            <span style={{ color: 'var(--primary)' }}>QUSH</span> UYI
                        </h2>
                        <p style={{
                            color: 'var(--text-muted)',
                            fontSize: '0.68rem',
                            marginTop: '2px',
                            fontWeight: 500,
                            letterSpacing: '1px',
                            textTransform: 'uppercase',
                        }}>
                            Admin Portal 3.0
                        </p>
                    </div>
                </div>
            </div>

            {/* Nav Links */}
            <nav style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '2px', padding: '0 12px' }}>
                <SidebarLink to="/" icon={<LayoutDashboard size={20} />} label="Dashboard" />
                <SidebarLink to="/verifications" icon={<ShieldCheck size={20} />} label="Verifikatsiya" badge="3" />
                <SidebarLink to="/shop" icon={<Store size={20} />} label="Do'kon (Ombor)" />
                <SidebarLink to="/settings" icon={<Settings size={20} />} label="Sozlamalar" />
            </nav>

            {/* User + Logout */}
            <div style={{ padding: '16px 20px', borderTop: '1px solid var(--border-glass)' }}>
                <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    marginBottom: '16px',
                    padding: '12px',
                    borderRadius: '12px',
                    background: 'rgba(255,255,255,0.02)',
                }}>
                    <div style={{
                        width: 38,
                        height: 38,
                        borderRadius: '10px',
                        background: 'linear-gradient(135deg, #00FF87, #00C969)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: '#0B0D17',
                        fontWeight: 800,
                        fontSize: '0.85rem',
                    }}>
                        AD
                    </div>
                    <div>
                        <span style={{ display: 'block', fontWeight: 600, fontSize: '0.88rem' }}>Admin</span>
                        <span style={{ display: 'block', fontSize: '0.72rem', color: 'var(--text-muted)' }}>Super Admin</span>
                    </div>
                </div>
                <button
                    className="btn btn-danger"
                    style={{
                        width: '100%',
                        justifyContent: 'center',
                        borderRadius: '12px',
                        padding: '12px',
                        fontSize: '0.85rem',
                    }}
                    onClick={onLogout}
                >
                    <LogOut size={18} /> Chiqish
                </button>
            </div>
        </aside>
    );
};

// ─── Sidebar Link Component ───
const SidebarLink: React.FC<{
    to: string;
    icon: React.ReactNode;
    label: string;
    badge?: string;
}> = ({ to, icon, label, badge }) => (
    <NavLink
        to={to}
        end={to === '/'}
        className={({ isActive }) => `sidebar-link ${isActive ? 'active' : ''}`}
        style={{
            display: 'flex',
            alignItems: 'center',
            gap: '14px',
            padding: '13px 18px',
            textDecoration: 'none',
            color: 'var(--text-muted)',
            fontSize: '0.92rem',
            fontWeight: 500,
            borderRadius: '12px',
            transition: 'all 0.2s ease',
            position: 'relative',
        }}
    >
        {icon}
        <span style={{ flex: 1 }}>{label}</span>
        {badge && (
            <span style={{
                background: 'rgba(255, 176, 32, 0.15)',
                color: '#FFB020',
                padding: '2px 8px',
                borderRadius: '8px',
                fontSize: '0.72rem',
                fontWeight: 700,
            }}>
                {badge}
            </span>
        )}
    </NavLink>
);
