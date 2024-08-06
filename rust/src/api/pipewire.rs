use std::{
    collections::HashMap,
    sync::{
        atomic::{AtomicBool, Ordering},
        Mutex,
    },
};

use flutter_rust_bridge::frb;
use once_cell::sync::Lazy;
use pipewire::{context::Context, main_loop::MainLoop, spa::utils::dict::DictRef};

pub use pipewire::{permissions::PermissionFlags, types::ObjectType};

static PIPEWIRE_THREAD_RUNNING: AtomicBool = AtomicBool::new(false);
static PIPEWIRE_GLOBALS: Lazy<Mutex<HashMap<u32, GlobalObject>>> =
    Lazy::new(|| Mutex::new(HashMap::new()));

fn require_pipewire_thread() {
    if PIPEWIRE_THREAD_RUNNING.swap(true, Ordering::SeqCst) {
        return;
    }

    std::thread::spawn(|| {
        if let Err(e) = pipewire_thread() {
            eprintln!("PipeWire thread exited with error: {:#?}", e);
        }
        PIPEWIRE_THREAD_RUNNING.store(false, Ordering::SeqCst);
    });
}

fn pipewire_thread() -> anyhow::Result<()> {
    let mainloop = MainLoop::new(None)?;
    let context = Context::new(&mainloop)?;
    let core = context.connect(None)?;
    let registry = core.get_registry()?;

    println!("starting");

    let _listener = registry
        .add_listener_local()
        .global(|global| {
            PIPEWIRE_GLOBALS
                .lock()
                .unwrap()
                .insert(global.id, global.into());
        })
        .register();

    // Calling the `destroy_global` method on the registry will destroy the object with the specified id on the remote.
    // We don't have a specific object to destroy now, so this is commented out.
    // registry.destroy_global(313).into_result()?;

    mainloop.run();

    Ok(())
}

pub enum PipeWireMsg {
    Print,
}

pub fn pipewire_send_msg(msg: PipeWireMsg) {
    require_pipewire_thread();
}

#[frb(sync)]
pub fn pipewire_get_globals() -> Vec<GlobalObject> {
    require_pipewire_thread();
    PIPEWIRE_GLOBALS.lock().unwrap().values().cloned().collect()
}

#[derive(Debug, Clone)]
pub struct GlobalObject {
    pub id: u32,
    // pub permissions: PermissionFlags,
    pub kind: ObjectType,
    pub version: u32,
    pub props: HashMap<String, String>,
}

#[frb(mirror(ObjectType))]
pub enum ObjectType_ {
    Client,
    ClientEndpoint,
    ClientNode,
    ClientSession,
    Core,
    Device,
    Endpoint,
    EndpointLink,
    EndpointStream,
    Factory,
    Link,
    Metadata,
    Module,
    Node,
    Port,
    Profiler,
    Registry,
    Session,
    Other(String),
}

impl<P: AsRef<DictRef>> From<&pipewire::registry::GlobalObject<P>> for GlobalObject {
    fn from(global: &pipewire::registry::GlobalObject<P>) -> Self {
        Self {
            id: global.id,
            // permissions: global.permissions,
            kind: global.type_.clone(),
            version: global.version,
            props: global
                .props
                .as_ref()
                .unwrap()
                .as_ref()
                .iter()
                .map(|(k, v)| (k.to_string(), v.to_string()))
                .collect(),
        }
    }
}
