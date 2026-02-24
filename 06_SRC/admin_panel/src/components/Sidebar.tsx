import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Store, Settings, LogOut, Bird, ShieldCheck, BarChart3 } from 'lucide-react';

interface SidebarProps {
    onLogout: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ onLogout }) => {
    return (
        <aside className="sidebar">
            {/* Brand */}
            <div className="sb-brand">
                <div className="sb-logo">
                    <Bird size={22} color="#00FF87" />
                </div>
                <div>
                    <h2 className="sb-title"><span>QUSH</span> UYI</h2>
                    <p className="sb-ver">Admin Portal 3.0</p>
                </div>
            </div>

            {/* Nav Links */}
            <nav className="sb-nav">
                <SbLink to="/" icon={<LayoutDashboard size={20} />} label="Dashboard" />
                <SbLink to="/analytics" icon={<BarChart3 size={20} />} label="Analitika" />
                <SbLink to="/verifications" icon={<ShieldCheck size={20} />} label="Verifikatsiya" badge="3" />
                <SbLink to="/shop" icon={<Store size={20} />} label="Do'kon (Ombor)" />
                <SbLink to="/settings" icon={<Settings size={20} />} label="Sozlamalar" />
            </nav>

            {/* User + Logout */}
            <div className="sb-footer">
                <div className="sb-user">
                    <div className="sb-avatar">AD</div>
                    <div>
                        <b>Admin</b>
                        <span>Super Admin</span>
                    </div>
                </div>
                <button className="btn btn-danger sb-logout" onClick={onLogout}>
                    <LogOut size={18} /> Chiqish
                </button>
            </div>
        </aside>
    );
};

const SbLink: React.FC<{ to: string; icon: React.ReactNode; label: string; badge?: string }> = ({ to, icon, label, badge }) => (
    <NavLink to={to} end={to === '/'} className={({ isActive }) => `sb-link ${isActive ? 'active' : ''}`}>
        {icon}
        <span>{label}</span>
        {badge && <em className="sb-badge">{badge}</em>}
    </NavLink>
);
